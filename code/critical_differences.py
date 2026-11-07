# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

"""Critical differences for list scores of a speech-recognition test.

Two methods:

1. Cox et al. (1987) / RAU. Percent-correct list scores are converted to
   rationalized arcsine units (Studebaker, 1985):
       T = arcsin(sqrt(X / (N + 1))) + arcsin(sqrt((X + 1) / (N + 1)))
       RAU = 1.46 * (31.83098861 * T - 50) + 50
   For each listener, the SD of their RAU list scores is taken; SD_95 is the
   95th percentile of these SDs. The critical difference for comparing the mean
   of n lists with the mean of n other lists is
       CD(n) = 2.7 * SD_95 / sqrt(n) * sqrt((N_lists - n) / (N_lists - 1))

2. Thornton & Raffin (1978) binomial model. For an assumed number of
   independent items N, the 95% range for a retest score around a first score
   is obtained on the arcsine scale (SD = sqrt(2 / (N + 1)) for N <= 50,
   sqrt(2 / (N + 0.5)) above) and transformed back to percent. N is chosen as
   the value for which the share of observed same-listener list pairs falling
   outside the range is closest to 5%.

Input: a CSV with one row per listener x list and the columns
    listener     listener ID (unique across conditions if several are pooled)
    list         list number
    score        percent keywords correct on that list (0-100)

Usage: python critical_differences.py list_scores.csv [--rau-n 40] [--lists 20]
Requires numpy, pandas, scipy.
"""

import argparse
from itertools import combinations

import numpy as np
import pandas as pd
from scipy.optimize import brentq


def arcsine_transform(score_pct, N):
    X = np.clip(score_pct / 100.0 * N, 0, N)
    return np.arcsin(np.sqrt(X / (N + 1))) + np.arcsin(np.sqrt((X + 1) / (N + 1)))


def arcsine_sd(N):
    if N >= 50:
        return np.sqrt(2 / (N + 0.5))
    if N > 10:
        return np.sqrt(2 / (N + 1))
    raise ValueError("N must be > 10")


def arcsine_to_percent(T, N):
    if T <= 0:
        return 0.0
    if T >= np.pi:
        return 100.0
    try:
        X = brentq(lambda x: arcsine_transform(x / N * 100, N) - T, 0, N)
        return X / N * 100
    except ValueError:
        return 0.0 if T < np.pi / 2 else 100.0


def rau(score_pct, N):
    return 1.46 * (31.83098861 * arcsine_transform(score_pct, N) - 50) + 50


def binomial_cd_table(N, scores=range(0, 101)):
    """Lower and upper 95% bounds for a retest score, for each first score."""
    sd = arcsine_sd(N)
    rows = []
    for s in scores:
        T = arcsine_transform(s, N)
        rows.append({"score": s,
                     "lower": arcsine_to_percent(T - 1.96 * sd, N),
                     "upper": arcsine_to_percent(T + 1.96 * sd, N)})
    return pd.DataFrame(rows)


def cox_rau_cd(list_scores, rau_n, n_lists, max_n=10):
    """SD_95 in RAU and CD(n) for n = 1..max_n lists."""
    d = list_scores.assign(rau=rau(list_scores["score"], rau_n))
    sd_per_listener = d.groupby("listener")["rau"].std()
    sd_95 = sd_per_listener.quantile(0.95)
    cd = {n: 2.7 * sd_95 / np.sqrt(n) * np.sqrt((n_lists - n) / (n_lists - 1))
          for n in range(1, max_n + 1)}
    return sd_95, cd


def list_pairs(list_scores):
    """All pairs of list scores from the same listener (x = first list, y = second)."""
    wide = list_scores.pivot_table(index="listener", columns="list", values="score")
    pairs = [wide[[a, b]].dropna().to_numpy() for a, b in combinations(wide.columns, 2)]
    return pd.DataFrame(np.vstack(pairs), columns=["x", "y"])


def share_outside(pairs, N):
    cd = binomial_cd_table(N).set_index("score")
    x = np.clip(np.round(pairs["x"]).astype(int), 0, 100)
    lo, hi = cd.loc[x, "lower"].to_numpy(), cd.loc[x, "upper"].to_numpy()
    return float(np.mean((pairs["y"].to_numpy() < lo) | (pairs["y"].to_numpy() > hi)) * 100)


def fit_binomial_n(list_scores, N_values=range(20, 110, 10)):
    pairs = list_pairs(list_scores)
    shares = {N: share_outside(pairs, N) for N in N_values}
    best = min(shares, key=lambda n: abs(shares[n] - 5))
    return best, shares


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("list_scores")
    ap.add_argument("--rau-n", type=int, default=40, help="N used in the RAU transform")
    ap.add_argument("--lists", type=int, default=20, help="number of lists per listener")
    a = ap.parse_args()

    scores = pd.read_csv(a.list_scores, dtype={"listener": str})
    sd_95, cd = cox_rau_cd(scores, a.rau_n, a.lists)
    print(f"Cox/RAU: SD_95 = {sd_95:.2f} RAU")
    for n in (1, 2, 5):
        print(f"  CD, {n} vs {n} list(s): {cd[n]:.1f} RAU")

    best, shares = fit_binomial_n(scores)
    print("Binomial model: % of same-listener list pairs outside the 95% range")
    for N, s in shares.items():
        print(f"  N = {N:3d}: {s:5.2f}%")
    print(f"  Best fit: N = {best}")
    table = binomial_cd_table(best, range(0, 101, 5))
    print(table.round(1).to_string(index=False))


if __name__ == "__main__":
    main()

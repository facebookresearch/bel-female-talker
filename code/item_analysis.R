# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

################################################################################
### Item statistics for speech-recognition sentences
################################################################################
# Computes, for each sentence and each condition, the item statistics used as
# anticlustering input to build the BELR lists:
#
#   Item_Difficulty      mean keywords correct / highest score observed on that
#                        sentence in that condition
#   Item_Discrimination  corrected item-total correlation: Pearson r between the
#                        sentence score and the listener's total over all other
#                        sentences; 0 when every listener gave the same score
#
# Both are classical test theory item statistics. Values are rounded to two
# decimals, as in the table the BELR lists were built from.
#
# Input: a CSV with one row per listener x sentence and the columns
#   condition    condition label (e.g. 1A)
#   listener     listener ID, unique within a condition
#   sentence_n   sentence ID (e.g. 309 = original list 3, sentence 9)
#   score        keywords repeated correctly (0-4 for BEL)
# Every listener in a condition must have a score for every sentence.
#
# Usage:  Rscript item_analysis.R scores.csv item_statistics_out.csv
# Packages: dplyr, tidyr
################################################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) stop("usage: Rscript item_analysis.R scores.csv item_statistics_out.csv")

scores <- read.csv(args[1], colClasses = c(condition = "character", listener = "character",
                                           sentence_n = "integer", score = "integer"))

item_statistics <- function(d) {
  wide <- d %>%
    select(listener, sentence_n, score) %>%
    pivot_wider(names_from = sentence_n, values_from = score)
  m <- as.matrix(select(wide, -listener))
  if (anyNA(m)) stop("missing scores in condition ", d$condition[1])
  m <- m[, order(as.integer(colnames(m))), drop = FALSE]
  total <- rowSums(m)
  discrimination <- sapply(seq_len(ncol(m)), function(k) {
    if (sd(m[, k]) == 0) return(0)
    cor(m[, k], total - m[, k])
  })
  highest <- apply(m, 2, max)
  data.frame(sentence_n = as.integer(colnames(m)),
             Item_Difficulty = round(ifelse(highest == 0, 0, colMeans(m) / highest), 2),
             Item_Discrimination = round(discrimination, 2))
}

out <- bind_rows(lapply(split(scores, scores$condition), function(d) {
  item_statistics(d) %>% mutate(condition = d$condition[1])
})) %>%
  pivot_wider(names_from = condition,
              values_from = c(Item_Difficulty, Item_Discrimination),
              names_glue = "{.value}_{condition}") %>%
  arrange(sentence_n)

write.csv(out, args[2], row.names = FALSE)
cat("Wrote", args[2], ":", nrow(out), "sentences,", length(unique(scores$condition)), "conditions\n")

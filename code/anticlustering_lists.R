# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

################################################################################
### Partition sentences into equivalent lists with anticlustering
################################################################################
# Builds the BELR lists: the 500 BEL sentences are split into 20 lists of 25 so
# that the lists are as similar as possible on
#   - item difficulty and discrimination in each of the four conditions
#     (1A female average VE, 2A male average VE, 2B female high VE, 2C male high VE)
#   - syllable count, fricative/affricate count, and mean keyword lexical
#     occurrence rate
# using k-plus anticlustering (Papenberg & Klau, 2021; R package anticlust).
#
# Within a list, sentences are numbered in ascending order of their original
# BEL number. Run on item_statistics_BEL.csv, this reproduces the published
# BELR assignment (tested with R 4.5.1 and anticlust 0.8.18).
#
# Usage:  Rscript anticlustering_lists.R item_statistics_BEL.csv lists_out.csv [BELR_list_assignments.csv]
# The optional third argument is compared with the result.
# Packages: anticlust
################################################################################

suppressPackageStartupMessages(library(anticlust))

args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% c(2, 3)) {
  stop("usage: Rscript anticlustering_lists.R item_statistics.csv lists_out.csv [reference.csv]")
}

N_LISTS <- 20
CONDITIONS <- c("1A", "2A", "2B", "2C")
FEATURES <- c(as.vector(sapply(CONDITIONS, function(p) paste0(c("Item_Difficulty_", "Item_Discrimination_"), p))),
              "syllables", "fricative_affricate_count", "rate_kw_occurence_in_lex_mean")

items <- read.csv(args[1])
items <- items[order(items$sentence_n), ]
missing <- setdiff(FEATURES, names(items))
if (length(missing) > 0) stop("missing columns: ", paste(missing, collapse = ", "))

set.seed(123)
lists <- anticlustering(items[, FEATURES],
                        K = N_LISTS,
                        objective = "kplus",
                        method = "local-maximum",
                        standardize = TRUE,
                        repetitions = 10)

out <- data.frame(original_BEL_list = items$sentence_n %/% 100,
                  original_BEL_item = items$sentence_n %% 100,
                  new_list = lists)
out <- out[order(out$new_list, out$original_BEL_list, out$original_BEL_item), ]
out$new_item <- ave(out$new_list, out$new_list, FUN = seq_along)
out <- out[, c("new_list", "new_item", "original_BEL_list", "original_BEL_item")]
write.csv(out, args[2], row.names = FALSE)
cat("Wrote", args[2], "\n")

# Feature means per list, to inspect the balance
means <- aggregate(items[, FEATURES], by = list(list = lists), FUN = mean)
print(round(sapply(means[, -1], range), 3))

if (length(args) == 3) {
  ref <- read.csv(args[3])
  m <- merge(out, ref, by = c("original_BEL_list", "original_BEL_item"))
  same <- sum(m$new_list == m$BELR_list & m$new_item == m$BELR_item)
  cat("Matches reference for", same, "of", nrow(m), "sentences\n")
}

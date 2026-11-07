Analysis code
=============

  item_analysis.R          item difficulty and discrimination per sentence and condition
  anticlustering_lists.R   partitions the sentences into equivalent lists (builds the BELR lists)
  critical_differences.py  critical differences for list scores (Cox/RAU and binomial model)
  item_statistics_BEL.csv  the item table the BELR lists were built from


item_statistics_BEL.csv
-----------------------

One row per BEL sentence.

  sentence_n                       original BEL list x 100 + sentence (309 = list 3, sentence 9)
  syllables                        number of syllables
  fricative_affricate_count        number of fricatives and affricates
  rate_kw_occurence_in_lex_mean    mean rate of occurrence of the keywords in the BEL lexicon
  Item_Difficulty_<cond>           mean keywords correct / highest score observed on the sentence
  Item_Discrimination_<cond>       corrected item-total correlation (0 if all listeners scored the same)

The first three are from the BEL corpus materials (Calandruccio & Smiljanic, 2012). The item
statistics are from the validation listeners, per condition: 1A female average vocal effort
(16 listeners), 2A male average vocal effort (16), 2B female high vocal effort (16), 2C male
high vocal effort (15). Values are rounded to two decimals.


Reproducing the BELR lists
--------------------------

  Rscript anticlustering_lists.R item_statistics_BEL.csv lists.csv BELR_list_assignments.csv

The last argument is the list table in the dataset; the script reports how many sentences
match it. Requires R and the anticlust package (tested with R 4.5.1, anticlust 0.8.18).


Applying the method to other materials
--------------------------------------

1. Score each listener on every sentence (keywords correct) and run
     Rscript item_analysis.R scores.csv item_statistics.csv
   scores.csv columns: condition, listener, sentence_n, score.
2. Add the linguistic features to item_statistics.csv and run anticlustering_lists.R.
   The condition labels and features are set at the top of the script.
3. Compute critical differences from list scores:
     python critical_differences.py list_scores.csv
   list_scores.csv columns: listener, list, score (percent correct). Listener IDs must be
   unique across conditions when conditions are pooled.

item_analysis.R needs dplyr and tidyr. critical_differences.py needs numpy, pandas, and scipy.


References
----------

Calandruccio, L., & Smiljanic, R. (2012). New sentence recognition materials developed using a
  basic non-native English lexicon. Journal of Speech, Language, and Hearing Research, 55(5),
  1342-1355.
Cox, R. M., Alexander, G. C., & Gilmore, C. (1987). Development of the Connected Speech Test (CST).
  Ear and Hearing, 8(5 Suppl), 119S-126S.
Papenberg, M., & Klau, G. W. (2021). Using anticlustering to partition data sets into equivalent
  parts. Psychological Methods, 26(2), 161-174.
Studebaker, G. A. (1985). A "rationalized" arcsine transform. Journal of Speech and Hearing
  Research, 28(3), 455-462.
Thornton, A. R., & Raffin, M. J. M. (1978). Speech-discrimination scores modeled as a binomial
  variable. Journal of Speech and Hearing Research, 21(3), 507-518.

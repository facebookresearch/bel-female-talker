# BEL sentences, female talker, average and high vocal effort

This dataset contains recordings of the 500 Basic English Lexicon (BEL) sentences
(Calandruccio & Smiljanic, 2012) produced by one adult female talker in two speaking
styles: average vocal effort and high vocal effort (Lombard speech). The sentences are
arranged in 20 reshuffled lists of 25 sentences (BELR lists). The recordings and list
assignments are described and validated in:

  [Citation to be added on publication. Manuscript JSLHR-26-00621: "Validation, Critical
  Differences, and List Optimization of Basic English Lexicon (BEL) Sentences Across
  Talkers and Vocal Effort Levels."]


Download
--------

The recordings (WAV and MP4, about 28 GB) and the speech-shaped noise are downloaded from
https://ai.meta.com/datasets/bel-female-talker-downloads/. This repository holds the list assignments and the analysis code.


Contents
--------

  BELR_list_assignments.csv  list assignments, sentence text, and scoring keywords
  code/                    analysis code: item statistics, anticlustering, critical differences
  LICENSE                  CC BY-NC 4.0

The download contains:

  audio/average_VE/        500 WAV files, average vocal effort
  audio/high_VE/           500 WAV files, high vocal effort
  audiovisual/average_VE/  500 MP4 files, average vocal effort
  audiovisual/high_VE/     500 MP4 files, high vocal effort
  noise/                   speech-shaped noise, one file per vocal effort condition


File names
----------

  BELR<list><item>_F_<level>.<ext>     e.g. BELR0703_F_75.wav = list 7, sentence 3

<list> and <item> are two-digit BELR list and item numbers. <level> is the level of the
babble noise the talker heard during recording: 40 = 40 dB SPL (average vocal effort),
75 = 75 dB SPL (high vocal effort).


Recording
---------

The talker read the sentences from a teleprompter in a sound-treated room with a green
screen and four-point lighting. A listener sat about 1 m from the talker. Audio was
recorded with a Sennheiser 416 shotgun microphone 0.4 m in front of the talker at a
20-degree elevation, at 48 kHz. Video was recorded with a Samsung S22 smartphone at
3840 x 2160 and 60 frames per second, frontal view.

The talker wore earbuds playing 8-channel babble at 40 dB SPL (average vocal effort) or
75 dB SPL (high vocal effort). Earbud levels were calibrated with pink noise into a KU 100
dummy head. An engineer monitored the session and had off-target sentences re-recorded.


Processing
----------

Audio: the speech portion of each file was selected by hand, and its RMS level was scaled
to the mean level of its vocal effort condition. Files are 16-bit mono WAV at 48 kHz.

Audio-visual: the original video track carries the rescaled audio track. The audio stream
of each MP4 file is identical to the corresponding WAV file. Level scaling was applied to
the audio only, so each video shows the articulation produced at the original level.

Noise: for each vocal effort condition, white noise was shaped to the long-term average
spectrum of the 500 rescaled sentences and scaled to their mean level (60 s, 16-bit mono
WAV, 48 kHz).


List assignments and scoring
----------------------------

BELR_list_assignments.csv has one row per sentence:

  BELR_list, BELR_item                    reshuffled list and position
  original_BEL_list, original_BEL_item    list and position in Calandruccio & Smiljanic (2012)
  sentence_keywords_uppercase             sentence text, the four keywords in capitals
  keyword_1 ... keyword_4                 the four scored keywords
  audio_*, video_*                        relative paths of the matching files

Each list has 25 sentences and 100 keywords. In the validation study, a list score was the
percentage of keywords repeated correctly.

The practice sentences used in the validation study are not part of this dataset.


Analysis code
-------------

code/ holds the scripts for the item analysis, the anticlustering that produced the BELR
lists, and the critical differences, together with the item table the BELR lists were built
from. See code/README.txt.


Attribution and license
-----------------------

The BEL sentence texts are from Calandruccio, L., & Smiljanic, R. (2012). New sentence
recognition materials developed using a basic non-native English lexicon. Journal of
Speech, Language, and Hearing Research, 55(5), 1342-1355.
https://doi.org/10.1044/1092-4388(2012/11-0260)

The recordings, noise files, and list assignments are released by Meta Platforms, Inc.
under the Creative Commons Attribution-NonCommercial 4.0 International license
(CC BY-NC 4.0), as found in LICENSE.

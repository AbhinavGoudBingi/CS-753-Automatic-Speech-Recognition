#!/bin/bash

steps/get_train_ctm.sh data/train/ data/lang exp/tri1
cat exp/tri1/ctm > word_time.txt
rm -rf outputaudio
mkdir outputaudio
python3 clipping.py $1
rm word_time.txt
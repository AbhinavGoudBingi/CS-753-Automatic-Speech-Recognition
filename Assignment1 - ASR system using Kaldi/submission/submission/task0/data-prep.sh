#!/bin/bash

directories=("train" "test" "truetest")
for directory in "${directories[@]}"
do

mkdir corpus/data/$directory

cat corpus/data/data-info.txt | grep $directory | cut -d" " -f2- > tmp.txt

IFS=' ' read -a words < tmp.txt
for element in "${words[@]}"
do
cat corpus/data/transcriptions.txt | grep $element >> corpus/data/$directory/text
for wav_file in corpus/data/wav/$element/*.wav
do
	t=${wav_file%.wav}
	echo "${t#corpus/data/wav/$element/} $wav_file" >> corpus/data/$directory/wav.scp
	echo "${t#corpus/data/wav/$element/} $element" >> corpus/data/$directory/utt2spk
done

done

[ ! -L "utils" ] && ln -s ../../wsj/s5/utils
./utils/utt2spk_to_spk2utt.pl corpus/data/$directory/utt2spk > corpus/data/$directory/spk2utt

./utils/fix_data_dir.sh corpus/data/$directory
IFS=$OLDIFS
rm tmp.txt
done


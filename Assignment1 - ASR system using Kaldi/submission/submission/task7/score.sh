#!/bin/bash
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0

[ -f ./path.sh ] && . ./path.sh

# begin configuration section.
cmd=run.pl
stage=0
decode_mbr=true
word_ins_penalty=0.0
min_lmwt=7
max_lmwt=17
#end configuration section.

[ -f ./path.sh ] && . ./path.sh
. parse_options.sh || exit 1;

# if [ $# -ne 3 ]; then
#   echo "Usage: local/score.sh [--cmd (run.pl|queue.pl...)] <data-dir> <lang-dir|graph-dir> <decode-dir>"
#   echo " Options:"
#   echo "    --cmd (run.pl|queue.pl...)      # specify how to run the sub-processes."
#   echo "    --stage (0|1|2)                 # start scoring script from part-way through."
#   echo "    --decode_mbr (true/false)       # maximum bayes risk decoding (confusion network)."
#   echo "    --min_lmwt <int>                # minumum LM-weight for lattice rescoring "
#   echo "    --max_lmwt <int>                # maximum LM-weight for lattice rescoring "
#   exit 1;
# fi

data=data/test
lang_or_graph=exp/tri1/graph/
dir=exp/tri1/decode_test/

symtab=$lang_or_graph/words.txt

for f in $symtab $dir/lat.1.gz $data/text; do
  [ ! -f $f ] && echo "score.sh: no such file $f" && exit 1;
done

mkdir -p $dir/scoring/log

cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g' > $dir/scoring/test_filt.txt

python3 speakers.py $dir/scoring/test_filt.txt

$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/best_path.LMWT.log \
  lattice-scale --inv-acoustic-scale=LMWT "ark:gunzip -c $dir/lat.*.gz|" ark:- \| \
  lattice-add-penalty --word-ins-penalty=$word_ins_penalty ark:- ark:- \| \
  lattice-best-path --word-symbol-table=$symtab \
    ark:- ark,t:$dir/scoring/LMWT.tra || exit 1;

# Note: the double level of quoting for the sed command

IFS=' ' read -a speakers < speakers.txt
for element in "${speakers[@]}"
do
cat $dir/scoring/test_filt.txt | grep $element > $dir/scoring/test_filt_$element.txt
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/score.LMWT.log \
   cat $dir/scoring/LMWT.tra \| \
    utils/int2sym.pl -f 2- $symtab \| sed 's:\<UNK\>::g' \| \
    compute-wer --text --mode=present \
     ark:$dir/scoring/test_filt_$element.txt  ark,p:- ">&" $dir/wer_LMWT || exit 1;
for x in exp/tri1/decode*; do [ -d $x ] && echo -n "$element " >> formatting.txt && grep WER $x/wer_* | utils/best_wer.sh >> formatting.txt; done
done

IFS=$OLDIFS
rm speakers.txt

awk '{ $15=""}1' formatting.txt | awk '{ $2=""}1'
rm formatting.txt

exit 0;

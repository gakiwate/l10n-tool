#!/usr/bin/bash

MOSES_PATH=~/mosesdecoder
CORPUS_PATH=~/corpus
LM_PATH=~/lm
WORKING_PATH=~/working
IRSTLM_PATH=~/irstlm
EX_BIN_DIR=$MOSES_PATH/giza
LEX_DIR=~/lex-dir

ls lang.list &> /dev/null
if [ $? -ne 0 ]
then
	echo "ERROR: Script needs lang.list"
	exit
fi

TOTAL_LANG=`wc -l lang.list | cut -d " " -f1`
echo $TOTAL_LANG

#The first language in the list is considered as the base language
M_LANG=`cat lang.list | head -1`


mkdir $LM_PATH &> /dev/null
mkdir $WORKING_PATH &> /dev/null 
mkdir $LEX_DIR &> /dev/null

for (( i = 2 ; i <= $TOTAL_LANG; i++ ))
do
	F_LANG=`cat lang.list | head -$i | tail -1`
	echo Creating Lex Table for: $F_LANG

	mkdir $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG &> /dev/null

	$MOSES_PATH/scripts/tokenizer/tokenizer.perl -l $M_LANG < $CORPUS_PATH/Mozilla.$M_LANG > \
		$CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$M_LANG
	$MOSES_PATH/scripts/tokenizer/tokenizer.perl -l $F_LANG < $CORPUS_PATH/Mozilla.$F_LANG > \
		$CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$F_LANG

	$MOSES_PATH/scripts/recaser/train-truecaser.perl --model $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/truecase-model.$M_LANG \
		--corpus $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$M_LANG
	$MOSES_PATH/scripts/recaser/train-truecaser.perl --model $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/truecase-model.$F_LANG \
		--corpus $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$F_LANG

	$MOSES_PATH/scripts/recaser/truecase.perl --model $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/truecase-model.$M_LANG \
		< $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$M_LANG > $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.true.$M_LANG
	$MOSES_PATH/scripts/recaser/truecase.perl --model $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/truecase-model.$F_LANG \
		< $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.tok.$F_LANG > $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.true.$F_LANG

	$MOSES_PATH/scripts/training/clean-corpus-n.perl $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.true $F_LANG $M_LANG \
		$CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.clean 1 80
#LANGUAGE MODEL TRAINING

	mkdir $LM_PATH/Mozilla.$M_LANG-$F_LANG &> /dev/null

	$IRSTLM_PATH/bin/add-start-end.sh  < $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.true.$M_LANG > $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.sb.$M_LANG
	export IRSTLM=$HOME/irstlm
	$IRSTLM_PATH/bin/build-lm.sh -i $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.sb.$M_LANG -t ./tmp -p -s \
		improved-kneser-ney -o $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.lm.$M_LANG
	$IRSTLM_PATH/bin/compile-lm --text yes $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.lm.$M_LANG.gz $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.arpa.$M_LANG

	$MOSES_PATH/bin/build_binary $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.arpa.$M_LANG $LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.blm.$M_LANG

#TRAINING TRANSLATION SYSTEM
	mkdir $WORKING_PATH/Mozilla.$M_LANG-$F_LANG &> /dev/null
	cd $WORKING_PATH/Mozilla.$M_LANG-$F_LANG

	nohup nice $MOSES_PATH/scripts/training/train-model.perl -external-bin-dir $EX_BIN_DIR -root-dir train \
		-corpus $CORPUS_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.clean -f $F_LANG -e $M_LANG -alignment grow-diag-final-and \
		-reordering msd-bidirectional-fe -lm 0:3:$LM_PATH/Mozilla.$M_LANG-$F_LANG/Mozilla.blm.$M_LANG:8 >& training.out
	sort $WORKING_PATH/Mozilla.$M_LANG-$F_LANG/train/model/lex.f2e > $LEX_DIR/Mozilla.lex.$M_LANG-$F_LANG
	cd -
done

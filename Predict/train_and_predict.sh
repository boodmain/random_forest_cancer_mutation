

TRAIN_SET=$1
PREDICT_SET=$2
PREDICT_LIST=$3
RESULT_CLASS="TEMP/RESULT_CLASS.tsv"
RESULT_PROB="TEMP/RESULT_PROB.tsv"

echo "Args [1] = $TRAIN_SET : Traning set from Random Forest" 1>&2
echo "Args [2] = $PREDICT_SET : Set for prediction from Feature Table" 1>&2
echo "Args [3] = $PREDICT_LIST : List of mutation for prediction (args[2] and [3] should be ordered)" 1>&2
Rscript ./train_and_predict.R $TRAIN_SET $PREDICT_SET $RESULT_CLASS $RESULT_PROB

paste $PREDICT_LIST $RESULT_CLASS $RESULT_PROB

rm -f TEMP/*


INPUT=$1
GENE_SCORE=$2

PREDICT_DIR="Predict_set"

echo Making dir: $PREDICT_DIR
rm -rf $PREDICT_DIR
mkdir $PREDICT_DIR
cd $PREDICT_DIR


mkdir Data
cd Data

ln -s ../../$INPUT Features.tsv
ln -s ../../$GENE_SCORE Gene_Score.tsv

cd ../..
scripts/preproc_train_set.sh $PREDICT_DIR


echo "Two files are created"
echo 1. $PREDICT_DIR/Data/My_Predict_set.tsv       #Feature Table for predict
echo 2. $PREDICT_DIR/Data/My_Predict_set_list.tsv  #List of mutation name


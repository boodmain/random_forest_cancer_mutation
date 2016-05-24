
DIR1=$1

cd $DIR1

Rscript ../scripts/train_RF_10x5FCV.R > Result_RF_10x5FCV.txt

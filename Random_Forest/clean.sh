

CANCER_TYPE="Breast Lung"
TorN="Cancer Normal"
BG_WINDOW="1kb 5kb 10kb 100kb"


for cancer in $CANCER_TYPE
do
  for t_or_n in $TorN
  do
    for bgw in $BG_WINDOW
    do
      dir_name=$cancer"_"$t_or_n"_"$bgw

      rm -rf $dir_name
    done
  done
done


rm -rf Predict_set

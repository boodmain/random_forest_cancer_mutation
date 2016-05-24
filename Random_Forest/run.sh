

#CANCER_TYPE="Breast Lung"
#TorN="Cancer Normal"
#BG_WINDOW="1kb 5kb 10kb 100kb"
#

CANCER_TYPE="Breast Lung"
TorN="Cancer"
BG_WINDOW="5kb 10kb"


DIR_LIST=""

for cancer in $CANCER_TYPE
do
  for t_or_n in $TorN
  do
    for bgw in $BG_WINDOW
    do
      dir_name=$cancer"_"$t_or_n"_"$bgw
      feature_table=$cancer"_"$t_or_n".tsv"
      p_val_table=$cancer"_"$t_or_n"_"$bgw".tsv"

      echo Making dir: $dir_name
      rm -rf $dir_name
      mkdir $dir_name
      cd $dir_name
      mkdir Data
      cd Data

      ln -s ../../Data/Feature_table/$feature_table Features.tsv
      ln -s ../../Data/Recurrence_Pval/$p_val_table Recurrence_pVal.tsv
      ln -s ../../Data/Gene_Score/Breast_Cancer.tsv Gene_Score.tsv

      cd ../..
      DIR_LIST="$dir_name $DIR_LIST"
    done
  done
done




#make training set
for var in $DIR_LIST
do
    scripts/preproc_train_set.sh $var
done

#WORK_PID=`jobs -l | awk '{print $2}'`
#wait $WORK_PID


#5-fold CV
for var in $DIR_LIST
do
    scripts/train_RF_10x5FCV.sh $var
done

#WORK_PID=`jobs -l | awk '{print $2}'`
#wait $WORK_PID


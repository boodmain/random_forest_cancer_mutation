
DIR1=$1
cd $DIR1/Data


#Get true list for mutation
cat Recurrence_pVal.tsv | awk '
    $2=="1" {print "TRUE\t"$1}
' > True_list.tsv





#Process Gene_score to Target_Gene_Score
cat Gene_Score.tsv | awk '
    NR==1 {
           printf "DICT"
           for (i=1; i<=NF; i++){
               printf "\tTarget_" $i;
           }
           printf "\n";
          }
    NR>1 {print "DICT\t" $0}
' > Target_Gene_Dict.tsv



#Process Gene_score to TF_Gene_Score
cat Gene_Score.tsv | awk '
    NR==1 {
           printf "DICT\tTF_Name";
           for (i=2; i<=NF; i++){
               printf "\tTF_" $i;
           }
           printf "\n";
          }
    NR>1 {print "DICT\t" $0}
' > TF_Gene_Dict.tsv



#1 Pos
#2 Target_Gene <- Step 1 : Filter out, Step 3 : Replace
#3 TF_Name <- Step 2 : Replace
#4 diff_Pval
#5 avg_Pval
#6 TF_sign
#...

#Step 1: find and filter field 'Target_Gene'
cat Target_Gene_Dict.tsv Features.tsv | awk '
    BEGIN   { OFS = "\t" }
    $1 == "DICT" { NAME[$2]="T" }
    $1 != "DICT" && ($2 in NAME) { 
        print $0;
    }
' > My_feature_step1.tsv



#Step 2: find and replace field 'TF_Name' of My_feature_step1 with My_TF_Gene_Dict.tsv
cat TF_Gene_Dict.tsv My_feature_step1.tsv | awk '
    BEGIN   { OFS = "\t"; max_nf=0 }
    $1 == "DICT" {
        if (max_nf < NF) {
          max_nf = NF;
        }
        NAME[$2] = "T";
        for (i=3; i<=NF; i++) {
          d_name = $2 "_X_" i;
          DICT[d_name]=$i;
        }
    }

    $1 != "DICT" { 
        printf $1 "\t" $2;

        if ($3 in NAME) {
          for (i=3; i<=max_nf; i++) {
            d_name = $3 "_X_" i;
            if (d_name in DICT) {
              printf "\t" DICT[d_name];
            }else{
              printf "\t" 0;
            }
          }
        } else {
           for (i=3; i<=max_nf; i++) printf "\t0";
        }

        for (i=4; i<=NF; i++) printf "\t" $i;
        printf "\n";
    }
' > My_feature_step2.tsv


#Step 3: find and replace field 'Target_Gene' of My_feature_step2 with My_Target_Gene_Dict.tsv
cat Target_Gene_Dict.tsv My_feature_step2.tsv | awk '
    BEGIN   { OFS = "\t" ; max_nf=0}
    $1 == "DICT" {
        if (max_nf < NF) {
          max_nf = NF;
        }
        NAME[$2] = "T";
        for (i=3; i<=NF; i++) {
          d_name = $2 "_X_" i;
          DICT[d_name]=$i;
        }
    }
    ($1 != "DICT") && ($2 in NAME) {
        printf $1;
        for (i=3; i<= max_nf; i++)
        {
            d_name = $2 "_X_" i;
            if (d_name in DICT){
              printf "\t" DICT[d_name];
            }else{
              printf "\t" 0;
            }
        }

        for (i=3; i<=NF; i++) printf "\t" $i;
        printf "\n";
    }
' > My_feature_step3.tsv

echo "Fields of My_feature_step3.tsv"
echo "---------------------------"
head -n 1 My_feature_step3.tsv | awk 'BEGIN{RS="\t"} {print "#" NR, $1}'
echo "---------------------------"
echo " "


# Delete First Line to Make Feature only table
tail -n +2 My_feature_step3.tsv > My_feature_step4.tsv


#find and replace '.' field to '0'
cat True_list.tsv My_feature_step4.tsv | awk '
    $1 == "TRUE" {
       T_LIST[$2] = "T";
    }
    ($1 != "TRUE")  && ($1 in T_LIST){
      for (i=2; i<=NF; i++) {
        if ($i == ".") {
          printf "0\t";
        } else if ($i == "PUT") {
          printf "0\t";
        } else if ($i == "LOSS") {
          printf "-1\t";
        } else if ($i == "GAIN") {
          printf "1\t";
        } else {
          printf $i "\t";
        }
      }
      print 1;
    }
' > My_Training_True.tsv

#find and replace '.' field to '0'
cat True_list.tsv My_feature_step4.tsv | awk '
    $1 == "TRUE" {
       T_LIST[$2] = "T";
    }
    ($1 != "TRUE")  && (!($1 in T_LIST)){
      for (i=2; i<=NF; i++) {
        if ($i == ".") {
          printf "0\t";
        } else if ($i == "PUT") {
          printf "0\t";
        } else if ($i == "LOSS") {
          printf "-1\t";
        } else if ($i == "GAIN") {
          printf "1\t";
        } else {
          printf $i "\t";
        }
      }
      print 0;
    }
' > My_Training_False.tsv


#find and replace '.' field to '0'
cat My_feature_step3.tsv | awk '
    {
      for (i=2; i<=NF; i++) {
        if ($i == ".") {
          printf "0\t";
        } else if ($i == "PUT") {
          printf "0\t";
        } else if ($i == "LOSS") {
          printf "-1\t";
        } else if ($i == "GAIN") {
          printf "1\t";
        } else {
          printf $i "\t";
        }
      }
      print 0;
    }
' > My_Predict_set.tsv

cut -f 1 My_feature_step3.tsv > My_Predict_set_list.tsv



#final set = True(1000 line) + False( 3* true set)
cat My_feature_step3.tsv  | head -n 1 | cut -f 1 --complement | awk '{print $0 "\tTorF"}' > My_FinalSet_Training.tsv

T_lines=`wc -l My_Training_True.tsv | awk '($1 > 1000){print 1000} ($1<=1000) {print $1}'`
F_lines=`expr $T_lines \* 3`
cat My_Training_True.tsv  | shuf | head -n $T_lines >> My_FinalSet_Training.tsv
cat My_Training_False.tsv | shuf | head -n $F_lines >> My_FinalSet_Training.tsv



echo "Fields of My_FinalSet_Training.tsv"
echo "---------------------------"
head -n 1 My_FinalSet_Training.tsv | awk 'BEGIN{RS="\t"} {print "#" NR, $1}'
echo "---------------------------"
echo " "


echo "# of fields:"
awk '{print NF}' My_FinalSet_*.tsv | sort -u

echo "# of recode:"
wc My_*



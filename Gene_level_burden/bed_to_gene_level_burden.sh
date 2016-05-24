
rm -rf TEMP
mkdir TEMP

BED_INPUT=$1
PREDICT_LIST=$2
PREDICT_TEMP="TEMP/MUTATION_CLASS.tsv"

echo "Args [1] = $BED_INPUT : Bed file for Position and Individual eg) chr1 10000 10001 SAMPLE1" 1>&2
echo "Args [2] = $PREDICT_LIST : Prediction result for mutations eg) chr1:10001 TRUE" 1>&2

cat $PREDICT_LIST \
| awk 'NR>1{print "PREDICTED\t" $1 "\t" $2}' \
> $PREDICT_TEMP

cat $PREDICT_TEMP $BED_INPUT \
| awk '$1=="PREDICTED" {
          predicted[$2] = $3;
       }
       $1!="PREDICTED" {
          mut_name = $1 ":" $3;
          sample_name = $4;
          if (mut_name in predicted)
          {
            all_n[sample_name]++;
            if (predicted[mut_name]=="TRUE") true_n[sample_name]++;
            else if (predicted[mut_name]=="FALSE") false_n[sample_name]++;
          }
       }
       END {
         OFS = "\t";
         print "Sample","Gene_burden","TRUE","FALSE"
         for (i in all_n)
         {
           gene_burden = (true_n[i]+1)/(false_n[i]+1);
           print i, gene_burden, true_n[i] + 0, false_n[i] + 0;
         }
       }
'

rm -rf TEMP

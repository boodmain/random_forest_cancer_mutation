
rm -rf TEMP
mkdir TEMP

INPUT=$1
BED1="1.cancer_gwas.bed"

STEP2="TEMP/STEP2.bed"
RESULT1="TEMP/RESULT1.tsv"
RESULT2="TEMP/RESULT2.tsv"
RESULT3="TEMP/RESULT3.tsv"

#-------INPUT-BED-(A)-------------------------------- ======GWAS=BED=(B)================     <DISTANCE>
#chr1 934839  934840  C   G   chr1:934840     ISG15   chr1    8373751 8373752 rs10864348      7438912
#chr1 1119819 1119820 G   A   chr1:1119820    TTLL10  chr1    8373751 8373752 rs10864348      7253932

#step1 GWAS distance
closestBed -a $INPUT -b $BED1 -d | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT1
paste $INPUT $RESULT1 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2

#step2 Early_to_late ratio
awk '{OFS="\t"; print $1, $2, $3, $6}' $INPUT > $STEP2
cd 2.Early_to_Late_ratio

./early_to_late_ratio.sh ../$STEP2 > ../$RESULT2
cd ..
paste $INPUT $RESULT2 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2


cd 3.PhastCons

./bed_to_phastCons.sh ../$STEP2 > ../$RESULT3
cd ..
paste $INPUT $RESULT3 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2


paste $RESULT1 $RESULT2 $RESULT3 \
| awk '
    BEGIN {
      OFS="\t"; 
      print "Dist_GWAS_2D", "Early.to.late_Rate", "PhastCons";
    }
    {
      print $2, $4, $6;
    }
'


rm -rf TEMP


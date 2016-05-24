
rm -rf TEMP
mkdir TEMP

INPUT=$1
MEME_DATA="humanMatrix.meme.dat"
BED2="2.DnaseMcf7.bed"


STEP21="TEMP/STEP21.bed"
STEP22="TEMP/STEP22.bed"

FASTA1="TEMP/FASTA1.fasta"
FASTA2="TEMP/FASTA2.fasta"

TEMP1="TEMP/TEMP1.tsv"
TEMP2="TEMP/TEMP2.bed"

FASTA1R="TEMP/FASTA1_REF.fasta"
FASTA1A="TEMP/FASTA1_ALT.fasta"
FIMO1R="TEMP/FIMO_REF.dat"
FIMO1A="TEMP/FIMO_ALT.dat"
FIMO2="TEMP/FIMO_PUT.dat"
LOG1R="TEMP/FIMO_REF.log"
LOG1A="TEMP/FIMO_ALT.log"
LOG2="TEMP/FIMO_PUT.log"
TEMP1R="TEMP/TEMP1R.tsv"
TEMP1A="TEMP/TEMP1A.tsv"

RESULT0="TEMP/RESULT0.tsv"
RESULT1="TEMP/RESULT1.tsv"
RESULT2="TEMP/RESULT2.tsv"
RESULT_ALL="TEMP/RESULT_ALL.tsv"


cat $INPUT \
| awk 'BEGIN{OFS="\t"} {print $1, $2-30, $3+30, $4, $5, $1 "=" $3}' \
> $STEP21


# It is for putative TF
intersectBed -a $INPUT -b $BED2 -wa -wb \
| cut -f 8-10 \
> $STEP22




#default TF binding
#chr1:123456*.     0     0     .          200
#--pos------ gene  diff  avg   gain/loss  distance
cat $INPUT \
| awk 'BEGIN{OFS="\t"} {print $6 "*" ".", 0, 0, ".", 200;}' \
> $RESULT0


fastaFromBed -bed ./$STEP21 -fi ./hg19.fa -fo ./$FASTA1
fastaFromBed -bed ./$STEP22 -fi ./hg19.fa -fo ./$FASTA2


# Gain or Loss
cat $FASTA1 \
| awk '
    BEGIN {RS=">"; FS="\n"; OFS="\t"}
    NF>2 {print $1, $2}
' > $TEMP1


paste $TEMP1 $STEP21 \
| awk '{print ">" $8 ":" $4 "-" $5 "\n" substr($2, 1, 30) $6 substr($2, 32)}' \
> $FASTA1R

paste $TEMP1 $STEP21 \
| awk '{print ">" $8 ":" $4 "-" $5 "\n" substr($2, 1, 30) $7 substr($2, 32)}' \
> $FASTA1A


#Find TFs
fimo -text -parse-genomic-coord -thresh 1e-5 $MEME_DATA $FASTA1R > $FIMO1R 2> $LOG1R
fimo -text -parse-genomic-coord -thresh 1e-5 $MEME_DATA $FASTA1A > $FIMO1A 2> $LOG1A
fimo -text -parse-genomic-coord -thresh 1e-5 $MEME_DATA $FASTA2  > $FIMO2  2> $LOG2



# if ref = 10e-5, alt = 10e-7,
# avg = 6, diff = 2, sign = GAIN
cat $FIMO1R | awk -F"[_\t=]" 'NR>1{print $4 ":" $5 "*" $2 "\t" log($10)/log(10)}' > $TEMP1R
cat $FIMO1A | awk -F"[_\t=]" 'NR>1{print $4 ":" $5 "*" $2 "\t" 0-(log($10)/log(10))}' > $TEMP1A
cat $FIMO2  | awk -F"[_\t=]" 'NR>1{OFS="\t"; print $4, $5, $6, $2, $9}' | sortBed > $TEMP2

#chr1:123456*GENE1    -3.5  (REF)
#chr1:123456*GENE1    4.5   (ALT)
cat $TEMP1R $TEMP1A \
| awk '
    BEGIN {OFS="\t"}
    $2 < 0 {
      if ($1 in MIN) {
        if (MIN[$1] > $2) {
          MIN[$1] = $2;
          MAX[$1] = 0;
        }
      }else{
        MIN[$1] = $2;
        MAX[$1] = 0;
      }
    }
    $2 > 0 {
      if ($1 in MAX) {
        if (MAX[$1] < $2) {
          MAX[$1] = $2;
        }
      }else{
        MAX[$1] = $2;
      }
    }
    END {
      for (MUT in MAX) {
        MINUS = MAX[MUT] + MIN[MUT];
        PLUS  = MAX[MUT] - MIN[MUT];
        AVG   = PLUS / 2;
        if (MINUS > 0) {
          SIGN="GAIN";
          DIFF=MINUS;
          print MUT, DIFF, AVG, SIGN, 0;
        } else if (MINUS < 0){
          SIGN="LOSS";
          DIFF=-MINUS;
          print MUT, DIFF, AVG, SIGN, 0;
        } 
      }
    } ' \
> $RESULT1
#chr1:123456*GENE1    1.0    4.0    GAIN    0
#gain or loss



#chr1    9411712 9411713 G       C       chr1:9411713    SPSB1   chr1    2518001 2518009 TAF1    3.01e-06        6893704
closestBed -a $INPUT -b $TEMP2 -d \
| awk '{OFS="\t"; print $6 "*" $11, 0, $12, "PUT", $13;}' \
> $RESULT2





#sort and pick best TF
#larger diff, more proximal to mutation

cat $RESULT0 $RESULT1 $RESULT2 \
| awk -F "[\t*]" '
    {
      OFS = "\t";
      print $1, $2, $3, $4, $5, $6;
    }
' \
| sort -k1,1 -k3,3nr -k6,6n \
| awk '
    PREV != $1 {
      print $0;
      PREV = $1;
    }
' \
| awk -F "[\t:]" '
    {
      OFS = "\t";
      print $1, $2-1, $2, $1 ":" $2, $3, $4, $5, $6;
    }
' \
| sortBed \
| awk '
    {
      OFS = "\t";
      print $4, $5, $6, $7, $8;
    }
' > $RESULT_ALL
#chr1:123456    GENE1    1.0    4.0    GAIN


paste $INPUT $RESULT_ALL | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2

cat $RESULT_ALL \
| awk '
  BEGIN{
    OFS = "\t";
    print "TF_Name","diff_Pval","avg_Pval","TF_sign";
  }
  {
    print $2, $3, $4, $5;
  }
'

rm -rf TEMP

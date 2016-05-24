
rm -rf TEMP
mkdir TEMP

INPUT=$1

#-------INPUT-BED-(A)------------------------------------------- ======SIGNAL=BED=(B)=======
#chr1    2005390 2005391 G       A       chr1:2005391    PRKCZ   .       -1      -1      .
#chr1    2144144 2144145 G       A       chr1:2144145    C1orf86 chr1    2144005 2144155 32

BED0="0.Mcf7.DnaseSig.bed"
BED1="1.Mcf7.H3K27ac.bed"
BED2="2.Mcf7.H3K27me3.bed"
BED3="3.Mcf7.H3K36me3.bed"
BED4="4.Mcf7.H3K4me3.bed"
BED5="5.Mcf7.H3K9me3.bed"

RESULT0="TEMP/RESULT0.tsv"
RESULT1="TEMP/RESULT1.tsv"
RESULT2="TEMP/RESULT2.tsv"
RESULT3="TEMP/RESULT3.tsv"
RESULT4="TEMP/RESULT4.tsv"
RESULT5="TEMP/RESULT5.tsv"

intersectBed -a $INPUT -b $BED0 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT0
intersectBed -a $INPUT -b $BED1 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT1
intersectBed -a $INPUT -b $BED2 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT2
intersectBed -a $INPUT -b $BED3 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT3
intersectBed -a $INPUT -b $BED4 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT4
intersectBed -a $INPUT -b $BED5 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT5

#Check mutations to be ordered
paste $INPUT $RESULT0 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT1 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT2 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT3 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT4 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT5 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2


paste $RESULT0 $RESULT1 $RESULT2 $RESULT3 $RESULT4 $RESULT5 \
| awk '
    BEGIN {
      OFS="\t"; 
      print "DnaseSig","H3K27ac","H3K27me3","H3K36me3","H3K4me3","H3K9me3";
    }
    {
      print $2, $4, $6, $8, $10, $12
    }
'

#OUTPUT file
#DnaseSeq H3k27ac H3k27me3 H3k36me3 H3k4me3 H3k9me3
#32       .       .        .        8.5454  .
#.        .       .        .        .       .
#.        .       .        .        .       .
#.        .       .        .        .       .
#104      .       .        .        .       .
#.        .       49.33    .        .       .


rm -rf TEMP

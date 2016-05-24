
INPUT=$1

#-------INPUT-BED-(A)------------------------------------------- ======SIGNAL=BED=(B)=======
#chr1    2005390 2005391 G       A       chr1:2005391    PRKCZ   .       -1      -1      .
#chr1    2144144 2144145 G       A       chr1:2144145    C1orf86 chr1    2144005 2144155 32

BED0="0.Dnase.bed"
BED1="1.H3K27ac.bed"
BED2="2.H3K27me3.bed"
BED3="3.H3K36me3.bed"
BED4="4.H3K4me1.bed"
BED5="5.H3K4me2.bed"
BED6="6.H3K4me3.bed"
BED7="7.H3K79me2.bed"
BED8="8.H3K9ac.bed"
BED9="9.H3K9me3.bed"
BED10="10.H4K20me1.bed"


RESULT0="TEMP/RESULT0.tsv"
RESULT1="TEMP/RESULT1.tsv"
RESULT2="TEMP/RESULT2.tsv"
RESULT3="TEMP/RESULT3.tsv"
RESULT4="TEMP/RESULT4.tsv"
RESULT5="TEMP/RESULT5.tsv"
RESULT6="TEMP/RESULT6.tsv"
RESULT7="TEMP/RESULT7.tsv"
RESULT8="TEMP/RESULT8.tsv"
RESULT9="TEMP/RESULT9.tsv"
RESULT10="TEMP/RESULT10.tsv"

intersectBed -a $INPUT -b $BED0 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT0
intersectBed -a $INPUT -b $BED1 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT1
intersectBed -a $INPUT -b $BED2 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT2
intersectBed -a $INPUT -b $BED3 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT3
intersectBed -a $INPUT -b $BED4 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT4
intersectBed -a $INPUT -b $BED5 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT5
intersectBed -a $INPUT -b $BED6 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT6
intersectBed -a $INPUT -b $BED7 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT7
intersectBed -a $INPUT -b $BED8 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT8
intersectBed -a $INPUT -b $BED9 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT9
intersectBed -a $INPUT -b $BED10 -wa -wb -loj | awk 'BEGIN{OFS="\t"} {print $6 "\t" $11}' > $RESULT10

#Check mutations to be ordered
paste $INPUT $RESULT0 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT1 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT2 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT3 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT4 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT5 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT6 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT7 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT8 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT9 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2
paste $INPUT $RESULT10 | awk '$6 != $8 {print "DATA ERROR"; exit 1;}' 1>&2


paste $RESULT0 $RESULT1 $RESULT2 $RESULT3 $RESULT4 $RESULT5 $RESULT6 $RESULT7 $RESULT8 $RESULT9 $RESULT10 \
| awk '
    BEGIN {
      OFS="\t"; 
      print "Dnase" ,"H3K27ac" ,"H3K27me3" ,"H3K36me3" ,"H3K4me1" ,"H3K4me2" ,"H3K4me3" ,"H3K79me2" ,"H3K9ac" ,"H3K9me3" ,"H4K20me1";
    }
    {
      print $2, $4, $6, $8, $10, $12, $14, $16, $18, $20, $22
    }
'

#OUTPUT file
#Dnase    H3K27ac H3K27me3 H3K36me3 H3K4me1 H3K4me2 H3K4me3 H3K79me2 H3K9ac H3K9me3 H4K20me1
#32       .       .        .        8.5454  .       .       .        .      .       .
#.        .       .        .        .       .       .       .        .      .       .
#104      .       .        .        .       .       .       .        49.33  .       .



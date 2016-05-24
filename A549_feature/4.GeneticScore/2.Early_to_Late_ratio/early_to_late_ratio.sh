#Early-to-late ratio was calculated as (G1B + S1)/(S4 + G2).
#Ref: http://www.nature.com/nature/journal/v488/n7412/full/nature11273.html

INPUT=$1

TEMP_G1B="TEMP/G1b.tsv"
TEMP_S1="TEMP/S1.tsv"
TEMP_S4="TEMP/S4.tsv"
TEMP_G2="TEMP/G2.tsv"
TEMP_ALL="TEMP/ALL.tsv"

bigWigAverageOverBed G1b.bigWig $INPUT $TEMP_G1B
bigWigAverageOverBed S1.bigWig  $INPUT $TEMP_S1
bigWigAverageOverBed S4.bigWig  $INPUT $TEMP_S4
bigWigAverageOverBed G2.bigWig  $INPUT $TEMP_G2

# format
# chr1:934840     1       1       77      77      77
# -1-- +2++++    <3>     <4>     <5>     <6>     <7>
# -8-- +9++++    <10>    <11>    <12>    <13>    <14>
# -15- +16+++    <17>    <18>    <19>    <20>    <21>
# -22- +23+++    <24>    <25>    <26>    <27>    <28>

paste $TEMP_G1B $TEMP_S1 $TEMP_S4 $TEMP_G2 \
| awk '
    BEGIN {FS = "[:\t]"; OFS="\t";}
    $2 != $9  {print "DATA ERROR"; exit 1;}
    $2 != $16 {print "DATA ERROR"; exit 1;}
    $2 != $23 {print "DATA ERROR"; exit 1;}
    {print $1, $2-1, $2, $1 ":" $2, $5, $12, $19, $26}
' | sortBed > $TEMP_ALL


cat $TEMP_ALL \
| cut -f4-8 \
| awk '
    BEGIN {
      OFS="\t";
    }
    {
      G1b_S1 = $2 + $3;
      S4_G2  = $4 + $5;

      if ( S4_G2 == 0) {
        if ( G1b_S1 == 0) {
          print $1, ".";
        } else {
          print $1, G1b_S1;
        }
      } else {
        print $1, (G1b_S1 / S4_G2);
      }
    }
'

rm -f TEMP/*

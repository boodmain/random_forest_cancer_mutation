
INPUT=$1


rm -rf INPUT
mkdir  INPUT
cd     INPUT

cat ../$INPUT | awk '{print >> $1 }'
cd ..

rm -rf OUTPUT
mkdir  OUTPUT

for CHR in `ls INPUT/`
do
    echo phastCons $CHR 1>&2
    intersectBed -a INPUT/$CHR \
                 -b phastCons/bedGraphs/$CHR.phastCons100way.bedGraph \
                 -wa -wb -loj -sorted \
    | cut -f4,8 \
    > OUTPUT/result.$CHR.tsv
done


cat OUTPUT/result.*.tsv \
| awk '
    BEGIN{FS="[:\t]"; OFS="\t"}
    { print $1, $2-1, $2, $1 ":" $2, $3}
' | sortBed \
| awk '{print $4 "\t" $5}'



rm -rf INPUT OUTPUT

# Fields of Input BED file
#
#    chrom - name of the chromosome
#    chromStart - Start position of the mutation
#    chromEnd - End position of the mutation
#    Reference allele
#    Mutated allele
#
# Example
#chr1	4541594	4541595	G	A	ICGC-1d27253f-b036-44e7-a04d-8da5bbf57419	Breast_ICGC
#chr1	4542491	4542492	C	A	ICGC-4da999a0-ef41-4a0b-b1d1-446b39cc855a	Breast_ICGC
#chr1	4543980	4543981	C	G	ICGC-174850b4-5ec2-462b-a890-89bd1716b3c2	Breast_ICGC
#chr1	4544994	4544995	G	A	ICGC-96312510-c126-485d-8109-ed81844a1dc3	Breast_ICGC
#chr1	4548204	4548205	T	A	ICGC-d2f2560c-ec80-4fea-9474-c47a2e85ea95	Breast_ICGC
#chr1	4549557	4549558	G	A	ICGC-566792ae-f853-4a47-856d-f02cdcfcb18a	Breast_ICGC
#chr1	4551985	4551986	G	T	ICGC-6fa2a667-9c36-4526-8a58-1975e863a806	Breast_ICGC
#chr1	4553134	4553135	C	T	ICGC-b58ad350-5140-4fa8-bc2c-24bca8395f3a	Breast_ICGC
#chr1	4553699	4553700	C	G	ICGC-c364e81c-eb1e-4870-ab37-9c661f5f2e3d	Breast_ICGC
#chr1	4562000	4562001	C	T	ICGC-5ed024e8-d05e-4c65-9441-eda9930ccc82	Breast_ICGC

rm -rf TEMP
mkdir TEMP


if [ "$#" -lt "2" ]
then
echo ""
echo "Usage: $0 Input_bed_file Output_tsv_file"
echo ""
echo "Fields of Input BED file"
echo "1. chrom - name of the chromosome"
echo "2. chromStart - Start position of the mutation"
echo "3. chromEnd - End position of the mutation"
echo "4. Reference allele"
echo "5. Mutated allele"
echo "6th and the latters will not be used"
echo ""
exit 1
fi

INPUT=$1
STEP0="TEMP/STEP0.bed"
STEP1="TEMP/STEP1.bed"

RESULT0="TEMP/RESULT0.tsv"
RESULT1="TEMP/RESULT1.tsv"
RESULT2="TEMP/RESULT2.tsv"
RESULT3="TEMP/RESULT3.tsv"
RESULT4="TEMP/RESULT4.tsv"
OUTPUT=$2

# Features
# ========
# Pos                (STEP1)
# Target_Gene        (STEP1)
# TF_Name            (STEP2)
# diff_Pval          (STEP2)
# avg_Pval           (STEP2)
# TF_sign            (STEP2)
# DnaseSig           (STEP3.0)
# H3K27ac            (STEP3.0)
# H3K27me3           (STEP3.0)
# H3K36me3           (STEP3.0)
# H3K4me3            (STEP3.0)
# H3K9me3            (STEP3.0)
# Dist_GWAS_2D       (STEP4.1)
# Early.to.late_Rate (STEP4.2)
# PhastCons          (STEP4.3)


echo ""
echo "0. Re-formating bedfile"
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5}' $INPUT | sortBed > $STEP0
echo "  $STEP0 : `wc -l $STEP0 | awk '{print $1}'` lines"


echo ""
echo "1. Finding target gene"
cd 1.TargetGene_3D
./bed_to_target_gene.sh ../$STEP0 > ../$STEP1
cd ..
echo "  $STEP1 : `wc -l $STEP1 | awk '{print $1}'` lines"

awk 'BEGIN{print "Pos"}         {print $6}' $STEP1 > $RESULT0
awk 'BEGIN{print "Target_Gene"} {print $7}' $STEP1 > $RESULT1


echo ""
echo "2. Finding binding TF"
cd 2.TF
./bed_to_TFbind.sh ../$STEP1 > ../$RESULT2
cd ..


echo ""
echo "3. Finding Epigenetic signals"
cd 3.EpiSignal
./bed_to_episignal.sh ../$STEP1 > ../$RESULT3
cd ..


echo ""
echo "4. Finding Genetic scores"
cd 4.GeneticScore
./bed_to_genetic_score.sh ../$STEP1 > ../$RESULT4
cd ..


paste $RESULT0 $RESULT1 $RESULT2 $RESULT3 $RESULT4 \
> $OUTPUT

rm -rf TEMP

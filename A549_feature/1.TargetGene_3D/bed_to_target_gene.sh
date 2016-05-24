
INPUT=$1

#-------INPUT-BED-(A)---------------     ======TARGET=GENE=BED=(B)========================
#chr1    725680  725681  G       A       chr1    723938  725938  NOC2L   0.877   ImPet   3

intersectBed -a $INPUT -b Position_to_TargetGene.bed -wa -wb -sorted \
| awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $1 ":" $3, $9, $12, $10}' \
| sort -k6,6 -k8,8rn -k9,9rn \
| awk 'BEGIN{OFS="\t"; PREV=""} $6!=PREV {print $1, $2, $3, $4, $5, $6, $7; PREV=$6}' \
| sortBed

#OUTPUT bed file
#chr10   100027717       100027718       G       A       chr10:100027718 LOXL4


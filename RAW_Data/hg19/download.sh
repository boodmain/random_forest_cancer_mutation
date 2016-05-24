
rm -rf Fasta
mkdir Fasta
cd Fasta

wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.2bit
twoBitToFa ./hg19.2bit ./hg19.fa

cd ..

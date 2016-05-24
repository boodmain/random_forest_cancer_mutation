echo "Download public data for phastCons : It needs tens of gigabytes of storage"
rm -rf wigFix
mkdir  wigFix
cd     wigFix

for i in `seq 1 22` X Y
do
    wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/phastCons100way/hg19.100way.phastCons/chr$i.phastCons100way.wigFix.gz
    gunzip chr$i.phastCons100way.wigFix.gz
done


cd ..

rm -rf bedGraphs
mkdir  bedGraphs
cd     bedGraphs

for i in `seq 1 22` X Y
do
    echo "wigToBigWig chr$i" 1>&2
    wigToBigWig ../wigFix/chr$i.phastCons100way.wigFix ../hg19.chrom.sizes out.bw
    echo "bigWigToBedGraph chr$i" 1>&2
    bigWigToBedGraph out.bw chr$i.phastCons100way.bedGraph
done

rm -f out.bw

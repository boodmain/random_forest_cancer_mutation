import math

f=open('../../Breast_WGS_mutations.position.input.bed')

f1=open('CompPvalDiff/TF_MOTIF_GAIN.NAME_GENE.txt')
f2=open('CompPvalDiff/TF_MOTIF_LOSS.NAME_GENE.txt')
f3=open('CompPvalDiff/Putative_TF_find/Breast_WGS_mutations.Putative_bestTF_inDHS.txt')

tfgaindic={}
for line in f1:
	tmp=line.strip().split('\t')
	pos=tmp[0]+':'+tmp[1]
	avgP= "{0:.2E}".format( (float(tmp[10])+float(tmp[11]))/2.0, 5) 
	beforeP=-math.log10(float(tmp[10])); afterP=-math.log10(float(tmp[11]))
	diffP=afterP-beforeP
	if pos in tfgaindic:
		if tfgaindic[pos][1]<diffP:
			tfgaindic[pos]=[tmp[5],diffP,avgP]
	else:
		tfgaindic[pos]=[tmp[5],diffP,avgP]

for pos in tfgaindic:
	tfgaindic[pos][1]=str(round(tfgaindic[pos][1],5))


tflossdic={}
for line in f2:
	tmp=line.strip().split('\t')
	pos=tmp[0]+':'+tmp[1]
	avgP= "{0:.2E}".format( (float(tmp[10])+float(tmp[11]))/2.0, 5) 
	beforeP=-math.log10(float(tmp[10])); afterP=-math.log10(float(tmp[11]))
	diffP=beforeP-afterP
	if pos in tflossdic:
		if tflossdic[pos][1]<diffP:
			tflossdic[pos]=[tmp[5],diffP,avgP]
	else:
		tflossdic[pos]=[tmp[5],diffP,avgP]

for pos in tflossdic:
	tflossdic[pos][1]=str(round(tflossdic[pos][1],5))

tfputdic={}
f3.readline()
for line in f3:
	tmp=line.strip().split('\t')
	tfputdic[tmp[0]]=[tmp[1],"0",tmp[3]]


for line in f:
	pos=line.strip().split('\t')[3]
	if pos in tfgaindic:
		if pos in tflossdic:
			if tfgaindic[pos][1]>tflossdic[pos][1]:
				print pos+'\t'+'\t'.join(tfgaindic[pos])+'\tGAIN'
			else:
				print pos+'\t'+'\t'.join(tflossdic[pos])+'\tLOSS'
		else:
			print pos+'\t'+'\t'.join(tfgaindic[pos])+'\tGAIN'
	else:
		if pos in tflossdic:
			print pos+'\t'+'\t'.join(tflossdic[pos])+'\tLOSS'
		else:
			if pos in tfputdic:			
				print pos+'\t'+'\t'.join(tfputdic[pos])+'\tPUT'
			else:
				print pos+'\t.\t.\t.\t.'



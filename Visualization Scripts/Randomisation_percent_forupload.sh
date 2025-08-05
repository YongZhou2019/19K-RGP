#!/bin/bash

#conda init
#conda activate plink2
## Usage : himmamp@KW61048:/home/projects/10KRGP/scripts$ ./Randomisation_percent.sh ../dataset/SNPs/20KSamples.txt raw ../dataset/SNPs/raw/genome1.genomewide.SNPs.withID.PlinkFormat

## NOTE plink2 --bfile works with bim,fam,bed files as input
## plink2 --pfile works with psam,pvar,pgen files as input

#numofsample=${2}
#percentage=$2

fname="Randomisation_${2}_percentage_numsnps_biallelic.txt"

for percentage in 1 10 50 100 150 200 250 300; 
do
	#fname="Randomisation_${2}_percentage_${percentage}_biallelic.txt"
 
	for i in {1..10}; do
		sample_size=$(($(wc -l < $1) * percentage / 100))
		shuf -n "$sample_size" $1 > "sample_${2}_${percentage}_${i}.txt"
        	
		#plink2 --pfile $3 --keep "sample_"${2}"_"${percentage}"_"${i}".txt" --make-pgen pvar-cols=xheader,qual,filter,info --allow-extra-chr --min-ac 1 --geno 0.2 --maf 0.01 --out "rs_"${2}"_"${percentage}"_"${i}"_plink"

		#plink2 --bfile $3 --keep "sample_"${2}"_"${percentage}"_"${i}".txt" --make-pgen --allow-extra-chr --min-ac 1 --geno 0.2 --maf 0.01 --out "rs_"${2}"_"${percentage}"_"${i}"_plink"
		plink2 --bfile $3 --keep "sample_"${2}"_"${percentage}"_"${i}".txt" --make-pgen --allow-extra-chr --min-ac 1 --out "rs_"${2}"_"${percentage}"_"${i}"_plink"


		newsnpfname="Randomisation_${2}_percentage_${percentage}_${i}_biallelic_snps.txt"
		grep -v "^#" "rs_${2}_${percentage}_${i}_plink.pvar" | grep -v "ChrUN" | cut -f3 > $newsnpfname 
		snpcount=`wc -l $newsnpfname`
		rm "rs_${2}_${percentage}_${i}_plink.pvar"
		rm "rs_${2}_${percentage}_${i}_plink.pgen"
		rm "rs_${2}_${percentage}_${i}_plink.psam"
		rm "rs_${2}_${percentage}_${i}_plink.log"
		rm "sample_${2}_${percentage}_${i}.txt"
		echo $percentage $i $snpcount >> $fname
	done
done



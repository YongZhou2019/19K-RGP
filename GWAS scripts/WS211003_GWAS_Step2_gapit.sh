#!/bin/bash
#SBATCH -N 1
#SBATCH --cpus-per-task=36
#SBATCH --partition=batch
#SBATCH -J GWAS
#SBATCH -o GWAS.%J.out
#SBATCH -e GWAS.%J.err
#SBATCH --mail-user=keerthana.manickam@kaust.edu.sa
#SBATCH --mail-type=ALL
#SBATCH --time=100:30:00
#SBATCH --mem=500G

#run the application:
#R
module load plink/1.90b6.24
module load R/4.3.2/gnu-12.2.0 


genome=genome1 ### genome1   ### change Parameter1
TRAIT=13kpanel.txt ###  ### Phenotype, change Parameter2

###set paths;
project=/ibex/scratch/projects/c2028/keerthana/13K/
export Genotype=$project/Genotype/$genome.biallelic.base.genomewide.SNPs.withID.PlinkFormat
export script=$project/GWASresults/Grainlength/$genome/GWAS_scripts
export R=$project/GWASresults/Grainlength/$genome/GWAS_scripts/Rscripts
export QC=$project/GWASresults/Grainlength/$genome/1_QC
export GWASPgapit=$project/GWASresults/Grainlength/$genome/QC4withPC_K
mkdir -p $GWASPgapit

###########################################################
### Association analyses ###
###########################################################
### transfer the format from plink to bed, then to hmp;
plink --bfile $QC/QC4 --export vcf --allow-extra-chr --out $GWASPgapit/QC4
/ibex/scratch/projects/c2028/keerthana/softwares/tassel-5-standalone/run_pipeline.pl -Xms100g -Xmx1000g -vcf $GWASPgapit/QC4.vcf -sortPositions -export $GWASPgapit/QC4.tmp -exportType HapmapDiploid
cat $GWASPgapit/QC4.tmp.hmp.txt | sed -e 's/0_E/E/g' -e 's/#//g' > $GWASPgapit/QC4.hmp.txt
rm $GWASPgapit/QC4.tmp.hmp.txt
sed -i 's/0_IRGC/IRGC/g' $GWASPgapit/QC4.hmp.txt 

#### GWAS   ###
cat /ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/$genome/GWAS_scripts/Rscripts/QC4withPC_K_3000.r | sed "s/PPPPP/$TRAIT/g" > $GWASPgapit/QC4withPC_K.r
cd $GWASPgapit/
export OMP_NUM_THREADS=32
Rscript QC4withPC_K.r

#######To run with QC3 
#plink --bfile $QC/QC3 --export vcf --allow-extra-chr --out $GWASPgapit/QC3
#/ibex/scratch/projects/c2028/keerthana/softwares/tassel-5-standalone/run_pipeline.pl -Xms100g -Xmx1000g -vcf $GWASPgapit/QC3.vcf -sortPositions -export $GWASPgapit/QC3.tmp -exportType HapmapDiploid
#cat $GWASPgapit/QC3.tmp.hmp.txt | sed -e 's/0_E/E/g' -e 's/#//g' > $GWASPgapit/QC3.hmp.txt
#rm $GWASPgapit/QC3.tmp.hmp.txt
#sed -i 's/0_IRGC/IRGC/g' $GWASPgapit/QC3.hmp.txt

#### GWAS   ###
#cat /ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/$genome/GWAS_scripts/Rscripts/QC3withPC_K.r | sed "s/PPPPP/$TRAIT/g" > $GWASPgapit/QC3withPC_K.r
#cd $GWASPgapit/
#export OMP_NUM_THREADS=36
#Rscript QC3withPC_K.r



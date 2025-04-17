#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=batch
#SBATCH -J GWAS
#SBATCH -o GWAS.%J.out
#SBATCH -e GWAS.%J.err
#SBATCH --mail-user=keerthana.manickam@kaust.edu.sa
#SBATCH --mail-type=ALL
#SBATCH --time=10:30:00
#SBATCH -c 32
#SBATCH --mem=100G

#run the application:
#R

module load R/4.3.2/gnu-12.2.0 
module load plink/1.90b6.24

###===============================
### gwas pipeline 1, plink/tassel/gapit; used in work station;
### Yong;
### Data: 2021-10-03
###===============================

###===============================
genome=genome1  ### change Parameter1

###set paths;
project=/ibex/scratch/projects/c2028/keerthana/13K/
export Genotype=$project/Genotype/$genome.biallelic.base.genomewide.SNPs.withID.PlinkFormat
export script=$project/GWASresults/Grainlength/$genome/GWAS_scripts
export R=$project/GWASresults/Grainlength/$genome/GWAS_scripts/Rscripts
export QC=$project/GWASresults/Grainlength/$genome/1_QC_5000_10

mkdir -p $QC

###===============================
# Investigate missingness per individual and per SNP and make histograms. 
# output: plink.imiss and plink.lmiss, these files show respectively the proportion of missing SNPs per individual and the proportion of missing individuals per SNP.

## Step1 - generate genotype based on phenotype list
POPname=13kpanel
plink --bfile $Genotype --allow-extra-chr --keep $project/Genotype/Grainlength/$POPname.txt --make-bed --out $QC/QC1

##### To run for different number of samples with randomization 
##shuf -n 5000 $project/Genotype/Grainlength/13kpanel.txt > $QC/5000samples.txt
##plink --bfile $Genotype --allow-extra-chr --keep $QC/5000samples.txt --make-bed --out $QC/QC1

cd $QC/

## Step2 - Check genotype missing

plink --bfile $QC/QC1 --allow-extra-chr  --missing --out $QC/Genotype.missing

# Generate plots to visualize the missingness results.
cp $R/hist_miss.R $R/hist_miss2.R $R/hist_miss3.R $R/MAF_check.R $R/MAF_check2.R $R/check_heterozygosity_rate.R $R/check_heterozygosity_rate2.R $R/heterozygosity_outliers_list.R ./
Rscript --no-save hist_miss.R


## Step3 - Delete SNPs with missingness >0.2.

plink --bfile $QC/QC1 --allow-extra-chr  --geno 0.2 --make-bed --out $QC/QC2
plink --bfile $QC/QC2 --allow-extra-chr  --missing --out $QC/QC2.missing   ### need to do this again because, the genotype changed;
Rscript --no-save $R/hist_miss3.R

# Generate a plot of the MAF distribution.
plink --bfile $QC/QC2 --allow-extra-chr  --freq --out $QC/QC2.MAF_check
Rscript --no-save MAF_check.R

## Step4 - Remove SNPs with a low MAF frequency. # A conventional MAF threshold for a regular GWAS is between 0.01 or 0.05, depending on sample size.
plink --bfile $QC/QC2 --allow-extra-chr  --maf 0.05 --make-bed --out $QC/QC3
plink --bfile $QC/QC3 --allow-extra-chr  --freq --out $QC/QC3.MAF_check
Rscript --no-save MAF_check2.R

############################################################
### Step5 - LD prune

plink --bfile  $QC/QC3 --allow-extra-chr  --indep-pairwise 25Kb 1 0.8  --out $QC/QC4
plink --bfile $QC/QC3 --allow-extra-chr --extract $QC/QC4.prune.in --make-bed --out $QC/QC4

plink --bfile $QC/QC4 --allow-extra-chr  --missing --out $QC/QC4.missing   ### need to do this again because, the genotype changed;
Rscript --no-save $R/hist_miss4.R

plink --bfile $QC/QC4 --allow-extra-chr  --freq --out $QC/QC4.MAF_check
Rscript --no-save $R/MAF_check4.R


############################################################
# CONGRATULATIONS!! You've just succesfully completed the first tutorial! You are now able to conduct a proper genetic QC.



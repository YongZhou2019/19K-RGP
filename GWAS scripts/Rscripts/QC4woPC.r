library(multtest)
library(gplots)
library(genetics)
library(MASS)
library(compiler) #thislibraryisalreadyinstalledinR
library("scatterplot3d")

source("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/GWAS_scripts/gapit_functions.txt")
source("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/GWAS_scripts/emma.txt")


myY<-read.table("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/Phenotype/Collab_Grainlength/Grainlength.txt",head=TRUE)
myG<-read.table("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/QC4woPC/QC4.hmp.txt",head=FALSE)

#Step 2: Run GAPIT

myGAPIT <- GAPIT(
Y=myY,
G=myG,
)

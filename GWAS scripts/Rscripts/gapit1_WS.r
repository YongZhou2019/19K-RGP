#setwd("C:/Users/Administrator/Desktop/10kd_GWAS_ZY20170823/GAPIT_CAU_20170823/10kd_without_27kd_0")
library(multtest)
library(gplots)
# library(LDheatmap)
library(genetics)
library(MASS)
library(compiler) #thislibraryisalreadyinstalledinR
library("scatterplot3d")
#source("http://zzlab.net/GAPIT/gapit_functions.txt")
#source("http://zzlab.net/GAPIT/emma.txt")

source("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/GWAS_scripts/gapit_functions.txt")
source("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/GWAS_scripts/emma.txt")

##setwd("c:/users/toshiba/desktop/gapit6")

myY<-read.table("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/Phenotype/Final_Grainlength/3kpanel.txt",head=TRUE)
myG<-read.table("/ibex/scratch/projects/c2028/keerthana/Magic16_Gwas/SNPs/GWASresults/Grainlength/excluded_genome1/3kpanel/3_GWASPgapit/QC4.hmp.txt",head=FALSE)

#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3
)

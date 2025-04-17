library(multtest)
library(gplots)
library(genetics)
library(MASS)
library(compiler) #thislibraryisalreadyinstalledinR
library("scatterplot3d")

source("/ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/genome1/GWAS_scripts/gapit_functions.txt")
source("/ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/genome1/GWAS_scripts/emma.txt")


myY<-read.table("/ibex/scratch/projects/c2028/keerthana/13K/Phenotype/GRLT.txt",head=TRUE)
myG<-read.table("/ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/genome1/QC4withPC/QC4.hmp.txt",head=FALSE)

#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3)


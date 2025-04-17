library(multtest)
library(gplots)
library(genetics)
library(MASS)
library(compiler) #thislibraryisalreadyinstalledinR
library("scatterplot3d")


source("http://zzlab.net/GAPIT/gapit_functions.txt")
source("http://zzlab.net/GAPIT/emma.txt")


myY<-read.table("/ibex/scratch/projects/c2028/keerthana/13K/Phenotype/GRLT.txt",head=TRUE)
myG<-read.table("/ibex/scratch/projects/c2028/keerthana/13K/GWASresults/Grainlength/genome1/QC3withPC_K/QC3.hmp.txt",head=FALSE)

#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3,
kinship.cluster=c("average", "complete", "ward"),
kinship.group=c("Mean", "Max")
)

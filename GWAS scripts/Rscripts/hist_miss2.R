indmiss<-read.table(file="QC1.missing.imiss", header=TRUE)
snpmiss<-read.table(file="QC1.missing.lmiss", header=TRUE)
# read data into R 

pdf("QC1.missing.imiss.pdf") #indicates pdf format and gives title to file
hist(indmiss[,6],main="Histogram individual missingness") #selects column 6, names header of file

pdf("QC1.missing.lmiss.pdf") 
hist(snpmiss[,5],main="Histogram SNP missingness")  
dev.off() # shuts down the current device

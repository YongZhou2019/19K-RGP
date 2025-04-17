indmiss<-read.table(file="PRUNEIN.missing.imiss", header=TRUE)
snpmiss<-read.table(file="PRUNEIN.missing.lmiss", header=TRUE)
# read data into R 

pdf("PRUNEIN.missing.imiss.pdf") #indicates pdf format and gives title to file
hist(indmiss[,6],main="Histogram individual missingness") #selects column 6, names header of file
dev.off() # shuts down the current device

pdf("PRUNEIN.missing.lmiss.pdf") 
hist(snpmiss[,5],main="Histogram SNP missingness")  
dev.off() # shuts down the current device

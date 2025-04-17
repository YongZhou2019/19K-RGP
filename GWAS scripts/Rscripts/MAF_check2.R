maf_freq <- read.table("QC3.MAF_check.frq", header =TRUE, as.is=T)
pdf("QC3.MAF_distribution.pdf")
hist(maf_freq[,5],main = "MAF distribution", xlab = "MAF")
dev.off()

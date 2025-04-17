# install.packages("qqman",repos="http://cran.cnr.berkeley.edu/",lib="~" ) # location of installation can be changed but has to correspond with the library location 
library(qqman)  
results_log <- read.table("genomeNNNN.plink.qassoc", head=TRUE)
# pdf("manhattan_genomeNNNN.assoc.linear.pdf", width = 6, height = 6)
jpeg("manhattan_genomeNNNN.plink.qassoc.jpeg")
manhattan(results_log,chr="CHR",bp="BP",p="P",snp="SNP", main = "Manhattan plot: logistic")
dev.off()

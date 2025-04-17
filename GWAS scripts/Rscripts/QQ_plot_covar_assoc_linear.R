# install.packages("qqman",repos="http://cran.cnr.berkeley.edu/",lib="~" ) # location of installation can be changed but has to correspond with the library location 
library(qqman)  #library("qqman",lib.loc="~") 
results_log <- read.table("genomeNNNN.plink_covar.assoc.linear", head=TRUE)
# pdf("QQ-Plot_genomeNNNN.assoc.linear.pdf", width = 6, height = 6)
jpeg("QQ-Plot_genomeNNNN.plink_covar.assoc.linear.jpeg")
qq(results_log$P, main = "Q-Q plot of GWAS p-values : log")
dev.off()

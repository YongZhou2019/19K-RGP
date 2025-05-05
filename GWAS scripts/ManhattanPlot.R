# To plot using qqman
install.packages("qqman")
library(qqman)

file.choose()

gwasResults <- read.csv("/Users/manickk/Desktop/13K/GWAS/GRLT/5000/GAPIT.Association.GWAS_Results.MLM.GRLT.csv",sep=",")
colnames(gwasResults)

png("/Users/manickk/Desktop/13K/GWAS/GRLT/5000/manhattanplot.png", width = 800, height = 400)
manhattan(gwasResults, main="Manhattan Plot",
          chr = "Chr",
          bp = "Pos",
          p = "P.value",
          snp = "SNP",
          col = c("#4197d8","#f8c120"),
          ylim= c(0,20),
          suggestiveline = -log10(1.43217E-06),
          genomewideline = FALSE)
print("manhattanplot")
dev.off()

################# for two thresholds   ########################
library(qqman)
# Read the GWAS results CSV file
gwasResults <- read.csv("/Users/manickk/Desktop/New/GWAS_results/genome1/nopruning/GAPIT..GRLT.GWAS.Results.csv")

# Define significance thresholds
suggestive_threshold <- 5.905418 # Example suggestive threshold
genome_wide_threshold <- 6.604388
# Set up the output PNG file
png("/Users/manickk/Desktop/New/GWAS_results/genome11/manhattanplot.png", width = 800, height = 400)

# Create the Manhattan plot
manhattan(gwasResults, 
          main = "Manhattan Plot",
          chr = "Chromosome",
          bp = "Position",
          p = "P.value",
          snp = "SNP",
          col = c("#4197d8", "#f8c120"),
          ylim = c(0, 20),
          suggestiveline = suggestive_threshold,
          genomewideline = genome_wide_threshold)

# Print message to console
print("Manhattan plot generated")

# Close the PNG device
dev.off()


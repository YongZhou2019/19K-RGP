#############    To check outliers and distribution analysis for phenotype data   #################### 

############# Step 1:     Merge Pheno and geno fam file    ####################

file.choose()
library(tools)

# Load FAM
fam = read.table("/Users/manickk/Desktop/3K/QC4region/genome1.excluded.fam", stringsAsFactors = FALSE, header = FALSE, comment.char = "")
colnames(fam) = c("FID", "IID", "F", "M", "S", "PHENO")
fam$order = 1:nrow(fam)
rownames(fam) = fam$IID

# Load phenotype dataset
if(file_ext("/Users/manickk/Desktop/3K/QC4region/GRWT/GRWT") != "csv") {
  pheno = read.table("/Users/manickk/Desktop/3K/QC4region/GRWT/PCA_GRWT.txt", stringsAsFactors = FALSE, header = TRUE, comment.char = "")
} else {
  pheno = read.csv("/Users/manickk/Desktop/3K/QC4region/GRWT/PCA_GRWT.txt", stringsAsFactors = FALSE, na.strings = c("NA", "."))
}

# Ensure the first column in the phenotype file is named "ID"
colnames(pheno)[1] = "ID"

# Extract the specific trait (grain_length)
trait = pheno[, c("ID", "GRWT")]

# Remove NA
trait = trait[!is.na(trait[["GRWT"]]), ]

cat("Trait grain_length has ", sum(!is.na(trait[["GRWT"]])), " observations.\n")

# Merge FAM wo the specific trait
fam_ph = merge(fam, trait, by.x = "IID", by.y = "ID", sort = FALSE, all.x = TRUE)
fam_ph$PHENO = fam_ph[["GRWT"]]
fam_ph = fam_ph[order(fam_ph$order), c("FID", "IID", "F", "M", "S", "PHENO")]

out_file <- paste0(file_path_sans_ext("/Users/manickk/Desktop/3K/QC4region/GRWT/g1_GRWT_PCA11.txt"), "wo_fam.txt")
write.table(fam_ph, file = out_file, sep = "\t", row.names = FALSE, col.names = TRUE)

################ Step 2:   QQ plot      ###################

library(car)
qqplot_out_file <- "/Users/manickk/Desktop/3K/QC4region/GRWT/g1_GRWT_PCA11_QQplot.pdf"
# Plotting section
try({
  trait[["GRWT"]] <- as.numeric(trait[["GRWT"]])
  pdf(file = qqplot_out_file, width = 8, height = 7)
  par(cex.axis = 1.5)
  hist(trait[["GRWT"]], 20, col = "#aaccee", xlab = "GRWT", main = "GRWT")
  qqPlot(trait[["GRWT"]], ylab = "GRWT")
  dev.off()
})

######## If any outliers there and to add PCA - control population difference   ########

model = lm( GRWT ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7, data = mydata)

qqPlot( residuals(model))
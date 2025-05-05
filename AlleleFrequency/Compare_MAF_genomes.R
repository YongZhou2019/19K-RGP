#####To combine two genomes MAF

library(ggplot2)
library(dplyr)

genome1 <- read.table("/Users/manickk/Desktop/Chr07/PreciseLocation/G1.maf_csvfile.txt", header=TRUE)
genome6 <- read.table("/Users/manickk/Desktop/Chr07/PreciseLocation/G6.maf_csvfile.txt", header=TRUE)

# Function to categorize MAF into bins for Group 1
categorize_genome1 <- function(genome1) {
  class1 <- genome1 >= 0.01 & genome1 < 0.05
  class2 <- genome1 >= 0.05 & genome1 < 0.1
  class3 <- genome1 >= 0.1 & genome1 < 0.2
  class4 <- genome1 >= 0.2 & genome1 < 0.3
  class5 <- genome1 >= 0.3 & genome1 < 0.4
  class6 <- genome1 >= 0.4 & genome1 <= 0.5
  
  bins <- character(length(genome1))
  bins[class1] <- "Class 1"
  bins[class2] <- "Class 2"
  bins[class3] <- "Class 3"
  bins[class4] <- "Class 4"
  bins[class5] <- "Class 5"
  bins[class6] <- "Class 6"
  return(bins)
}

categorize_genome1()

# Function to categorize MAF into bins for Group 2
categorize_genome6 <- function(genome6) {
  class1 <- genome6 >= 0.01 & genome6 < 0.05
  class2 <- genome6 >= 0.05 & genome6 < 0.1
  class3 <- genome6 >= 0.1 & genome6 < 0.2
  class4 <- genome6 >= 0.2 & genome6 < 0.3
  class5 <- genome6 >= 0.3 & genome6 < 0.4
  class6 <- genome6 >= 0.4 & genome6 <= 0.5
  
  bins <- character(length(genome6))
  bins[class1] <- "Class 1"
  bins[class2] <- "Class 2"
  bins[class3] <- "Class 3"
  bins[class4] <- "Class 4"
  bins[class5] <- "Class 5"
  bins[class6] <- "Class 6"
  return(bins)
}

categorize_genome1(genome1)

# Apply categorization functions to both groups
genome1$MAF_bins <- categorize_genome1(genome1$MAF)
genome6$MAF_bins <- categorize_genome6(genome6$MAF)

# Calculate count of values for each category for Group 1
count_data_genome1 <- genome1 %>%
  group_by(MAF_bins) %>%
  summarize(count = n(), group = "Genome 1")

# Calculate count of values for each category for Group 2
count_data_genome6 <- genome6 %>%
  group_by(MAF_bins) %>%
  summarize(count = n(), group = "Genome 6")

# Combine the count data from both groups
combined_count_data <- rbind(count_data_genome1, count_data_genome6)

# Define the additional range for each class
extrainfo <- c("1-5%", "5-10%", "10-20%", "20-30%", "30-40%", "40-50%")

# Combine the original class names and the additional range
combined_count_data$MAF_bins <- factor(combined_count_data$MAF_bins, levels = c("Class 1", "Class 2", "Class 3", "Class 4", "Class 5", "Class 6"))
new_labels <- paste(levels(combined_count_data$MAF_bins), extrainfo, sep = "\n")

# Plot
ggplot(combined_count_data, aes(x = MAF_bins, y = count, fill = group)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9), alpha = 0.6) +
  geom_text(aes(label = paste("n =", count)), 
            position = position_dodge(width = 0.9), 
            color = "black", size = 5, vjust = -0.5) +
  scale_x_discrete(labels = new_labels) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 12, color = "black"),
    axis.text.y = element_text(size = 12, color = "black"),
    legend.title = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(size = 11),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14)
  ) +
  ggtitle("Bar Plot of Sample Size") +
  xlab("Frequency of Class") +
  ylab("Sample Size") +
  scale_fill_manual(values = c("#00798c", "#ff7f0e"))
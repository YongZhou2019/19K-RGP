# Load required libraries
file.choose()

library(ggplot2)
library(dplyr)
library(tidyverse)
install.packages("hrbrthemes")
install.packages("gdtools")
library(hrbrthemes)
library(viridis)

############################for between MAF value and frequency type

MAF <- read.table("/Users/manickk/Desktop/MAF.txt", header=TRUE)

categorize_MAF <- function(maf) {
    class1 <- maf < 0.0001 
    class2 <- maf >= 0.0001 & maf < 0.01
    class3 <- maf >= 0.01 & maf < 0.05
    class4 <- maf >= 0.05
  
  bins <- character(length(maf))
  bins[class1] <- "Ultra-rare"
  bins[class2] <- "Rare"
  bins[class3] <- "Low Frequency"
  bins[class4] <- "Common"
  return(bins)
}

######################## gg plot ########################

MAF_bins <- categorize_MAF(MAF$MAF)
MAF_bins

# Create a data frame with MAF and corresponding bins
data <- data.frame(MAF = MAF, MAF_bins = MAF_bins)
data

write.table(data, file = "/Users/manickk/Desktop/MAFclass.txt", sep = "\t", row.names = FALSE)

# Calculate count of values for each category
count_data <- data %>%
  group_by(MAF_bins) %>%
  summarize(count = n())
count_data

# Define the additional range for each class
extrainfo <- c("MAF<0.01%", "0.01%<MAF<1%", "1%<MAF<5%", "MAF>5%")

# Define the order of classes for plotting
class_order <- c("Ultra-rare", "Rare", "Low Frequency", "Common")

# Create a factor variable for MAF_bins to ensure correct ordering in the plot
count_data$MAF_bins <- factor(count_data$MAF_bins, levels = class_order)

new_labels <- c(
  "Ultra-rare\nMAF<0.01%", 
  "Rare\n0.01%<MAF<1%", 
  "Low Frequency\n1%<MAF<5%", 
  "Common\nMAF>5%"
)

# Plot
ggplot(count_data, aes(x = MAF_bins, y = count)) +
  geom_bar(stat = "identity", fill = "#00798c", alpha = 0.6) +
  geom_text(aes(label = paste("n =", count)), 
            color = "black", size = 5, vjust = -0.5) +
  scale_x_discrete(labels = new_labels) +  # Set custom axis labels
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 12, color = "black"),
    axis.text.y = element_text(size = 12, color = "black"),
    legend.position = "none",
    plot.title = element_text(size = 11),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14)
  ) +
  ggtitle("Bar Plot of Sample Size") +
  xlab("Frequency of Class") +
  ylab("Sample Size")


######## To do violin plot   ########################
ggplot(count_data, aes(x = MAF_bins, y = count)) +
  geom_violin(fill = "lightblue") +
  labs(x = "Frequency Type", y = "Sample Size") +
  ggtitle("Bar Plot of Sample Size") +
  theme(plot.title = element_text(hjust = 0.5)) +
  # Add text annotations for count of MAF values along x-axis
  scale_x_discrete(labels = summary_stats$label) +
  # Adjust the position of the x-axis labels
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

######## To do violin plot with dots   ########################
ggplot(count_data, aes(x = MAF_bins, y = count)) +
  geom_violin(fill = "lightblue") +
  geom_jitter(aes(color = MAF_bins), width = 0.2, alpha = 0.5) +  # Add jittered points
  labs(x = "Frequency Type", y = "Sample Size") +
  ggtitle("Bar Plot of Sample Size") +
  theme(plot.title = element_text(hjust = 0.5)) +
  # Add text annotations for count of MAF values along x-axis
  scale_x_discrete(labels = summary_stats$label) +
  # Adjust the position of the x-axis labels
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
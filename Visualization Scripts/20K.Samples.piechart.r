### Author(s): Yong Zhou / 2024-12-30

# Load required libraries
library(ggplot2)
#install.packages("svglite")
library(svglite)
# Set working directory (update as needed)
setwd("/Users/yongzhou/Downloads/3/10KRGP/06.Analsysis/02.10K_3K_merge/Piechart")

# Load the data
data <- read.table("20K.piechart.txt", header = TRUE, sep = "\t")

# Calculate percentages for the pie chart
data$Percentage <- round(data$Numbers / sum(data$Numbers) * 100, 1)

# Add labels combining dataset names, numbers, and percentages
data$Label <- paste0(data$Datasets, "\n", data$Numbers, " (", data$Percentage, "%)")

# Generate the pie chart
pie_chart <- ggplot(data, aes(x = "", y = Numbers, fill = Datasets)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  theme_void() +  # Remove all axes and background
  scale_fill_brewer(palette = "Set3") +  # Set a visually pleasing color palette
  labs(
    title = "Datasets Numbers",
    fill = "Datasets"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold")
  ) +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5), size = 4)

# Display the pie chart
print(pie_chart)

# Save the pie chart as SVG, PDF, and PNG (300 dpi)
ggsave("PieChart_Datasets_Numbers.svg", pie_chart, width = 8, height = 8)
ggsave("PieChart_Datasets_Numbers.pdf", pie_chart, width = 8, height = 8)
#ggsave("PieChart_Datasets_Numbers.png", pie_chart, width = 8, height = 8, dpi = 300)

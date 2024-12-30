### Author(s): Yong Zhou / 2024-12-30

# Load required libraries
library(ggplot2)
library(reshape2)  # For data reshaping

# Set working directory (update as needed)
setwd("//Users/yongzhou/Downloads/3/10KRGP/06.Analsysis/02.10K_3K_merge/SequenceCoverage")

# Load the data
data <- read.table("SequenceCoverage.txt", header = TRUE, sep = "\t")

# Reshape the data from wide to long format for ggplot2
data_long <- melt(data, id.vars = "SequenceCoverage", variable.name = "Dataset", value.name = "Count")

# Generate the bar plot with solid box/boundaries
bar_plot <- ggplot(data_long, aes(x = SequenceCoverage, y = Count, fill = Dataset)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "black") +  # Add black borders to bars
  scale_fill_brewer(palette = "Set2") +  # Set a visually pleasing color palette
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5),
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Add solid border around plot
    panel.grid.major = element_line(color = "gray80"),  # Optional: Adjust grid line color
    panel.grid.minor = element_blank()  # Optional: Remove minor grid lines
  ) +
  labs(
    title = "Sequence Coverage Across Datasets",
    x = "Sequence Coverage",
    y = "Count",
    fill = "Dataset"
  )

# Display the plot
print(bar_plot)

# Save the plot as SVG, PDF, and PNG (300 dpi)
#ggsave("SequenceCoverage_BarPlot.svg", bar_plot, width = 10, height = 6)
ggsave("SequenceCoverage_BarPlot.pdf", bar_plot, width = 10, height = 6)
#ggsave("SequenceCoverage_BarPlot.png", bar_plot, width = 10, height = 6, dpi = 300)


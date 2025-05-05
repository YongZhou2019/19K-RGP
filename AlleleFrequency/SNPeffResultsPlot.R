# Load necessary libraries
library(ggplot2)
library(tidyr)

# Create the data frame with count values
data <- data.frame(
  Type = c("HIGH", "LOW", "MODERATE", "MODIFIER"),
  Common = c(121, 3001, 3319, 70425),
  Low = c(27, 1135, 1126, 26644),
  Rare = c(1194, 44694, 42441, 532525),
  Ultra_rare = c(178, 11372, 6939, 75516)
)

# Reshape the data from wide to long format
long_data <- pivot_longer(data, cols = Common:Ultra_rare, names_to = "Category", values_to = "Count")

# Create the bar plot with count values, faceted by Type
ggplot(long_data, aes(x = Category, y = Count, fill = Category)) +
  geom_bar(stat = "identity", position = "stack", width = 0.9) +  # Stack bars with reduced width
  geom_text(aes(label = Count),  # Add count labels
            position = position_stack(vjust = 0.5),  # Position labels in the middle of the bars
            size = 3) +  # Adjust the size of the text
  facet_wrap(~ Type, scales = "free", nrow = 2) +  # Facet by Type, 2 rows for compactness
  theme_minimal() +
  labs(title = "Bar Plot by Category and Type (Count)", x = "Category", y = "Count") +
  theme(
    axis.text.x = element_text(size = 8, angle = 0, hjust = 0.5),  # Smaller text, horizontal alignment
    plot.title = element_text(size = 16, face = "bold"),  # Larger and bold title font
    strip.text = element_text(size = 14, face = "bold"),  # Increase the facet labels (Type names) font size
    panel.spacing = unit(0.5, "lines"),  # Adjust spacing between facets
    plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm")  # Reduce margin around the plot
  )

##################### Percentage   ###############

# Load necessary libraries
library(ggplot2)
library(tidyr)

# Create the data frame with percentage values
data <- data.frame(
  Type = c("HIGH", "LOW", "MODERATE", "MODIFIER"),
  Common = c(0.157417, 3.904197, 4.317904, 91.62),
  Low = c(0.093322, 3.922992, 3.891884, 92.091801),
  Rare = c(0.192316, 7.198794, 6.835907, 85.772984),
  Ultra_rare = c(0.189352, 12.097229, 7.381522, 80.331897)
)

# Reshape the data from wide to long format
long_data <- pivot_longer(data, cols = Common:Ultra_rare, names_to = "Category", values_to = "Percentage")

# Create the bar plot with percentage values
ggplot(long_data, aes(x = Category, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", position = "stack", width = 0.9) + 
  geom_text(aes(label = Percentage),  # Add count labels
            position = position_stack(vjust = 0.5),  # Position labels in the middle of the bars
            size = 3) +  # Adjust the size of the text# Stack bars with reduced width
  facet_wrap(~ Type, scales = "free", nrow = 2) +  # Facet by category, 2 rows for compactness
  theme_minimal() +
  labs(title = "Bar Plot by Type and Category (Percentage)", x = "Type", y = "Percentage (%)") +
  theme(
    axis.text.x = element_text(size = 8, angle = 0, hjust = 0.5),  # Smaller text, horizontal alignment
    plot.title = element_text(size = 16, face = "bold"),  # Larger and bold title font
    strip.text = element_text(size = 12, face = "bold"),  # Increase the facet labels (Category names) font size
    panel.spacing = unit(0.5, "lines"),  # Adjust spacing between facets
    plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm")  # Reduce margin around the plot
  )

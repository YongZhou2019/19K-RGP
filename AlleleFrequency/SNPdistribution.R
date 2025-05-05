####SNP distribution between sub populations 

library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyr)

data_table <- read.table("/Users/manickk/Desktop/Test.txt", header = TRUE)

# Rename the columns
colnames(data_table) <- c("SNP", "Subpop", "0/0", "1/1", "total_count")

# Melt the data frame to long format
data_melted <- melt(data_table, id.vars = c("SNP", "Subpop", "total_count"), variable.name = "Genotype", value.name = "Count")

data_melted <- data_table %>%
  pivot_longer(cols = c(`0/0`, `1/1`), names_to = "Genotype", values_to = "Count") %>%
  mutate(Percentage = Count / total_count * 100)

# Create pie charts
pie_charts <- ggplot(data_melted, aes(x = "", y = Percentage, fill = Genotype)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  facet_grid(SNP ~ Subpop) +
  scale_fill_manual(values = c("0/0" = "orange", "1/1" = "blue")) +
  theme_void() +
  theme(
    legend.position = "bottom",
    strip.text.x = element_text(size = 9, face = "bold"),
    strip.text.y = element_text(size = 10, face = "bold"), # Adjust the size as needed
    plot.title = element_text(size = 16, hjust = 0.5, vjust = 8)  # Adjust the title position as needed
  ) +
  labs(fill = "Genotype") +
  ggtitle("Chromosome 7 leading SNP distribution across subpopulations")  # Add a title here

# Print the pie charts
print(pie_charts)

pie_charts <- ggplot(data_melted, aes(x = "", y = Percentage, fill = Genotype)) +
  geom_bar(stat = "identity", width = 1, color = "black") +  # Add color aesthetic for outline
  coord_polar("y", start = 0) +
  facet_grid(SNP ~ Subpop) +
  scale_fill_manual(values = c("0/0" = "orange", "1/1" = "blue")) +
  theme_void() +
  theme(
    legend.position = "bottom",
    strip.text.x = element_text(size = 9, face = "bold"),
    strip.text.y = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 16, hjust = 0.5, vjust = 8)
  ) +
  labs(fill = "Genotype") +
  ggtitle("Chromosome 7 leading SNP distribution across subpopulations")

# Print the pie charts
print(pie_charts)
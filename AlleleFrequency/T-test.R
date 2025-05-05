#######       Do t-test 

MAF <- read.table("/Users/manickk/Desktop/AlleleFreq_GLgenes/MAF.txt", header=TRUE)

ultra_rare_threshold <- 0.0001  
rare_threshold <- 0.01         
low_frequency_threshold <- 0.05 

categorize_MAF <- function(maf) {
  ultra_rare <- maf <= ultra_rare_threshold
  rare <- maf > ultra_rare_threshold & maf < rare_threshold
  low_frequency <- maf >= rare_threshold & maf <= low_frequency_threshold
  common <- maf > low_frequency_threshold
  bins <- character(length(maf))
  bins[ultra_rare] <- "Ultra-rare"
  bins[rare] <- "Rare"
  bins[low_frequency] <- "Low frequency"
  bins[common] <- "Common"
  return(bins)
}

MAF_bins <- sapply(MAF, categorize_MAF)

# Create a data frame with MAF and corresponding bins
data <- data.frame(MAF = MAF, MAF_bins = MAF_bins)

# Split the data into separate groups based on the class
data_list <- split(data$MAF.1, data$MAF)

data_list <- split(data$MAF, data$MAF.1)

data_list

# Initialize an empty data frame to store results
results <- data.frame(Group1 = character(), Group2 = character(), P_Value = numeric(), Significance = character())

# Perform pairwise t-tests
n_groups <- length(data_list)
for (i in 1:(n_groups - 1)) {
  for (j in (i + 1):n_groups) {
    # Perform error handling for potential missing or non-numeric values
    tryCatch({
      t_result <- t.test(data_list[[i]], data_list[[j]])
      if (t_result$p.value < 0.001) {
        significance <- "***"
      } else if (t_result$p.value < 0.01) {
        significance <- "**"
      } else if (t_result$p.value < 0.05) {
        significance <- "*"
      } else {
        significance <- "ns"
      }
      results <- rbind(results, data.frame(Group1 = names(data_list)[i], Group2 = names(data_list)[j], P_Value = t_result$p.value, Significance = significance))
    }, error = function(e) {
      cat("Error occurred during t-test for groups", names(data_list)[i], "and", names(data_list)[j], ":", conditionMessage(e), "\n")
    })
  }
}

# Print the results
print(results)

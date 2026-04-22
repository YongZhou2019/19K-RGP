#!/usr/bin/env Rscript

#
# 文件名: heatmap_chromosome_split.R
#
# 功能: 读取已按亚群分割的 SNP 祖源文件 (例如 cBas-1A.txt, cB-2.txt)，
#       合并数据，并用 ComplexHeatmap 绘制热图。
#       (版本3: 自动从文件名推断亚群)
#

# 1. 加载所需包
suppressPackageStartupMessages({
  library(argparse)
  library(data.table)
  library(ComplexHeatmap)
  library(RColorBrewer)
  library(tidyverse) # 主要用于 join、replace_na, mutate
  library(tools)     # 用于 file_path_sans_ext
})

ht_opt$message = FALSE  # 关闭 ComplexHeatmap 的提示信息

# 2. 命令行参数
parser <- ArgumentParser(description = "使用 ComplexHeatmap 绘制染色体热图 (数据已按亚群分割)。")
parser$add_argument("-i", "--input", required = TRUE, 
                    help = "输入目录，包含多个亚群的 .txt 文件 (例如 ./chr1/output/)。")
# 移除了 -s 参数
parser$add_argument("-n", "--ancestry_names", required = TRUE, 
                    help = "祖源名称，逗号分隔 (与数字代码 1,2,3... 对应)。")
parser$add_argument("-o", "--output", required = TRUE, 
                    help = "输出图像文件名 (例如: chr3_heatmap.png)。")
parser$add_argument("-t", "--title", type = "character", default = "Chromosome Ancestry", 
                    help = "【可选】图表标题。")

args <- parser$parse_args()

# 3. 定义颜色方案
cat("步骤 1/6: 定义颜色方案...\n")
ancestry_colors_db <- c(
  "cAus" = "#DAA520", "XI_indica" = "#f47983",
  "GJ_temp" = "#4682B4", "GJ_trop" = "#1E90FF", "GJ"="#4682B4",
  "Niv1" = "#8FBC8F", "Niv2" = "#2E8B57",
  "Ruf1" = "#FF6347", "Ruf2" = "#B22222",
  "Unknown" = '#D3D3D3'
)
user_anc_names <- str_split(args$ancestry_names, ",")[[1]] %>% str_trim()
all_plot_names <- unique(c(user_anc_names, "Unknown"))

plot_colors <- ancestry_colors_db[names(ancestry_colors_db) %in% all_plot_names]
for (name in all_plot_names) {
  if (!name %in% names(plot_colors)) {
    plot_colors[name] <- "#808080"
    if (name != "Unknown") {
      cat(paste0("警告: 祖源 '", name, "' 在预设颜色库中未找到，已分配灰色。\n"))
    }
  }
}

# 4. 读取并合并数据 (data.table) - [修改]
cat("步骤 2/6: 读取并合并数据...\n")
files_to_read <- list.files(path = args$input, pattern = "\\.txt$", full.names = TRUE)
if (length(files_to_read) == 0) stop("错误: 输入目录中没有找到 .txt 文件。")

# 从文件名获取亚群名称
subpop_names <- tools::file_path_sans_ext(basename(files_to_read))

data_list <- list()
sample_to_subpop_list <- list() # 用于构建我们自己的亚群归属 data.frame

# 循环读取所有文件，同时构建数据列表和样本归属列表
for (i in seq_along(files_to_read)) {
  file <- files_to_read[i]
  subpop_name <- subpop_names[i]
  
  cat(sprintf("  正在读取: %s (亚群: %s)\n", basename(file), subpop_name))
  
  tryCatch({
    df_dt <- fread(file, header = TRUE, sep = "\t")
    
    if (ncol(df_dt) < 2) {
       warning(paste0("文件 '", basename(file), "' 列数不足 (<2)，已跳过。"))
       next
    }
    
    setnames(df_dt, trimws(colnames(df_dt)))
    if (anyDuplicated(colnames(df_dt))) {
      stop(paste0("文件 '", basename(file), "' 存在重复列名。"))
    }
    
    sample_ids <- df_dt[[1]] # 从第一列获取样本 ID
    
    # 1. 为样本注释构建映射
    sample_to_subpop_list[[i]] <- data.table(SampleID = sample_ids, Subpop = subpop_name)
    
    # 2. 为热图数据准备 data frame
    df_frame <- as.data.frame(df_dt)
    rownames(df_frame) <- df_frame[[1]]
    df_frame[[1]] <- NULL
    data_list[[i]] <- df_frame
    
  }, error = function(e) {
     warning(paste0("读取文件 '", basename(file), "' 时出错: ", e$message, "，已跳过。"))
  })
}

if (length(data_list) == 0) {
  stop("错误: 目录中所有 .txt 文件均无法读取或为空。")
}

# (!! 关键 !!) 从我们收集的列表中创建 subpop_df
subpop_df <- rbindlist(sample_to_subpop_list)

# (!! 
# (!! 以下逻辑与原脚本相同 !!)
# (!! 
# (!! 
# 寻找所有文件中的共同 SNP 位点
common_snps <- Reduce(intersect, lapply(data_list, colnames))
if (length(common_snps) == 0) stop("错误: 所有亚群文件之间没有找到共同 SNP 位点。")
cat(sprintf("在所有文件中找到了 %d 个共同的 SNP 位点。\n", length(common_snps)))

# 排序
snum <- suppressWarnings(as.numeric(common_snps))
if (all(is.na(snum))) {
  snum2 <- as.numeric(gsub("[^0-9]", "", common_snps))
  if (any(is.na(snum2))) {
    stop("错误: 共同列名无法解析为数字，请检查文件。")
  }
  common_snps_sorted <- common_snps[order(snum2)]
} else {
  common_snps_sorted <- common_snps[order(snum, na.last = TRUE)]
}

# 筛选 + 合并
data_list_filtered <- lapply(seq_along(data_list), function(i) {
  df <- data_list[[i]]
  missing <- setdiff(common_snps_sorted, colnames(df))
  if (length(missing) > 0) {
    stop(paste0("文件 (亚群 ", subpop_names[i], ") 缺少列: ",
                paste(head(missing, 6), collapse = ", "), " ..."))
  }
  df[, common_snps_sorted, drop = FALSE]
})
ancestry_raw <- rbindlist(data_list_filtered, use.names = TRUE, fill = FALSE)
ancestry_raw <- as.data.frame(ancestry_raw)
rownames(ancestry_raw) <- unlist(lapply(data_list_filtered, rownames))
ancestry_raw <- ancestry_raw[, order(as.numeric(colnames(ancestry_raw))), drop = FALSE]

# 5. 映射祖源代码
cat("步骤 3/6: 映射祖源代码到名称...\n")
name_map <- c("Unknown", user_anc_names)
ancestry_int_matrix <- as.matrix(ancestry_raw)
mode(ancestry_int_matrix) <- "integer"
ancestry_named <- matrix(
  name_map[ancestry_int_matrix + 1],
  nrow = nrow(ancestry_int_matrix),
  dimnames = dimnames(ancestry_int_matrix)
)
if (any(is.na(ancestry_named))) {
  warning("警告: 有些祖源代码无法映射，请检查 -n 参数。")
}

# 6. 样本注释 - [修改]
cat("步骤 4/6: 准备样本注释...\n")
# (!! 移除 !!): subpop_df <- fread(args$subpop, header = FALSE, sep = "\t")
# (!! 移除 !!): colnames(subpop_df) <- c("SampleID", "Subpop")
# 我们在步骤 4 中已经创建了 subpop_df

# (!! 
# (!! 
# (!! 
# (!! 以下逻辑与原脚本相同 !!)
# (!! 
# (!! 
# 定义亚群的特定排序
custom_subpop_order <- c(
  "Rayada", "cA",
  "XI", "adm"
)

# 1. 先进行连接和替换 NA
sample_info_raw <- tibble(SampleID = rownames(ancestry_named)) %>%
  left_join(subpop_df, by = "SampleID") %>% # (!! 使用我们在步骤4中创建的 subpop_df !!)
  replace_na(list(Subpop = "Unassigned"))

# 2. 找出所有在数据中但不在自定义列表中的亚群
all_subpops_in_data <- unique(sample_info_raw$Subpop)
other_subpops <- setdiff(all_subpops_in_data, custom_subpop_order)

# 3. 对这些 "其他" 亚群进行排序，确保 "Unassigned" 始终在最后
other_subpops_sorted <- other_subpops[other_subpops != "Unassigned"]
if ("Unassigned" %in% other_subpops) {
  other_subpops_sorted <- c(sort(other_subpops_sorted), "Unassigned")
} else {
  other_subpops_sorted <- sort(other_subpops_sorted)
}

# 4. 合并为最终的因子水平 (自定义顺序优先，然后是其他)
final_subpop_levels <- c(custom_subpop_order, other_subpops_sorted)

# 5. 应用因子水平并排序
sample_info <- sample_info_raw %>%
  mutate(Subpop = factor(Subpop, levels = final_subpop_levels)) %>%
  arrange(Subpop, SampleID) # 现在会按照因子的level排序

ancestry_sorted <- ancestry_named[sample_info$SampleID, ]

# (!! 以下逻辑与原脚本相同 !!)
subpop_annotation_data <- sample_info$Subpop
names(subpop_annotation_data) <- sample_info$SampleID

unique_subpops <- levels(subpop_annotation_data)
unique_subpops_present <- unique_subpops[unique_subpops %in% all_subpops_in_data] 

num_colors_needed <- max(3, length(unique_subpops_present))
subpop_colors <- colorRampPalette(brewer.pal(min(8, num_colors_needed), "Set2"))(length(unique_subpops_present))
names(subpop_colors) <- unique_subpops_present

left_ha <- rowAnnotation(
  Subpop = subpop_annotation_data,
  col = list(Subpop = subpop_colors),
  width = unit(0.7, "cm"),
  annotation_legend_param = list(
    title = "Sub-population",
    title_gp = gpar(fontsize = 14),
    labels_gp = gpar(fontsize = 12),
    at = unique_subpops_present
  )
)

# 7. X轴坐标
cat("步骤 5/6: 准备自定义X轴...\n")
positions <- as.numeric(colnames(ancestry_sorted))
min_pos <- min(positions); max_pos <- max(positions)
# --- 修改: 恢复 0.5Mb (5e5) 刻度 ---
tick_by <- 5e5 # 0.5Mb
tick_pos_bp <- seq(from = floor(min_pos / tick_by) * tick_by,
                   to = ceiling(max_pos / tick_by) * tick_by,
                   by = tick_by)
tick_pos_bp <- tick_pos_bp[tick_pos_bp >= min_pos & tick_pos_bp <= max_pos]
if (length(tick_pos_bp) < 2) tick_pos_bp <- c(min_pos, max_pos)
# 移除之前确保首尾的逻辑，恢复为原始 0.5Mb 逻辑
# tick_pos_bp <- unique(c(min_pos, tick_pos_bp, max_pos))
# tick_pos_bp <- sort(tick_pos_bp)
at_indices <- sapply(tick_pos_bp, function(p) which.min(abs(positions - p)))
labels_mb <- paste0(round(positions[at_indices] / 1e6, 2)) # 修改: 保留2位小数 (e.g., 0.5, 1.0, 1.5)
# --- 修改结束 ---

bottom_ha <- HeatmapAnnotation(
  "Position (Mb)" = anno_mark(
    at = at_indices,
    labels = labels_mb,
    labels_gp = gpar(fontsize = 12),
    side = "bottom"
  )
)

# 8. 绘图
cat("步骤 6/6: 绘制热图...\n")
ht <- Heatmap(
  ancestry_sorted,
  name = "Ancestry",
  col = plot_colors,
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  show_row_names = FALSE,
  show_column_names = FALSE,
  heatmap_legend_param = list(
    title = "Inferred Ancestry",
    title_gp = gpar(fontsize = 14),
    labels_gp = gpar(fontsize = 12),
    at = all_plot_names[all_plot_names %in% names(plot_colors)]
  ),
  left_annotation = left_ha,
  bottom_annotation = bottom_ha
)

png(args$output, width = 16, height = 10, units = "in", res = 500)
draw(ht, column_title = args$title, column_title_gp = gpar(fontsize = 20, fontface = "bold"))
dev.off()

cat(paste0("\n图表已保存到: ", args$output, "\n"))

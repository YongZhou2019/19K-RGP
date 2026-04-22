#!/bin/bash

# Title: batch_convert_elai.sh
# Description: This script automates the conversion of ELAI output files
#              (.ps21.txt and .snpinfo.txt) into a heatmap-ready matrix format.
#              It iterates through all directories starting with 'chr', and for each,
#              processes the results for a predefined list of admixed groups.
# Author: Wen Zhao

# --- Configuration ---

# 脚本在遇到任何错误时立即退出
set -e

# 定义要调用的 Python 转换脚本的路径
# 请确保此路径是正确的
PYTHON_SCRIPT_PATH="../convert_elai_to_heatmap.py"

# 定义需要处理的混合群体列表
ADMIXED_GROUPS=("Rayada" "cA" "XI" "adm")

# 定义传递给 Python 脚本的祖先源名称列表
# 这个列表必须与您运行 ELAI 时使用的源群体一致
ANCESTOR_NAMES="cAus,XI_indica,GJ,Ruf1,Ruf2,Niv1,Niv2"

# --- Main Logic ---

echo "--- 开始批量转换 ELAI 结果为热图格式 ---"

# 1. 查找并遍历当前目录下所有以 'chr' 开头的文件夹
for chr_dir in Chr*/; do
    # 检查找到的是否确实是一个目录
    if [ -d "$chr_dir" ]; then
        # 移除变量末尾的斜杠，使名称更整洁
        chr_dir=${chr_dir%/}
        echo "================================================="
        echo "正在处理染色体目录: $chr_dir"
        
        # 2. 进入染色体目录
        cd "$chr_dir"

        # 3. 创建用于存放本次转换结果的输出目录
        mkdir -p "output"
        echo "  -> 已创建输出目录: ${chr_dir}/output/"

        # 4. 遍历预定义的混合群体列表
        for group in "${ADMIXED_GROUPS[@]}"; do
            echo "    -> 正在处理混合群体: $group"

            # 根据目录和群体名称构建文件前缀
            # (例如: chr1 和 cB-1 -> chr1-cB-1)
            file_prefix="${chr_dir}-${group}"

            # 定义输入文件的路径
            # (例如: cB-1/output/chr1-cB-1.snpinfo.txt)
            input_subdir="${group}/output"
            snpinfo_file="${input_subdir}/${file_prefix}.snpinfo.txt"
            ps21_file="${input_subdir}/${file_prefix}.ps21.txt"

            # 定义输出文件的路径
            # (例如: output/cB-1.txt)
            output_file="output/${group}.txt"

            # 检查所需的输入文件是否存在
            if [ -f "$snpinfo_file" ] && [ -f "$ps21_file" ]; then
                echo "      -> 找到输入文件，开始转换..."
                
                # 5. 调用 Python 脚本执行转换
                python "$PYTHON_SCRIPT_PATH" \
                    -p "$snpinfo_file" \
                    -f "$ps21_file" \
                    -n "$ANCESTOR_NAMES" \
                    -o "$output_file"
                
                echo "      -> 转换完成！结果已保存至: ${chr_dir}/${output_file}"
            else
                # 如果文件不存在，则打印警告并跳过
                echo "      -> 警告: 未能找到输入文件，跳过此群体。"
                echo "         (Searched for: ${chr_dir}/${snpinfo_file})"
            fi
        done

	cd output
	#bash ../../create_subpop_mapping.sh

        # 6. 返回到上级目录，准备处理下一个染色体
        cd ../..
        echo "处理完成: $chr_dir"
        echo "================================================="
        echo ""
    fi
done

echo "--- 所有染色体目录均已处理完毕 ---"


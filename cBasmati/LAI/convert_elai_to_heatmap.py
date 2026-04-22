#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import sys
import os

def process_elai_output(snpinfo_path, ancestryfile_path, ancestor_names_str, output_path):
    """
    Processes ELAI output files and converts them into a heatmap-ready text format.

    Args:
        snpinfo_path (str): Path to the .snpinfo.txt file.
        ancestryfile_path (str): Path to the .ps21.txt file.
        ancestor_names_str (str): Comma-separated string of ancestor names.
        output_path (str): Path for the output .txt file.
    """
    print("--- 步骤 1: 解析参数和加载 SNP 位置信息 ---")
    
    # 解析祖先名称
    try:
        ancestor_names = [name.strip() for name in ancestor_names_str.split(',')]
        num_ancestors = len(ancestor_names)
        if num_ancestors == 0:
            raise ValueError
        print("-> 识别到 {} 个祖先源: {}".format(num_ancestors, ", ".join(ancestor_names)))
    except (ValueError, IndexError):
        print("错误: 祖先名称列表 '-n' 格式不正确或为空。请提供一个用逗号分隔的列表。")
        sys.exit(1)

    # ★★★ 新增: 创建从祖先名称到数字代号的映射 ★★★
    # "Unknown" -> "0", 第一个祖先 -> "1", ...
    name_to_int_map = {"Unknown": "0"}
    for i, name in enumerate(ancestor_names):
        name_to_int_map[name] = str(i + 1)
    print("-> 已创建祖先到数字的映射。")

    # 读取 SNP 位置信息
    snp_positions = []
    try:
        with open(snpinfo_path, 'r') as f:
            next(f)  # 跳过表头
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    snp_positions.append(parts[1])
        print("-> 成功从 '{}' 加载了 {} 个 SNP 位置。".format(snpinfo_path, len(snp_positions)))
    except IOError:
        print("错误: 无法打开或读取 SNP 信息文件: {}".format(snpinfo_path))
        sys.exit(1)

    print("\n--- 步骤 2: 逐行处理祖先概率文件并写入输出 ---")
    
    # ★★★ 新增: 从输出文件名获取前缀，用于生成样本名 ★★★
    output_prefix = os.path.splitext(os.path.basename(output_path))[0]
    
    try:
        with open(ancestryfile_path, 'r') as infile, open(output_path, 'w') as outfile:
            # ★★★ 修改: 写入新的表头，增加 "Sample" 列 ★★★
            outfile.write("Sample\t" + "\t".join(snp_positions) + "\n")
            
            haplotype_count = 0
            for line in infile:
                haplotype_count += 1
                
                # 为当前行生成唯一的样本名
                sample_name = "{}_{}".format(output_prefix, haplotype_count)
                
                probabilities = [float(p) for p in line.strip().split()]
                
                if len(probabilities) != len(snp_positions) * num_ancestors:
                    print("\n错误: 在第 {} 行，概率值数量 ({}) 与预期的 SNP*祖先 数量 ({}) 不匹配。".format(
                        haplotype_count, len(probabilities), len(snp_positions) * num_ancestors
                    ))
                    print("请检查您的祖先名称列表是否正确。")
                    sys.exit(1)

                numeric_assignments = []
                # 以 n (祖先数) 为步长遍历概率列表
                for i in range(0, len(probabilities), num_ancestors):
                    prob_chunk = probabilities[i:i + num_ancestors]
                    
                    max_prob = -1.0
                    max_idx = -1
                    for idx, prob in enumerate(prob_chunk):
                        if prob > max_prob:
                            max_prob = prob
                            max_idx = idx
                            
                    # ★★★ 修改: 根据逻辑分配数字代号 ★★★
                    if max_prob > 0.75:
                        assigned_name = ancestor_names[max_idx]
                        numeric_assignments.append(name_to_int_map[assigned_name])
                    else:
                        numeric_assignments.append(name_to_int_map["Unknown"])
                
                # ★★★ 修改: 写入样本名和数字代号 ★★★
                outfile.write(sample_name + "\t" + "\t".join(numeric_assignments) + "\n")
                
                if haplotype_count % 20 == 0:
                    sys.stdout.write("\r-> 已处理 {} 个单倍型...".format(haplotype_count))
                    sys.stdout.flush()

            print("\n-> 处理完成！共处理 {} 个单倍型。".format(haplotype_count))
            print("\n--- 步骤 3: 完成 ---")
            print("结果已成功保存至: {}".format(output_path))

    except IOError:
        print("错误: 无法打开或读取祖先概率文件: {}".format(ancestryfile_path))
        sys.exit(1)
    except Exception as e:
        print("\n处理过程中发生未知错误: {}".format(e))
        sys.exit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="将 ELAI 输出文件 (.ps21.txt 和 .snpinfo.txt) 转换为带有样本列和数字代号的热图格式文本文件。",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('-p', '--snpinfo', type=str, required=True,
                        help="ELAI 输出的 .snpinfo.txt 文件路径。")
    parser.add_argument('-f', '--ancestryfile', type=str, required=True,
                        help="包含祖先概率的 .ps21.txt 文件路径。")
    parser.add_argument('-n', '--ancestornames', type=str, required=True,
                        help="与 ELAI 分析时顺序一致的、用逗号分隔的祖先源名称列表。\n例如: 'cAus,XI_indica,GJ,Ruf1,Ruf2,Niv1,Niv2'")
    parser.add_argument('-o', '--output', type=str, required=True,
                        help="输出的 .txt 文件名。")

    args = parser.parse_args()

    process_elai_output(args.snpinfo, args.ancestryfile, args.ancestornames, args.output)



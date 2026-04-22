#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
描述:
统计12个染色体（chr1-chr12）和三个亚群（cB-1, cB-2, cB-3）的祖源信息。
计算染色体水平和全基因组水平的祖源占比。

输入文件格式 (例如 ./chr1/output/cB-1.txt):
Sample  1240    1266    1268
cB-2_1  3       3       3
cB-2_2  3       3       3
...

祖源代码 (1-7):
1: cAus
2: XI_indica
3: GJ
4: Ruf1
5: Ruf2
6: Niv1
7: Niv2

用法:
python ancestry_calculator.py -c chromosome_proportions.tsv -g genome_proportions.tsv
"""

import os
import argparse
import sys

# --- 全局常量 ---

CHROMOSOMES = ['chr' + str(i) for i in range(1, 13)]
SUBPOPULATIONS = ['cBas-1A', 'cBas-1B',
  'cBas-1C.1', 'cBas-1C.2', 'cB-1C-adm', 'cBas-1D', 'cBas-1E',
  'cB-2', 'cB-3']

# 祖源代码到名称的映射
ANCESTRY_MAP = {
    0: 'Unknown',
    1: 'cAus',
    2: 'XI_indica',
    3: 'GJ',
    4: 'Ruf1',
    5: 'Ruf2',
    6: 'Niv1',
    7: 'Niv2'
}
# 按顺序排列的祖源名称 (用于输出表头)
# 修改：包含 0: 'Unknown'
ANCESTRY_NAMES = [ANCESTRY_MAP[i] for i in range(0, 8)]

# --- 核心计算函数 ---

def calculate_ancestry_proportions(args):
    """
    主函数：执行祖源比例计算
    """
    
    # 用于存储染色体水平的结果: results_chr[chr][subpop][ancestry_name] = proportion
    results_chr = {}
    
    # 用于累加全基因组的计数: counters_genome[subpop][ancestry_code] = count
    counters_genome = {subpop: {code: 0 for code in ANCESTRY_MAP} for subpop in SUBPOPULATIONS}
    # 同样累加全基因组的总SNP数: counters_genome[subpop]['total_snps'] = count
    for subpop in SUBPOPULATIONS:
        counters_genome[subpop]['total_snps'] = 0

    print("开始处理染色体...")

    # 1. 遍历每个染色体和亚群，计算染色体水平占比并累加全基因组计数
    for chromosome in CHROMOSOMES:
        results_chr[chromosome] = {}
        print(f"  正在处理: {chromosome}")
        
        # --- 新增: 用于累加当前染色体总计的计数器 ---
        counts_chr_total = {code: 0 for code in ANCESTRY_MAP}
        total_snps_chr_total = 0
        # --- 结束新增 ---
        
        for subpop in SUBPOPULATIONS:
            # 构造文件路径, 假设脚本在 chr1, chr2... 的上级目录运行
            filepath = os.path.join('.', chromosome, 'output', f"{subpop}.txt")
            
            # 存储当前染色体+亚群的计数
            counts_chr = {code: 0 for code in ANCESTRY_MAP}
            total_snps_chr = 0
            
            try:
                with open(filepath, 'r') as f:
                    # 跳过表头
                    try:
                        next(f)
                    except StopIteration:
                        # 文件为空
                        print(f"    警告: 文件为空 {filepath}")
                        continue

                    # 逐行读取 (每个样本)
                    for line in f:
                        parts = line.strip().split()
                        if not parts or len(parts) < 2:
                            # 跳过空行或只有样本名的行
                            continue
                        
                        # 从第二列开始是SNP数据 (parts[1:])
                        for code_str in parts[1:]:
                            try:
                                code = int(code_str)
                                if code in ANCESTRY_MAP:
                                    # 累加染色体计数
                                    counts_chr[code] += 1
                                    # 累加全基因组计数
                                    counters_genome[subpop][code] += 1
                                
                                # 无论代码是否有效，都计入总SNP数
                                total_snps_chr += 1
                                counters_genome[subpop]['total_snps'] += 1
                                
                            except ValueError:
                                # 忽略非整数值 (例如 'NA' 或 '-')
                                continue
                                
            except FileNotFoundError:
                print(f"    警告: 文件未找到 {filepath}。跳过...")
                results_chr[chromosome][subpop] = {name: 0.0 for name in ANCESTRY_NAMES}
                continue
            except Exception as e:
                print(f"    错误: 读取文件 {filepath} 时发生错误: {e}")
                continue

            # --- 新增: 累加到染色体总计数 ---
            total_snps_chr_total += total_snps_chr
            for code in ANCESTRY_MAP:
                counts_chr_total[code] += counts_chr[code]
            # --- 结束新增 ---

            # 2. 计算当前染色体+亚群的祖源占比
            proportions_chr = {}
            if total_snps_chr > 0:
                for code, name in ANCESTRY_MAP.items():
                    proportions_chr[name] = counts_chr[code] / total_snps_chr
            else:
                # 如果没有SNP，所有比例为0
                proportions_chr = {name: 0.0 for name in ANCESTRY_NAMES}
            
            # 存入结果
            # 存入结果
            results_chr[chromosome][subpop] = proportions_chr

        # --- 新增: 计算当前染色体的 'Total' 占比 ---
        proportions_chr_total = {}
        if total_snps_chr_total > 0:
            for code, name in ANCESTRY_MAP.items():
                proportions_chr_total[name] = counts_chr_total[code] / total_snps_chr_total
        else:
            proportions_chr_total = {name: 0.0 for name in ANCESTRY_NAMES}
        results_chr[chromosome]['Total'] = proportions_chr_total
        # --- 结束新增 ---

    print("染色体处理完毕。")

    # 3. 计算全基因组水平的祖源占比
    print("正在计算全基因组占比...")
    
    # --- 新增: 定义包含 'Total' 的列表，并计算 'Total' 的全基因组计数 ---
    SUBPOPULATIONS_PLUS_TOTAL = SUBPOPULATIONS + ['Total']
    
    counters_genome['Total'] = {code: 0 for code in ANCESTRY_MAP}
    counters_genome['Total']['total_snps'] = 0
    for subpop in SUBPOPULATIONS: # 仅遍历原始亚群
        counters_genome['Total']['total_snps'] += counters_genome[subpop]['total_snps']
        for code in ANCESTRY_MAP:
            counters_genome['Total'][code] += counters_genome[subpop][code]
    # --- 结束新增 ---

    results_genome = {}
    for subpop in SUBPOPULATIONS_PLUS_TOTAL: # 修改：使用新列表
        results_genome[subpop] = {}
        total_snps_genome = counters_genome[subpop]['total_snps']
        
        if total_snps_genome > 0:
            for code, name in ANCESTRY_MAP.items():
                count = counters_genome[subpop][code]
                results_genome[subpop][name] = count / total_snps_genome
        else:
            # 如果该亚群在所有染色体都没有SNP
            print(f"  警告: 亚群 {subpop} 的全基因组总SNP为0。")
            results_genome[subpop] = {name: 0.0 for name in ANCESTRY_NAMES}

    # 4. 写入输出文件1 (染色体水平)
    print(f"正在写入染色体水平结果到: {args.c}")
    try:
        with open(args.c, 'w') as f_out_chr:
            # 写入表头
            header_chr = ['Chromosome', 'Subpopulation'] + ANCESTRY_NAMES
            f_out_chr.write("\t".join(header_chr) + "\n")
            
            # 写入数据
            for chromosome in CHROMOSOMES:
                if chromosome not in results_chr:
                    continue
                for subpop in SUBPOPULATIONS_PLUS_TOTAL: # 修改：使用新列表
                    if subpop not in results_chr[chromosome]:
                        continue
                        
                    proportions = results_chr[chromosome][subpop]
                    line_parts = [chromosome, subpop]
                    for name in ANCESTRY_NAMES:
                        # 使用 .get(name, 0.0) 确保即使缺少数据也不会出错
                        line_parts.append(f"{proportions.get(name, 0.0):.6f}")
                    
                    f_out_chr.write("\t".join(line_parts) + "\n")
                    
    except IOError as e:
        print(f"错误: 无法写入染色体输出文件 {args.c}。{e}", file=sys.stderr)
        sys.exit(1)

    # 5. 写入输出文件2 (全基因组水平)
    print(f"正在写入全基因组水平结果到: {args.g}")
    try:
        with open(args.g, 'w') as f_out_genome:
            # 写入表头
            header_genome = ['Subpopulation'] + ANCESTRY_NAMES
            f_out_genome.write("\t".join(header_genome) + "\n")
            
            # 写入数据
            for subpop in SUBPOPULATIONS_PLUS_TOTAL: # 修改：使用新列表
                proportions = results_genome[subpop]
                line_parts = [subpop]
                for name in ANCESTRY_NAMES:
                    line_parts.append(f"{proportions.get(name, 0.0):.6f}")
                
                f_out_genome.write("\t".join(line_parts) + "\n")
                
    except IOError as e:
        print(f"错误: 无法写入全基因组输出文件 {args.g}。{e}", file=sys.stderr)
        sys.exit(1)

    print("\n处理完成。")
    print(f"染色体占比表: {args.c}")
    print(f"全基因组占比表: {args.g}")

# --- 启动器 ---

def main():
    """
    解析命令行参数
    """
    parser = argparse.ArgumentParser(
        description="统计染色体和全基因组水平的祖源占比。",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    # 遵循用户偏好，使用单字母参数
    parser.add_argument(
        '-c', 
        metavar='FILE',
        dest='c',
        default='chromosome_proportions.tsv',
        help="输出染色体水平占比的文件路径。\n(默认: 'chromosome_proportions.tsv')"
    )
    
    parser.add_argument(
        '-g', 
        metavar='FILE',
        dest='g',
        default='genome_proportions.tsv',
        help="输出全基因组水平占比的文件路径。\n(默认: 'genome_proportions.tsv')"
    )
    
    args = parser.parse_args()
    
    # 执行计算
    calculate_ancestry_proportions(args)

if __name__ == "__main__":
    main()

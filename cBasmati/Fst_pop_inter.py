#!/usr/bin/env python3
"""
Author: Wen Zhao
Email: zhaozs221@163.com
Creation Date: 2025
License: Free to use with proper attribution
"""

import argparse
import glob
import os
import pandas as pd


# 固定亚群体列表
groups = [
    "cB-1A", "cB-1B", "cB-1C.1", "cB-1C.2", "cB-1D", "cB-1E", "cB-2", "cB-3"
]

def get_top_percent_rows(df, percent):
    # 计算Top百分比的阈值
    threshold = df['WEIGHTED_FST'].quantile(1 - percent / 100)
    return df[df['WEIGHTED_FST'] >= threshold]

def main():
    parser = argparse.ArgumentParser(description="筛选每个群体与其他群体的Top百分比Fst区域，并输出交集与并集文件。")
    parser.add_argument('--top', type=float, required=True, help='Fst筛选Top百分比（如10表示Top10%）')
    parser.add_argument('--dir', type=str, default='.', help='.fst文件所在目录，默认为当前目录')
    args = parser.parse_args()

    top_percent = args.top
    work_dir = args.dir

    for group in groups:
        # 查找包含group的所有.fst文件
        pattern = os.path.join(work_dir, f"*{group}*.fst")
        files = glob.glob(pattern)
        if not files:
            print(f"[警告] 未找到包含{group}的.fst文件")
            continue
        print(f"[信息] {group} 相关文件: {files}")
        region_sets = []
        # 获取表头（前三列）
        header = None
        for file in files:
            try:
                df = pd.read_csv(file, sep='\t', dtype=str)
                if header is None:
                    header = list(df.columns[:3])
                # 转换WEIGHTED_FST为float
                df['WEIGHTED_FST'] = pd.to_numeric(df['WEIGHTED_FST'], errors='coerce')
                df = df.dropna(subset=['WEIGHTED_FST'])
                top_df = get_top_percent_rows(df, top_percent)
                # 只保留前三列
                region_set = set(tuple(x) for x in top_df.iloc[:, :3].values)
                region_sets.append(region_set)
                print(f"[信息] {file} 筛选Top{top_percent}% 区域数: {len(region_set)}")
            except Exception as e:
                print(f"[错误] 处理文件{file}时出错: {e}")
        if not region_sets:
            print(f"[警告] {group} 没有可用的Top区域数据")
            continue
        # 求交集和并集
        inter = set.intersection(*region_sets) if len(region_sets) > 1 else region_sets[0]
        union = set.union(*region_sets)
        # 输出文件
        if inter:  # 只有交集非空才输出
            inter_file = os.path.join(work_dir, f"{group}-Fst{int(top_percent)}-inter.txt")
            with open(inter_file, 'w') as f:
                f.write('\t'.join(header) + '\n')
                for row in sorted(inter):
                    f.write('\t'.join(row) + '\n')
            print(f"[输出] {group} 交集: {inter_file}")
        else:
            print(f"[输出] {group} 交集为空，不输出交集文件")
        union_file = os.path.join(work_dir, f"{group}-Fst{int(top_percent)}-union.txt")
        with open(union_file, 'w') as f:
            f.write('\t'.join(header) + '\n')
            for row in sorted(union):
                f.write('\t'.join(row) + '\n')
        print(f"[输出] {group} 并集: {union_file}")

if __name__ == '__main__':
    main()
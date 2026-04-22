import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import argparse
import sys
import time

def main():
    parser = argparse.ArgumentParser(description="[低内存版] 绘制单条染色体的群体平均祖源概率折线图")
    parser.add_argument("-p", "--ps21", required=True, help="单个亚群的ps21文件")
    parser.add_argument("-s", "--snpinfo", required=True, help="snpinfo文件 (含表头, 第二列需为物理位置)")
    parser.add_argument("-k", "--n_ancestry", type=int, required=True, help="祖源数量 (例如: 5)")
    parser.add_argument("-n", "--names", nargs='+', required=True, help="祖源名称列表")
    parser.add_argument("-c", "--colors", nargs='+', help="自定义颜色列表")
    parser.add_argument("-t", "--title", default="Local Ancestry", help="图表标题")
    parser.add_argument("-o", "--output", required=True, help="输出图片文件名")
    parser.add_argument("--output-txt", help="[可选] 输出包含每个位点祖源概率值的文本文件路径 (TSV格式)")
    parser.add_argument("--chunksize", type=int, default=10, help="每次读取的行数 (默认10)，越小越省内存")
    
    args = parser.parse_args()

    # 检查参数
    if len(args.names) != args.n_ancestry:
        print(f"错误: 祖源名称数量 ({len(args.names)}) 与指定数量 ({args.n_ancestry}) 不一致。")
        sys.exit(1)

    start_time = time.time()

    # 1. 读取 SNP Info (小文件用 Pandas 即可)
    print("正在读取 SNP 信息...")
    try:
        snp_df = pd.read_csv(args.snpinfo, sep=r'\s+')
        if 'pos' not in snp_df.columns.str.lower():
            positions = snp_df.iloc[:, 1].values
        else:
            pos_col = [c for c in snp_df.columns if c.lower() == 'pos'][0]
            positions = snp_df[pos_col].values
        positions_mb = positions / 1000000.0
    except Exception as e:
        print(f"读取 SNPInfo 失败: {e}")
        sys.exit(1)

    # 获取绘图范围
    x_min, x_max = np.min(positions_mb), np.max(positions_mb)

    # 2. 分块读取 ps21 并计算累加和
    print(f"正在分块读取矩阵 (Chunksize={args.chunksize}): {args.ps21} ...")
    
    # 初始化累加器
    total_sum = None
    total_rows = 0
    
    try:
        # chunksize 返回一个迭代器，不会一次性读取所有数据
        reader = pd.read_csv(args.ps21, sep=r'\s+', header=None, chunksize=args.chunksize)
        
        for i, chunk in enumerate(reader):
            # 确保只取需要的列数 (防止行尾多余空格导致多出空列)
            expected_cols = len(positions) * args.n_ancestry
            if chunk.shape[1] > expected_cols:
                chunk = chunk.iloc[:, :expected_cols]
            
            # 将当前块的数据转换为数值型 (sum 运算需要)
            chunk_vals = chunk.values
            
            # 计算当前块的列和 (axis=0 表示按列求和)
            chunk_sum = np.sum(chunk_vals, axis=0)
            
            # 累加到全局
            if total_sum is None:
                total_sum = chunk_sum
            else:
                total_sum += chunk_sum
            
            total_rows += chunk.shape[0]
            
            # 打印进度 (每读 5 个块打印一次)
            if (i + 1) % 5 == 0:
                print(f"  -> 已处理 {total_rows} 行...")
                
    except Exception as e:
        print(f"读取或计算失败: {e}")
        sys.exit(1)

    if total_rows == 0:
        print("错误: 文件为空或未读取到任何数据")
        sys.exit(1)

    print(f"读取完成，总行数: {total_rows}")
    print("正在计算平均值...")
    
    # 计算最终平均值
    col_means = total_sum / total_rows

    # 重塑数据
    reshaped_means = col_means.reshape(-1, args.n_ancestry)

    read_time = time.time() - start_time
    print(f"数据处理耗时: {read_time:.2f} 秒")

    # --- 新增功能: 输出概率值文件 ---
    if args.output_txt:
        print(f"正在导出概率矩阵至: {args.output_txt} ...")
        try:
            # 构建输出 DataFrame
            out_df = pd.DataFrame(reshaped_means, columns=args.names)
            # 插入物理位置列 (作为第一列)
            out_df.insert(0, 'Position', positions)
            # 保存为 TSV (制表符分隔)，保留4位小数
            out_df.to_csv(args.output_txt, sep='\t', index=False, float_format='%.4f')
            print(f"  -> 导出成功: {args.output_txt}")
        except Exception as e:
            print(f"  -> 导出失败: {e}")
    # ----------------------------

    # 3. 绘图 (Matplotlib)
    print("正在绘图...")
    fig, ax = plt.subplots(figsize=(12, 5))
    default_colors = ['#E41A1C', '#377EB8', '#4DAF4A', '#984EA3', '#FF7F00', '#FFFF33', '#A65628', '#F781BF']
    colors = args.colors if args.colors else default_colors

    for i in range(args.n_ancestry):
        label = args.names[i]
        color = colors[i % len(colors)]
        ax.plot(positions_mb, reshaped_means[:, i], label=label, color=color, linewidth=1.5, alpha=0.9)

    ax.xaxis.set_major_locator(ticker.MultipleLocator(0.5))
    ax.set_xlim(x_min, x_max) # 消除左右空白
    ax.set_xlabel("Physical Position (Mb)", fontsize=12)
    ax.yaxis.set_major_locator(ticker.MultipleLocator(0.2))
    ax.set_ylim(-0.02, 1.02)
    ax.set_ylabel("Average Ancestry Probability", fontsize=12)
    ax.tick_params(axis='x', labelsize=8) 
    ax.tick_params(axis='y', labelsize=10)
    ax.set_title(args.title, fontsize=14, fontweight='bold')
    ax.legend(bbox_to_anchor=(1.01, 1), loc='upper left', borderaxespad=0., title="Source Population")

    plt.tight_layout()
    plt.savefig(args.output, dpi=300)
    print(f"图表已保存至: {args.output}")

if __name__ == "__main__":
    main()

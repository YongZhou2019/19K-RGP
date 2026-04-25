# 基因组祖源分析流程 (ELAI Pipeline)

## 概述

本流程用于对水稻基因组进行**本地祖源推断 (Local Ancestry Inference)**，使用 ELAI (Expectation-Maximization for Admixture Linkage) 软件分析，最终生成染色体热图和祖源占比统计结果。

## 完整操作流程

### 步骤 0: 准备输入文件

确保以下文件存在:
1. **VCF文件**: 包含所有样本的基因型数据
2. **样本映射文件**: `all.txt` (格式: 两列，无表头，`sample_id  population_name`)

```bash
# 示例 all.txt 格式:
W123    cAus
W456    XI_indica
R001    Rayada
...
```

---

### 步骤 1: 创建群体样本列表

```bash
bash 01.create_list.sh all.txt
```

**功能**:
- 从 `all.txt` 读取样本-群体映射
- 生成 `list/all.list` (所有样本ID，每行一个)
- 为每个群体生成 `list/{population}.list` (每个样本扩展为两个单倍型: sample_1, sample_2)

**输出**:
- `list/all.list`
- `list/cAus.list`, `list/XI_indica.list`, ..., `list/adm.list`

---

### 步骤 2: 运行 ELAI 祖源分析

```bash
bash 02.process_elai.sh
```

**功能**:
- 为 **12条染色体 (Chr01-Chr12)** × **n个混合群体** = 12n个分析任务分别创建作业脚本
- 自动提交作业到计算集群 (使用 `dsub`)

**每个作业内部执行流程**:
1. **提取VCF**: 使用 `bcftools view -r` 提取指定染色体数据
2. **基因型定相**: 使用 `Beagle` 对基因型进行定相 (phasing)
3. **格式转换**: 将定相后的VCF转换为 ELAI 所需的 BIMBAM 格式
   - `vcf_trans_bimbam0.py`: 转换所有样本
   - `vcf_trans_bimbam2.py`: 按群体分离
4. **运行ELAI**: 
   - 7个参考群体 (source populations): cAus, XI_indica, GJ, Ruf1, Ruf2, Niv1, Niv2
   - 参数: `-C 7` (7个祖源), `-c 35` (期望35代混合), `-s 20` (EM迭代20次)
   - 过滤: MAF > 0.01, missing rate < 0.2

**输出** (每个染色体/群体目录下):
- `{chr}.filtered.phased.vcf.gz`: 定相后的VCF
- `{chr}.hap.{group}.inp`: 各群体的BIMBAM格式文件
- `{chr}-{group}.ps21.txt`: 祖源概率矩阵 (行=单倍型, 列=SNP位点)
- `{chr}-{group}.snpinfo.txt`: SNP位置信息

---

### 步骤 3: 转换 ELAI 输出为热图格式

```bash
bash 03.convert.sh
```

**功能**:
- 遍历所有染色体目录 (Chr01-Chr12)
- 对每个混合群体调用 `convert_elai_to_heatmap.py`
- 将 ELAI 的概率输出转换为**最可能祖源**的数字编码矩阵

**转换逻辑** (`convert_elai_to_heatmap.py`):
1. 读取 `.snpinfo.txt` 获取SNP物理位置
2. 逐行读取 `.ps21.txt` 的概率矩阵
3. 对每个SNP位点:
   - 找到概率最高的祖源
   - 如果最高概率 > **0.75**，分配对应祖源代码
   - 否则标记为 `Unknown` (代码0)
4. 输出格式:
   ```
   Sample    1240    1266    1268    ...
   Rayada_1  3       3       1       ...
   Rayada_2  3       3       1       ...
   ```

**祖源代码映射**:
| 代码 | 祖源名称 |
|------|----------|
| 0    | Unknown  |
| 1    | cAus     |
| 2    | XI_indica|
| 3    | GJ       |
| 4    | Ruf1     |
| 5    | Ruf2     |
| 6    | Niv1     |
| 7    | Niv2     |

**输出**: `Chr*/output/{group}.txt`

---

### 步骤 4: 绘制祖源热图

```bash
# 对每条染色体运行 (示例: Chr01)
Rscript 04.heatmap.R \
  -i Chr01/output/ \
  -n cAus,XI_indica,GJ,Ruf1,Ruf2,Niv1,Niv2 \
  -o plot/Chr01_heatmap.png \
  -t "Chr01 Ancestry Heatmap"
```

**功能** (`04.heatmap.R`):
- 读取 `Chr*/output/` 目录下所有群体的 `.txt` 文件
- 自动从文件名推断亚群归属 (无需额外的样本-亚群映射文件)
- 合并所有群体数据，按SNP位置排序
- 使用 `ComplexHeatmap` 绘制热图

**热图特征**:
- **行**: 样本单倍型 (按亚群分组排序)
- **列**: SNP位点 (按物理位置排序)
- **颜色**: 每个SNP位点推断的祖源
- **左侧注释**: 亚群分组
- **X轴**: 物理位置 (Mb，每0.5Mb标记)

---

### 步骤 5 (可选): 祖源占比统计

```bash
python ancestry_calculator.py \
  -c chromosome_proportions.tsv \
  -g genome_proportions.tsv
```

**功能**:
- 统计每条染色体上各祖源的SNP占比
- 统计全基因组水平的祖源占比
- 同时计算每个亚群和所有样本的总计

**输出文件**:
1. `chromosome_proportions.tsv`: 染色体水平祖源占比

2. `genome_proportions.tsv`: 全基因组水平祖源占比

---

### 步骤 6 (可选): 绘制祖源概率折线图

```bash
python plot_chr_ancestry.py \
  -p Chr01/Rayada/output/Chr01-Rayada.ps21.txt \
  -s Chr01/Rayada/output/Chr01-Rayada.snpinfo.txt \
  -k 7 \
  -n cAus XI_indica GJ Ruf1 Ruf2 Niv1 Niv2 \
  -t "Chr01 Rayada Average Ancestry Probability" \
  -o plot/Chr01_Rayada_probability.png \
  --output-txt plot/Chr01_Rayada_probability.txt
```

**功能**:
- 计算所有单倍型在每个SNP位点的平均祖源概率
- 绘制沿染色体的祖源概率折线图
- 支持分块读取大文件 (低内存模式)

---

## 参考链接

- ELAI 软件主页: [https://github.com/xyangGT/ELAI](https://github.com/xyangGT/ELAI)
- ComplexHeatmap 文档: [https://jokergoo.github.io/ComplexHeatmap-reference/](https://jokergoo.github.io/ComplexHeatmap-reference/)

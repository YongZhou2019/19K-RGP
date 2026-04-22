#!/bin/bash

# Title: submit_elai_jobs.sh
# Description: This script iterates through a list of chromosomes, and for each one,
# it generates and submits separate analysis jobs for multiple admixed populations.
# Author: Wen Zhao

# --- Configuration ---

# 脚本在遇到任何错误时立即退出
set -e

# 定义要分析的染色体列表
CHROMOSOMES=($(seq -f "Chr%02g" 1 12))
# 定义所有需要作为混合群体进行分析的群体
ADMIXED_GROUPS=("Rayada" "cA" "XI" "adm")

# --- Main Logic ---

echo "--- 开始为所有染色体和混合群体生成并提交作业 ---"

# 1. 外层循环：遍历每一条染色体
for chr in "${CHROMOSOMES[@]}"; do
    
    # 构建该染色体的主目录名和 bcftools 所需的区域字符串
    chr_dir_name="${chr}"
    chr_for_bcftools="${chr}"

    # 为该染色体创建一个主目录
    mkdir -p "$chr_dir_name"

    # 2. 内层循环：遍历每一个需要分析的混合群体
    for admixed_group in "${ADMIXED_GROUPS[@]}"; do
        
        echo "--- 准备作业: 染色体 [${chr_dir_name}], 混合群体 [${admixed_group}] ---"

        # 为每个作业创建唯一的脚本文件名和输出子目录
        job_script_name="${chr_dir_name}/${chr_dir_name}_${admixed_group}.sh"
        output_subdir="${chr_dir_name}/${admixed_group}"
        
        # 创建用于存放该作业结果和日志的子目录
        mkdir -p "$output_subdir"

        # 3. 使用 "here document" (cat <<EOF) 动态创建作业提交脚本
        cat > "$job_script_name" <<EOF
#!/bin/bash
#DSUB -n elai_${chr_dir_name}_${admixed_group}
#DSUB -R 'cpu=15'
#DSUB -o ${output_subdir}/job_%J.out

### --- 作业命令开始 --- ###
echo "--- 作业启动: 染色体 [${chr_dir_name}], 混合群体 [${admixed_group}] ---"
date
set -e

# 1. 加载运行所需的环境模块
module load arm/bcftools/1.21
module load arm/elai/1.01
module load arm/r/4.4.1
module load arm/python/2.7.18

# 定义 Python 和 R 脚本的绝对路径
PYTHON_BIMBAM0="/share/home/wzhao25/20k/Code/src/vcf_trans_bimbam0.py"
PYTHON_BIMBAM2="/share/home/wzhao25/20k/Code/src/vcf_trans_bimbam2.py"

# 定义所有可能用到的群体
ALL_GROUPS=("cAus" "XI_indica" "GJ" "Ruf1" "Ruf2" "Niv1" "Niv2" "Rayada" "cA" "XI" "adm")
# 定义 ELAI 分析中作为源群体的群体
SOURCE_GROUPS="cAus,XI_indica,GJ,Ruf1,Ruf2,Niv1,Niv2"

# 2. 进入为此作业创建的特定子目录
cd "${output_subdir}" || { echo "错误: 无法进入目录 ${output_subdir}"; exit 1; }

# 定义此作业中使用的文件前缀
PREFIX="${chr_dir_name}"

# 3. 步骤 1: 使用 bcftools 提取整条染色体的 VCF
echo "步骤 1: 提取染色体 ${chr_for_bcftools} 的 VCF..."
bcftools view -r '${chr_for_bcftools}' -O z -o "\${PREFIX}.filtered.vcf.gz" /share/home/wzhao25/20k/lai/genome_rayada/cB_wild_JCList.vcf.gz

# 4. 步骤 2: 使用 Beagle 进行定相
echo "步骤 2: 使用 Beagle 进行定相..."
java -jar -Xmx50g ~/biosoft/beagle.5.4.jar \\
    gt="\${PREFIX}.filtered.vcf.gz" \\
    window=10 \\
    out="./\${PREFIX}.filtered.phased" \\
    nthreads=15

# 5. 步骤 3: 准备 ELAI 输入文件
echo "步骤 3: 准备 ELAI 输入文件..."
PHASED_VCF_GZ="\${PREFIX}.filtered.phased.vcf.gz"

# 从定相后的VCF获得snp位置信息
zcat "\$PHASED_VCF_GZ" | grep -v "#" | cut -f 2 > "\${PREFIX}.pos.tmp"
paste -d "\t" "\${PREFIX}.pos.tmp" "\${PREFIX}.pos.tmp" > "\${PREFIX}.input.pos"
rm "\${PREFIX}.pos.tmp"

snp_num=\$(cat "\${PREFIX}.input.pos" | wc -l)
if [ "\$snp_num" -eq 0 ]; then
    echo "警告: 定相后无SNP，终止此作业。"
    exit 0
fi

python2 "\$PYTHON_BIMBAM0" \\
    "\$PHASED_VCF_GZ" \\
    "/share/home/wzhao25/20k/lai/genome_rayada/list/all.list" \\
    "\${PREFIX}.filtered.all.inp" \\
    "\${snp_num}"

# 分群体提取
for gp in "\${ALL_GROUPS[@]}"; do
    python2 "\$PYTHON_BIMBAM2" \\
        "\${PREFIX}.filtered.all.inp" \\
        "/share/home/wzhao25/20k/lai/genome_rayada/list/\${gp}.list" \\
        "\${PREFIX}.hap.\${gp}.inp" \\
        "\${snp_num}"
done

# 6. 步骤 4: 运行 ELAI 分析
echo "步骤 4: 运行 ELAI 分析 (混合群体: ${admixed_group})..."
elai \\
    -g "\${PREFIX}.hap.cAus.inp" -p 10 \\
    -g "\${PREFIX}.hap.XI_indica.inp" -p 11 \\
    -g "\${PREFIX}.hap.GJ.inp" -p 12 \\
    -g "\${PREFIX}.hap.Ruf1.inp" -p 13 \\
    -g "\${PREFIX}.hap.Ruf2.inp" -p 14 \\
    -g "\${PREFIX}.hap.Niv1.inp" -p 15 \\
    -g "\${PREFIX}.hap.Niv2.inp" -p 16 \\
    -g "\${PREFIX}.hap.${admixed_group}.inp" -p 1 \\
    -pos "\${PREFIX}.input.pos" \\
    -s 20 \\
    -o "\${PREFIX}-${admixed_group}" \\
    -C 7 \\
    -c 35 \\
    -mg 100 \\
    -R 123 \\
    -exclude-maf 0.01 \\
    --exclude-miss 0.2 \\
    --exclude-nopos

date
echo "--- 作业成功完成: \${PREFIX} - ${admixed_group} ---"
### --- 作业命令结束 --- ###
EOF

        # 4. 赋予生成的作业脚本可执行权限
        chmod +x "$job_script_name"

        # 5. 使用 dsub -s 提交作业脚本
        dsub -s "$job_script_name"

        echo "    -> 作业脚本 ${job_script_name} 已提交。"
        echo ""

    done # 结束内层循环 (混合群体)

done # 结束外层循环 (染色体)

echo "所有染色体的所有作业均已成功提交！"


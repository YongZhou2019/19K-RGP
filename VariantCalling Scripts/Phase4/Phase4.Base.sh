#!/bin/bash
## Variables

genome=gggg

export REF=/project/k10069/shaheen2ref/"$genome".fa

export OUTPUT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/Phase3_scripts/genome5/genome5.Phase3_output/
export Phase4_output=/scratch/project/k10069/manickk/"$genome"/Phase4_output_New


### 这儿回来继续！！！
export SNPs=${OUTPUT}/SNPs_sort;
export INDELs=${OUTPUT}/INDELs_sort;
export SNPs_per_Chr=${Phase4_output}/SNPs_per_Chr;
export INDELs_per_Chr=${Phase4_output}/INDELs_per_Chr;
mkdir -p $SNPs_per_Chr ;
mkdir -p $INDELs_per_Chr ;

## Rank based value 
val=$1;
if [ $val -eq 0 ]
then 
  LINE=1;
else
 LINE=$((val + 1))
fi

## Read one Split value Per Rank 
CHR=`sed -n ${LINE}p distribution.txt | awk '{print $1}'`
CHUNK=`sed -n ${LINE}p distribution.txt | awk '{print $2}'`

set INPUT_SNP
set INPUT_INDEL
for i in `seq 1 $CHUNK`; 
 do
  INPUT_SNP+="-I $SNPs/filtered_snps.$CHR.$i.SNPs.withID.sort.vcf.gz "; 
  INPUT_INDEL+="-I $INDELs/$CHR.$i.withID.sort.vcf.gz "; 
done

 ## For SNPs
  time -p gatk GatherVcfs ${INPUT_SNP} -O $SNPs_per_Chr/$CHR.SNPs.vcf.gz -R $REF
 ## For INDELs
  time -p gatk GatherVcfs ${INPUT_INDEL} -O $INDELs_per_Chr/$CHR.INDELs.vcf.gz -R $REF

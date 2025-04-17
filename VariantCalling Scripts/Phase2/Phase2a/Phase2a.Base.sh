#!/bin/bash
### Environment variables 

genome=genome5 ### change Parameter here only

tmp=${PROJECT}/tmp
export REF=/project/k10069/shaheen2ref/"$genome".fa 
export PROJECT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/sbatch5/Results/New
export INPUT=${PROJECT}/tmpBAM
export VCF=${PROJECT}/VCF;
export HCBAM=${PROJECT}/HCBAM;
mkdir -p $VCF
mkdir -p $HCBAM
export CORE=1 ;

val=$1;
if [ $val -eq 0 ]
then 
  LINE=1;
  export SAMPLES=1;
else
 LINE=$((val + 1))
fi
## Read one Split value Per Rank 

PREFIX=`sed -n ${LINE}p Phase2.prefix.txt | awk '{print $1}'` ;
mkdir -p ${VCF}/${PREFIX};
mkdir -p ${HCBAM}/${PREFIX};
# ### Phase2

echo "------------------------------------- Step 1: HaplotypeCaller ----------------------------------------------------------------------------------------"
time -p gatk --java-options "-Xmx4g -Xms4g" HaplotypeCaller --input $INPUT/"${PREFIX}".sorted.fxmt.mkdup.addrep.bam --intervals chrNN:startNN-endNN --output $VCF/${PREFIX}/${PREFIX}.chrNN.sizeNN.startNN.endNN.snps.indels.g.vcf.gz --reference $REF --emit-ref-confidence GVCF --min-base-quality-score 20 --bam-output $HCBAM/${PREFIX}/${PREFIX}.chrNN.sizeNN.startNN.endNN.assembledHC.bam --tmp-dir $tmp

echo "------------------------------------- Step 2: Tabix --------------------------------------------------------------------------------------------------"  
time -p tabix -f $VCF/${PREFIX}/${PREFIX}.chrNN.sizeNN.startNN.endNN.snps.indels.g.vcf.gz




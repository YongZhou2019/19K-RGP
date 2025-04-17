#!/bin/bash
## Variables

genome=gggg

REF=/project/k10069/shaheen2ref/"$genome".fa

export OUTPUT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/Phase3_scripts/"$genome"/"$genome".Phase3_output
mkdir -p $OUTPUT

export chunkVCF=${OUTPUT}/chunkVCF;
mkdir -p $chunkVCF

## Rank based value 
val=$1;
if [ $val -eq 0 ]
then 
  LINE=1;
else
 LINE=$((val + 1))
fi

## Read one Split value Per Rank 
ChrName=`sed -n ${LINE}p split.tmp.txt  | awk '{print $1}'`
size=`sed -n ${LINE}p split.tmp.txt  | awk '{print $2}'`
Start=`sed -n ${LINE}p split.tmp.txt  | awk '{print $3}'`
End=`sed -n ${LINE}p split.tmp.txt  | awk '{print $4}'`
INPUT=`cat Phase3.input.list`

echo "Phase3a"
## Step 1
#echo " -----Step1, GATK: CombineGVCFs --------------"
mkdir -p /tmp/gatk_tmp; ### tried 160G/job, but OOM failure.
#time -p gatk --java-options "-Xmx320g -Xms320g" CombineGVCFs --variant $INPUT --reference $REF --intervals $ChrName:$Start-$End --output ${chunkVCF}/Combine.$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp 

### to remove some intervals, if some jobs failed.
#time -p gatk --java-options "-Xmx100g -Xms100g" CombineGVCFs --variant $INPUT --reference $REF --intervals $ChrName:$Start-$End --exclude-intervals XL.intervals --output ${chunkVCF}/Combine.$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp  
time -p gatk --java-options "-Xmx320g -Xms320g" CombineGVCFs --variant $INPUT --reference $REF --intervals $ChrName:$Start-$End --exclude-intervals XL.intervals --output ${chunkVCF}/Combine.$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp

rm -rf /tmp/gatk_tmp/* 

echo 'DONE'

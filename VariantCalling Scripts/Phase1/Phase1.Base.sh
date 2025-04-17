#!/bin/bash
### Environment variables 

genome=genome5     ### modify reference genome;!!!
SBATCH=sbatch5
SZBATCH=szbatch26  

export REF=/project/k10069/shaheen2ref/"$genome".fa
export INPUT=/project/k10069/shaheen2_projects/05_10KRGP/03.cleandata/$SBATCH/$SZBATCH  
export PROJECT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/Results/New 

export CORE=8 ;
val=$1;
if [ $val -eq 0 ]
then 
  LINE=1;
else
 LINE=$((val + 1))
fi

## Read one Sample Per Rank 
DATA=`sed -n ${LINE}p  Phase1.txt `;    ### modify here as well;
PREFIX=`basename $DATA _trimmed_1.fastq.gz` ;
SAMPLE=${PREFIX%*_*};
BAM=${PROJECT}/tmpBAM/$SAMPLE
mkdir -p $BAM;

tmp=${PROJECT}/tmp
mkdir -p $tmp

## Random wait before creating $BAM directory (to safeguard /luster file system)
export MAXWAIT=10
sleep $[ ( $RANDOM % $MAXWAIT )  + 1 ]s

## Step 1
# echo "------------------------------------- Step 1 executing: BWA MEM ---------------------------------------------------------------------------------------"
time -p bwa mem -M -t $CORE $REF $INPUT/${PREFIX}_trimmed_1.fastq.gz $INPUT/${PREFIX}_trimmed_1.fastq.gz | samtools view -@ $CORE -b -S -h -q 30 - | samtools sort -T $tmp/ - > $BAM/$PREFIX.sorted.bam

# ## Step 2
# echo "------------------------------------- Step 2 executing: FixMateInformation  -----------------------------------------------------------------------------"
time -p gatk --java-options "-Xmx8g -Xms8g" FixMateInformation --INPUT $BAM/$PREFIX.sorted.bam --SORT_ORDER coordinate --OUTPUT $BAM/$PREFIX.sorted.fxmt.bam --TMP_DIR $tmp/
rm $BAM/$PREFIX.sorted.bam

# ## Step 3
# echo "------------------------------------- Step 3 executing: MarkDuplicates -----------------------------------------------------------------------------------"
time -p gatk --java-options "-Xmx8g -Xms8g" MarkDuplicates --INPUT $BAM/$PREFIX.sorted.fxmt.bam --METRICS_FILE $BAM/$PREFIX.metrics --OUTPUT $BAM/$PREFIX.sorted.fxmt.mkdup.bam --TMP_DIR $tmp/
rm $BAM/$PREFIX.sorted.fxmt.bam

# ## Step 4
# echo "------------------------------------- Step 4 executing: AddOrReplaceReadGroups ----------------------------------------------------------------------------"
time -p gatk --java-options "-Xmx8g -Xms8g" AddOrReplaceReadGroups --INPUT $BAM/$PREFIX.sorted.fxmt.mkdup.bam --OUTPUT ${PROJECT}/tmpBAM/$SAMPLE.sorted.fxmt.mkdup.addrep.bam --RGID $SAMPLE --RGPL Illumina --RGSM $SAMPLE --RGLB $SAMPLE --RGPU unit1 --RGCN BGI --SORT_ORDER coordinate --TMP_DIR $tmp/
rm $BAM/$PREFIX.sorted.fxmt.mkdup.bam
rm $BAM/$PREFIX.metrics
rm -rf $BAM

echo "------------------------------------- Step 5: sam-index ---------------------------------------------------------------------------------------------"
time -p samtools index ${PROJECT}/tmpBAM/$SAMPLE.sorted.fxmt.mkdup.addrep.bam

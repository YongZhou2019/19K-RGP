#!/bin/bash
### Environment variables 

genome=genome5 ### change Parameter here only

export REF=/project/k10069/shaheen2ref/"$genome".fa   ; ### change Parameter1
export PROJECT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/sbatch5/Results/New
export VCF=${PROJECT}/VCF;
export MERGEVCFs=${PROJECT}/MergeVcfs
export HCBAM=${PROJECT}/HCBAM;
export MERGEHCBAMs=${PROJECT}/MergeHCBAMs
mkdir -p $MERGEVCFs
mkdir -p $MERGEHCBAMs

## Rank based value 
val=$1;
if [ $val -eq 0 ]
then 
  LINEE=1;
else
  LINEE=$((val + 1))
fi

PREFIX=`sed -n ${LINEE}p Phase2.prefix.txt `

## Read one Split value Per Rank 
CHUNK=`less split.txt | wc -l`

set INPUT_chunk
for LINE in `seq 1 $CHUNK`; 
 do
  chr=`sed -n ${LINE}p split.txt | awk '{print $1}'` ;
  size=`sed -n ${LINE}p split.txt | awk '{print $2}'` ;
  start=`sed -n ${LINE}p split.txt | awk '{print $3}'` ;
  end=`sed -n ${LINE}p split.txt | awk '{print $4}'` ;

  INPUT_chunk+="-I $VCF/$PREFIX/$PREFIX.$chr.$size.$start.$end.snps.indels.g.vcf.gz "; 
done

### Phase2 
echo "------------------------------------- Step 1: MergeVcfs ---------------------------------------------------------------------------------------------"
#addednowtocheck
#tmpp=${PROJECT}/tmpp
#mkdir -p $tmpp

#time -p gatk --java-options "-Xmx4g -Xms4g" MergeVcfs ${INPUT_chunk} -O $MERGEVCFs/$PREFIX.snps.indels.g.vcf.gz -R $REF --tmp-dir $tmpp

#time -p gatk MergeVcfs ${INPUT_chunk} -O $MERGEVCFs/$PREFIX.MergeVcfs.SNPs.vcf.gz -R $REF

time -p gatk MergeVcfs ${INPUT_chunk} -O $MERGEVCFs/$PREFIX.snps.indels.g.vcf.gz -R $REF



## at least it is working
#time -p gatk --java-options "-Xmx4g -Xms4g" MergeVcfs ${INPUT_chunk} -O $MERGEVCFs/$PREFIX.snps.indels.g.vcf.gz -R $REF

echo "------------------------------------- Step 2: Tabix --------------------------------------------------------------------------------------------------"  
time -p tabix -f $MERGEVCFs/$PREFIX.snps.indels.g.vcf.gz
time -p cnf tabix -f $MERGEVCFs/$PREFIX.snps.indels.g.vcf.gz


### Phase2a
echo "------------------------------------- Step 3: samtools-merge  ---------------------------------------------------------------------------------------"
time -p samtools merge -f -n $MERGEHCBAMs/${PREFIX}.assembledHC.bam $HCBAM/$PREFIX/${PREFIX}.*.assembledHC.bam
rm $VCF/* $HCBAM/*
echo "DONE"


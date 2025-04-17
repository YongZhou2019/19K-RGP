#!/bin/bash
### Environment variables 

genome=genome5 ### change Parameter here only

export REF=/project/k10069/shaheen2ref/"$genome".fa  ; ### change Parameter1
export INPUT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/"$genome"/sbatch5/Results/New/tmpBAM ; ### change Parameter2
export PROJECT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/"$genome"/sbatch5/Results/New ; ### change Parameter3
export MERGEHCBAMs=${PROJECT}/MergeHCBAMs
export sortedCRAM=${PROJECT}/sortedCRAM;
export HCCRAM=${PROJECT}/HCCRAM;
mkdir -p $sortedCRAM
mkdir -p $HCCRAM

export CORE=1 ;


## Rank based value 
val=$1;
if [ $val -eq 0 ]
then 
  LINEE=1;
else
  LINEE=$((val + 1))
fi

PREFIX=`sed -n ${LINEE}p Phase2c.prefix.txt `


### Phase2c
### edit Yong2023-09-15,  translate the bam files to CRAM files;
samtools view -T $REF -o $sortedCRAM/${PREFIX}.sorted.fxmt.mkdup.addrep.bam.cram $INPUT/"${PREFIX}".sorted.fxmt.mkdup.addrep.bam
# rm $INPUT/${PREFIX}.sorted.bam ### next genome, remove them;
samtools view -T $REF -o $HCCRAM/${PREFIX}.assembledHC.bam.cram $MERGEHCBAMs/${PREFIX}.assembledHC.bam

# rm $MERGEHCBAMs/${PREFIX}.assembledHC.bam


#!/bin/bash
## Variables

genome=gggg

export REF=/project/k10069/shaheen2ref/"$genome".fa

### export OUTPUT=/scratch/project/k10008/"$genome".results/Phase3_output
### export chunkVCF=${OUTPUT}/chunkVCF;

export chunkVCF=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/"$genome"/Phase3_scripts/"$genome"/"$genome".Phase3_output/chunkVCF
export OUTPUT=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/"$genome"/Phase3_scripts/"$genome"/"$genome".Phase3_output/
export genotype=${OUTPUT}/genotype;
export SNPs=${OUTPUT}/SNPs;
export INDELs=${OUTPUT}/INDELs;

export SNPs_withID=${OUTPUT}/SNPs_withID;
export INDELs_withID=${OUTPUT}/INDELs_withID;

export SNPs_sort=${OUTPUT}/SNPs_sort;
export INDELs_sort=${OUTPUT}/INDELs_sort;


mkdir -p $genotype
mkdir -p $SNPs
mkdir -p $INDELs
mkdir -p $SNPs_withID
mkdir -p $INDELs_withID

mkdir -p $SNPs_sort
mkdir -p $INDELs_sort


## Rank based value 
val=$1;
if [ $val -eq 0 ]
then 
  LINE=1;
else
 LINE=$((val + 1))
fi

## Read one Split value Per Rank 
ChrName=`sed -n ${LINE}p split.tmp.txt | awk '{print $1}'`
size=`sed -n ${LINE}p split.tmp.txt | awk '{print $2}'`
Start=`sed -n ${LINE}p split.tmp.txt | awk '{print $3}'`
End=`sed -n ${LINE}p split.tmp.txt | awk '{print $4}'`
INPUT=`cat Phase3.input.list`

echo "Phase3b"
mkdir -p /tmp/gatk_tmp/$ChrName.$size;
## Step 2
#echo " ----- Step 2, GATK: GenotypeGVCFs -----------"
#time -p gatk --java-options "-Xmx4g -Xms4g" GenotypeGVCFs --variant ${chunkVCF}/Combine.$ChrName.$size.vcf.gz --reference $REF --intervals $ChrName:$Start-$End --output ${genotype}/Genotype.$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp/$ChrName.$size/ #

## Step 3
echo " ----- Step 3, GATK: SelectVariants (SNPs) -----------"
time -p gatk --java-options "-Xmx4g -Xms4g" SelectVariants --variant ${genotype}/Genotype.$ChrName.$size.vcf.gz --reference $REF -select-type SNP --output $SNPs/$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp/$ChrName.$size/ #;

## Step 4
echo " ----- Step 4, GATK: VariantFiltration (SNPs) --------"
time -p gatk --java-options "-Xmx4g -Xms4g" VariantFiltration --variant $SNPs/$ChrName.$size.vcf.gz --reference $REF --filter-expression "QUAL < 30.0 || QD < 2.0 || MQ < 20.0 || MQRankSum < -3.0 || ReadPosRanKSum < -3.0 || DP < 5.0" --filter-name snp_filter --output $SNPs/filtered_snps.$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp/$ChrName.$size/ #;

## Step 5
#echo " ----- Step 5, GATK: SelectVariants (INDELs) -----------"
#time -p gatk --java-options "-Xmx4g -Xms4g" SelectVariants --variant ${genotype}/Genotype.$ChrName.$size.vcf.gz --reference $REF -select-type INDEL --output $INDELs/$ChrName.$size.vcf.gz --tmp-dir /tmp/gatk_tmp/$ChrName.$size/ #;

rm -rf /tmp/gatk_tmp/$ChrName.$size


 ## Step 6) add IDS,
bcftools annotate --set-id +'%CHROM\_%POS\_%REF\_%FIRST_ALT' -Oz -o $SNPs_withID/filtered_snps.$ChrName.$size.withID.vcf.gz $SNPs/filtered_snps.$ChrName.$size.vcf.gz
#bcftools annotate --set-id +'%CHROM\_%POS\_%REF\_%FIRST_ALT' -Oz -o $INDELs_withID/$ChrName.$size.withID.vcf.gz $INDELs/$ChrName.$size.vcf.gz

## Step 7) sort,
mkdir -p $SNPs_sort/tmmp.$ChrName.$size
bcftools sort -m 4G $SNPs_withID/filtered_snps.$ChrName.$size.withID.vcf.gz -Oz -o $SNPs_sort/filtered_snps.$ChrName.$size.SNPs.withID.sort.vcf.gz -T $SNPs_sort/tmmp.$ChrName.$size

#mkdir -p $INDELs_sort/tmmp.$ChrName.$size
#bcftools sort -m 4G $INDELs_withID/$ChrName.$size.withID.vcf.gz -Oz -o $INDELs_sort/$ChrName.$size.withID.sort.vcf.gz -T $INDELs_sort/tmmp.$ChrName.$size

#rm -rf $SNPs_withID $INDELs_withID $SNPs $INDELs


echo 'DONE'


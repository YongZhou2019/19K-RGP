#!/bin/bash
REF=$1;
SpliteLength=$2;
if [ "$#" -ne 2 ];
then
 printf "\033c"
 echo " ***************************************************************************************************************************"
 echo ""
 echo " Run this script with 2 arguments: "
 echo "      1. Your Reference file" 
 echo "      2. Your SpliteLength of the Chromosome size (e.g. 200000)"
 echo " "
 echo "  Example: "
 echo "    ./Phase3.prerequisite.sh /project/k01/kathirn/3k/ref/Nipponbare_chr.fasta 200000"
 echo ""
 echo " ***************************************************************************************************************************"
 exit;
else
  echo "Your Reference file: $REF "
  echo "Your gVCF file directory: $SpliteLength"
fi

rm -Rf submitted_chunks_data.txt split.txt distribution.txt; 


# Store the all the Chromosome Chunks for reference in a file "submitted_chunks_data.txt"
while IFS=$'\t' read -r -a myREF
do
 ChrName=${myREF[0]};
 ChrLen=${myREF[1]};
 Part=$(( $ChrLen / $SpliteLength )) ;
 tmp=$(( $Part * $SpliteLength )) ;
 if [ $ChrLen -gt $tmp ]; then
    Part=$(( $Part + 1 ));
    echo "$ChrName split into $Part parts" >> submitted_chunks_data.txt
 else 
    echo "$ChrName split into $Part parts" >> submitted_chunks_data.txt
 fi
done < $REF.fai

## Prepare the Split and Distribution 

while IFS=$'\t' read -r -a myREF
do
 size=1;
 ChunkSize=$SpliteLength;
 ChrName=${myREF[0]};
 ChrLen=${myREF[1]};

 ## PREPARE CHUNKS for EACH CHROMOSOME 
  for ((Start=1; Start<$ChrLen; Start+=$ChunkSize))
   do
     End=$(( $size*$ChunkSize ))
     if [ $End -lt $ChrLen ]
     then
       echo "$ChrName   $size   $Start  $End"  >> split.txt
       size=$(( $size + 1 ));
     else   ### Last chunk 
       Start=$(( $End - $ChunkSize +1 ));
       End=$ChrLen;
       echo "$ChrName  $size  $Start  $End"   >> split.txt
    fi ## END OF ALL CHUNKS within the specific CHROMOSOME 
 #  echo "Preparing for the next Chunk:" $ChrName.chunk_$size 
done ## END OF CHROMOSOME (Chr by Chr) 
  echo "$ChrName    $size" >> distribution.txt
done < $REF.fai
  ## END OF ALL CHROMOSOMEs

TotalLines=`cat split.txt | wc -l` ;
#Nodes=$(( ((TotalLines+31) / 32) ))
Nodes=$(( ((TotalLines+31) / 4) ))

echo "The following values can be set in your Phase3.batch "
echo " -N $Nodes and --ntasks=$TotalLines "


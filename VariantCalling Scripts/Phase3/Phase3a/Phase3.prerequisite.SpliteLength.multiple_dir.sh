#!/bin/bash

function menu()
{
# Bash Menu Script Example
  PS3='Please enter your choice: '
  options=("Enter '1' for Reference" 
	 "Enter '2' for no. of VCFs directory locations" 
	 "Enter '3' for SpliteLength of the Chromosome size" 
	 "Enter '4' for generating pre-requisite")

  select opt in "${options[@]}"
  do
    case $opt in
        "Enter '1' for Reference")
            read -p "Enter your Reference file location (e.g. /project/k01/kathirn/3k/ref/Nipponbare_chr.fasta): " REF ;
            ;;
        "Enter '2' for no. of VCFs directory locations")
	    read -p "Enter number of VCFs directory locations: " NOS ;
	    for LOC in `seq 1 $NOS`;
	     do
		 read -p "Enter your $LOC th absolute location of VCFs directory: " INPDIR[$LOC] ;
	     done
            ;;
        "Enter '3' for SpliteLength of the Chromosome size")
            read -p "Enter your SpliteLength of the Chromosome size (e.g. 200000): " SpliteLength
            ;;
        "Enter '4' for generating pre-requisite")
          if [[ -z $REF ]] && [[ -z $NOS ]] && [[ -z $SpliteLength ]]; then
	    echo "Reference, SpliteLength of the Chromosome size and gVCF file locations are not provided ... Exiting!!" ; 	
            break;
 	 else
	   rm -Rf submitted_chunks_data.txt split.txt distribution.txt; 
           distribute; 
 	   exit ;
          fi
            ;;
        *) echo "You entered Invalid option $REPLY";;
    esac
  done ;
 }

function distribute()
{  
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

## Add all the *.g.vcf files for CombineGVCF
set INPUT_TMP
for LOC in `seq 1 $NOS`;
 do
  for i in `ls -l ${INPDIR[$LOC]}/*.g.vcf.gz | awk '{print $9}'`
   do
     INPUT_TMP+="$i -V "; 
   done
 done 
    INPUT=${INPUT_TMP::-4} 
   echo $INPUT > Phase3.input.list
   echo "********* Pre-requisite 'Phase3.input.list' file was generated ************"
}

function main()
{
 menu ;
}
main ;



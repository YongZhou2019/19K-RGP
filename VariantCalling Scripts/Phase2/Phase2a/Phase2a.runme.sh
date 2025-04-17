genome=genome5
SBATCH=sbatch5
SZBATCH=szbatch26

Script=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/$SZBATCH/Scripts/Phase2/Phase2a
mkdir -p $Script

export REF=/project/k10069/shaheen2ref/"$genome".fa 
sh Phase2.prerequisite.SpliteLength.sh $REF 5000000 ### this will genrate split.txt


for i in $SZBATCH  #
do
 
#ls /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/$SBATCH/Results/New/tmpBAM/ | awk -F '.' '{print $1}'| sort | uniq > Phase2.prefix.txt

ls /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/$SBATCH/Results/New/tmpBAM/ | awk -F '.' '{print $1}' | sort | uniq | sed -n '6501,6704p' > Phase2.prefix.txt

wc=`less split.txt | wc -l`

chunk=0
#while(( chunk < "$wc")) ### you will need to use this.
while(( chunk < "wc")) ### this is the test 
do  
    let "chunk += 1"   ### same as: let 'i = i + 1'
    echo $chunk

    cd /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/Phase2_scripts/Phase2a
    chr=`sed -n ${chunk}p split.txt | awk '{print $1}'` ;
    size=`sed -n ${chunk}p split.txt | awk '{print $2}'` ;
    start=`sed -n ${chunk}p split.txt | awk '{print $3}'` ;
    end=`sed -n ${chunk}p split.txt | awk '{print $4}'` ;
echo $chr $size $start $end

## generate the submition file;
mkdir -p $Script/$chr.$size
cp Phase2.prefix.txt Phase2.c Phase2.exe $Script/$chr.$size/

cat Phase2a.Base.sh | sed -e "s/gggg/$genome/g" -e "s/chrNN/$chr/g"  -e "s/sizeNN/$size/g"  -e "s/startNN/$start/g"  -e "s/endNN/$end/g" -e "s/MMMM/$SBATCH/g" -e "s/NNNN/$szbatch/g" > $Script/$chr.$size/Phase2.sh

a1=`less Phase2.prefix.txt | wc -l`
a2=$(( ((a1+95) / 96) )) ### 96 jobs per node (comes by 384g/4g=96jobs)
echo "task="$a1 "N="$a2

cat Phase2a.Base.batch | sed -e "s/gggg/$genome/g" -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" > "$Script"/$chr.$size/Phase2.batch

cd "$Script"/$chr.$size/
sbatch Phase2.batch
cd $PWD


### sleep a bit for waiting a next chr job;

sleep 2s
squeue -u manickk
done
done



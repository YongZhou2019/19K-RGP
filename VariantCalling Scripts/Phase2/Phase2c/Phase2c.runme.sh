### phase2c is submitted based samples for cram files from bam files, per sbatch
### this is the one that run on shaheen2

genome=genome5
SBATCH=sbatch5
SZBATCH=szbatch20

Script=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/$SZBATCH/Scripts/Phase2
mkdir -p $Script/Phase2c

ls /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/"$genome"/$SBATCH/Results/New/MergeHCBAMs/ | awk -F '.' '{print $1}' > Phase2c.prefix.txt

cp Phase2c.prefix.txt $Script/Phase2c/
cp  Phase2.c Phase2.exe $Script/Phase2c/

cat Phase2c.Base.sh | sed -e "s/gggg/$genome/g" > $Script/Phase2c/Phase2.sh

a1=`cat $Script/Phase2c/Phase2c.prefix.txt | wc -l`
a2=$(( ((a1+95) / 96) )) ### 96 jobs per node (comes by 384g/4g=96jobs)

echo "task="$a1 "N="$a2

cat Phase2c.Base.batch | sed -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" > $Script/Phase2c/Phase2.batch

cd $Script/Phase2c 

sbatch Phase2.batch


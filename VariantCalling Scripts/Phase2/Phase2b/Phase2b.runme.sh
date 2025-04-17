### phase2b is submitted based samples (merge, MergeVcfs), per szbatch
genome=genome5
SBATCH=sbatch5
SZBATCH=szbatch26


Script=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/$SZBATCH/Scripts/Phase2/
mkdir -p $Script/Phase2b

cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase2_scripts/Phase2a/Phase2.prefix.txt $Script/Phase2b/
cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase2_scripts/Phase2a/split.txt $Script/Phase2b/
cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase2_scripts/Phase2b/Phase2.c  $Script/Phase2b/
cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase2_scripts/Phase2b/Phase2.exe $Script/Phase2b/

cat Phase2b.Base.sh | sed -e "s/gggg/$genome/g" -e "s/ssss/$SBATCH/g" > $Script/Phase2b/Phase2.sh

a1=`less $Script/Phase2b/Phase2.prefix.txt | wc -l`
a2=$(( ((a1+95) / 96) )) ### 96 jobs per node (comes by 384g/4g=96jobs)

echo "task="$a1 "N="$a2
cat Phase2b.Base.batch | sed -e "s/gggg/$genome/g" -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" > $Script/Phase2b/Phase2.batch

cd $Script/Phase2b
sbatch Phase2.batch

### sleep a bit for waiting a next chr job;
sleep 0.5s
squeue -u manickk


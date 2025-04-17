### pre-edit Phase1_Base.sh and Phase1_Base.batch
### change the Phase1_Base.sh and Phase1_Base.batch, now only change genome$ in this file;

genome=genome5  ### modify reference genome;!!!
SBATCH=sbatch5
SZBATCH=szbatch26

Script=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/$genome/$SBATCH/$SZBATCH/Scripts/Phase1

mkdir $Script 

### generate the file we need, prefix names;

ls /project/k10069/shaheen2_projects/05_10KRGP/03.cleandata/$SBATCH/$SZBATCH  | grep '1.fastq.gz' > "$Script"/Phase1.txt

cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase1_scripts/Phase1.exe "$Script"/Phase1.exe
cp /scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/sbatch5/Phase1_scripts/Phase1.c "$Script"/Phase1.c
### generate the excute file;
cat Phase1.Base.sh | sed "s/gggg/$genome/g" > "$Script"/Phase1.sh

### generate the submition file;
a1=`cat "$Script"/Phase1.txt | wc -l`
# a11=$(( (a1*2)  ))
 a2=$(( ((a1+23) / 24) )) ### 24 jobs/node, 8 cores per job

echo "batch"$i "task="$a1 "N="$a2
cat Phase1.Base.batch | sed -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" -e "s/gggg/$genome/g"  > "$Script"/Phase1.batch
cd "$Script"/
sbatch Phase1.batch

### sleep a bit for waiting a next chr job;
sleep 2s
squeue -u manickk



### 2024-06-12;

genome=genome5

### step1
export Scripts_scratch=/scratch/project/k10069/manickk/"$genome"/Phase4/
mkdir -p $Scripts_scratch

CurPath=`pwd` ### /project/k10069/scripts_shaheen3/genome33.20K.gvcfs/Phase3_SH4
cd $CurPath

cp distribution.txt Phase4.c Phase4.exe $Scripts_scratch/

# ### step2
	a1=`cat $Scripts_scratch/distribution.txt | wc -l`
	a2=$(( ((a1+47) / 48) )) ###  48个任务一个node跑
	
cat Phase4.Base.batch | sed -e "s/gggg/$genome/g" -e "s/xxxx/$a1/g" -e "s/yyyy/$a2/g" > $Scripts_scratch/Phase4.batch

cat Phase4.Base.sh | sed -e "s/gggg/$genome/g" > $Scripts_scratch/Phase4.sh
cd $Scripts_scratch
sbatch Phase4.batch


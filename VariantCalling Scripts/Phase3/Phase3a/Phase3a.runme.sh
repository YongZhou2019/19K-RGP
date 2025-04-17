### 2024-06-02;

genome=genome5
REF=/project/k10069/shaheen2ref/"$genome".fa

Scripts_scratch=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/Phase3_scripts

CurPath=`pwd` ### /project/k10069/scripts_shaheen3/genome33.20K.gvcfs/Phase3_SH3; /project/k10069/scripts_shaheen3/Phase3_SH3
cd $CurPath

# ###Phase3_Step1:
# ### change the intervals: range 100Kb to 500Kb;
# sh Phase3.prerequisite.SpliteLength.sh $REF $gVCFs 100000 #only 100K chunk, the jobs could be done within one day

###
# zhouy0e@login3:/project/k10069/scripts_shaheen3/Phase3_SH3> sh Phase3.prerequisite.SpliteLength.multiple_dir.sh 
# 1) Enter '1' for Reference ###REF=/project/k10069/shaheen2ref/"$genome".fa
# 2) Enter '2' for no. of VCFs directory locations
# 3) Enter '3' for SpliteLength of the Chromosome size
# 4) Enter '4' for generating pre-requisite
# Please enter your choice: 1
# Enter your Reference file location (e.g. /project/k01/kathirn/3k/ref/Nipponbare_chr.fasta): /project/k10069/shaheen2ref/genome33.fa
# Please enter your choice: 2
# Enter number of VCFs directory locations: 3
# Enter your 1 th absolute location of VCFs directory: /scratch/project/k10008/iops/genome33/20K.gvcfs/10K.gvcfs/
# Enter your 2 th absolute location of VCFs directory: /scratch/project/k10008/iops/genome33/20K.gvcfs/3K.gvcfs              
# Enter your 3 th absolute location of VCFs directory: /scratch/project/k10008/iops/genome33/20K.gvcfs/7K.gvcfs
# Please enter your choice: 3
# Enter your SpliteLength of the Chromosome size (e.g. 200000): 50000
# Please enter your choice: 4
# The following values can be set in your Phase3.batch 
#  -N 1983 and --ntasks=7904 
# ********* Pre-requisite 'Phase3.input.list' file was generated ************

###Phase3_Step2: seperte to 12 + unplaced chromsome and delete the tmp files; 
echo 'run: sbatch Phase3a.Chr$i.batch'
echo 'Here is an exmple what I did'
### trying to make it auto submit and delete the tmp files;

#LI=`cat split.txt | head -n 3802 | wc -l` ### 20kb/chunck, 18750  chuncks; head -n 100

LI=`cat missingtbilist.txt | wc -l`

# ### when it is failed for some chunks, this is the way out.
 # LI=`cat split2.txt | wc -l` ### 20kb/chunck, 18750  chuncks
 echo $LI
 
j=0 ### which line (+1) do you want to start with.
while(( j < $LI))
do
	cd $CurPath
     # let "sum+=i"
     let "j += 50" #let "j += 100"   ### same as: let 'i = i + 1' let "j += 200"
	 let "i = j - 49" #let "i = j - 99" ### let "i = j - 199"
		echo $i $j 

	mkdir -p $Scripts_scratch/Phase3a/"$i"
	#cp Phase3.c Phase3.exe Phase3.input.list $Scripts_scratch/Phase3a/"$i"/
	
	cp Phase3.c Phase3.exe Phase3.input.list XL.intervals $Scripts_scratch/Phase3a/"$i"/
	
	#cat split.txt | sed -n "$i","$j"p  > $Scripts_scratch/Phase3a/"$i"/split.tmp.txt
	
	cat missingtbilist.txt | sed -n "$i","$j"p  > $Scripts_scratch/Phase3a/"$i"/split.tmp.txt

	cat Phase3a.base.sh | sed -e "s/gggg/$genome/g" > $Scripts_scratch/Phase3a/"$i"/Phase3.sh 

	a1=`cat $Scripts_scratch/Phase3a/"$i"/split.tmp.txt | wc -l`
	# a2=$(( ((a1+49) / 50) )) ### 50 个任务一个node, test。
	# a2=$(( ((a1+9) / 10) )) ### 10个任务一个node, test
	# a2=$(( ((a1+1) / 2) )) ### 3个任务一个node, test; 160G/job, OOM failure
	 a2=$a1 ## 1个任务一个node, test
	echo $i "task="$a1 "N="$a2
	cat Phase3a.base.batch | sed -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" -e "s/gggg/$genome/g" -e "s/xxxx/$i/g" > $Scripts_scratch/Phase3a/"$i"/Phase3a."$i".batch
	cd $Scripts_scratch/Phase3a/"$i"/
	sbatch Phase3a."$i".batch
	echo $i " submitted"
	squeue -u manickk
	sleep 2s
done ### $j $i loop


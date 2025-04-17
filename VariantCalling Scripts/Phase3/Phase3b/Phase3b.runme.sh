### 2024-06-12;

genome=genome5
REF=/project/k10069/shaheen2ref/"$genome".fa

Scripts_scratch=/scratch/project/k10008/FromShaheen2ScratchK1671/manickk/genome5/Phase3_scripts
mkdir -p $Scripts_scratch/Phase3b

CurPath=`pwd` ### /project/k10069/scripts_shaheen3/genome33.20K.gvcfs/Phase3_SH3; 
cd $CurPath

LI=`cat split.txt | head -n 3801 | wc -l` ### 100kb/chunck 

#LI=`cat split.txt |head -n 10 |  wc -l`
echo $LI

### 3 jobs failed
# LI=`cat split4.txt | wc -l` ### 100kb/chunck
# echo $LI

j=0 ### which line (+1) do you want to start with.S
while(( j < $LI))
do
	cd $CurPath
     # let "sum+=i"
     #let "j += 10"   ### same as: let 'i = i + 1'
	#let "i = j - 9"
	let "j += 100" 
	let "i = j - 99"
		echo $i $j 

	mkdir -p $Scripts_scratch/Phase3b/"$i"/
	cp Phase3.c Phase3.exe Phase3.input.list $Scripts_scratch/Phase3b/"$i"/
	cat Phase3b.base.sh | sed -e "s/gggg/$genome/g" -e "s/xxxx/$i/g" > $Scripts_scratch/Phase3b/"$i"/Phase3.sh 
	cat split.txt | sed -n "$i","$j"p split.txt > $Scripts_scratch/Phase3b/"$i"/split.tmp.txt 
	
	#cat geno_misstbi.list | sed -n "$i","$j"p geno_misstbi.list > $Scripts_scratch/Phase3b/"$i"/split.tmp.txt
	
	a1=`cat $Scripts_scratch/Phase3b/"$i"/split.tmp.txt | wc -l`
	a2=$(( ((a1+47) / 48) )) ### 4g/job, 384g/4=96 jobs/node;

	echo $i "task="$a1 "N="$a2
	cat Phase3b.base.batch | sed -e "s/abcde/$a1/g" -e "s/abcd/$a2/g" -e "s/gggg/$genome/g" -e "s/xxxx/$i/g" > $Scripts_scratch/Phase3b/"$i"/Phase3b."$i".batch
	cd $Scripts_scratch/Phase3b/"$i"/
	sbatch Phase3b."$i".batch
	echo $i " submitted"
	squeue -u manickk
	sleep 2s 

done


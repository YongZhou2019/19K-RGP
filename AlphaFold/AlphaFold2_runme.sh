#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=batch
#SBATCH -J af
#SBATCH -o logs/af.%A_%a_%N.out
#SBATCH -e logs/af.%A_%a_%N.out
#SBATCH --time=1-00:00:00
#SBATCH --mem=150GB
#SBATCH --gres=gpu:v100:1
#SBATCH -c 4
#SBATCH --array=1-10

module load alphafold/2.3.1/python3 
export MYDIR=$PWD
export ALPHAFOLD_DATA_DIR=/ibex/reference/KSL/alphafold/2.3.1
export CUDA_VISIBLE_DEVICES=0
export TF_FORCE_UNIFIED_MEMORY=1
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.5
export XLA_PYTHON_CLIENT_ALLOCATOR=platform
export TMPDIR=/ibex/scratch/$USER/tmp

export INPUT=`ls -dl $MYDIR/*.fasta | awk '{print $9}' | head -n $SLURM_ARRAY_TASK_ID | tail -n 1` ;
export MYFILENAME=$(basename -- "$INPUT") ;
export SAMPLE=`basename $MYFILENAME .fasta`
## Run1
export OUTPUT=$MYDIR/$SAMPLE/run1
mkdir -p $OUTPUT;
python3 /ibex/sw/csg/alphafold/2.3.1/el7.9_conda/alphafold/run_alphafold.py  --use_gpu_relax  --data_dir=/ibex/reference/KSL/alphafold/2.3.1  --uniref90_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref90/uniref90.fasta  --mgnify_database_path=/ibex/reference/KSL/alphafold/2.3.1/mgnify/mgy_clusters_2022_05.fa  --bfd_database_path=/ibex/reference/KSL/alphafold/2.3.1/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt  --uniref30_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref30/UniRef30_2021_03 --template_mmcif_dir=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/mmcif_files  --obsolete_pdbs_path=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/obsolete.dat  --pdb70_database_path=/ibex/reference/KSL/alphafold/2.3.1/pdb70/pdb70  --model_preset=monomer  --max_template_date=2022-10-01  --db_preset=full_dbs --output_dir=$OUTPUT  --fasta_paths=$INPUT 


## Run2
export OUTPUT=$MYDIR/$SAMPLE/run2
mkdir -p $OUTPUT;
python3 /ibex/sw/csg/alphafold/2.3.1/el7.9_conda/alphafold/run_alphafold.py  --use_gpu_relax  --data_dir=/ibex/reference/KSL/alphafold/2.3.1  --uniref90_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref90/uniref90.fasta  --mgnify_database_path=/ibex/reference/KSL/alphafold/2.3.1/mgnify/mgy_clusters_2022_05.fa  --bfd_database_path=/ibex/reference/KSL/alphafold/2.3.1/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt  --uniref30_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref30/UniRef30_2021_03 --template_mmcif_dir=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/mmcif_files  --obsolete_pdbs_path=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/obsolete.dat  --pdb70_database_path=/ibex/reference/KSL/alphafold/2.3.1/pdb70/pdb70  --model_preset=monomer  --max_template_date=2022-10-01  --db_preset=full_dbs --output_dir=$OUTPUT  --fasta_paths=$INPUT 

## Run3
export OUTPUT=$MYDIR/$SAMPLE/run3
mkdir -p $OUTPUT;
python3 /ibex/sw/csg/alphafold/2.3.1/el7.9_conda/alphafold/run_alphafold.py  --use_gpu_relax  --data_dir=/ibex/reference/KSL/alphafold/2.3.1  --uniref90_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref90/uniref90.fasta  --mgnify_database_path=/ibex/reference/KSL/alphafold/2.3.1/mgnify/mgy_clusters_2022_05.fa  --bfd_database_path=/ibex/reference/KSL/alphafold/2.3.1/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt  --uniref30_database_path=/ibex/reference/KSL/alphafold/2.3.1/uniref30/UniRef30_2021_03 --template_mmcif_dir=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/mmcif_files  --obsolete_pdbs_path=/ibex/reference/KSL/alphafold/2.3.1/pdb_mmcif/obsolete.dat  --pdb70_database_path=/ibex/reference/KSL/alphafold/2.3.1/pdb70/pdb70  --model_preset=monomer  --max_template_date=2022-10-01  --db_preset=full_dbs --output_dir=$OUTPUT  --fasta_paths=$INPUT 

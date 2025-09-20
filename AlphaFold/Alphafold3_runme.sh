#!/bin/bash
#SBATCH --time=2:30:00
#SBATCH -A c2227
#SBATCH --gres=gpu:a100:1
#SBATCH -c 8
#SBATCH -o af3.run3.ZS135.rerun.transcript_Os01t0357100-02.out
#SBATCH -e af3.run3.ZS135.rerun.transcript_Os01t0357100-02.out
#SBATCH --mem=128GB


module load alphafold/3.0.0/python3.11

export PYTHONWARNINGS=ignore
export JAX_TRACEBACK_FILTERING=off
export CUDA_VISIBLE_DEVICES=0
export TF_FORCE_UNIFIED_MEMORY=1 
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.5
export XLA_PYTHON_CLIENT_ALLOCATOR=platform
                                                      
time run_alphafold.py --json_path=ZS135.rerun.transcript_Os01t0357100-02.json --db_dir=$DB_DIR --output_dir=ZS135.rerun.transcript_Os01t0357100-02.RUN1 --flash_attention_implementation=xla --model_dir=/ibex/scratch/projects/c2072/beegfs/work/alphafold/alphafold3/model_dir/

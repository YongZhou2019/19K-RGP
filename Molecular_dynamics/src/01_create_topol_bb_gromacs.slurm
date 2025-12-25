#!/bin/bash
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=v100:1
#SBATCH --cpus-per-gpu=6  
#SBATCH --mem=64G
#SBATCH --partition=batch 
#SBATCH --job-name=fixbb_4_gmx
#SBATCH --mail-type=ALL
#SBATCH --output=%x-%j-slurm.out
#SBATCH --error=%x-%j-slurm.err 

# Load environment which has Jupyter installed. It can be one of the following:
# - Machine Learning module installed on the system (module load machine_learning)
# - your own conda environment on Ibex
# - a singularity container with python environment (conda or otherwise)  

# setup the environment
module purge

# You can use the machine learning module 
#module load machine_learning/2022.11
# or you can activate the conda environment directly by uncommenting the following lines
export CONDA_PKGS_DIRS=/ibex/user/barradd/conda_cache
source /ibex/user/barradd/miniconda3/bin/activate
export ENV_PREFIX=/ibex/scratch/projects/c2002/sfGPF-xtrf/biobb_wf_md_setup/env
conda activate $ENV_PREFIX
sleep 60
~/scwrl4/Scwrl4 -i structure.pdb -o structure_complex.pdb -h > /dev/null
sleep 30
python /ibex/project/c2002/rice_and_af2/src/create_topol_and_conc.py 


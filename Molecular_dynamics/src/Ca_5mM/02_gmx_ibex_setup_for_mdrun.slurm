#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=v100:1
#SBATCH --cpus-per-gpu=16
#SBATCH --mem=32G
#SBATCH --partition=batch 
#SBATCH --job-name=gmx_ibex_ca_medium
#SBATCH --mail-type=ALL
#SBATCH --output=%x-%j-slurm.out
#SBATCH --error=%x-%j-slurm.err 

# You can use the machine learning module 
#module load machine_learning/2022.11
# or you can activate the conda environment directly by uncommenting the following lines
export CONDA_PKGS_DIRS=/ibex/user/barradd/conda_cache
source /ibex/user/barradd/miniconda3/bin/activate

export ENV_PREFIX=/ibex/project/c2002/rice_and_af2/biobb_wf_md_setup/env
conda activate $ENV_PREFIX
sleep 60

### get all the mdp files 
wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/minimization.mdp
wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/nvt.mdp
wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/npt.mdp
wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/free.mdp
wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/ions.mdp

echo 14 > in.txt
sleep 60

# Step 1: Generate topology
gmx -nobackup -nocopyright pdb2gmx -f ../structure_complex_fixed_pymol_phosphorilated_with_Ca_renamed.pdb -o structure_complex_pdb2gmx.gro -p p2g.top -water spce -ff amber99sb-ildn -i posre.itp

# Step 2: Define box
gmx -nobackup -nocopyright editconf -f structure_complex_pdb2gmx.gro -o structure_complex_editconf.gro -d 1.0 -bt cubic -c

# Step 3: Solvate
gmx -nobackup -nocopyright solvate -cp structure_complex_editconf.gro -cs spc216.gro -o structure_complex_solvate.gro -p p2g.top

# Step 4: Add Na+ and Cl- ions for neutralization and 0.14 M NaCl concentration
gmx -nobackup -nocopyright grompp -f minimization.mdp -c structure_complex_solvate.gro -r structure_complex_solvate.gro -p p2g.top -o structure_complex_gppion.tpr -po mdout.mdp -maxwarn 1

gmx -nobackup -nocopyright genion -s structure_complex_gppion.tpr -o structure_complex_genion_NaCl.gro -p p2g.top -neutral -conc 0.14 -pname NA -nname CL -seed 1993 < in.txt

# Step 5: Add Ca2+ ions for 5 mM (0.005 M) concentration
gmx -nobackup -nocopyright grompp -f minimization.mdp -c structure_complex_genion_NaCl.gro -r structure_complex_genion_NaCl.gro -p p2g.top -o structure_complex_gppca.tpr -po mdout.mdp -maxwarn 1

# Adjust -np based on your system size
# Here, we assume adding 2 Ca2+ ions to the 6 structural in the EF-hand of CBL8 for 5 mM concentration
gmx -nobackup -nocopyright genion -s structure_complex_gppca.tpr -o structure_complex_genion_final.gro -p p2g.top -pname CA -np 2 -nname CL -nn 4 -seed 1994 < in.txt

# Step 6: Energy minimization with all ions
gmx -nobackup -nocopyright grompp -f minimization.mdp -c structure_complex_genion_final.gro -r structure_complex_genion_final.gro -p p2g.top -o structure_complex_gppmin.tpr -po mdout.mdp -maxwarn 10

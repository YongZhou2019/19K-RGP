#!/bin/bash
#SBATCH --nodes=3
#SBATCH --partition=workq
#SBATCH --ntasks-per-core=1
#SBATCH --time=24:00:00
#SBATCH --error=log/gromacs_err_%j.err
#SBATCH --output=log/gromacs_out_%j.out
#SBATCH -J gromacs
#SBATCH -A v10004

#----------------------------------------------------------#
echo "The job "${SLURM_JOB_ID}" is running on "${SLURM_JOB_NODELIST}
#----------------------------------------------------------#

module swap PrgEnv-cray PrgEnv-intel
module load gromacs/2021.4

export CRAY_ROOTFS=DSL 
export OMP_NUM_THREADS=1

### get all the mdp files 
# wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/minimization.mdp
# wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/nvt.mdp
# wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/npt.mdp
# wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/free.mdp
# wget https://biobb-gromacs.readthedocs.io/en/latest/_static/mdp/ions.mdp

### create a file to input gromacs to select the SOL particule (solvent)
echo 13 > in.txt
sed -i "s:nsteps = 5000:nsteps = 60000000:g" free.mdp
sleep 10
gmx -nobackup -nocopyright pdb2gmx -f ../structure_complex_fixed.pdb -o structure_complex_pdb2gmx.gro -p p2g.top -water spce -ff amber99sb-ildn -i posre.itp
gmx -nobackup -nocopyright editconf -f structure_complex_pdb2gmx.gro -o structure_complex_editconf.gro -d 1.0 -bt cubic -c
gmx -nobackup -nocopyright solvate -cp structure_complex_editconf.gro -cs spc216.gro -o structure_complex_solvate.gro -p p2g.top
gmx -nobackup -nocopyright grompp -f minimization.mdp  -c structure_complex_solvate.gro -r structure_complex_solvate.gro -p p2g.top -o structure_complex_gppion.tpr -po mdout.mdp -maxwarn 1
gmx -nobackup -nocopyright genion -s structure_complex_gppion.tpr -o structure_complex_genion_.gro -p p2g.top -neutral -conc 0.14 -seed 1993 < in.txt
gmx -nobackup -nocopyright grompp -f minimization.mdp -c structure_complex_genion_.gro -r structure_complex_genion_.gro -p p2g.top -o structure_complex_gppmin.tpr -po mdout.mdp -maxwarn 10

#### minization one ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppmin.tpr -o structure_complex_min.trr -c structure_complex_min.gro -e structure_complex_min.edr -g structure_complex_min.log

gmx -nobackup -nocopyright grompp -f nvt.mdp -c structure_complex_min.gro -r structure_complex_min.gro -p p2g.top -o structure_complex_gppnvt.tpr -po mdout.mdp -maxwarn 10


#### nvt minimization ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppnvt.tpr -o structure_complex_nvt.trr -c structure_complex_nvt.gro -e structure_complex_nvt.edr -g structure_complex_nvt.log -cpo structure_complex_nvt.cpt

gmx -nobackup -nocopyright grompp -f npt.mdp -c structure_complex_nvt.gro -r structure_complex_nvt.gro -p p2g.top -o structure_complex_gppnpt.tpr -po mdout.mdp -maxwarn 10 -t structure_complex_nvt.cpt

#### npt minimization ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppnpt.tpr -o structure_complex_npt.trr -c structure_complex_npt.gro -e structure_complex_npt.edr -g structure_complex_npt.log -cpo structure_complex_npt.cpt 

gmx -nobackup -nocopyright grompp -f free.mdp -c structure_complex_npt.gro -r structure_complex_npt.gro -p p2g.top -o structure_complex_gppmd.tpr -po mdout.mdp -maxwarn 10 -t structure_complex_npt.cpt

#### MD simulation #### 
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppmd.tpr -o structure_complex_md.trr -c structure_complex_md.gro -e structure_complex_md.edr -g structure_complex_md.log -cpo structure_complex_md.cpt 

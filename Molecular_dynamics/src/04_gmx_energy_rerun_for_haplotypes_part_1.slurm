#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --partition=workq 
#SBATCH --job-name=gmx_rerun
#SBATCH --mail-type=ALL
#SBATCH --output=log/%x-%j-slurm.out
#SBATCH --error=log/%x-%j-slurm.err
#SBATCH -A v10004

#----------------------------------------------------------#
echo "The job "${SLURM_JOB_ID}" is running on "${SLURM_JOB_NODELIST}
#----------------------------------------------------------#

module swap PrgEnv-cray PrgEnv-intel
module load gromacs/2021.4

export CRAY_ROOTFS=DSL 
export OMP_NUM_THREADS=1

#sleep 10

# this are the commands to create the index files
gmx make_ndx -nobackup -f structure_complex_md.gro -o index.ndx < ../index_chains_md_sim.txt
sleep 10

module swap gromacs/2021.4 gromacs/2025.3

# this specific to the CBL8_CIPK17 complex  
# MD_scripts/free_contacts_CIPK17_CBL8_interface.mdp
gmx -nobackup -nocopyright grompp -n index.ndx -f ../free_contacts_CIPK17_CBL8_interface.mdp -c structure_complex_npt.gro -r structure_complex_npt.gro -p p2g.top -t structure_complex_npt.cpt -o structure_complex_gppmd_contacts_CIPK_CBL8.tpr -po mdout_contacts_CIPK_CBL8.mdp -maxwarn 10
srun --ntasks=192 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -rerun structure_complex_md.trr -s structure_complex_gppmd_contacts_CIPK_CBL8.tpr -deffnm energy_rerun_CIPK_CBL8_NAC77_interface
#
gmx -nobackup -nocopyright grompp -n index.ndx -f ../free_contacts_CIPK17_CBL8_proteins.mdp -c structure_complex_npt.gro -r structure_complex_npt.gro -p p2g.top -t structure_complex_npt.cpt -o structure_complex_gppmd_contacts_CIPK_CBL8.tpr -po mdout_contacts_CIPK_CBL8.mdp -maxwarn 10
srun --ntasks=192 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -rerun structure_complex_md.trr -s structure_complex_gppmd_contacts_CIPK_CBL8.tpr -deffnm energy_rerun_CIPK_CBL8_NAC77_proteins

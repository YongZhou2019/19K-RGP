
#!/bin/bash
#SBATCH --nodes=3
#SBATCH --partition=workq
#SBATCH --ntasks-per-core=1
#SBATCH --time=24:00:00
#SBATCH --error=log/gromacs_Ca_med_err_%j.err
#SBATCH --output=log/gromacs_Ca_med_out_%j.out
#SBATCH -J gmx_Ca_med
#SBATCH -A v10004

#----------------------------------------------------------#
# CALCIUM SIMULATION - MEDIUM CONCENTRATION (5 mM CaCl2)
# Physiological stress signaling condition
# Total ionic strength: ~0.14 M NaCl + 5 mM CaCl2
#----------------------------------------------------------#
echo "The job "${SLURM_JOB_ID}" is running on "${SLURM_JOB_NODELIST}
#----------------------------------------------------------#

module swap PrgEnv-cray PrgEnv-intel
module load gromacs/2025.3

export CRAY_ROOTFS=DSL 
export OMP_NUM_THREADS=1

#### Minimization ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppmin.tpr -o structure_complex_min.trr -c structure_complex_min.gro -e structure_complex_min.edr -g structure_complex_min.log

# Step 7: NVT equilibration
gmx -nobackup -nocopyright grompp -f nvt.mdp -c structure_complex_min.gro -r structure_complex_min.gro -p p2g.top -o structure_complex_gppnvt.tpr -po mdout.mdp -maxwarn 11

#### NVT equilibration ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppnvt.tpr -o structure_complex_nvt.trr -c structure_complex_nvt.gro -e structure_complex_nvt.edr -g structure_complex_nvt.log -cpo structure_complex_nvt.cpt

# Step 8: NPT equilibration
gmx -nobackup -nocopyright grompp -f npt.mdp -c structure_complex_nvt.gro -r structure_complex_nvt.gro -p p2g.top -o structure_complex_gppnpt.tpr -po mdout.mdp -maxwarn 10 -t structure_complex_nvt.cpt

#### NPT equilibration ##
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppnpt.tpr -o structure_complex_npt.trr -c structure_complex_npt.gro -e structure_complex_npt.edr -g structure_complex_npt.log -cpo structure_complex_npt.cpt 

# Step 9: Production MD
gmx -nobackup -nocopyright grompp -f free.mdp -c structure_complex_npt.gro -r structure_complex_npt.gro -p p2g.top -o structure_complex_gppmd.tpr -po mdout.mdp -maxwarn 10 -t structure_complex_npt.cpt

#### MD simulation #### 
srun --ntasks=576 --hint=nomultithread ${GROMACS_HOME}/bin/gmx_mpi -nobackup -nocopyright mdrun -s structure_complex_gppmd.tpr -o structure_complex_md.trr -c structure_complex_md.gro -e structure_complex_md.edr -g structure_complex_md.log -cpo structure_complex_md.cpt

echo "Simulation complete - Medium Ca2+ concentration (5 mM)"
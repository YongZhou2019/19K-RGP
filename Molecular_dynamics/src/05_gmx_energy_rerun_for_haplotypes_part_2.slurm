#!/bin/bash
#SBATCH --job-name=gmx_rerun
#SBATCH --partition=workq
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=24
#SBATCH --time=02:00:00
#SBATCH --output=log/%x-%j.out
#SBATCH --error=log/%x-%j.err
#SBATCH -A v10004


echo "Job ${SLURM_JOB_ID} running on ${SLURM_JOB_NODELIST}"
echo "Total tasks: ${SLURM_NTASKS}, CPUs per task: ${SLURM_CPUS_PER_TASK}"

# Load environment
module swap PrgEnv-cray PrgEnv-intel
module load gromacs/2025.3

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Input files
TPR="structure_complex_gppmd.tpr"
TRR="structure_complex_md.trr"
NDX="index.ndx"

# Regions (must match names in index.ndx)
REGIONS=(CBL8_protein CIPK17_protein interface_CIPK17_to_CBL8 interface_CBL8_to_CIPK17 NAC77_protein interface_NAC77_dimer interface_NAC77_to_CIPK17 interface_CIPK17_to_NAC77)

mkdir -p log

# Parallel execution with proper piping
for i in "${REGIONS[@]}"; do
    srun --exclusive -n1 echo ${i} | gmx -nobackup -nocopyright rmsf \
        -s ${TPR} \
        -f ${TRR} \
        -n ${NDX} \
        -o rmsf_selected_regions_${i}.xvg -res \
        > log/gyrate_${i}.out 2>&1 &
done

wait  # Wait for all parallel tasks to finish

# Parallel execution with proper piping
for i in "${REGIONS[@]}"; do
    srun --exclusive -n1 echo ${i} | gmx -nobackup -nocopyright gyrate \
        -s ${TPR} \
        -f ${TRR} \
        -n ${NDX} \
        -o gyration_selected_region_${i}.xvg \
        > log/gyrate_${i}.out 2>&1 &
done

wait  # Wait for all parallel tasks to finish

# Energy analysis (also needs piping)
srun --exclusive -n1 gmx -nobackup -nocopyright energy \
    -f energy_rerun_CIPK_CBL8_NAC77_proteins.edr \
    -o energy_analysis_CIPK17_CBL8_NAC77_proteins.xvg < in_for_energy_protein_list_v2.txt

srun --exclusive -n1 gmx -nobackup -nocopyright energy \
    -f energy_rerun_CIPK_CBL8_NAC77_interface.edr \
    -o energy_analysis_CIPK17_CBL8_NAC77_interfaces.xvg < in_for_energy_interface_list_v2.txt

# Conversion 
srun --exclusive -n1 echo "Protein" "Protein" | gmx -nobackup -nocopyright trjconv \
    -s structure_complex_gppmd.tpr \ 
    -b 0 -e 120000 -fit none -center -pbc mol -ur compact \ 
    -f traj_comp.xtc \
    -o structure_complex_md_noPDB.xtc \

srun --exclusive -n1 echo "Protein" | gmx -nobackup -nocopyright trjconv -nocenter \
    -s structure_complex_gppmd.tpr \
    -f structure_complex_md.gro \
    -o structure_complex_md_dry.gro


echo "All tasks completed successfully."


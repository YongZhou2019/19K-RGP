#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-gpu=16
#SBATCH --mem=32G
#SBATCH -C a100
#SBATCH --partition=batch 
#SBATCH --job-name=bionemo
#SBATCH --mail-type=ALL
#SBATCH --output=logs/out/%x-%j-slurm.out
#SBATCH --error=logs/err/%x-%j-slurm.err

# setup the environment
module load rl9-gpustack
module load nvidia-sdk/nvhpc/23.1

export XDG_RUNTIME_DIR=/tmp node=$(hostname -s) 
user=$(whoami) 
submit_host=${SLURM_SUBMIT_HOST} 
port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
local_ip=$(hostname -I  | awk -F" " '{print $1}')

# Ensure directories exist
mkdir -p /run/user/${UID}/bus /ibex/user/${user}/podman_images

echo -e "

${node} pinned to port ${port}

You can now view your Jupyter Lab in your browser.

Network URL: http://${local_ip}:${port}
Network URL: http://${node}.kaust.edu.sa:${port}

" >&2


podman run \
-e NVIDIA_VISIBLE_DEVICES='' \
--rm \
-p ${port}:8888 \
-p 8501:8501 \
--device=nvidia.com/gpu=all \
--security-opt=label=disable \
--root=/ibex/user/${user}/podman_images \
-v ${PWD}:/workspace/data \
nvcr.io/nvidia/clara/bionemo-framework:nightly \
jupyter lab --no-browser --port-retries=0  --ip=0.0.0.0 --allow-root



date
echo "filesystem check"
find /tmp/${user}/podman/overlay \! -user ${user} -ls | head
date
#!/bin/bash

####### For Server/WorkStation Grade machines
####### Refer to: https://slurm.schedmd.com/mc_support.html

#SBATCH --job-name=xxx

##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=xxx@go.olemiss.edu

#SBATCH --time=30-00:00:00
#SBATCH --nodes=1

####### -B socket[:core[:thread]]
#SBATCH -B 1:12:1

#SBATCH --mem-per-cpu=200M

#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=12
#SBATCH --ntasks-per-socket=12
#SBATCH --ntasks-per-core=1
#SBATCH --hint=nomultithread

#SBATCH --gres=gpu:2

cd $SLURM_SUBMIT_DIR

####### The current slurm job file uses NVIDIA GPU MPS accelerator for fast LAMMPS runs;
####### set "-B 1:*:*" to maximize the efficiency for multi-GPUs in PCIe 3.0 systems
####### (avoid bandwidth issue between 2 CPUs) as much as possible;
####### set "-B *:*:1", "--cpus-per-task=1", and "--hint=nomultithread" to match the
####### disabled hyperthreading.

####### node01/04: 2*{cpu(20c)@2.4GHz} + 2*{gpu(48cu)} (HT disabled);

####### As of 03/24, multiple nvidia-cuda-mps-server instances can finally work on
####### different GPUs, which means one can submit & run 2 jobs with one gpu each job
####### at the same time. Thanks to the updated RHEL 9, Linux kernel 5.14, CUDA 12.3
####### ("On a Single-User System" in https://docs.nvidia.com/deploy/mps/index.html),
####### and slurm 23.02.07 packages.

####### If run single urgent case, use 1*12 MPI (~60% per CPU) + 2 GPU for the job will
####### be the best for efficiency (Ref: 100%); <the current one>
####### If run series normal cases, use 1*12 MPI (~60% per CPU) + 1 GPU for each job will
####### be the best for efficiency (Ref:  70%);
####### Hence, you will get 2*0.7x = 1.4x times the acceleration for 2 cases using 1
####### GPU each rather than run them one by one using 2 GPUs.

####### Change the email address in "--mail-user" entry if need notifications.

module load openmpi
module load openblas
module load fftw3
module load lammps/gcc/sfft/openmpi/cuda/2Aug23.3

export CUDA_MPS_PIPE_DIRECTORY=$SLURM_SUBMIT_DIR/nvidia-mps.$SLURM_JOB_ID
export CUDA_MPS_LOG_DIRECTORY=$SLURM_SUBMIT_DIR/nvidia-log.$SLURM_JOB_ID
nvidia-cuda-mps-control -d
sleep 1

mpiexec --map-by core --bind-to core --report-bindings -n 12 lmp_mpi -sf gpu -pk gpu 2 neigh yes newton on pair/only off split 1.0 -i input.lmps

sleep 1
echo quit | nvidia-cuda-mps-control
sleep 1
rm -r $SLURM_SUBMIT_DIR/nvidia-*

module purge

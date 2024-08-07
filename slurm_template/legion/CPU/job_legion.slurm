#!/bin/bash

####### For Laptop/PC Grade machines
####### Refer to: https://slurm.schedmd.com/mc_support.html

#SBATCH --job-name=xxx

##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=xxx@go.olemiss.edu

#SBATCH --time=30-00:00:00
#SBATCH --nodes=1

####### -B socket[:core[:thread]]
#SBATCH -B 1:16:1

#SBATCH --mem-per-cpu=500M

#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=16
#SBATCH --ntasks-per-socket=16
#SBATCH --ntasks-per-core=1
#SBATCH --hint=nomultithread

##SBATCH --gres=gpu:1

cd $SLURM_SUBMIT_DIR

####### The current slurm job file uses only CPU for LAMMPS runs;
#######
#######
####### set "-B *:*:1", "--cpus-per-task=1", and "--hint=nomultithread" to match the
####### disabled hyperthreading.

####### legion:    1*{cpu(16c)@2.5GHz} + 1*{gpu(76cu)} (HT disabled);

####### As of 03/24, slurm has been updated to 23.02.07 version.
#######
#######
#######
#######

####### Use 1*16 MPI (100% CPU) for the job will
####### be the best for efficiency (Ref: 100%); <the current one>
#######
#######
#######
#######

####### Change the email address in "--mail-user" entry if need notifications.

module load openmpi
module load openblas
module load fftw3
module load lammps/gcc/sfft/openmpi/cuda/2Aug23.3

#export CUDA_MPS_PIPE_DIRECTORY=$SLURM_SUBMIT_DIR/nvidia-mps.$SLURM_JOB_ID
#export CUDA_MPS_LOG_DIRECTORY=$SLURM_SUBMIT_DIR/nvidia-log.$SLURM_JOB_ID
#nvidia-cuda-mps-control -d
#sleep 1

mpiexec --map-by core --bind-to core --report-bindings -n 16 lmp_mpi -i input.lmps

#sleep 1
#echo quit | nvidia-cuda-mps-control
#sleep 1
#rm -r $SLURM_SUBMIT_DIR/nvidia-*

module purge

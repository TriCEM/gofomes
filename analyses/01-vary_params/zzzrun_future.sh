#!/bin/bash
#SBATCH --job-name=fomes_sim_varyparams
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nbrazeau@med.unc.edu
#SBATCH --ntasks=256
#SBATCH --mem=128G
#SBATCH --time=5-00:00:00
#SBATCH --output=fomes_varyparams_%j.log


## remember R can only handle 128-3 connections at time
## LongLeaf has 24-36 cores per node on general
R CMD BATCH 01-run_fomes_on_maestro.R

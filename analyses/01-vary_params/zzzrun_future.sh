#!/bin/bash
#SBATCH --job-name=fomes_sim_varyparams
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nbrazeau@med.unc.edu
#SBATCH --ntasks=36
#SBATCH --mem=256G
#SBATCH --time=5-00:00:00
#SBATCH --output=fomes_varyparams_%j.log

R CMD BATCH 01-run_fomes_on_maestro.R

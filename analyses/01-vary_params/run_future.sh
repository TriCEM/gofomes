#!/bin/bash
#SBATCH --job-name=fomes_sim_networks
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nbrazeau@med.unc.edu
#SBATCH --ntasks=36
#SBATCH --mem=64G
#SBATCH --time=5-00:00:00
#SBATCH --output=fomes_networks_%j.log

R CMD BATCH analyses/_future_fomesSim.R


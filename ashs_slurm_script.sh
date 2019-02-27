#!/bin/bash
#SBATCH --job-name=ashs_temp
#SBATCH -N 1
#SBATCH -c 4 
#SBATCH --partition=all,long,wks
#SBATCH --mem=20000
#SBATCH -o slurm.%N.%j.out 
#SBATCH -e slurm.%N.%j.error  

/data/fasttemp/uqtshaw/nlinmocopaper/ashs_script.sh $SUBJNAME


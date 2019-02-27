#!/bin/bash
for subjName in `cat /data/fasttemp/uqtshaw/qsm28/subjnames.csv` ; do
        sbatch --export=SUBJNAME=$subjName /data/fasttemp/uqtshaw/nlinmocopaper/ashs_slurm_script.sh
done

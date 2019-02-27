#!/bin/bash
#this is the ashs script for qsm28 dataset (or any in bids format with pp/mc scripts run)
#Thomas Shaw 11/2/19 
#run ashs after checking inputs exist
#run this on nlin, lin, and average for qsm study
#this is the one for the nlin paper. 
subjName=$1
source ~/.bashrc
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4
export NSLOTS=4
#module load freesurfer/6.0
#module load singularity/2.4.2

ashs_singularity="singularity exec --bind /data:/data /data/fastertemp/uqtshaw/7Tea/derivatives/ashs_20180427.simg"
bidsdir=/data/fasttemp/uqtshaw/qsm28
ss="ses-01"
deriv=$bidsdir/derivatives
t1wpp=$deriv/preprocessing/$subjName/${subjName}_${ss}_T1w_N4corrected_norm_brain_preproc.nii.gz
t2NLIN=$deriv/tse_mc/${subjName}/${subjName}_${ss}_T2w_NlinMoCo_res-iso.3_N4corrected_norm_denoised_brain_preproc.nii.gz
t2LIN=$deriv/preprocessing/$subjName/${subjName}_${ss}_T2w_LinMoCo_res-iso.3_N4corrected_norm_denoised_brain_preproc.nii.gz
t2AVE=$deriv/preprocessing/$subjName/${subjName}_${ss}_T2w_run-mean_res-iso.3_N4corrected_norm_denoised_brain_preproc.nii.gz 
eval=/data/lfs2/software/tools/EvaluateSegmentation/EvaluateSegmentation
#eval truth, segment
evals="-use DICE,ICCORR"
#-xml result.xml
deriv=/data/fasttemp/uqtshaw/qsm28/derivatives
source ~/.bashrc
export FSLOUTPUTTYPE=nii.gz
export FSLDIR=/data/lfs2/software/fsl/5.0/
. ${FSLDIR}/etc/fslconf/fsl.sh

#ashs of templates to be done beforehand. 
#$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2NLIN -w $deriv/ashs/${subjName}/1_nlin
#$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2LIN -w $deriv/ashs/${subjName}/2_lin
#$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2AVE -w $deriv/ashs/${subjName}/3_ave

#to be run once after ASHS on templates is done
#for reg in 1_nlin 2_lin 3_ave ; do
# fslmaths $deriv/templates_of_ashs_results/${reg}/${reg}_ashs_of_template/final/${reg}_ashs_left_lfseg_corr_nogray.nii.gz -add $deriv/templates_of_ashs_results/${reg}/${reg}_ashs_of_template/final/${reg}_ashs_right_lfseg_corr_nogray.nii.gz $deriv/templates_of_ashs_results/${reg}/${reg}_ashs_of_template/final/${reg}_ashs_combined_lfseg_corr_nogray.nii.gz; 
#done


/data/home/uqtshaw/bin/ants/bin//DenoiseImage -d 3 -i ${deriv}/tse_mc/$subjName/${subjName}_${ss}_T2w_NlinMoCo_res-iso.3_N4corrected_norm_brain_preproc.nii.gz -n Rician -o ${deriv}/tse_mc/$subjName/${subjName}_${ss}_T2w_NlinMoCo_res-iso.3_N4corrected_norm_denoised_brain_preproc.nii.gz
mkdir -p $deriv/ashs/${subjName}
$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2NLIN -w $deriv/ashs/${subjName}/1_nlin
$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2LIN -w $deriv/ashs/${subjName}/2_lin
$ashs_singularity /ashs-1.0.0/bin/ashs_main.sh -I $subjName -a /ashs_atlas_upennpmc_20170810 -g $t1wpp -f $t2AVE -w $deriv/ashs/${subjName}/3_ave
mkdir $deriv/templates_of_ashs_results/1_nlin/invWarps
mkdir $deriv/templates_of_ashs_results/2_lin//invWarps
mkdir $deriv/templates_of_ashs_results/3_ave/invWarps
mv $deriv/templates_of_ashs_results/3_ave/*Inverse* $deriv/templates_of_ashs_results/3_ave/invWarps/
mv $deriv/templates_of_ashs_results/2_lin/*Inverse* $deriv/templates_of_ashs_results/2_lin/invWarps/
mv $deriv/templates_of_ashs_results/1_nlin/*Inverse* $deriv/templates_of_ashs_results/1_nlin/invWarps/


#warp
for method in 1_nlin 2_lin 3_ave ; do
    for side in left right ; do
	#warp segs. 
	WarpImageMultiTransform 3 $deriv/ashs/$subjName/$method/final/${subjName}_${side}_lfseg_corr_nogray.nii.gz $deriv/templates_of_ashs_results/$method/${subjName}_${side}_lfseg_corr_nogray_warped_to_template.nii.gz -R $deriv/templates_of_ashs_results/${method}/${method}template1.nii.gz $deriv/templates_of_ashs_results/${method}/${method}${subjName}_mprage*Warp.nii.gz $deriv/templates_of_ashs_results/${method}/${method}${subjName}*GenericAffine.mat --use-NN
    done
done



#overlap metrics
#first combine all of the files together using fslmaths
for reg in 1_nlin 2_lin 3_ave ; do
    
    fslmaths $deriv/templates_of_ashs_results/$reg/${subjName}_right_lfseg_corr_nogray_warped_to_template.nii.gz -add $deriv/templates_of_ashs_results/$reg/${subjName}_left_lfseg_corr_nogray_warped_to_template.nii.gz $deriv/templates_of_ashs_results/$reg/${subjName}_combined_lfseg_corr_nogray_warped_to_template.nii.gz
done

#list all the subjects normally 

#compare each of these to their respective tse template in terms of the segmented volumes (newly created)
for reg in 1_nlin 2_lin 3_ave ; do
    $eval $deriv/templates_of_ashs_results/$reg/${subjName}_combined_lfseg_corr_nogray_warped_to_template.nii.gz $deriv/templates_of_ashs_results/${reg}/${reg}_ashs_of_template/final/${reg}_ashs_combined_lfseg_corr_nogray.nii.gz $evals -xml $deriv/templates_of_ashs_results/${subjName}_${reg}_combined_lfseg_corr_nogray-template_comparison.xml
done

<<EOF

#compare each case between subjects (different text files created using permuation creator, only to be run once.)
for reg in 1_nlin 2_lin 3_ave ; do
    for x in `seq 1 812` ; do
        $eval `sed -n "${x}p" /data/fasttemp/uqtshaw/qsm28/QSM28/7_evaluate_registrations/subjnames_${reg}_perms.csv | cut -d ',' -f    1` `sed -n "${x}p" /data/fasttemp/uqtshaw/qsm28/QSM28/7_evaluate_registrations/subjnames_${reg}_perms.csv | cut -d ',' -f2`  $evals     -xml $deriv/registration_results/${x}_${reg}_pairwise_comparison_V2.xml
    done
done

EOF

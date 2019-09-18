# NonLinRegImprovesSegRel
Non linear registration improves segmentation reliability

Code (hopefully) runs with BIDS on Slurm or serially. Singularity image contains FSL, ASHS, ROBEX, and ANTs 

1) PP_script.sh (preprocessing)
2) tse_mc.sh (motion correction - Non linear realignment)
3) tse_lin script is for the linear and averaging steps
3) ashs and evaluate registrations are for applying ASHS to the templates and individual scans, warping the labels to template space.
4) evaluating segmentations done in last script including sharpness estimation and overlap metrics.


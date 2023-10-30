## bash script to get the old retinotopy and ROI data from the NYU retinotopy dataset and overlay it on the new anatomical data

export SUBJID=wlsubj138
export SESS_TA=ses-nyu3t99
export SESS_SO=ses-nyu3t01

export EXP_DIR=/Volumes/server/Projects/attentionpRF/derivatives
export SUBJECTS_DIR=${EXP_DIR}/freesurfer
export PRF_SAVE_DIR=${EXP_DIR}/prfs/sub-${SUBJID}/${SESS_TA}/prfFolder/NYU_3T
export EXP_ANAT_DIR=${SUBJECTS_DIR}/sub-${SUBJID}

export NYURetDir=/Volumes/server/Projects/Retinotopy_NYU_3T/derivatives
export NYUAnatDir=${NYURetDir}/freesurfer/sub-${SUBJID}
export PRF_SURF_DIR=${NYURetDir}/prfanalyze-vista/sub-${SUBJID}/${SESS_SO}


# SUBJECTS_DIR should be empty
export SUBJECTS_DIR=''

mkdir -p ${PRF_SAVE_DIR}

	# pRF data was analyzed in a different session on the surface - therefore first 
	# transform ROI surfaces from pRF session to current session 
	# (Note: same anatomical was used, so there should be minimal interpolation)
mri_surf2surf --srcsubject $NYUAnatDir --trgsubject $EXP_ANAT_DIR --hemi rh \
	--sval $PRF_SURF_DIR/rh.ROIs_V1-IPS.mgz --tval $PRF_SAVE_DIR/rh.ROIs_V1-IPS.mgz
mri_surf2surf --srcsubject $NYUAnatDir --trgsubject $EXP_ANAT_DIR --hemi lh \
	--sval $PRF_SURF_DIR/lh.ROIs_V1-IPS.mgz --tval $PRF_SAVE_DIR/lh.ROIs_V1-IPS.mgz

	# Transform pRF estimate surface masks to current session
#export PARAMS=("angle" "eccen" "sigma" "vexpl" "x" "y") 

#for P in "${PARAMS[@]}"
#do

	#mri_surf2surf --srcsubject $NYUAnatDir --trgsubject $EXP_ANAT_DIR --hemi rh --sval $PRF_SURF_DIR/rh.${P}.mgz --tval $PRF_SAVE_DIR/rh.${P}.mgz
	#mri_surf2surf --srcsubject $NYUAnatDir --trgsubject $EXP_ANAT_DIR --hemi lh --sval $PRF_SURF_DIR/lh.${P}.mgz --tval $PRF_SAVE_DIR/lh.${P}.mgz

#done

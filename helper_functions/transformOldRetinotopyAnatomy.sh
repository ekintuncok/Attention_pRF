#!/bin/bash -l


# Setup paths - subj ID should be passed as an argument when calling this function
export SUBJID=${1}
export SESS=ses-nyu3t01

# Main experimental directory
export EXP_DIR=/Volumes/server/Projects/attentionpRF/derivatives
export SUBJECTS_DIR=${EXP_DIR}/freesurfer

# Functional data directory
export FUNC_DIR=${EXP_DIR}/fmriprep/sub-${SUBJID}/${SESS}


# Where to save the pRF estimate surface overlays
export EXP_ANAT_DIR=${SUBJECTS_DIR}/sub-${SUBJID}
export PRF_SAVE_DIR=${EXP_DIR}/prfs/sub-${SUBJID}/${SESS}/prfFolder
# pRF retinotopy session directory
export PRF_EXP_DIR=/Volumes/server/Projects/Retinotopy_NYU_3T/derivatives
# anatomy - should be identical to current session anatomy..
export PRF_ANAT_DIR=${PRF_EXP_DIR}/freesurfer/sub-${SUBJID}
# pRF estimates surface overlays and ROI mgz
export PRF_SURF_DIR=${PRF_EXP_DIR}/prfanalyze-vista/sub-${SUBJID}/${SESS}

# Create directory to store ROI and pRF estimate volumes
export ROI_SAVE_DIR=${EXP_DIR}/roiVols/sub-${SUBJID}
export PRFVOL_SAVE_DIR=${EXP_DIR}/prfVols/sub-${SUBJID}


# 1: Bring in pRF overlays and hand drawn visual ROIs from surface to surface
# 2: Transform visual ROI labels into an annotation file 
# 3: Transform somatosenory ROI labels into an annotation file
# 4: Convert annotation files and all surface overlays into volume
export DO_IMPORT_PRF=1
export DO_CONVERT_VISROI=1


# Import pRF parameter overlays and ROI masks from pRF retinotopy session
if [ "$DO_IMPORT_PRF" == 1 ]; then

	# SUBJECTS_DIR should be empty
	export SUBJECTS_DIR=''

	mkdir -p ${PRF_SAVE_DIR}

	# pRF data was analyzed in a different session on the surface - therefore first 
	# transform ROI surfaces from pRF session to current session 
	# (Note: same anatomical was used, so there should be minimal interpolation)
	mri_surf2surf --srcsubject $PRF_ANAT_DIR --trgsubject $EXP_ANAT_DIR --hemi rh \
	 --sval $PRF_SURF_DIR/rh.ROIs_V1-4.mgz --tval $PRF_SAVE_DIR/rh.ROIs_V1-4.mgz
	mri_surf2surf --srcsubject $PRF_ANAT_DIR --trgsubject $EXP_ANAT_DIR --hemi lh \
	--sval $PRF_SURF_DIR/lh.ROIs_V1-4.mgz --tval $PRF_SAVE_DIR/lh.ROIs_V1-4.mgz

	# Transform pRF estimate surface masks to current session
	export PARAMS=("angle" "eccen" "sigma" "vexpl") 

	for P in "${PARAMS[@]}"
	do

		mri_surf2surf --srcsubject $PRF_ANAT_DIR --trgsubject $EXP_ANAT_DIR --hemi rh --sval $PRF_SURF_DIR/rh.${P}.mgz --tval $PRF_SAVE_DIR/rh.${P}.mgz
		mri_surf2surf --srcsubject $PRF_ANAT_DIR --trgsubject $EXP_ANAT_DIR --hemi lh --sval $PRF_SURF_DIR/lh.${P}.mgz --tval $PRF_SAVE_DIR/lh.${P}.mgz

	done


fi

# Freesurfer directory
export SUBJECTS_DIR=${EXP_DIR}/freesurfer
export LABEL_DIR=${SUBJECTS_DIR}/sub-${SUBJID}/label
	

# converts ROI masks .mgz  file to labels and annot files - mainly for visualization purposes
if [ "$DO_CONVERT_VISROI" == 1 ]; then

	roiname_array=("" "V1" "V2" "V3" "hV4") # first entry needs to be empty - loop starts at index 0.. 

	mkdir ${LABEL_DIR}/vistaPRF

	for hemi in lh rh
	do

		# First convert .mgz to labels
		for i in {1..4}
		do
			mri_cor2label --i ${PRF_SAVE_DIR}/${hemi}.ROIs_V1-4.mgz --id ${i} --l ${LABEL_DIR}/vistaPRF/${hemi}.vistaPRF.${roiname_array[${i}]}.label \
			--surf sub-${SUBJID} $hemi inflated
		done

		# next group all labels in annotation file
		mris_label2annot --s sub-${SUBJID} --h $hemi --ctab ${CLUT_DIR}/ROI_colorLUT.txt --a vistaPRF --l ${LABEL_DIR}/vistaPRF/${hemi}.vistaPRF.V1.label \
		--l ${LABEL_DIR}/vistaPRF/${hemi}.vistaPRF.V2.label --l ${LABEL_DIR}/vistaPRF/${hemi}.vistaPRF.V3.label --l ${LABEL_DIR}/vistaPRF/${hemi}.vistaPRF.hV4.label 


	done

fi


# To check whether mri_vol2vol works without specifiying registration:
# Downsamples T1 into functional space resolution:
# mri_vol2vol --regheader --s sub-${SUBJID} --mov func/sub-wlsubj121_ses-nyu3t01_task-loc_run-1_space-T1w_boldref.nii.gz --fstarg --o test_anat_in_func.mgh --inv
# Upsamples functional to T1:
# mri_vol2vol --regheader --s sub-${SUBJID} --mov func/sub-wlsubj121_ses-nyu3t01_task-loc_run-1_space-T1w_boldref.nii.gz --fstarg --o test_func2anat.mgh 

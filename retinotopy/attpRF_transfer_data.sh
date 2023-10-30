
for subid in wlsubj049 wlsubj079 wlsubj122 wlsubj123 wlsubj127 wlsubj135 wlsubj138 wlsubj141
do
	export SUBJID=$subid
	for foldername in mgzfiles niftiles
	do
		export FLDR=$foldername
		DEST_DIR=et2160@greene.hpc.nyu.edu:/scratch/et2160/attentionpRF/derivatives/GLMdenoise/main/sub-${SUBJID}/ses-nyu3t99/
		DATA_DIR=/Volumes/server/Projects/attentionpRF/derivatives/GLMdenoise/main/sub-${SUBJID}/ses-nyu3t99/${FLDR}
		scp -r $DATA_DIR $DEST_DIR
	done
done


for subid in wlsubj049 wlsubj079 wlsubj122 wlsubj123 wlsubj127 wlsubj135 wlsubj138 wlsubj141
do
	export SUBJID=$subid
	DEST_DIR=et2160@greene.hpc.nyu.edu:/scratch/et2160/attentionpRF/derivatives/GLMdenoise/main/sub-${SUBJID}/ses-nyu3t99/
	DATA_DIR=/Volumes/server/Projects/attentionpRF/derivatives/GLMdenoise/main/sub-${SUBJID}/ses-nyu3t99/*betas*
	scp $DATA_DIR $DEST_DIR
done

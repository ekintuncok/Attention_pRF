export SUBJECTS_DIR=/Volumes/server/Projects/attentionpRF/derivatives/freesurfer

cd /Volumes/server/Projects/attentionpRF/labels/lh/sub-wlsubj127

mris_label2annot --s sub-wlsubj127 --h lh --ctab /Volumes/server/Projects/attentionpRF/BIDS/labels/lh/lh.NYUret.annot.ctab.rtf --a NYUretannot --l lh.ROIs_V1-4.V1.label --l lh.ROIs_V1-4.V2.label --l lh.ROIs_V1-4.V3.label --l lh.ROIs_V1-4.hV4.label --nhits nhits.mgh


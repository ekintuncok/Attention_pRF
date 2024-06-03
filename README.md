This repository hosts the analysis code used in preprocessing, analyzing and visualizing the data that is reported in this preprint: https://www.biorxiv.org/content/10.1101/2024.03.02.583127v3
The preprocessed data to reproduce the figures as well as the raw data can be found in this repository: https://osf.io/g8b9v/

## Project goal:

The project investigates how multiple visual cortex maps prepare for the representation of an upcoming stimulus upon endogenous (voluntary) attentional cues. We collected fMRI data from 8 observers (the 9th observer was excluded from further analysis) across 4 scan sessions (around ~1 hour of data in each scan collected across 10 runs). Observers completed a trial-based orientation discrimination task with an attentional cue. On every trial, observers received an attentional cue and as they waited for the appearance of upcoming stimuli (target and distractors) a mapping stimulus appeared at a random, unpredictable location. We measured the BOLD response to the mapping stimuli for different attention conditions (see the paper for more details on the protocol).

# Code structure:

## behavior

Behavior data is shared in the preprocessed and raw format in the OSF repository. For making the paper figure 2A and 2B, run directly _figures/fig2_A_B_dprime_RT.m_ script on the preprocessed data in BehaviorAnalyzed folder. Analysis scripts explained below in detail.

### behavior (folder name)

- s0_run_subject_analysis : calls the function "analyze_subject.m" to compute d prime and extract response times from each observer
- analyze_subject : main function that computes reported behavior measurements (d prime, RT) for each observer), then plots these values with an error estimation based on within-subject variability. The output from this stage is saved separately for each observer. These files are in the OSF data directory BehaviorAnalyzed/sub-wlsubj***. Note that the first subject's data (wlsubj049) were collected with a slightly different design output. Therefore, their data were analyzed separately.
- bootstrap_behavior: bootstraps the responses of each observer to calculate the error (in function analyze_subject)
- save_group_data : loops through the subject data and concatenates them to create a group level data matrix. These files are in the OSF data directory BehaviorAnalyzed/behavioral_sensitivity.mat and BehaviorAnalyzed/reaction_time.mat
- check_resp_rate : calculate the proportion of missed trial responses to report in the descriptives of the paper

## eye 

Eye data is shared in the preprocessed and raw format in the OSF repository. For making the paper figure 2C, run directly _figures/fig2_C_averageGaze.m_ script on the preprocessed data in EyeAnalyzed folder. Analysis scripts explained below in detail.

### eye_scripts (folder name)

- 

## fMRI

- s0_attentionpRF : main script that adds the needed toolboxes to path, defines the main data and figure folders, assigns subject and session lists, some basic indexing information (columns that represent attend up vs down, etc.
- s1_attpRF_prepareforGLM : prepares the data for GLMdenoise, which is the first stage analysis in the pipeline. This script doesn't have to run on the processed data that is used to make the figures. Only to be used for repeating the entire analysis pipeline.
    - (func) gii2nii : For each observer, it converts the GIFTI fMRI files to NIFTI ang MGZ files. MGZ files are inputted to GLMdenoise
    - (func) BIDSformatdesign : For each observer, it creates a design matrix to be inputted to GLMdenoise. This function is based on the winawerlab MRItools repository. 

- s3_attpRF_visualizeprfsolutions : 



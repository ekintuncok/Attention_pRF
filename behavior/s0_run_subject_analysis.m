%% Attention pRF
% Ekin Tuncok, 12/2021
%%%%% Main script to run different parts of the behavioral analysis.
% Structure of the output matrix:
% Col 1: Session number
% Col 2: Trial number
% Col 3: Mapping stimulus location
% Col 4: Pre cue (1: upper, 2: lower, 3: left, 4:right, 5:neutral)
% Col 5: Post cue
% Col 6: Target Gabor tilt direction (-1 = Left (CCW), 1 = Right, (CW))
% Col 7: Response (-1 = Left (CCW), 1 = Right, (CW))
% Col 8: Reaction time
% Add later --> % Col 9: Answer ( 1 = Accurate, -1 = Inaccurate)
clear
close all
clc
% Clean behavioral data, concatenate it:
projectDir = '/Volumes/server/Projects/attentionpRF';
subject = {'wlsubj135'};
sessionList = {'nyu3t01','nyu3t02','nyu3t03','nyu3t04'};
runs = 1:10;
rawdatadir = [projectDir sprintf('/BehaviorData/BehavioralRaw/sub-%s/', subject{1})];
% load the design file:
dataConcatenated = [];
for sesInd = 1:length(sessionList)
    responses = [];
    for r = 1:length(runs)
        runNumber = runs(r);
        if runNumber ~= 10
            load([rawdatadir sprintf('%s_ses-%s_task-attPRF_run-0%i_data.mat', subject{1}, sessionList{sesInd}, runNumber)]);
        else
            load([rawdatadir sprintf('%s_ses-%s_task-attPRF_run-%i_data.mat', subject{1}, sessionList{sesInd}, runNumber)]);
        end
        responses = [responses; data.output.responses];
    end
    save([rawdatadir sprintf('sub-%s_ses-%s_responses.mat',subject{1},sessionList{sesInd})], 'responses');
    responses = [sesInd*ones(length(responses),1) responses];
    dataConcatenated = [dataConcatenated; responses];
end
% add the precue info which is missing:
% Take the data collected across three sessions, concatenate them
% clean the data
dataConcatenated = dataConcatenated(~isnan(dataConcatenated(:,8)),:);

%% Main 
% put the subject and session information
resultsDir = sprintf('/Volumes/server/Projects/attentionpRF/BehaviorData/BehaviorAnalyzed/sub-%s/',subject{1});

[output] = attpRF_behavior_analyze_subj(subject, sessionList,dataConcatenated,resultsDir);
% Sessions are represented in cells in separate fields. the fourth cell
% hosts the data averaged across sessions

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save([resultsDir sprintf('/%s_output.mat',subject{1})],'-struct', 'output');
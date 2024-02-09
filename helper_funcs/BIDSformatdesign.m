function BIDSformatdesign(path2project, subject, task, sessionList, designFolder)

% Create BIDS formatted TSV events file & extract trial based stim information
% Based on MRI_tools Toolbox function bidsTSVtoDesign.m
% Written by Ekin Tünçok (September, 2021)
% Updated January 2022: script still needs some more cleaning in terms of
% the defined directiories.

behDataDir        = fullfile(path2project, 'BehaviorData','BehavioralRaw', sprintf('sub-%s/',subject));
newsession = 'nyu3t99';

for sessionInd = 1:length(sessionList)
    % timing output is assigned to the output file of each run, so just
    % retrieve the first run of each session:
    load([behDataDir sprintf('%s_ses-%s_task-attPRF_run-01_data.mat', subject, sessionList{sessionInd})])
    timing = data.output.timing;
    save([behDataDir sprintf('sub-%s_ses-%s_timing.mat', subject, sessionList{sessionInd})],'timing');
end
fprintf('>>> design folder is set to: %s \n', designFolder)
designDir         = [path2project 'derivatives/design_matrices/'];
saveDir = [designDir designFolder sprintf('/sub-%s/ses-%s',subject, newsession)];

if ~exist(fullfile(path2project, 'derivatives','design_matrices', ...
        sprintf('%s', designFolder), sprintf('sub-%s', subject), sprintf('ses-%s', newsession)),'dir')
    mkdir(fullfile(path2project, 'derivatives','design_matrices', ...
        sprintf('%s', designFolder), sprintf('sub-%s', subject), sprintf('ses-%s', newsession)))
end

for sessionInd = 1:length(sessionList)
    load([behDataDir sprintf('sub-%s_ses-%s_timing.mat', subject, sessionList{sessionInd})]);
    load([behDataDir sprintf('sub-%s_ses-%s_responses.mat', subject, sessionList{sessionInd})]);
    output.responses{sessionInd} = responses;
    output.timing{sessionInd} = timing;
end

run = 1:length(dir(fullfile(path2project, 'derivatives', 'fmriprep',...
    sprintf('sub-%s', subject), sprintf('ses-%s', newsession), 'func', '*_run-*')))/2;


numofTrials = 52;
numofEvents = 7;
% see if you can get this info from one of the output files
% extract the onset of mapping stim duration
% preallocate
T       = cell(1,numel(run));
thisRun = run(1);
totalRun = 1;

% loop through sessions, and runs:
for sessionInd = 1:length(sessionList)
    for currentRun = 1:length(run)/length(sessionList)
        currentIter = 1;
        currentMatrix = output.responses{sessionInd}(output.responses{sessionInd}(:,1) == currentRun, :);
        duration    = [0.3000; diff(output.timing{1,sessionInd}(:,currentRun))];
        onset       = [0; output.timing{1,sessionInd}(1:end-1,currentRun)];
        if strcmp(subject, 'wlsubj127') && sessionInd == 1 || strcmp(subject, 'wlsubj123') || strcmp(subject, 'wlsubj049')
            event_type  = repmat(1:numofEvents, 1, numofTrials)';
        else
            event_type  = [repmat(1:numofEvents, 1, numofTrials)'; 8];
        end
        event_name  = cell(length(output.timing{1,sessionInd}(:,currentRun)),1);
        stim_index  = zeros(length(output.timing{1,sessionInd}(:,currentRun)),1);
        for ind = 1:length(event_type)
            if event_type(ind) == 1
                event_name{ind}      = 'fixation';
            elseif event_type(ind) == 2
                event_name{ind}       = 'precue';
            elseif event_type(ind) == 3
                event_name{ind}       = 'prf_bar';
            elseif event_type(ind) == 4
                event_name{ind}       = 'fixation';
            elseif event_type(ind) == 5
                event_name{ind}       = 'gabor';
            elseif event_type(ind) == 6
                event_name{ind}       = 'response_cue';
            elseif event_type(ind) == 7
                event_name{ind}       = 'responsewindow';
            elseif event_type(ind) == 8
                event_name{ind}       = 'exitTRs';
            end
        end

        stim_index = attpRF_create_design_matrix(designFolder, event_type, currentMatrix, currentIter);
        
        stim_index = stim_index';
        prefix = sprintf('sub-%s_ses-%s_task-%s_run-%i', ...
            subject, newsession, task, thisRun);
        tsvfile  = sprintf('/%s_events.tsv', prefix);

        tsv = table(onset, duration, event_type, event_name, stim_index);
        T{totalRun}.onset         = onset;
        T{totalRun}.bar_onset     = onset(stim_index ~= 0);
        T{totalRun}.duration      = duration;
        T{totalRun}.bar_duration  = duration(stim_index ~= 0);
        T{totalRun}.event_type    = event_type;
        T{totalRun}.event_name    = event_name;
        bar_idx = stim_index~=0;
        T{totalRun}.stim_index    = stim_index;
        T{totalRun}.mappingLocs   = stim_index(bar_idx);
        writetable(tsv, [saveDir tsvfile], 'filetype', 'text')
        totalRun = totalRun + 1;
        if totalRun < numel(run)
            thisRun = run(totalRun+1);
        elseif totalRun == 30
            thisRun = run(totalRun);
        end
    end
end

% Initialize design matrix
runnum = num2cell(run);
n = sum(cellfun(@numel, runnum));
design = cell(1,n);

% Now convert the tsv tables into matrices
%   figure out the number of unique conditions across all runs
%   that should be the width of the matrix
all_event_types = [];
for ii = 1:n
    all_event_types = cat(1, all_event_types, T{ii}.stim_index(T{ii}.stim_index ~= 0,:));
end

unique_conditions = unique(all_event_types);
num_conditions = length(unique_conditions);
for ii = 1:n
    if strcmp(subject, 'wlsubj127') &&  ii < 11|| strcmp(subject, 'wlsubj123') || strcmp(subject, 'wlsubj049')
        totalTR     = 234;
        numvol = repmat(totalTR, 1, n);
    else
        totalTR     = 244;
        numvol = repmat(totalTR, 1, n);
    end


    m = zeros(numvol(ii), num_conditions);
    these_conditions = T{ii}.stim_index(T{ii}.stim_index ~= 0,:);
    [~,col_num{ii}] = ismember(these_conditions, unique_conditions);
    % time in seconds of start of each event
    row_nums{ii} = round(T{ii}.bar_onset / 1)+1;
    linearInd = sub2ind(size(m), row_nums{ii}, col_num{ii});
    m(linearInd) = 1;
    design{ii} = m;
    for ind = 1:length(col_num{ii})
        if T{ii}.bar_duration(ind) == 2 && ~strcmp(designFolder, '10')
            design{ii}(row_nums{ii}(ind)+1, col_num{ii}(ind)) = 1;
        end
        if mod(T{ii}.mappingLocs(ind), 2) == 0 && T{ii}.bar_duration(ind) == 1
            %fprintf('Warning: Correcting for the even-odd asymmetry by adjusting the variable weights....\n')
            design{ii}(row_nums{ii}(ind), col_num{ii}(ind)) = 1;
        elseif mod(T{ii}.mappingLocs(ind), 2) == 0 && T{ii}.bar_duration(ind) == 2
            design{ii}(row_nums{ii}(ind), col_num{ii}(ind)) = 1;
            design{ii}(row_nums{ii}(ind)+1, col_num{ii}(ind)) = 1;
        end
    end
end

% prepare and save the design matrices
currentRun = 1;
thisRun = run(1);

for iter = 1:length(run)
    m = design{currentRun};
    fname = sprintf('sub-%s_ses-%s_task-%s_run-%i_design.tsv', ...
        subject, newsession, task, thisRun);
    savepth = fullfile(saveDir, fname);
    dlmwrite(savepth, m, 'delimiter','\t');
    if iter ~= numel(run)
        thisRun = run(currentRun+1);
        currentRun = currentRun + 1;
    end
end
save([saveDir sprintf('/sub-%s_ses-%s_task-%s_design.mat', subject, newsession, task)], 'design');
end
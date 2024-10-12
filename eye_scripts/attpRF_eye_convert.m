% this script converts EDF files to .mat files for the time stamps of
% interest (in this case, the beginning of the trial, the onset of the
% mapping stimulus, and the onset of the task stimulus) and marks the
% blinks. These .mat files saved for each run of each scan for each
% observer are then passed on to the "extract" script for further cleaning
% before analysis.

s0_attentionpRF;
path2edfs = '/Volumes/server/Projects/attentionpRF/EDFfiles';
path2designmat = '/Volumes/server/Projects/attentionpRF/BehaviorData/BehavioralRaw';
filename2 = '/usr/local/bin/edf2asc';
edf_run_tags = {'01','02','03','04','05','06','07','08','09','10'};
run_n = length(edf_run_tags);
recording_rate = 1000;
num_trials_per_run = 52;


for subj_idx = 2:length(subject_list)
    calibration_accuracy = [];
    subject = subject_list(subj_idx).name;
    disp(subject)
    session_list = dir(fullfile(path2designmat, subject, '*experimentalDesignMat*'));
    for session_idx = 1:length(session_list)
        session = sprintf('ses-nyu3t0%i', session_idx);
        designfile = fullfile(path2designmat, subject, sprintf('%s_%s_task-attPRF_experimentalDesignMat.mat', subject, session));
        load(designfile)
        fprintf('>> Design matrix loaded for scan session: %i\n', session_idx)
        trial_information = design.trialMat;
        trial_timing = design.trialDur;
        trial_timing = cat(2, reshape(repmat([1:run_n],num_trials_per_run,1),run_n*num_trials_per_run,1),trial_timing);
        num_runs = unique(trial_information(:,1));
        for run_idx = 1:length(num_runs)
            fprintf('>> Current run: %i\n', run_idx)
            filename1 = fullfile(path2edfs, subject, session, sprintf('%s_H%s',extractAfter(subject,"subj"), edf_run_tags{run_idx}));
            curr_trial_info = trial_information(trial_information(:,1) == run_idx,:);
            [path, filename, ~] = fileparts(filename1);
            % if isfile(replace(filename1,'edf','msg'))
            %     path1=sprintf('%s/MATs/%s_tab.mat',path,filename);
            %     path2=sprintf('%s/MATs/%s_Dat_stim.mat',path,filename);
            %     path3=sprintf('%s/MATs/%s_blink.mat',path,filename);
            % else
            if exist(path, 'dir')
                cd(path);
                edf2asc=filename2;
                if exist([filename1, '.edf'], 'file')
                    [~,~] = system([edf2asc,' ',filename,'.edf -e -y']); % convert edf to asc
                    if exist(sprintf('%s.asc',filename), 'file')
                        movefile(sprintf('%s.asc',filename), sprintf('%s.msg',filename)); % rename part1 asc to msg (strs)
                        [~,~] = system([edf2asc,' ',filename,'.edf -s -miss -1.0 -y']);
                        movefile(sprintf('%s.asc',filename), sprintf('%s.dat',filename)); % rename part2 asc to dat (#s)
                        msgstr = sprintf('%s.msg',filename);
                        msgfid = fopen(msgstr,'r');
                        % path_blink=sprintf('%s\%s',path,msgstr);
                        % path3=extract_blink(path_blink);
                        tab = [];
                        t = 0;
                        sameData = 1;
                        while sameData
                            line = fgetl(msgfid);
                            if ~ischar(line)
                                sameData = 0;
                                break;
                            end
                            if ~isempty(line)                           % skip empty lines
                                la = strread(line,'%s');                % matrix of strings in line
                                if length(la) >= 3
                                    if strcmp(subject, 'sub-wlsubj049')
                                        switch char(la(3))
                                            case '!MODE'
                                                t = t+1;
                                                tab(t,1)  = curr_trial_info(t,3); % trialID
                                                tab(t,2)  = str2double(char(la(2)));    % trial start time
                                                mask = trial_timing(:,1) == run_idx;
                                                curr_timing = trial_timing(mask, [2:4, 10]);

                                                for trial_id = 1:length(curr_timing)-1
                                                    total_time_after_start = sum(curr_timing(trial_id,1:3));
                                                    tab(trial_id,3) = tab(trial_id,2) + recording_rate*total_time_after_start;
                                                    tab(trial_id+1,2) = tab(trial_id,2) + recording_rate*curr_timing(trial_id, end);
                                                    tab(trial_id+1,1) = curr_trial_info(trial_id+1,3);
                                                    if trial_id == 51
                                                        tab(trial_id+1,3) = tab(trial_id+1,2) + recording_rate*curr_timing(trial_id+1, end);
                                                    end
                                                end
                                        end
                                    else
                                        switch char(la(3))
                                            % get the time stamps of
                                            % interest
                                            case 'FIXATIONSTART' % when the trial started
                                                t = t+1; % count up (add this to the message that is  the first message and occurs reliably in every trial)
                                                tab(t,1)  = curr_trial_info(t,3);% precue direction
                                                tab(t,2)  = str2double(char(la(2)));    % trial start time
                                            case 'MAPPINGSTIMSTART' % when the mapping stimulus was shown
                                                if t ~= 0
                                                    tab(t,3)  = str2double(char(la(2)));
                                                end
                                            case 'TARGETDISPLAY' %when the task stimulus is on
                                                if t ~= 0
                                                    tab(t,4)  = str2double(char(la(2)));
                                                end
                                            case '!CAL'
                                                if length(la)>12
                                                    err1=la(10);
                                                    err2=la(12);
                                                    clb_err = [session_idx, run_idx, str2num(err1{1}), str2num(err2{1})];
                                                    calibration_accuracy = [calibration_accuracy; clb_err];
                                                end
                                        end
                                    end
                                end
                            end
                        end
                        % create MAT folder if does not exist
                        if ~isfolder('MATs')
                            mkdir('MATs')
                        end

                        save(sprintf('MATs/%s_tab.mat',filename),'tab');
                        fclose(msgfid);
                        % path_blink=sprintf('%s\%s',path,msgstr);
                        % path3=extract_blink(path_blink);

                        % extracts the blink information:
                        msgfid = fopen(msgstr,'r');
                        blink = [];
                        t = 0;
                        sameData = 1;
                        while sameData
                            line = fgetl(msgfid);
                            if ~ischar(line)                            % end of file
                                sameData = 0;
                                break;
                            end
                            if ~isempty(line)                           % skip empty lines
                                la = strread(line,'%s');                % matrix of strings in line
                                if length(la) >= 3
                                    switch char(la(1))
                                        case 'EBLINK'; t = t+1; % count up (add this to the message that is  the first message and occurs reliably in every trial)
                                            blink(t,1)  = str2double(char(la(3)));
                                            blink(t,2)  = str2double(char(la(4)));
                                            blink(t,3)  = str2double(char(la(5)));
                                    end
                                end
                            end
                        end
                        save(sprintf('%s/MATs/%s_blink.mat',path,filename),'blink')
                        path3=sprintf('%s/MATs/%s_blink.mat',path,filename);

                        dat = readtable(sprintf('%s.dat',filename));
                        dat.Var5 = [];
                        if size(dat,2) == 4
                            dat_arr = table2array(dat);

                            % remove blinks:
                            for thisBlink = 1:size(blink,1)
                                blink_start=find(dat_arr(:,1) == blink(thisBlink,1));
                                blink_end=find(dat_arr(:,1) == blink(thisBlink,2));
                                dat_arr(blink_start:blink_end,:) = [];
                            end

                            data_run = [];
                            for t = 1:size(tab,1)
                                mask = trial_timing(:,1) == run_idx;
                                curr_timing = trial_timing(mask, [2:4, 10]);                                if strcmp(subject, 'sub-wlsubj049')
                                    trial_end_timestamp_idx = 3;
                                else
                                    trial_end_timestamp_idx = 4;
                                end
                                currTStart = tab(t,2);
                                if t < 52
                                    currTEnd = tab(t+1, 2)-1;
                                else
                                    % for the last trial, this part
                                    % calculates the trial end based on its
                                    % duration (either 4 or 5 seconds)
                                    % because no trial start data to anchor

                                    currTEnd = currTStart+sum(curr_timing(end))*recording_rate;
                                end
                                eye_position_data = dat_arr(dat_arr(:,1)>=currTStart & dat_arr(:,1)<=currTEnd,:);
                                curr_run_info(1) = subj_idx;
                                curr_run_info(2) = session_idx;
                                curr_run_info(3) = run_idx;
                                curr_run_info(4) = t; % which trial?
                                curr_run_info(5) = tab(t,1); % which precue?

                                currDat = cat(2, [repmat(curr_run_info, length(eye_position_data), 1)], eye_position_data);
                                currDat(:,10) = zeros(length(currDat), 1);
                                data_run = cat(1, data_run,currDat);
                                timestamp_of_fx = find(data_run(:,6)==tab(t,2));
                                timestamp_of_ms = find(data_run(:,6)==tab(t,3));
                                timestamp_of_gb = find(data_run(:,6)==tab(t,4));
                                data_run(timestamp_of_fx:timestamp_of_fx+300, 10) = 1;
                                data_run(timestamp_of_ms:timestamp_of_ms+curr_timing(t,3)*recording_rate, 10) = 2;
                                data_run(timestamp_of_gb:timestamp_of_gb+300, 10) = 3;
                            end

                            % Delete msg & dat when no more needed (always keep the edf)
                            delete(sprintf('%s.msg',filename));
                            delete(sprintf('%s.dat',filename));

                            save(sprintf('MATs/%s_Dat_all.mat',filename),'data_run');
                            path1=sprintf('%s/MATs/%s_tab.mat',path,filename);
                        else
                            fprintf('>> Warning: Problem with the data file! Skipping...\n')
                        end
                    else
                        fprintf('>> Warning: EDF file for this run does not exist! Skipping...\n')
                    end
                else
                    fprintf('>> Warning: EDF folder for this scan session does not exist! Skipping...\n')
                end
            end
        end
        save(sprintf('MATs/calibration_accuracy.mat',filename),'calibration_accuracy', 'calibration_accuracy');
    end
end
%% create tab file
%%input filepath of eye movement data and the script edf2asc
s0_attentionpRF;
subject_list      = dir(fullfile(path2project, 'derivatives', 'freesurfer', 'sub-*'));
subject_list(9) = [];
path2edfs = '/Volumes/server/Projects/attentionpRF/EDFfiles';
path2designmat = '/Volumes/server/Projects/attentionpRF/BehaviorData/BehavioralRaw';
filename2 = '/usr/local/bin/edf2asc';
edf_run_tags = {'01','02','03','04','05','06','07','08','09','10'};
recording_rate = 1000;
for subj_idx = 1:length(subject_list)
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
        trial_timing = cat(2, reshape(repmat([1:10],52,1),520,1),trial_timing);
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
                            if ~ischar(line)                            % end of file
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
                                                tab(t,1)  = curr_trial_info(t,3);% trialID
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
                                            case 'FIXATIONSTART'
                                                t = t+1; % count up (add this to the message that is  the first message and occurs reliably in every trial)
                                                tab(t,1)  = curr_trial_info(t,3);% trialID
                                                tab(t,2)  = str2double(char(la(2)));    % trial start time
                                            case 'MAPPINGSTIMSTART'
                                                if t ~= 0
                                                    tab(t,3)  = str2double(char(la(2))); 
                                                end
                                            case 'TARGETDISPLAY' %stimulus on
                                                if t ~= 0
                                                    tab(t,4)  = str2double(char(la(2)));
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
                            data_run = [];
                            for t = 1:size(tab,1)
                                if strcmp(subject, 'sub-wlsubj049')
                                    trial_end_timestamp_idx = 3;
                                else
                                    trial_end_timestamp_idx = 4;
                                end
                                currTStart = tab(t,2);
                                currTEnd = tab(t,trial_end_timestamp_idx);
                                eye_position_data = dat_arr(dat_arr(:,1)>=currTStart & dat_arr(:,1)<=currTEnd,:);
                                curr_run_info(1) = subj_idx;
                                curr_run_info(2) = session_idx;
                                curr_run_info(3) = run_idx;
                                curr_run_info(4) = t; % which trial?
                                curr_run_info(5) = tab(t,1); % which precue?

                                currDat = cat(2, [repmat(curr_run_info, length(eye_position_data), 1)], eye_position_data);
                                data_run = cat(1, data_run,currDat);
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
    end
end
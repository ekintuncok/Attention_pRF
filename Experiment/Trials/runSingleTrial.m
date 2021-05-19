function [resMat]=runSingleTrial(scr,const,expDes,my_key,t)
% ----------------------------------------------------------------------
% [resMat] = runSingleTrial(scr,const,expDes,my_key,t)
% ----------------------------------------------------------------------
% Goal of the function :
% Main file of the experiment. Draw each sequence and return results.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer.
% const : struct containing all the constant configurations.
% expDes : struct containing all the variable design configurations.
% my_key : keyboard keys names.
% t : experiment meter.
% ----------------------------------------------------------------------
% Output(s):
% resMat(1) : experimental results
%          => = 1 : first interval
%          => = 2 : second interval
%          => = -1 : Voluntary brake 
% resMat(2) : Reaction time
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

while KbCheck; end
FlushEvents('KeyDown');

%% Compute and simplify var names :

ecc_target =    expDes.expMat(t,3);
ecc_random =    expDes.expMat(t,6);
tInterval =     expDes.expMat(t,4);
if tInterval == 1
    target_on1 = 1;
    target_on2 = 0;
elseif tInterval == 2
    target_on1 = 0;
    target_on2 = 1;
end

attCond = expDes.expMat(t,5);
if attCond == 1
    type = 1; % cued trials
    if tInterval == 1
        ecc_cue1 = ecc_target;
        ecc_cue2 = ecc_random;
    elseif tInterval == 2
        ecc_cue1 = ecc_random;
        ecc_cue2 = ecc_target;
    end
elseif attCond == 2
    ecc_cue1 = 1;
    ecc_cue2 = 2;
    type = 2; % neutral trials
end


%% Main loop

for tframes = 1:const.numFrm_Tot
    Screen('FillRect',scr.main,const.colBG);

    %% First interval
    % T1
    
    if tframes >= const.numFrm_T1_start && tframes <= const.numFrm_T1_end
        my_fixationCross(scr,const,const.black);
    end
    
    % T2
    if tframes >= const.numFrm_T2_start && tframes <= const.numFrm_T2_end
        my_cue(scr,const.black,const,type,ecc_cue1)
    end
    
    % T3
    if tframes >= const.numFrm_T3_start && tframes <= const.numFrm_T3_end
        % emtpty ISI
    end

    % T4
    if tframes >= const.numFrm_T4_start && tframes <= const.numFrm_T4_end
        if tframes == const.numFrm_T4_start
            const.randX_all = [];
            const.randY_all = [];
            for t_col = 1:const.num_col
                for t_raw = 1:const.num_raw
                    const.randX = randperm(5);
                    const.randY = randperm(5);
                    const.randX_all = [const.randX_all;const.randX];
                    const.randY_all = [const.randY_all;const.randY];
                end
            end
        end
        my_stim(scr,const,const.black,ecc_target,target_on1);
    end

    % T5
    if tframes >= const.numFrm_T5_start && tframes <= const.numFrm_T5_end
        my_mask(scr,const,const.black)
    end

    %% Second interval
    % T6
    if tframes >= const.numFrm_T6_start && tframes <= const.numFrm_T6_end
        my_fixationCross(scr,const,const.black);
    end
    
    % T7
    if tframes >= const.numFrm_T7_start && tframes <= const.numFrm_T7_end
        my_cue(scr,const.black,const,type,ecc_cue2)
    end
    
    % T8
    if tframes >= const.numFrm_T8_start && tframes <= const.numFrm_T8_end
        % ISI
    end
    
    % T9
    if tframes >= const.numFrm_T9_start && tframes <= const.numFrm_T9_end
        my_stim(scr,const,const.black,ecc_target,target_on2);
    end
    
    % T10

    if tframes >= const.numFrm_T10_start && tframes <= const.numFrm_T10_end
        my_mask(scr,const,const.black)
    end
    
    vbl = Screen('Flip',scr.main);

end
% Answer screen
[key_press,tRT]=getAnswer(scr,const,my_key);
tRT = tRT - vbl;

if key_press.rightShift == 1
    my_sound(1);
    resMat = [2,tRT];
elseif key_press.leftShift == 1
    my_sound(1);
    resMat = [1,tRT];
elseif key_press.space == 1
    my_sound(3);
    resMat = [-1,tRT];
elseif key_press.escape == 1
    overDone;
end
    
end
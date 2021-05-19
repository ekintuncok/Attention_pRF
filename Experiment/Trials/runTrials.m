function runTrials(scr,const,expDes,my_key,textExp,button)
% ----------------------------------------------------------------------
% runTrials(scr,const,expDes,my_key,textExp,button)
% ----------------------------------------------------------------------
% Goal of the function :
% Main trial function, display the trial function and save the experi-
% -mental data in different files.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer
% const : struct containing all the constant configurations.
% expDes : struct containing all the variable design and configurations.
% my_key : keyborad keys names
% textExp : struct contanining all instruction text.
% button : struct containing all button text.
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

%% Gereral instructions:
instructions(scr,const,my_key,textExp.instruction1,button.instruction1);

%% Main Loop
expDone = 0;
newJ = 0;
startJ = 1;
while ~expDone
    for t = startJ:expDes.j
        trialDone = 0;
        while ~trialDone

            [resMat] = runSingleTrial(scr,const,expDes,my_key,t);
            if resMat == -1
                % Exit button  => send a new trial + save trial configuration for later presentation
                trialDone = 1;
                newJ = newJ+1;
                expDes.expMatAdd(newJ,:) = expDes.expMat(t,:);
            else
                trialDone = 1;
                expResMat(t,:)= [expDes.expMat(t,:),resMat];
                csvwrite(const.expRes_fileCsv,expResMat);
            end
        end
    end
    %% If error of fixation of volontary missed trial
    if ~newJ
        expDone = 1;
    else
        startJ = expDes.j+1;
        expDes.j = expDes.j+newJ;
        expDes.expMat=[expDes.expMat;expDes.expMatAdd];
        expDes.expMatAdd = [];
        newJ = 0;
    end
end

const.my_clock_end = clock;
const_file = fopen(const.const_fileDat,'a+');
fprintf(const_file,'Ending time :\t%ih%i',const.my_clock_end(4),const.my_clock_end(5));
fclose('all');
instructions(scr,const,my_key,textExp.end,button.end);

end
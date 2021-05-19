function [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute an experimental randomised matrix containing all variable data
% used in the experiment.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing all constant configurations.
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg all variable data randomised.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

%% Experimental variables 

% Var 1 : pRF mapping stimulus locations [28+2 modalitie(s)]
expDes.Var1 =[1:50]';
    %Think of how to extract these

% Var 2 : Cue type and location
expDes.Var2 = [1:5]';

%
%% Experimental configuration :
expDes.var1List = expDes.Var1;
expDes.numVar1= numel(expDes.var1List);
expDes.var2List = expDes.Var2;
expDes.numVar2= numel(expDes.var2List);

expDes.numVar  = 3;


expDes.numRepeat = 1;
expDes.numTrials = expDes.numVar1 * expDes.numVar2 * expDes.numRepeat;

expDes.timePauseMin = 15;
expDes.timePause = expDes.timePauseMin*60;

%% Experimental loop
trialMat = zeros(expDes.numTrials,expDes.numVar);
ii = 0;
for iv1=1:expDes.numVar1
    for iv2=1:expDes.numVar2
        ii = ii + 1;
        trialMat(ii, 1) = iv1;
        trialMat(ii, 2) = iv2;
    end
end

rand('state',sum(100*clock));
trialMat = trialMat(randperm(expDes.numTrials),:);


for t_trial = 1:expDes.numTrials    
    
    randVar1 = expDes.var1List(trialMat(t_trial,1),:);
    randVar2 = expDes.var2List(trialMat(t_trial,2),:);
    
    expDes.j = t_trial;
    expDes.expMat(expDes.j,:)= [const.fromBlock,t_trial,randVar1,randVar2];
end


%% Saving procedure :

% .mat file
save(const.design_fileMat,'expDes');

end

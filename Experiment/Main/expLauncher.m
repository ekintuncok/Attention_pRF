%% General experimenter launcher %%
%  =============================  %
% Last edit : 09/01/2014
% By : Martin SZINTE
% Projet : Programming course - Experiment template
% Description : Adaptation of the Yeshurun and Carrasco (1998) Nature.
%% Initial settings
% Initial closing :
clear vars

addpath(genpath(cd('/Applications/Psychtoolbox')));

% Screen('Preference', 'SkipSyncTests', 1);
% General settings
const.expName      = 'Yeshurun98';          % experiment name and folder
const.expStart     = 0;                     % Start of a recording exp                          0 = NO   , 1 = YES

% Screen
setScreen = Screen('Computer');
compName = convertCharsToStrings(setScreen.system);

if compName == 'Mac OS 10.15.7'
    const.desiredFD    = 60;                    % Desired refresh rate
    const.desiredRes   = [2560, 1440];
end
% Desired resolution

% Path :
dir = (which('expLauncher'));cd(dir(1:end-18));

% Block definition
numBlockMain = 1;                           % number of block to play per run time
const.numBlockTot  = 10;                    % total number of block before analysis

% Subject configuration :
if const.expStart
    const.sjct = input(sprintf('\n\tInitials: '),'s');
    const.sjctCode = sprintf('%s_%s',const.sjct,const.expName);
    const.fromBlock  = input(sprintf('\n\tFrom Block nb: '));
    if const.fromBlock == 1;
        const.sjct_age = input(sprintf('\n\tAge: '));
        const.sjct_gender = input(sprintf('\n\tGender (M or F): '),'s');
    end
else
    const.sjct = 'Anon';const.fromBlock = 1;const.sjct_age = 'XX';const.sjct_gender = 'X';
end
const.sjctCode = sprintf('%s_%s',const.sjct,const.expName);


%% Main experimental code
for block = const.fromBlock:(const.fromBlock+numBlockMain-1)
    const.fromBlock = block;
  main(const);clear expDes
end

function [const] = dirSaveFile(const)
% ----------------------------------------------------------------------
% [const]=dirSaveFile(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Make directory and saving files.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

% Creates Directory
if ~isdir(sprintf('Data/%s',const.sjct));
    mkdir(sprintf('Data/%s',const.sjct));
    cd (sprintf('Data/%s',const.sjct));
else
    cd (sprintf('Data/%s',const.sjct));
end

if const.expStart
    expDir = sprintf('ExpData/Block%i',const.fromBlock);
    if ~isdir(expDir);
        mkdir(expDir);
        cd(expDir);
    else
        aswErase = input('\n This file already exist, do you want to overwrite it ? (Y or N)    ','s');
        if aswErase == 'N'
            error('Please restart the program with correct input.')
        elseif aswErase == 'Y'
            cd(expDir);
        else
            error('Incorrect input => Please restart the program with correct input.')
        end
    end

else
    const.c = clock;
    
    debugDir = sprintf('DebugData/%i-%i_trials/',const.c(2),const.c(3));
    if ~isdir(debugDir);
        mkdir(debugDir);
        cd (debugDir);
    else
        cd (debugDir);
    end

end

% Defines saving file names
const.scr_fileDat =         sprintf('scr_file%s.dat',const.sjctCode);
const.scr_fileMat =         sprintf('scr_file%s.mat',const.sjctCode);
const.const_fileDat =       sprintf('const_file%s.dat',const.sjctCode);
const.const_fileMat =       sprintf('const_file%s.mat',const.sjctCode);
const.expRes_fileCsv =      sprintf('expRes%s.csv',const.sjctCode);
const.design_fileMat =      sprintf('design%s.mat',const.sjctCode);

% Add path from the location of the data file folder
addpath('../../../../Config/');
addpath('../../../../Conversion/');
addpath('../../../../Data/');
addpath('../../../../Instructions/');
addpath('../../../../Main/');
addpath('../../../../Stim/');
addpath('../../../../Trials/');

end
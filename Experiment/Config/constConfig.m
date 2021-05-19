function [const]=constConfig(scr,const)
% ----------------------------------------------------------------------
% [const]=constConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute all constant data of this experiment.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer
% const : struct containg previous constant configurations.
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing all constant data.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

% Instructions
const.text_size = 20       ;
const.text_font = 'Helvetica';

% Color Configuration :
const.red =     [200,   0,   0];
const.green =   [  0, 200,   0];
const.blue =    [  0,   0, 200];
const.orange =  [255, 150,   0];
const.gray =    [127, 127, 127];
const.colBG =   [127, 127, 127];
const.white =   [255, 255, 255]; 
const.black =   [  0,   0,   0];

% Time
const.my_clock_ini = clock;

% Fixation cross
const.sideFP_val     = 0.5;         [const.sideFP_X,const.sideFP_Y] = vaDeg2pix(const.sideFP_val,scr);
const.thicknessFP_val  = 0.1;       [const.thicknessFP_X,const.thicknessFP_Y] = vaDeg2pix(const.thicknessFP_val,scr);

% Fake mapping stim
mapBarEdges = 24;
mapBarIncr = scr.scr_sizeY/mapBarEdges;
baseRect = [0 0 length(scr.scr_sizeX) mapBarIncr];
mapBarYCoord = mapBarIncr/2:mapBarIncr:scr.scr_sizeY;

centeredRect = CenterRectOnPointd(baseRect, 0, mapBarYCoord(5));

rectColor = const.black;
Screen('FillRect', window, rectColor, centeredRect);
Screen('Flip', window);

const.mappingStim = 

% Gabor locations:
% const.gaborLocs = 

% Gabor dimensions:
const.gaborSize = 3; %in visual angles
[gaborSizeScr] =  vaDeg2cm(const.gaborSize,scr)

%% Saving procedure :
const_file = fopen(const.const_fileDat,'w');
fprintf(const_file,'Subject initial :\t%s\n',const.sjct);
if const.fromBlock == 1
    fprintf(const_file,'Subject age :\t%s\n',const.sjct_age);
    fprintf(const_file,'Subject gender :\t%s\n',const.sjct_gender);
end
fprintf(const_file,'Date : \t%i-%i-%i\n',const.my_clock_ini(3),const.my_clock_ini(2),const.my_clock_ini(1));
fprintf(const_file,'Starting time : \t%ih%i\n',const.my_clock_ini(4),const.my_clock_ini(5));
fclose('all');

% .mat file
save(const.const_fileMat,'const');

end
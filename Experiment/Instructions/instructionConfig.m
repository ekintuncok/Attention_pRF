function [textExp,button] = instructionConfig
% ----------------------------------------------------------------------
% [textExp,button] = instructionConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Write text of calibration and general instruction for the experiment.
% ----------------------------------------------------------------------
% Input(s) :
% (none)
% ----------------------------------------------------------------------
% Output(s):
% textExp : struct containing all text of general instructions.
% button : struct containing all button instructions.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

%% Pause : 
pause_l1 = 'Pause :';
pause_l2 = 'Please take a break.';
pause_b1 = '-----------------  PRESS [SPACE] TO CONTINUE  -----------------';

textExp.pause = {pause_l1;pause_l2};
button.pause = {pause_b1};

%% End :
end_l1 = 'Thank you ...';
end_b1 = '--------------------  PRESS [SPACE] TO QUIT  -------------------';

textExp.end = {end_l1};
button.end =  {end_b1};

%% Main instruction :

instruction_l1  =  'In two following sequences, a central white cross will appear on '; 
instruction_l2  =  'the screen followed by a small or two long horizontal bars ';
instruction_l3  =  'indicating the possible location of a 3x3 texture array';
instruction_l4  =  'oriented differently compared to the background.';
instruction_l5  =  '';
instruction_l6  =  'During each trial keep fixating at the central white cross position, ';
instruction_l7  =  'draw your attention at the location of the horizontal bar and determine';
instruction_l8  =  'in which sequence does the 3x3 texture array appeared.';
instruction_l9  =  '';
instruction_l10 =  'If the 3x3 texture array was in the 1st sequence : press [RIGHT SHIFT]';
instruction_l11 =  'If the 3x3 texture array was in the 2nd sequence : press [LEFT SHIFT]';

instruction_b1 = '-----------------  PRESS [SPACE] TO CONTINUE  -----------------';

textExp.instruction1= {instruction_l1;instruction_l2;instruction_l3;instruction_l4;instruction_l5;...
                       instruction_l6;instruction_l7;instruction_l8;instruction_l9;instruction_l10;instruction_l11};
button.instruction1 =  {instruction_b1};

end
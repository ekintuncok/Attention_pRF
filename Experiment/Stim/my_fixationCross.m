function my_fixationCross(scr,const,color)
% ----------------------------------------------------------------------
% my_fixationCross(scr,const,color)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw a fixation cross in the center of the screen
% ----------------------------------------------------------------------
% Input(s) :
% scr = Window Pointer                              ex : w
% color = color of the circle in RBG or RGBA        ex : color = [0 0 0]
% const = structure containing constant configurations.
% ----------------------------------------------------------------------
% Output(s):
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

x = scr.x_mid;
y = scr.y_mid;
Screen('FillRect',scr.main,color,[(x-(const.sideFP_X/2)) (y-(const.thicknessFP_Y/2)) (x+(const.sideFP_X/2)) (y+(const.thicknessFP_Y/2))]);
Screen('FillRect',scr.main,color,[(x-(const.thicknessFP_X/2)) (y-(const.sideFP_Y/2)) (x+(const.thicknessFP_X/2)) (y+(const.sideFP_Y/2))]);


end
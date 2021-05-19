function my_cue(scr,color,const,type,ecc_cue)
% ----------------------------------------------------------------------
% my_cue(scr,color,const,type,ecc_cue)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw the cue of the experiment (for neutral of cued attention trials)
% ----------------------------------------------------------------------
% Input(s) :
% scr = Window Pointer                              ex : w
% color = color of the circle in RBG or RGBA        ex : color = [0 0 0]
% const = structure containing constant configurations.
% type = type of cue 
%  if == 1 : attention condition (small bar centered on a specific loc.)
%  if == 2 : neutral condition (large bar) 
% ecc_cue : eccentricity of the cue
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


side = ecc_cue+1;
% Attentionnal cue
if type == 1
    coord_left   = const.mat_col(side) - (const.cueAtt_sizeX/2);
    coord_top    = const.mat_raw(4) - (const.cueAtt_sizeY/2) - const.cue_addY;
    coord_right  = const.mat_col(side) + (const.cueAtt_sizeX/2);
    coord_bottom = const.mat_raw(4) + (const.cueAtt_sizeY/2) - const.cue_addY;
    
    rect = [coord_left,coord_top,coord_right,coord_bottom];
    Screen('FillRect',scr.main,color,rect);
    
    Screen('DrawLine',scr.main,color,[(x-(const.thicknessFP_X/2)) (y-(const.sideFP_Y/2)) (x+(const.thicknessFP_X/2)) (y+(const.sideFP_Y/2))]);


% Neutral cue
elseif type == 2
    coord_left1   = const.mat_col(15) - (const.cueNeu_sizeX/2);
    coord_top1    = const.mat_raw(4) - (const.cueNeu_sizeY/2) - const.cue_addY;
    coord_right1  = const.mat_col(15) + (const.cueNeu_sizeX/2);
    coord_bottom1 = const.mat_raw(4) + (const.cueNeu_sizeY/2) - const.cue_addY;
    rect1 = [coord_left1,coord_top1,coord_right1,coord_bottom1];
    Screen('FillRect',scr.main,color,rect1);
    
    coord_left2   = const.mat_col(15) - (const.cueNeu_sizeX/2);
    coord_top2    = const.mat_raw(4) - (const.cueNeu_sizeY/2) + const.cue_addY;
    coord_right2  = const.mat_col(15) + (const.cueNeu_sizeX/2);
    coord_bottom2 = const.mat_raw(4) + (const.cueNeu_sizeY/2) + const.cue_addY;
    rect2 = [coord_left2,coord_top2,coord_right2,coord_bottom2];
    Screen('FillRect',scr.main,color,rect2);
end
end
function my_circle(scr,color,x,y,r)
% ----------------------------------------------------------------------
% my_circle(scr,color,x,y,r)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw a circle or oval in position (x,y) with radius (r).
% ----------------------------------------------------------------------
% Input(s) :
% scr = Window Pointer                              ex : w
% color = color of the circle in RBG or RGBA        ex : color = [0 0 0]
% x = position x of the center                      ex : x = 550
% y = position y of the center                      ex : y = 330
% r = radius for X (in pixel)                       ex : r = 25
% ----------------------------------------------------------------------
% Output(s):
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

if r>30
    Screen('FillOval',scr.main,color,[(x-r) (y-r) (x+r) (y+r)]);
else
    Screen('DrawDots', scr.main,[x,y],r*2,color,[],2)
end
end
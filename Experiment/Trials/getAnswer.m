function [key_press,tRt]=getAnswer(scr,const,my_key)
% ----------------------------------------------------------------------
% [key_press]=getAnswer(scr,const,expDes,t,my_key)
% ----------------------------------------------------------------------
% Goal of the function :
% Check keyboard press, and return flags.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer.
% const : struct containing all the constant configurations.
% my_key : keyboard keys names.
% tRt : machine time of button press
% ----------------------------------------------------------------------
% Output(s):
% key_press : struct containing key answer.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

key_press.leftShift = 0;
key_press.rightShift = 0;
key_press.push_button = 0;
key_press.escape = 0;
key_press.space = 0;


% Keyboard checking :
while ~key_press.push_button
    Screen('FillRect',scr.main,const.colBG);
    my_circle(scr,const.red,scr.x_mid,scr.y_mid,const.radCircle)
    my_circle(scr,const.colBG,scr.x_mid,scr.y_mid,9*const.radCircle/10)
    my_fixationCross(scr,const,const.black);
    
    Screen('Flip',scr.main);
    [keyIsDown, seconds, keyCode] = KbCheck;
    if keyIsDown
        if (keyCode(my_key.escape)) && ~const.expStart
            key_press.push_button = 1;
            key_press.escape = 1;
            tRt = seconds;
        elseif (keyCode(my_key.space))
            key_press.push_button = 1;
            key_press.space = 1;
            tRt = seconds;
        elseif (keyCode(my_key.rightShift))
            key_press.rightShift = 1;
            key_press.push_button = 1;
            tRt = seconds;
        elseif (keyCode(my_key.leftShift))
            key_press.leftShift = 1;
            key_press.push_button = 1;
            tRt = seconds;
        end
    end
end
end
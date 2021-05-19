function [my_key]=keyConfig
% ----------------------------------------------------------------------
% [my_key]=keyConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Unify key names and return a structure containing each key names.
% ----------------------------------------------------------------------
% Input(s) :
% none
% ----------------------------------------------------------------------
% Output(s):
% my_key : structure containing all keyboard names.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

KbName('UnifyKeyNames');
my_key.escape       = KbName('Escape');
my_key.space        = KbName('Space');
my_key.rightShift   = KbName('RightShift');
my_key.leftShift    = KbName('LeftShift');

end
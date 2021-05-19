function my_sound (t)
% ----------------------------------------------------------------------
% my_sound(t)
% ----------------------------------------------------------------------
% Goal of the function :
% Play a wave file a specified number of time.
% ----------------------------------------------------------------------
% Input(s) :
% waveFile : wave file directory
% t : switch between diferent sounds.
% ----------------------------------------------------------------------
% Output(s):
% (none)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

if t == 1
    Snd('Play',[repmat(0.3,1,150) linspace(0.4,0.0,50)].*[zeros(1,100) sin(1:100)],3000);
    Snd('Play',[repmat(0.3,1,150) linspace(0.5,0.0,50)].*[zeros(1,100) sin(1:100)],4000);
    FlushEvents;
elseif t == 2
    Snd('Play',[repmat(0.3,1,150) linspace(0.4,0.0,50)].*[zeros(1,100) sin(1:100)],3000);
elseif t ==3 
    Snd('Play',[repmat(0.3,1,150) linspace(0.5,0.0,50)].*[zeros(1,100) sin(1:100)],4000);
end



end
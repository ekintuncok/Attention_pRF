function overDone
% ----------------------------------------------------------------------
% overDone
% ----------------------------------------------------------------------
% Goal of the function :
% Close screen, listen keyboard and save duration of the experiment
% ----------------------------------------------------------------------
% Input(s) :
% none
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------

ListenChar(1);
WaitSecs(2.0);

ShowCursor;
Screen('CloseAll');
timeDur=toc/60;
fprintf(1,'\nThis part of the experiment took : %2.0f min.\n\n',timeDur);

clear mex;
clear fun;

end


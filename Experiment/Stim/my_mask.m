function my_mask(scr,const,color)
% ----------------------------------------------------------------------
% my_mask(scr,const,color)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw the mask background.
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

j = 1;

for t_col = 1:const.num_col
    for t_raw = 1:const.num_raw
        for time = 1:2
            if time == 1
                x_ini1 = const.mat_col(t_col)-(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
                y_ini1 = const.mat_raw(t_raw)-(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
                x_end1 = const.mat_col(t_col)+(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
                y_end1 = const.mat_raw(t_raw)+(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            elseif time == 2
                x_ini1 = const.mat_col(t_col)-(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
                y_ini1 = const.mat_raw(t_raw)+(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
                x_end1 = const.mat_col(t_col)+(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
                y_end1 = const.mat_raw(t_raw)-(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            end
            Screen('DrawLines',scr.main,[x_ini1 x_end1 ; y_ini1 y_end1],3,color);
        end
        
        j = j+1;
        
        
    end
    
end
end

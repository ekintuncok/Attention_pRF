function my_stim(scr,const,color,ecc_target,target_on)
% ----------------------------------------------------------------------
% my_stim(scr,color,x,y,sideX,sideY)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw the texture background and texture target
% ----------------------------------------------------------------------
% Input(s) :
% scr = Window Pointer                              ex : w
% color = color of the circle in RBG or RGBA        ex : color = [0 0 0]
% const = structure containing constant configurations.
% ecc_target = eccentricity of the target
% target_on = switch of target interval
% ----------------------------------------------------------------------
% Output(s):
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 08 / 01 / 2014
% Project : Yeshurun98
% Version : -
% ----------------------------------------------------------------------
j = 1;
side = ecc_target;
for t_col = 1:const.num_col
    for t_raw = 1:const.num_raw
        % Target
        if (t_col == side || t_col == side+1 || t_col == side+2) && (t_raw == 3 || t_raw == 4 || t_raw == 5) && target_on;
            x_ini = const.mat_col(t_col)-(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
            y_ini = const.mat_raw(t_raw)+(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            x_end = const.mat_col(t_col)+(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
            y_end = const.mat_raw(t_raw)-(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            j = j+1;
        % Background
        else    
            x_ini = const.mat_col(t_col)-(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
            y_ini = const.mat_raw(t_raw)-(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            x_end = const.mat_col(t_col)+(const.stim_sizeX/2)+const.jitterX_val(const.randX_all(j,1));
            y_end = const.mat_raw(t_raw)+(const.stim_sizeY/2)+const.jitterY_val(const.randY_all(j,1));
            j = j+1;
        end
        Screen('DrawLine',scr.main,color,x_ini,y_ini,x_end,y_end,3);
    end
end

end

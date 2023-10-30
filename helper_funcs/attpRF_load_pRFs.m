function [cord1, cord2] = attpRF_load_pRFs(prfFolder, type)
if strcmp(type, 'cart')
    x_lh = MRIread(fullfile(prfFolder,'lh.x.mgz'));
    x_rh = MRIread(fullfile(prfFolder, 'rh.x.mgz'));
    x_coord = [x_lh.vol'; x_rh.vol'];

    y_lh = MRIread(fullfile(prfFolder,'lh.y.mgz'));
    y_rh = MRIread(fullfile(prfFolder, 'rh.y.mgz'));
    y_coord = -1*[y_lh.vol'; y_rh.vol'];
    cord1 = x_coord;
    cord2 = y_coord;

elseif strcmp(type, 'polar')
    eccen_lh = MRIread(fullfile(prfFolder,'lh.eccen.mgz'));
    eccen_rh = MRIread(fullfile(prfFolder, 'rh.eccen.mgz'));
    eccen = [eccen_lh.vol'; eccen_rh.vol'];

    angle_lh = MRIread(fullfile(prfFolder,'lh.angle.mgz'));
    angle_rh = MRIread(fullfile(prfFolder, 'rh.angle.mgz'));
    angle_rad = [angle_lh.vol'; angle_rh.vol'];
    angle = rad2deg(angle_rad);
    cord1 =eccen;
    cord2 =angle;
end
function [eccen, angle] = attpRF_load_pRFs(prfFolder)

eccen_lh = MRIread(fullfile(prfFolder,'lh.eccen.mgz'));
eccen_rh = MRIread(fullfile(prfFolder, 'rh.eccen.mgz'));
eccen = [eccen_lh.vol'; eccen_rh.vol'];

angle_lh = MRIread(fullfile(prfFolder,'lh.angle.mgz'));
angle_rh = MRIread(fullfile(prfFolder, 'rh.angle.mgz'));
angle_rad = [angle_lh.vol'; angle_rh.vol'];
angle = rad2deg(angle_rad);
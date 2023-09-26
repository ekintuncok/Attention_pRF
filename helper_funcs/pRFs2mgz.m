function pRFs2mgz(path2project, subject, prfFolder)

% Freesurfer directory
fspth = fullfile(path2project, 'derivatives', 'freesurfer', ['sub-' subject]);

filenames = dir([prfFolder '/*.mat']);

fits{1} = load([prfFolder filenames(1).name], 'results');
fits{2} = load([prfFolder filenames(2).name], 'results');

fits{1}.results.model{1}.sigma = fits{1}.results.model{1}.sigma.major; % not sure what these lines are doing
fits{2}.results.model{1}.sigma = fits{2}.results.model{1}.sigma.major;

hemis = {'lh';'rh'};
fields = {'angle', 'eccen', 'sigma', 'vexpl'};
for h = 1 : length(hemis)
    for f = 1:length(fields)
        % load the mgz file as a template
        mgz = MRIread(fullfile(fspth, 'mri', 'orig.mgz'));
        results = fits{h}.results;
        
        % get the x and y values from the results mat
        x0    = results.model{1}.x0;
        y0    = results.model{1}.y0;
        
        % convert the x and y coordinate values to eccentricity and polar angle
        if f == 1
            % polar angle
            overlayData = atan2(-results.model{1}.y0,results.model{1}.x0);
        elseif f == 2
            % eccentricity
            overlayData = sqrt(results.model{1}.x0.^2+results.model{1}.y0.^2);
        elseif f == 3
            % sigma
            overlayData = results.model{1}.sigma;
        elseif f == 4
            % variance explained(1-residuals)
            overlayData = 1 - (results.model{1}.rss ./ results.model{1}.rawrss);
        end
        
        % overlay and write
        mgz.vol = overlayData;
        MRIwrite(mgz, fullfile(prfFolder, sprintf('%s.%s.mgz',hemis{h},fields{f})));
        if f == 1
%             if h == 1
                angle_adj = (mod(90-180/pi * overlayData +180,360) - 180);
%             elseif h == 2    
%                 angle_adj = (mod(90-180/pi * overlayData +180,360) - 180);
% %                 angle_adj = angle_adj .* -1; %flip the sign of right hemisphere
%                 % so the maps between left and right hemisphere are identical
%                 % (easier for looping through hemispheres)  
%             end
            mgz.vol = angle_adj;
            MRIwrite(mgz, fullfile(prfFolder, sprintf('%s.angle_adj.mgz',hemis{h})));
        end
        
        if f == 4
            mgz.vol = x0;
            MRIwrite(mgz, fullfile(prfFolder,  sprintf('%s.x.mgz',hemis{h})));
            
            mgz.vol = y0;
            MRIwrite(mgz, fullfile(prfFolder,  sprintf('%s.y.mgz',hemis{h})));
        end
    end
end
end
function getWangROIs(subject, prfFolder, path2project,  fsavg_sym)

%% get the ROIs in native space
if fsavg_sym
    system(sprintf('xhemireg --s sub-%s', subject));
    system(sprintf('surfreg --s sub-%s --t fsaverage_sym --lh', subject));
    prompt = sprintf('Run docker run -ti --rm -v /Volumes/server/Projects/attentionpRF/derivatives/freesurfer/sub-%s:/input \nben/occipital_atlas:latest, press enter',subject);
    input(prompt);
end

% overlay pRF data on Wang atlas
hemi = {'lh', 'rh'};
path2subj = fullfile(path2project, 'derivatives','freesurfer', sprintf('sub-%s', subject), 'surf');
fields = {'angle', 'angle_adj', 'eccen', 'sigma', 'vexpl'};
for h = 1:length(hemi)
    for f = 1:length(fields)
        atlasmgz = [path2subj sprintf('/%s.wang2015_atlas.mgz', hemi{h})];
        atlas = MRIread(atlasmgz);
        atlas.vol(atlas.vol(1,1,:) == 0) = NaN;
        ROIind = find(~isnan(atlas.vol(1,1,:)));

        datafile = sprintf([prfFolder '%s.%s.mgz'], hemi{h}, fields{f});
        data = MRIread(datafile);

        ROIvalues = nan(size(data.vol));
        tmp = data.vol(1,ROIind);

        for ind = 1:length(ROIind)
            ROIvalues(1, ROIind(ind)) = tmp(ind);
        end

        atlas.vol(1,1,:) = ROIvalues;
        MRIwrite(atlas, fullfile(prfFolder,  sprintf('%s.%s.mgz',hemi{h}, fields{f})));
        path2subj = fullfile(path2project, 'derivatives','freesurfer', sprintf('sub-%s', subject), 'surf');
        fields = {'angle', 'angle_adj', 'eccen', 'sigma', 'vexpl'};
        for h = 1:length(hemi)
            for f = 1:length(fields)
                atlasmgz = [path2subj sprintf('/%s.wang2015_atlas.mgz', hemi{h})];
                atlas = MRIread(atlasmgz);
                atlas.vol(atlas.vol(1,1,:) == 0) = NaN;
                ROIind = find(~isnan(atlas.vol(1,1,:)));

                datafile = sprintf([prfFolder '%s.%s.mgz'], hemi{h}, fields{f});
                data = MRIread(datafile);

                ROIvalues = nan(size(data.vol));
                tmp = data.vol(1,ROIind);

                for ind = 1:length(ROIind)
                    ROIvalues(1, ROIind(ind)) = tmp(ind);
                end

                atlas.vol(1,1,:) = ROIvalues;
                MRIwrite(atlas, fullfile(prfFolder,  sprintf('%s.%sWangAtlas.mgz',hemi{h}, fields{f})));

            end
        end
    end

end
end

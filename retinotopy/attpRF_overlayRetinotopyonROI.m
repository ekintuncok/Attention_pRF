prf_folder = 'prfFolder_3';
for sub = 1:length(subject_list)
    subjecttmp = subject_list(sub).name;
    subject = subjecttmp(5:end);
    disp(subject)
    if sub == 1
        label_name = 'ROIs_V1-3';
    else
        label_name = 'ROIs_V1-IPS';
    end
    hemi = {'lh', 'rh'};
    path2subj = fullfile(path2project, 'derivatives','freesurfer', sprintf('sub-%s', subject), 'surf');
    fields = {'angle', 'angle_adj', 'eccen', 'sigma', 'vexpl'};
    conditions = {'1','2','3','4','5','avg'};
    for h = 1:length(hemi)
        for f = 1:length(fields)
            for c = 1:length(conditions)
                prfFolder         = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/%s/%s/', subject, session, prf_folder, conditions{c}));

                atlasmgz = [path2subj sprintf('/%s.%s.mgz', hemi{h}, label_name)];
                atlas = MRIread(atlasmgz);
                atlas.vol(atlas.vol(1,1,:) == 0) = NaN;
                % We do not have good IPS data, remove it all for the sake
                % of caution:
                atlas.vol(atlas.vol(1,1,:) == 7) = NaN;

                ROIind = find(~isnan(atlas.vol(1,1,:)));

                datafile = sprintf([prfFolder '%s.%s.mgz'], hemi{h}, fields{f});
                data = MRIread(datafile);

                ROIvalues = nan(size(data.vol));
                tmp = data.vol(1,ROIind);

                for ind = 1:length(ROIind)
                    ROIvalues(1, ROIind(ind)) = tmp(ind);
                end
                
                atlas.vol(1,1,:) = ROIvalues;
                MRIwrite(atlas, fullfile(prfFolder,  sprintf('%s.%s%s.mgz',hemi{h}, label_name, fields{f})));
            end
        end
    end
end
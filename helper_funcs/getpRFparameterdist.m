function getpRFparameterdist(path2project, subject, prfFolder, figuresFolder)

close all
hemi = {'lh', 'rh'};
fields = { 'vexpl', 'angle_adj', 'eccen', 'sigma'};
titles = {'Variance explained', 'Polar angle', 'Eccentricity', 'pRF size'};
ROIs = {'V1v','V1d', 'V2v','V2d', 'V3v','V3d'};
titlesHem = {'LH', 'RH'};
ROIindices = [];
figure;
iter = 1;
for h = 1:length(hemi)
    for f = 1:length(fields)
        for l = 1:length(ROIs)
            path2fs = fullfile(path2project, 'derivatives', 'freesurfer',sprintf('%s', subject));
            wangMGZ = MRIread(fullfile(path2fs, 'surf', sprintf('%s.wang2015_atlas.mgz', hemi{h})));
            
            label = read_label(sprintf('sub-%s',subject), sprintf('%s.wang2015_atlas.%s',hemi{h},ROIs{l}));
            ROIindices = [ROIindices; label(:,1)];
            ROIindices = sort(ROIindices,'ascend');
        end
        
        data = MRIread([prfFolder sprintf('%s.%sWangAtlas.mgz', hemi{h}, fields{f})]);
        datatoplot = data.vol(ROIindices+1);
%         datatoplot(data.vol == 0) = NaN;
        subplot(2,4,iter)
        histgrm = histogram(datatoplot);
        histgrm.FaceColor = [0 0 0];
        histgrm.EdgeColor = [0 0 0];
        xlabel([titles{f} sprintf('%s', titlesHem{h})])
        set(gca,'FontSize', 15)
        iter = iter + 1;
    end
end
ax = suptitle(sprintf('pRF parameter distributions for V1, V2 and V3, subj = %s', subject));
set(ax,'FontSize',20,'FontWeight','normal')
set(gcf, 'Position', [0 0 1000 1000])
saveas(histgrm, [figuresFolder '/prfParameterDistributions.svg'])
saveas(histgrm, [figuresFolder '/prfParameterDistributions.png'])
end
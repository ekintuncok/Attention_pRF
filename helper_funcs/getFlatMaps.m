function getFlatMaps(path2project,subject,session,conditions, atlas_input, folderTag)
titles = {'Variance Explained (%)', 'Eccentricity (in deg)', 'Polar Angle', 'Size (in deg)'};
color   = 0.5;
hemi  = {'lh','rh'};

%% load ROIs
close all
label = cell(1, length(hemi));
labelfolder  = fullfile(path2project,'derivatives','freesurfer',sprintf('sub-%s/surf',subject));

if strcmp(atlas_input, 'hand') && ~(strcmp(subject, 'wlsubj049'))
    atlas = {'ROIs_V1-IPS'};
    atlas_prf = {'ROIs_V1-IPS'};
elseif strcmp(atlas_input, 'hand') && strcmp(subject, 'wlsubj049')
    atlas = {'ROIs_V1-3'};
    atlas_prf = {'ROIs_V1-3'};
else strcmp(atlas_input, 'wang')
    atlas = {'wang2015_atlas'};
    atlas_prf = {'WangAtlas'};
end

%
% for h = 1:length(hemi)
%     label  = MRIread([labelfolder sprintf('/%s.%s.mgz', hemi{h}, atlas{1})]);
%     vol_temp = zeros(1,1,size(label.vol,2));
%     vol_temp(1,1,:) = label.vol;
%     label.vol = vol_temp;
%     MRIwrite(label, [labelfolder sprintf('/%s.%s.mgz', hemi{h}, atlas{1})]);
% end


for h = 1:length(hemi)
    label{h}  = MRIread([labelfolder sprintf('/%s.%s.mgz', hemi{h}, atlas{1})]);
    ips_indices = label{h}.vol == 7;
    label{h}.vol(1,1,ips_indices) = 0;
end

lhmask = label{1}.vol;
rhmask = label{2}.vol;
roi = [squeeze(lhmask) ;squeeze(rhmask)];
for c = 1:length(conditions)
    prfFolder         = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/%s/%s/', subject, session, folderTag, conditions{c}));
    figuresFolder     = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/Figures/%s', subject, session, conditions{c}));
    if ~exist(figuresFolder,'dir')
        mkdir(figuresFolder)
    end
    lheccen = MRIread([prfFolder sprintf('lh.%seccen.mgz', atlas_prf{1})]);
    rheccen = MRIread([prfFolder sprintf('rh.%seccen.mgz', atlas_prf{1})]);

    lhangle = MRIread([prfFolder sprintf('lh.%sangle_adj.mgz', atlas_prf{1})]);
    rhangle = MRIread([prfFolder sprintf('rh.%sangle_adj.mgz', atlas_prf{1})]);

    lhvar = MRIread([prfFolder 'lh.vexpl.mgz']);
    rhvar = MRIread([prfFolder 'rh.vexpl.mgz']);
    lhvar = lhvar.vol;
    rhvar = rhvar.vol;

    lhsigma = MRIread([prfFolder sprintf('lh.%ssigma.mgz', atlas_prf{1})]);
    rhsigma = MRIread([prfFolder sprintf('rh.%ssigma.mgz', atlas_prf{1})]);

    paramsToPlot = {'vexpl','eccen','angle','sigma'};

    for p = 1:length(paramsToPlot)
        if p == 1
            datatoplot = [lhvar rhvar];
            bins = 0:0.1:1;
            cmap = cmaplookup(bins,0,1,[],hot(256));
            clim = [0 1];
            thresh = 0;
            roiColor = 'w';
            roiWidth = {5};
        elseif p == 2
            lhdata = squeeze(lheccen.vol) .* double(lhvar > 0.10)';
            rhdata = squeeze(rheccen.vol) .* double(rhvar > 0.10)';
            datatoplot = [lhdata' rhdata'];
            datatoplot(isnan(datatoplot(1,:))) = -1;
            bins = 1:1:12;
            cmap = cmaplookup(bins,0,12,[],flipud(jet(256)));
            clim = [0 10];
            thresh = 0.01;
            roiColor = 'w';
            roiWidth = {3};
        elseif p == 3
            lhdata = squeeze(lhangle.vol) .* double(lhvar > 0.10)';
            rhdata = squeeze(rhangle.vol) .* double(rhvar > 0.10)';
            datatoplot = [squeeze(lhdata)'*-1 -1*squeeze(rhdata)'];
            datatoplot(isnan(datatoplot(1,:))) = -181;
            bins = -180:1:180;
            cmap_pa = load('cmap_neuropythy_angle.mat');
            cmap  = cmaplookup(bins,-180,180,[],cmap_pa.cmap_neuro);
            clim = [-180 180];
            thresh = -180;
            roiColor = 'w';
            roiWidth = {2};
        else
            lhdata = squeeze(lhsigma.vol) .* double(lhvar > 0.10)';
            rhdata = squeeze(rhsigma.vol) .* double(rhvar > 0.10)';
            datatoplot = [lhdata' rhdata'];
            datatoplot(isnan(datatoplot(1,:))) = 0;
            bins = 0.01:0.3:5;
            cmap  = cmaplookup(bins,0.02,4,[],jet(256));
            clim = [0.01 5];
            thresh = 0.01;
            roiColor = 'w';
            roiWidth = {3};
        end

        [~,~,rgbimg] = cvnlookup(['sub-' subject],1,datatoplot',clim,cmap,thresh,[],0,...
            {'roimask',{double(roi)},...
            'roicolor','k','roiwidth',2});
        [r,c,~] = size(rgbimg);
        [i, j]  = find(all(rgbimg == repmat(color,r,c,3),3));
        for ii = 1: length(i)
            rgbimg(i(ii),j(ii),:) = ones(1,3);
        end
        a = imagesc(rgbimg(:,:,:)); axis image tight;
        axis off
        axis image
        title(titles{p})
        set(gca,'fontsize',20,'fontname','arial');
        %         set(gcf,'Position', [0 0 1500 1500]);
        saveas(a, [figuresFolder sprintf('/%s_inf.svg',paramsToPlot{p})]);
        saveas(a, [figuresFolder sprintf('/%s_inf.png',paramsToPlot{p})]);

    end
end
end
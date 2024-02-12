function betas2nii(path2project, GLMfolder, subject, session, designFolder)
% Convert the output of GLM denoise (mat format) to mgz and niftii files.
% MGZ conversion is a step for getting the nii files. pRFvista will only
% accept the input in nifti format.


% set and make the output directories:
path2fs           = fullfile(path2project,  'derivatives', 'freesurfer', sprintf('sub-%s', subject));
mgzfolder         = fullfile(GLMfolder, 'mgzfiles');
niftifolder         = fullfile(GLMfolder, 'niftifiles');
if ~exist(mgzfolder,'dir')
    mkdir(mgzfolder)
end
if ~exist(niftifolder,'dir')
    mkdir(niftifolder)
end

lcurv = read_curv(fullfile(path2fs, 'surf', 'lh.curv'));
rcurv = read_curv(fullfile(path2fs, 'surf', 'rh.curv'));

hemi{1} = zeros(length(lcurv),1);
hemi{2} = zeros(length(rcurv),1);
data = load([GLMfolder sprintf('sub-%s_ses-%s_%s_results.mat', subject, session, designFolder)]);
fields = {'modelmd';'R2'}; % I can add fields later
%data.betas{1} = data.results.betas;
% data.R2 = data.results.R2;
if size(data.betas,2) > 1
    num_conditions = 5;
else
    num_conditions = 1;
end

for condition = 1:num_conditions

    if num_conditions > 1
        results.modelmd = [squeeze(data.betas{condition}), squeeze((data.betas{6}(1,:,1,condition)))']; % concatenate the MS response with blank responses
    else
        results.modelmd = squeeze(data.betas{condition}); % concatenate the MS response with blank responses
    end
    results.R2      = data.R2';
    leftidx  = 1:numel(lcurv);
    rightidx = (1:numel(rcurv))+numel(lcurv);
    hemi = {'lh';'rh'};
    tmp = cell(2,1);
    tmp{1} = struct('modelmd', {zeros(size(results.modelmd(leftidx,:)))}, 'R2', {zeros(size(results.R2(leftidx,:)))});
    tmp{2} = struct('modelmd', {zeros(size(results.modelmd(rightidx,:)))},'R2', {zeros(size(results.R2(rightidx,:)))});
    
    for f = 1 : length(fields)
        for h = 1 : length(hemi)
            tmp{h}.(fields{f}) = zeros(size(hemi{h}));
            if f == 1
                for r = 1:size(results.modelmd(leftidx,:),2)
                    if h  == 1
                        tmp{h}.(fields{f})(leftidx,r) = results.(fields{f})(leftidx,r);
                    else
                        tmp{h}.(fields{f})(1:length(rightidx),r) = results.(fields{f})(rightidx,r);
                    end
                end
            else
                if h  == 1
                    tmp{h}.(fields{f})(leftidx) = results.(fields{f})(leftidx);
                else
                    tmp{h}.(fields{f})(1:length(rightidx)) = results.(fields{f})(rightidx);
                end
            end
        end
    end
    % Added later on to have the .mat files for two hemispheres separately
    betas = tmp{1};
    save([GLMfolder sprintf('lh.betas.%i.mat',condition)], 'betas');
    clear betas
    betas = tmp{2};
    save([GLMfolder sprintf('rh.betas.%i.mat',condition)], 'betas');
    
    tmp{1}.R2 = tmp{1}.R2';
    tmp{2}.R2 = tmp{2}.R2';
    
    assert(isequal(numel(lcurv) + numel(rcurv), numel(results.R2)), ...
        'The number of vertices in the GLM denoise results and the l&r curv files do not match;');
    
    % extract the nifti files and the orig
    path2subj = fullfile(path2project, 'derivatives','fmriprep', sprintf('sub-%s', subject), 'ses-nyu3t01', 'func');
    runs = dir(sprintf('%s/*fsnative*.nii.gz',path2subj));
    myfiles_nii = cell(1,length(runs));
    for f = 1:length(runs)
        mytmpname = runs(f).name;
        myfiles_nii{f} = sprintf('%s/%s', path2subj, mytmpname);
    end
    
    tmp_file{1} = load_nifti(myfiles_nii{3});
    tmp_file{2} = load_nifti(myfiles_nii{4});
    mgz     = MRIread(sprintf('%s/mri/orig.mgz',path2fs));
    
    
    % MGZ conversions;
    for f = 1 : length(fields)
        for h = 1 : length(hemi)
            sizetosave  = size(eval(sprintf('tmp_file{%i}.vol', h)));
            mgz.vol = zeros([sizetosave(1:3) size(tmp{h}.(fields{f}),2)]);
            mgz.vol(:,1,1,:) = tmp{h}.(fields{f});
            MRIwrite(mgz, fullfile(mgzfolder, sprintf('%s.%s.%i.mgz',hemi{h},fields{f},condition)));
        end
    end
end

files_to_convert = dir([mgzfolder '/*modelmd*.mgz']);

for f = 1:length(files_to_convert)
    
    tmp = MRIread([files_to_convert(f).folder filesep files_to_convert(f).name]);
    
    [~,b,~] = fileparts(files_to_convert(f).name);
    
    niftiwrite(tmp.vol,sprintf('%s/%s.nii',niftifolder,b));
    gzip(sprintf('%s/%s.nii',niftifolder,b));
    
    a = niftiRead(sprintf('%s/%s.nii.gz',niftifolder,b));
    a.xyz_units = 'mm';
    a.time_units = 'sec';
    niftiWrite(a,sprintf('%s/%s.nii.gz',niftifolder,b));
end
end
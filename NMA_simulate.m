%% Define the params
npoints = 1001;
mxecc   = 10; % degrees
x       = linspace(-mxecc,mxecc,npoints)'; 
sd      = 2*[1 1.5]; % size of RF
voxsd   = 2; % size of voxel (extent of summation)
attgain = 2; % gain factor of attention field
attx0   = 0; % location of attention field
attsd   = 2; % size of AF
sigma   = .01; % sigma factor of normalization

%% Neural RFs
RF = exp(-1/2*(x/sd(1)).^2)';
RF = RF / sum(RF);
RFsupp = exp(-1/2*(x/(sd(2))).^2)';
RFsupp = RFsupp / sum(RFsupp);
%% Voxel summation (across neurons)
voxrf = exp(-1/2*(x/voxsd).^2);
voxrf = voxrf / sum(voxrf);
%% Stimuli
stim = eye(npoints);
%% Attention field
attfield = exp(-1/2*((x-attx0)/attsd).^2);
attfield = attgain*attfield  + 1;
%% Stimulus and Suppressive Drive
stimdrive = conv2(stim, RF, 'same');
numerator = stimdrive .* (attfield * ones(1,npoints));
suppdrive = conv2(numerator, RFsupp, 'same');
%% population response
popresp = numerator ./ (suppdrive + sigma);
voxresp = conv2(popresp, voxrf, 'same');

%% visualize
fH = figure(1); clf;
set(fH, 'Color', 'w');
lw = 3;
fs = 16;
subplot(3,3,1); plot(x, RF, x, RFsupp, 'LineWidth', lw);
title('RF, center and surround');
plotOptions(gca, fs);
subplot(3,3,2); plot(x, attfield, 'LineWidth', lw);
title('Attention field');
plotOptions(gca, fs);
subplot(3,3,3);
imagesc(x, x, stim')
title('Stimuli');
plotOptions(gca, fs);
subplot(3,3,4);
imagesc(x, x, stimdrive);
title('Stimulus drive');
plotOptions(gca, fs);
ylabel('Neural population')
xlabel('Stimulus')
subplot(3,3,5);
imagesc(x, x, suppdrive);
title('Suppressive drive');
plotOptions(gca, fs);
ylabel('Neural population')
xlabel('Stimulus')
subplot(3,3,6);
imagesc(x, x, popresp);
title('Population response');
plotOptions(gca, fs);
ylabel('Neural population')
xlabel('Stimulus')
subplot(3,3,7);
locs  = -5:5;
stimidx = zeros(size(locs));
for ii = 1:length(locs)
    k = locs(ii);
    [~, stimidx(ii)] = min(abs(x-(attx0+k)));
end
plot(x, popresp(:, stimidx), 'LineWidth', lw);
ylim([0,1])
title('Population response');
set(gca, 'XTick', x(stimidx),  'XGrid', 'on', 'GridAlpha', 1)
plotOptions(gca, fs);
hold on
[~, respidx] = max(popresp(:, stimidx)); yl = get(gca, 'YLim');
plot(x(respidx)*[1 1], yl, 'r--')
subplot(3,3,8);
plot(x, popresp(stimidx,:), 'LineWidth', lw)
ylim([0,1])
title('Neural responses');
plotOptions(gca, fs);
hold on; set(gca, 'XTick', x(stimidx),  'XGrid', 'on', 'GridAlpha', 1)
[~, respidx] = max(popresp(stimidx, :),[],2); yl = get(gca, 'YLim');
plot(x(respidx)*[1 1], yl, 'r--')
subplot(3,3,9);
plot(x, voxresp(stimidx,:), 'LineWidth', lw)
ylim([0,1])
title('Voxel responses');
plotOptions(gca, fs);
hold on; set(gca, 'XTick', x(stimidx),  'XGrid', 'on', 'GridAlpha', 1)
[~, respidx] = max(voxresp(stimidx, :),[],2); yl = get(gca, 'YLim');
plot(x(respidx)*[1 1], yl, 'r--')
set(gcf,'Position',[0 0 1600 1600])


function plotOptions(ax, fs)
set(ax, 'FontSize', fs)
end
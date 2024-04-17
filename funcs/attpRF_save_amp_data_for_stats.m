% Load the saved amplitude data from cortical target ROIs:
s0_attentionpRF;
load([fullfile(path2project,'derivatives','amplitude_data'),'/att_resp_reorg_pseudotimeseries.mat']);
attention_response = squeeze(mean(subj_averaged_attention_activity, 5)); % average across mapping stim positions
attend_in_response = attention_response(:,:,:,1) - attention_response(:,:,:,2);
attend_out_response = attention_response(:,:,:,3) - attention_response(:,:,:,2);

% some subjects have missing data. Either the maps couldn't be defined (subj049)
% or they don't have any vertices serviving at cortical ROI definitions (such
% as no vertex for UVM representation). 
% These cells are filled with NaN. For the purpose of repeated measures
% ANOVA, we will omit them


data = cat(4, attend_in_response, attend_out_response);
data(1,:,:,:) = [];
data(4,:,:,:) = [];
data(6,:,:,:) = [];

varType = ["double", "double", "double", "double","double"];
varNames = ["id","ROI", "Location","AttCondition","BOLD"];

tablesize = [size(data,1)*size(data,2)*size(data,3)*size(data,4), length(varNames)];
data_table = table('Size',tablesize,'VariableTypes',cellstr(varType),'VariableNames',cellstr(varNames));

iter = 1;
for subj = 1:size(data,1)
    for roi = 1:length(ROIs)
        for target = 1:num_targets
            for att_resp = 1:size(data,4)
                data_mat(iter,:) = [subj, roi, target, att_resp, data(subj, roi, target, att_resp)];
                iter = iter+1;
            end
        end
    end
end
data_table.id = data_mat(:,1);
data_table.ROI = data_mat(:,2);
data_table.Location = data_mat(:,3);
data_table.AttCondition = data_mat(:,4);
data_table.BOLD = data_mat(:,5);
writetable(data_table, fullfile(path2project, 'derivatives/amplitude_data/', 'amplitude_data_for_ANOVA.csv'), 'Delimiter', ',', 'QuoteStrings', 'all')
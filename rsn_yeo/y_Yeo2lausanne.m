function [rsn, ratio, regionDescriptions, rsnDescription] = ...
    y_Yeo2lausanne(fsaverageDirectory, DKtemplate)
% Y_YEO2LAUSANNE links DK template to Yeo2011_7Networks template based on
% Freesurfer annotation files
%
% INPUT:
%   fsaverageDirectory: directory to fsaverage subject,
%                       e.g., '/Applications/freesurfer/subjects/fsaverage'
%   DKtemplate: template name, e.g., 'aparc' 'lausanne120' 'lausanne250'
%
% OUTPUT:
%   rsn: N by 1 vector indicating the network to which the region belongs
%   ratio: N by M matrix, N is the number of regions, M is the
%               number of Yeo networks, indicating proportion of vertices 
%               of DK region in each Yeo network
%   regionDescription: DK region descriptions
%   moduleDescription: Yeo 7 RSN descriptions
%
% by Yongbin Wei, created @Feb 2017, last modified @June 2020

[vDK{1,1}, lDK{1,1}, tDK{1,1}] = read_annotation(...
    fullfile(fsaverageDirectory, 'label', ['lh.', DKtemplate, '.annot']));

[vDK{2,1}, lDK{2,1}, tDK{2,1}] = read_annotation(...
    fullfile(fsaverageDirectory, 'label', ['rh.', DKtemplate, '.annot']));

[vYeo{1,1}, lYeo{1,1}, tYeo{1,1}] = read_annotation(...
    fullfile(fsaverageDirectory, 'label', 'lh.Yeo2011_7Networks_N1000.annot'));

[vYeo{2,1}, lYeo{2,1}, tYeo{2,1}] = read_annotation(...
    fullfile(fsaverageDirectory, 'label', 'rh.Yeo2011_7Networks_N1000.annot'));

rsn_idx = tYeo{1,1}.table(:,5);
rsnDescription = {'Visual'; 'Somatomotor'; 'DorsalAttention'; ...
    'VentralAttention'; 'Limbic'; 'FrontalParietal'; 'DMN'};

[rsn_idx_unq, rsn_idx_unq_sort] = sort(rsn_idx);

for n = 1:2 % 1 lh; 2 rh
    vertex = vDK{n,1};
    label = lDK{n,1};
    colorTable = tDK{n,1};
    
    vertexY = vYeo{n,1};
    labelY = lYeo{n,1};
    colorTableY = tYeo{n,1};

    % for each region in DK
    for i=1:colorTable.numEntries                           
        % vertices index in region i
        vertex_idx = find(label==colorTable.table(i,5));          
        
        % label ID in Yeo
        labelY_i_all = labelY(vertex_idx);                     

        % count frequency
        labelY_i_count = histc(labelY_i_all, rsn_idx_unq);     
        
        if ~isempty(labelY_i_count)
            % largest count
            [~, J] = max(labelY_i_count);                           
            region_tmp{n,1}{i,1} = colorTable.struct_names{i};
            mod_tmp{n,1}(i,1) = rsn_idx_unq(J);             
            ratio_tmp{n,1}(i, rsn_idx_unq_sort) = ...
                labelY_i_count./sum(labelY_i_count);
        else
            region_tmp{n,1}{i,1} = colorTable.struct_names{i};
            mod_tmp{n,1}(i,1) = nan;
            ratio_tmp{n,1}(i,:) = nan;
        end
    end
end

% combine two hemi
region_tmp{1,1} = strcat('ctx-lh-', region_tmp{1,1});
region_tmp{2,1} = strcat('ctx-rh-', region_tmp{2,1});
regionDescriptions = [region_tmp{1,1}; region_tmp{2,1}];

ratio = [ratio_tmp{1,1}; ratio_tmp{2,1}];
ratio(:, 1) = [];
rsn = [mod_tmp{1,1}; mod_tmp{2,1}];
for i=1:numel(rsn_idx)
    rsn(rsn==rsn_idx(i)) = i;
end
rsn = rsn - 1;
rsn(rsn==0) = nan;

end 


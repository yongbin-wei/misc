function [groupedValues, regionDescriptions] = groupValues(values, ...
    freesurferDir, template, hemi)
% GROUPVALUES computes the mean value of vertices within each cortical
% region
%
% Input:
%   values: N by 1 vector of values for all N vertices
%   freesurferDir: full path to the folder of FS output
%   template: name of the parcellation. e.g., 'aparc', 'lausanne120', ...
%   hemi: hemisphere. e.g., 'lh', 'rh'
% 
% Output:
%   groupedValues: regional average of values
%   regionDescriptions: region names
%
% This function is created by Marcel de Reus, modified by Yongbin Wei
    
disp('Start grouping values...');

if nargin ~= 4
    error("Error: please provide all 4 arguments");
    return
end

% load parcellation
path_annot = fullfile(freesurferDir, 'label', [hemi '.' template '.annot']);
disp('Load annotations file ...');
disp(path_annot);
[~, label, colortable] = read_annotation(path_annot);

% prepare output
outputRegions = find(~ismember(...
    colortable.struct_names, {'corpuscallosum', 'unknown'}));
regionDescriptions = cellfun(@(x) ['ctx-' hemi '-' x], ...
    colortable.struct_names(outputRegions), 'UniformOutput', false);
groupedValues = zeros(numel(outputRegions), 1);

% group values
for i = 1:numel(outputRegions)
    groupedValues(i) = ...
        mean(values(label == colortable.table(outputRegions(i), 5)));
end

disp('>> finished without errors');

end

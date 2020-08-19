clear, clc, close all;

disp('## This pipeline produces gene expression levels for a given atlas');
disp('## GAMBA version');
disp('## Output 2 different versions of gene expressions: ');
disp('## non-normalized one and normalized one (zeros mean across samples)');
disp('## log 2 transformed');
disp('## using gene_symbol and entrez ID, including subcortical tissues');
disp('--------------------- Start -----------------------');

% set parameters
Parcellation = 'Kleist'; 
MinDist = 2; % minimum distance from tissue samples to gray matter voxels
MappingTable_FS = cell(6, 1);

% set paths
project_path = fileparts(fileparts(mfilename('fullpath')));
disp(['## PROJECT_PATH: ',project_path]);

data_path = fullfile(project_path, 'raw');
disp(['## DATA_PATH: ',data_path]);

biomartPath = fullfile(project_path, 'tables', 'mart_export.txt');
disp(['## Table_for_updating_probes: ',biomartPath]);
% Note. This file is downloaded from biomart on Jan 13rd 2020.

hgncPath = fullfile(project_path, 'tables', 'hgnc_symbols.txt');
disp(['## Table_for_updating_gene_symbols: ',hgncPath]);

mni152Path = '/Volumes/tidis/templates/MNI152_FS';
disp(['## MNI152 path: ',mni152Path]);

lookuptablePath = ['/Volumes/tidis/misc/atlases/', ...
    Parcellation, '/colortable_ranamed.txt'];
disp(['## Lookup tables path: ',lookuptablePath]);

matrix_path = fullfile(project_path, 'matrices');
disp(['## MATRIX_PATH: ',matrix_path]);

output_path = fullfile(matrix_path, ...
    ['GE_',Parcellation,'_',num2str(MinDist),'mm.mat']);
disp(['## OUTPUT_FILE: ', output_path]);

% load subjects
fid = fopen(fullfile(project_path,'subj_list.txt'),'r');
T = textscan(fid,'%s');
fclose(fid);
subj_name = T{1};
disp('## SUBJECT_NAME');
disp(subj_name);

% ------------------------ running -------------------------
for i = 1: numel(subj_name)    
    disp(['## Processing ',subj_name{i}]);
    
    % load data
    [Probes, SampleAnnot, PACall, Expression, Ontology] = ...
        y_read_data(fullfile(data_path, subj_name{i}));
  
    % update gene annotation using biomart    
    Probes = y_update_probes_v1(Probes, biomartPath);

    % update gene HGNC symbol
    TT = readtable(hgncPath);
    Probes.gene_symbol = y_update_genes(Probes, TT);
    
    % select only cortex/subcortex & left hemisphere
    isCortex = cellfun(@(X) isequal(X, 'CX'), SampleAnnot.slab_type,...
        'UniformOutput', false);
    isCortex = cellfun(@(X) X==1, isCortex);
    isLeft = cellfun(@(X) strfind(X, 'left'), SampleAnnot.structure_name,...
        'UniformOutput',false);
    isLeft = cellfun(@(X) ~isempty(X), isLeft);
    isIncl = isCortex .* isLeft;
    
    % rearrange data
    Expression(:,1) = [];    % delete the first column (i.e., id)
    PACall(:,1) = [];        % delete the first column (i.e., id)
    Expression(:,isIncl==0) = nan;   % set ~iscortex || ~isleft to nan
    PACall(:,isIncl==0) = nan;       % set ~iscortex || ~isleft to nan
    
    % only include expressions that are above the background
    Expression(PACall==0) = nan;

    % average gene expression across probes, for each gene     
    [gene_expression, gene_id, gene_symbol] = ...
        y_average_gene_across_probes_v4(Expression, Probes);
    
    % mapping tissue sample to regions    
    MappingTable_FS{i,1} = y_mapping_sample_to_region_FS_v2(SampleAnnot, ...
        Parcellation, isIncl, MinDist, mni152Path, lookuptablePath);
            
    % average gene expression within each region     
    [gene_expression_region_FS(:, :, i), regionDescriptions] = ...
        y_average_gene_within_region_v3(gene_expression, ...
        MappingTable_FS{i,1}, lookuptablePath); 
end

% exclude cerebellum
IIcerebellum = contains(regionDescriptions, 'Cerebellum');
regionDescriptions(IIcerebellum) = '';
gene_expression_region_FS(IIcerebellum, :, :) = [];

% normalize within subject, cortex and subcortex separately
IIcortex = contains(regionDescriptions, 'ctx-lh-');
IIsubcortex = contains(regionDescriptions, 'Left-');
gene_expression_region_FS_z = gene_expression_region_FS;
for i = 1:numel(subj_name)
    for j = 1:size(gene_expression_region_FS,2) 
       gene_expression_region_FS_z(IIcortex, j, i) = ...
           (gene_expression_region_FS(IIcortex, j, i) - ...
           nanmean(gene_expression_region_FS(IIcortex, j, i))) ...
           ./ nanstd(gene_expression_region_FS(IIcortex, j, i));
       if nnz(IIsubcortex) ~= 0
           gene_expression_region_FS_z(IIsubcortex, j, i) = ...
               (gene_expression_region_FS(IIsubcortex, j, i) - ...
               nanmean(gene_expression_region_FS(IIsubcortex, j, i))) ...
               ./ nanstd(gene_expression_region_FS(IIsubcortex, j, i));
       end
    end
end

% remove non-genes
I = cellfun(@(X) strfind(X,'A_'), gene_symbol,...
    'UniformOutput',false);
I = cellfun(@(X) ~isempty(X),I);
II = cellfun(@(X) strfind(X,'CUST_'), gene_symbol,...
    'UniformOutput',false);
II = cellfun(@(X) ~isempty(X),II);
III = I+II;
gene_symbol(III==1) = [];
gene_id(III==1) = [];
gene_expression_region_FS_z(:,III==1,:) = [];
gene_expression_region_FS(:,III==1,:) = [];

% gene_info table
gene_info = table(gene_symbol, gene_id);
head(gene_info)

% save data
disp('## Saving data...')
save(output_path, 'gene_expression_region_FS', ...
    'gene_expression_region_FS_z', ...
    'gene_symbol', 'regionDescriptions', 'MappingTable_FS', 'gene_info');

disp('--------------------- end -----------------------');
clc, clear, close all

datapath = '/Volumes/tidis/misc/brain_genes';


% load GTEx
GTEx = readtable(fullfile(datapath, ...
    'GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_median_tpm.gct'), ...
    'FileType', 'text');
tpm = GTEx{:, 3:end};
ensemble_id = GTEx.Name;

% load HAR
HAR = load(fullfile(datapath, 'HARs_all_Doan.mat'));
HAR.HARgenes = HAR.HARs_genes;

% upadate gene symbols
TT = readtable(fullfile(datapath, 'hgnc_symbols.txt'));
head(TT)

[HAR.HARgenes, HAR.HARgenes_clear , n_preG1, n_alias1] = ...
    y_update_gene_symbol(HAR.HARgenes, TT);

[GTEx.Description, ~, n_preG2, n_alias2] = ...
    y_update_gene_symbol(GTEx.Description, TT);

% =========== load AHBA ===========
AHBA = load( fullfile(datapath, '../../', 'AHBA', 'matrices', ...
    'GE_lausanne120_2mm_GAMBA_20200819.mat'), 'gene_symbol');

% =========== overlap between AHBA and GTEx ===========
[gene_symbols, I, J] = intersect(GTEx.Description, AHBA.gene_symbol);
tpm = tpm(I, :);
tpm(tpm==0) = nan;
tpm = log2(tpm + 1);

disp(['overlap between AHBA and GTEx: ',num2str(numel(gene_symbols))]);


%% =========== Brain related genes ===========
Descriptions = GTEx.Properties.VariableNames(3:end);
mask_brain = contains(Descriptions, 'Brain');

for ii = 1:size(tpm,1)
    [~, p(ii,1)] = ttest2(tpm(ii, mask_brain), tpm(ii, ~mask_brain), ...
        0.05, 'right');
end
p_adj = mafdr(p, 'BHFDR', true);
Q = 0.01;
rpkm_brain = tpm(p_adj < Q, :);
gene_brain = gene_symbols(p_adj <= Q);

gene_brain_HAR = intersect(HAR.HARgenes , gene_brain); % HAR Brain
gene_HAR = intersect(HAR.HARgenes, AHBA.gene_symbol); % HAR all
gene_AHBA = AHBA.gene_symbol; % AHBA all

% save
save(fullfile(datapath, ['GTEx_brain_genes_',num2str(Q),'_updated.mat']),...
    'gene_brain', 'gene_brain_HAR', 'gene_HAR');
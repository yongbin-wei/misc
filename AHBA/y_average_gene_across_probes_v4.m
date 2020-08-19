function [gene_expression, gene_id, gene_symbols] = ...
y_average_gene_across_probes_v4(Expression, Probes)
% This function avarage all expression of probes represented by the same
% gene. i.e., convert [N_prob x N_sample] to [N_gene x N_sample]
% by Yongbin Wei, 2018, VU Amsterdam, the Netherlands.

gene_id = unique(Probes.entrez_id); % get all genes
gene_id(isnan(gene_id)) = [];

gene_expression = ...
    zeros(numel(gene_id),size(Expression,2)); % N_genes x N_samples

% average probes represented by the same genes in each sample
for ii = 1:numel(gene_id)
    I = ismember(Probes.entrez_id, gene_id(ii));
    gene_expression(ii,:) = nanmean(Expression(I==1,:),1);% [Ngenes x Nsamples]
end

% winsorized at 50
gene_expression(gene_expression > 50) = 50;

% log2 transform 
gene_expression = log2(gene_expression + 1);

% gene symbols
[~, J] = ismember(gene_id, Probes.entrez_id);
gene_symbols = Probes.gene_symbol(J);

end
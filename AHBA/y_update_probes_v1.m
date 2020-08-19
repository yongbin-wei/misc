function probeTbl_out = y_update_probes_v1(probeTbl, biomartPath)
% Y_UPDATE_PROBES is used to update gene annoatation using data from biomart
% by Yongbin Wei, 2018, VU Amsterdam, the Netherlands.

T = readtable(biomartPath, 'Delimiter', ',');

% remove empty probes
II = cellfun(@(X) isempty(X), T.AGILENTWholeGenome4x44kV1Probe,...
    'UniformOutput', false);
II = cell2mat(II);
T(II, :) = [];

% remove empty id
II = isnan(T.NCBIGeneID);
T(II, :) = [];

% remove empty symbols
II = cell2mat(cellfun(@(X) isempty(X),T.HGNCSymbol,'UniformOutput',false));
T(II, :) = [];

% intersect probe name
[~, i1, i2] = intersect(probeTbl.probe_name, ...
    T.AGILENTWholeGenome4x44kV1Probe);

% gene symbol
probeTbl.gene_symbol(i1) = T.HGNCSymbol(i2);

% entrez id
probeTbl.entrez_id(i1) = T.NCBIGeneID(i2);

probeTbl_out = probeTbl;

end
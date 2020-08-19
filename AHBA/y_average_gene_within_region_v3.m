function [gene_expression_region, regionDescriptions] = ...
    y_average_gene_within_region_v3(Gene_expression, Map, lookup_tabl_dir)

    TL = readtable(lookup_tabl_dir);    
    labels_all = TL.Var1;
    
    gene_expression_region = ...
        nan(numel(labels_all), size(Gene_expression,1));

    for ii = 1:numel(labels_all)
        % find samples with the same roi
        I = ismember(Map.roi, labels_all(ii));
        % if there are samples
        if sum(I) ~= 0
            % average gene expression
            gene_expression_region(ii, :) = ...
                nanmean(Gene_expression(:, I), 2);
        end
    end
    regionDescriptions = TL.Var2;
end
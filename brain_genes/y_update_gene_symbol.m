function [gene_new, gene_clear, k_preG, k_alias] = y_update_gene_symbol( ...
    gene_old, HGNC_table)

    % which one is approved
    I = ismember(gene_old, HGNC_table.ApprovedSymbol); 
    % which one is alias
    II = ismember(gene_old, HGNC_table.AliasSymbol);
    % which one is old
    III = ismember(gene_old, HGNC_table.PreviousSymbol); 

    k_alias = 0;
    k_preG = 0;
    gene_new = gene_old;
    gene_clear = gene_old;

    for ii = 1:numel(gene_old)
        if I(ii) ~= 1              % if it is not an approved symbol
            tmp = gene_old(ii); % AHBA name 

            if III(ii) == 1      % if it is a previous symbol of others
                J = ismember(HGNC_table.PreviousSymbol, tmp);
                tmp_new = HGNC_table.ApprovedSymbol(J);  % new symbol
                tmp_new_unique = unique(tmp_new); % old id

                if numel(tmp_new_unique)~=1
                    continue;
                else
                    gene_clear{ii} = 'delete';
                    gene_new{ii} = tmp_new_unique{1};
                    k_preG = k_preG + 1;
                end
            else
                if II(ii) == 1       % if it is a alias of other
                    J = ismember(HGNC_table.AliasSymbol, tmp);
                    tmp_new = HGNC_table.ApprovedSymbol(J == 1);  % new symbol
                    tmp_new_unique = unique(tmp_new); % old id

                    if numel(tmp_new_unique)~=1
                        continue;
                    else
                        gene_clear{ii} = 'delete';
                        gene_new{ii} = tmp_new_unique{1};
                        k_alias = k_preG+1;
                    end   
                end
            end
        end    
    end
end
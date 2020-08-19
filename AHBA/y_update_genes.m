function [gene_AHBA_new, gene_AHBA_clear] = y_update_genes(Probes, HGNC_table)
% Y_UPDATE_GENES is used to update gene symbols using data from HGNC
% Input
%   'Probes' - content in Probes.txt
%   'HGNC_table' - HGNC table downloaded from the HGNC website
% by Yongbin Wei, 2018, VU Amsterdam, the Netherlands.

gene_AHBA = Probes.gene_symbol;
TT = HGNC_table;
AHBA = Probes;

I = ismember(gene_AHBA, TT.ApprovedSymbol); % which one is approved
II = ismember(gene_AHBA, TT.AliasSymbol); % which one is alias
III = ismember(gene_AHBA, TT.PreviousSymbol); % which one is old

n_alias = 0;
n_preG = 0;
gene_AHBA_new = gene_AHBA;
gene_AHBA_clear = gene_AHBA;

for i=1:numel(gene_AHBA)
    
    % if not approved
    if I(i)~=1              
        tmp = gene_AHBA{i}; % AHBA name 
        id_old = AHBA.entrez_id(i); % old id
        
        % if previous symbol      
        if III(i) == 1      
            J = ismember(TT.PreviousSymbol,tmp);
            tmp_new = TT.ApprovedSymbol(J==1);  % new symbol
            id_new = TT.NCBIGeneID(J==1);       % new id     
            [I1,J1] = ismember(id_old, id_new);
            % if same id, then change name
            if I1==1  
                gene_AHBA_clear{i} = 'delete';
                gene_AHBA_new{i} = tmp_new{J1};
                n_preG = n_preG+1;
            end
            
        % if alias symbol
        elseif II(i) == 1       
           J = ismember(TT.AliasSymbol,tmp);
           tmp_new = TT.ApprovedSymbol(J==1);  % new symbol
           id_new = TT.NCBIGeneID(J==1);       % new id     
           [I1,J1] = ismember(id_old, id_new);
           % if same id, then change name
           if I1==1  
               gene_AHBA_clear{i} = 'delete';
               gene_AHBA_new{i} = tmp_new{J1};
               n_alias = n_alias+1;
           end         
        end
    end
end    

disp(['# Gene symbol updating finished: ',...
    num2str(n_preG),' previous symbols are updated; ',...
    num2str(n_alias),' alias symbols are updated.'])
end
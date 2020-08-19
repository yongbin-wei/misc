function MappingTable = y_mapping_sample_to_region_FS_v2(SampleAnnot, ...
    Parcellation, isinclude, MinDist, MNI152_dir, lookup_tabl)

    %sample MNI coordinates
    SampleMNI = [SampleAnnot.mni_x, SampleAnnot.mni_y, SampleAnnot.mni_z];

    % load mni152 parcellation
    vol = MRIread(fullfile(MNI152_dir, 'mri', [Parcellation, '+aseg.mgz']));

    % display the region labels
    TL = readtable(lookup_tabl);
    label_id_include = TL.Var1(contains(TL.Var2, {'ctx-lh-', 'Left-'}));

    % exlude others
    vol.vol = vol.vol .* double(ismember(vol.vol, label_id_include)); 
    idx_voxels = find(vol.vol > 0);
    [C, R, S] = ind2sub(size(vol.vol), idx_voxels); % voxel subscripts
    CRS = [R-1, C-1, S-1]; % matlab subsripts to freesurfer CRS
    labels = vol.vol(idx_voxels);

    % mri_info --vox2ras MNI152_FS/mri/orig.mgz
    Norig = [-1.00000    0.00000    0.00000  128.50000;...
       0.00000    0.00000    1.00000 -145.50000;...
       0.00000   -1.00000    0.00000  150.50000;...
       0.00000    0.00000    0.00000    1.00000];
    MNI152RAS = Norig*[CRS, ones(numel(idx_voxels),1)]';
    MNI152RAS = MNI152RAS(1:3,:)';

    % calculate the minimum distance
    dist_min = zeros(size(SampleMNI,1),1);
    dist_min_idx = zeros(size(SampleMNI,1),1);
    for i=1:size(SampleMNI,1)
        tmp = sqrt(sum((bsxfun(@minus, MNI152RAS, SampleMNI(i,:))).^2,2)); 
        [dist_min(i), dist_min_idx(i)] = min(tmp);
    end
    sample_label = labels(dist_min_idx);
    sample_label(isinclude==0) = nan;

    % under distance threshold
    sample_idx_2mm = find(dist_min <= MinDist);
    sample_idx_2mm_other = find(dist_min > MinDist);
    dist_min(sample_idx_2mm_other) = nan;
    sample_label(sample_idx_2mm_other) = nan;

    sample_label_description = cell(numel(sample_label),1);
    for i=1:numel(sample_label)
        if ~isnan(sample_label(i))
            [~, J] = ismember(sample_label(i), TL.Var1);
            sample_label_description{i,1} = TL.Var2{J};
        end
    end

    MappingTable = table([1:numel(sample_label)]', SampleAnnot.structure_name, ...
        SampleAnnot.structure_acronym, SampleAnnot.slab_type, ...
         sample_label, sample_label_description);
    MappingTable.Properties.VariableNames = {'sample_id', 'structure_name', ...
        'structure_acronym', 'slab_type', 'roi', 'regionDescriptions'};
end
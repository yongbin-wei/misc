function remesh(subject, reference, hemi, surf)
% REMESH creates meshes of a FS subject to match meshes of a reference FS
% subject
%
% Input:
%   subject: full path to the folder of FS output of a subject
%   reference: full path to the folder of FS output of the reference
%   hemi: the hemisphere. e.g., 'lh', 'rh'
%   surf: the surface type. e.g., pial, white, inflated
%
% Note: This function requires FreeSurfer function read_surf.m
%
% This function is created by Marcel de Reus, modified by Yongbin Wei

if nargin < 2
    error("Error: please input at least the first 2 arguments");
    return
end

if nargin == 2
    hemi = 'lh';
    surf = 'pial';
    warning(['Warning: hemisphere and surf type are not specified. ',...
        'Using default settings']);
end

if nargin == 3
    surf = 'pial';
    warning('Warning: surf type is not specified. Using default settings');
end

disp('>> Pipeline starts ...')

% paths
path_subj_sphere_reg = fullfile(subject, 'surf', [hemi, '.sphere.reg']);
path_subj_surf = fullfile(subject, 'surf', [hemi, '.', surf]);
disp('>> Surface to be remeshed');
disp(path_subj_surf);

path_ref_sphere_reg = fullfile(reference, 'surf', [hemi, '.sphere.reg']);
path_ref_surf = fullfile(reference, 'surf', [hemi, '.', surf]);
disp('>> Reference surface');
disp(path_ref_surf);

if isequal(reference(end), '/')
    reference = reference(1:end-1);
end
[~, referenceName] = fileparts(reference);
opath = fullfile(subject, 'surf', [hemi, '.', surf, '.', referenceName]);

% load registered surface data
[regVertices faces] = read_surf(path_subj_sphere_reg);
faces = faces + 1;

[regVerticesRef facesRef] = read_surf(path_ref_sphere_reg);
facesRef = facesRef + 1;

% load subject's pial surface
oldVertices = read_surf(path_subj_surf);

% preallocate memory for new vertices
newVertices = zeros(size(regVerticesRef));

% put each reference vertex on subject's pial surface
for i = 1:size(regVerticesRef, 1)

    % rank subject's vertices based on proximity
    n = size(regVertices, 1);
    vertexRanks = zeros(n, 1);
    [~, I] = sort(regVertices*regVerticesRef(i, :)', 'descend'); %% min distance
    vertexRanks(I) = 1:n;

    % sort subject's faces based on vertex ranking
    [~, faceI] = sort(sum(vertexRanks(faces), 2), 'ascend');

    % find face which comprises the reference vertex
    counter = 1;
    while true
        vertexI = faces(faceI(counter), :);
        w = [regVerticesRef(i, :) 1]/[regVertices(vertexI, :) ones(3, 1)];
        if all(w >= 0)
            break;
        end
        counter = counter + 1;
    end

    % compute new coordinates and report progress
    newVertices(i, :) = w*oldVertices(vertexI, :);
end

% save remeshed surface
disp('>> Write to output file ...');
disp(opath);
write_surf(opath, newVertices, facesRef);

disp('>> finished without errors');

end

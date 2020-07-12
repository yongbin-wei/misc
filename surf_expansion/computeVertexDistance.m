function distance = computeVertexDistance(freesurferSurface)
% COMPUTEVERTEXDISTANCE computes the average distance for each vertex to
% its neigbours
%
% Input:
%   freesurferSurface: full path to the surface file (produced by
%   Freesurfer)
%
% Output:
%   distance: N by 1 vector of the mean distance for all N vertices
%
% This function is created by Marcel de Reus, modified by Yongbin Wei

disp('Start computing vertex distance ...');
if exist(freesurferSurface, 'file')
    % load surface
    [vertices faces] = read_surf(freesurferSurface);
    faces = faces + 1;

    % preallocate memory for output
    distance = zeros(size(vertices, 1), 1);

    % compute average distance to neighbors for each vertex
    for i = 1:numel(distance)

        % find neighboring vertices
        neighbors1 = faces(any(faces == i, 2), :);
        neighbors1 = unique(neighbors1(neighbors1 ~= i));

        % compute distance
        distance(i) = mean(sqrt(sum((vertices(neighbors1, :) - ...
            vertices(i*ones(numel(neighbors1), 1), :)).^2, 2)));
    end
end

disp('>> finished without errors');

end
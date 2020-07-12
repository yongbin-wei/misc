function [area, areaVertex] = computeFaceArea(freesurferSurface)
% COMPUTEFACEAREA computes the (average) area for each face in a surface
%
% Input:
%   freesurferSurface: full path to the surface file (produced by
%   Freesurfer)
%
% Output:
%   area: M by 1 vector of the area for all M faces
%   areaVertex: N by 1 vector of the mean area for all N vertices
%
% This function is created by Yongbin Wei

disp('Start computing face area...');

if exist(freesurferSurface, 'file')
    % load surface
    [vertices,faces] = read_surf(freesurferSurface);
    faces = faces + 1;

    % preallocate memory for output
    areaVertex = zeros(size(vertices,1),1);

    % compute area of each face
    A = vertices(faces(:,1),:);
    B = vertices(faces(:,2),:);
    C = vertices(faces(:,3),:);
    tmp = cross(C-A , B-A);
    area = 0.5 * sqrt(sum(tmp.^2 , 2));

    for i=1:size(areaVertex,1)
        areaVertex(i,1) = mean(area(any(faces==i,2)));
    end
end

disp('>> finished without errors');

end
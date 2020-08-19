function h = y_plotBrainMappVertices(val, surf, type, color, limits)
% ======================== Function Description ===========================
% Y_PLOTBRAINMAPPVERTICES(VAL, SURF) plots brain maps
%
% INPUT
%   val: N by 1 vector of values needed to be plotted
%   surf: the corresponding surface file path
%   type: colormap type of cbrewer. e.g., 'div', 'seq', 'qual'
%   color: colormap color of cbrewer. e.g., 'RdBu', 'Blues'   
%   limits: [minimum, maximum] to be plotted
%
% NOTE! this function is based on cbrewer and real2rgb toolboxes
%
% Written by Yongbin Wei, 2018, Marcel de Reus, 2015

% ======================== Function Starts Here ===========================

if nargin == 2
    limits = [min(val), max(val)];
    type = 'seq';
    color = 'Blues';
elseif nargin == 3
    limits = [min(val), max(val)];
    if isequal(type, 'seq')
        color = 'Blues';
    elseif isequal(type, 'div')
        color = 'RdBu';
    else
        color = 'Set1';
    end
elseif nargin == 4
    limits = [min(val), max(val)];
end

% only include cortex
if strfind(surf,'lh') ~= 0
    path = [fileparts(surf),'/../label/lh.aparc.annot'];
else
    path = [fileparts(surf),'/../label/rh.aparc.annot'];
end
[~, label, ct] = read_annotation(path);
cortex = double(label ~= ct.table(1, 5)) .* double(label ~= 0);

% adjust val
val = val .* cortex;
val(val < limits(1)) = limits(1);
val(val > limits(2)) = limits(2);

% generate color map
if isequal(type, 'seq')
    CT=cbrewer('seq', color, 1000);
    B1 = squeeze(real2rgb(val, CT));
elseif isequal(type, 'div')
    CT=cbrewer('div', color, 1000);
    CT = flipud(CT);
    CT = CT(101:900,:);
    tmp = max(abs([limits(1), limits(2)]));
    val = [val; -tmp; tmp];
    B1 = squeeze(real2rgb(val, CT));
    B1 = B1(1:end-2, :);
    val = val(1:end-2);
end 

% plot surface map
h = plotSurface(surf, val, B1);

view([90,0]);

end
        

function h = plotSurface(freesurferSurface, values, colorMatrix)    
    m = size(colorMatrix, 1);
    if m ~= numel(values) + 1
       colorMatrix = [colorMatrix; 0 0 0]; % background color
    end

    % load freesurfer surface
    [vertices, faces] = read_surf(freesurferSurface);
    colorIndices = [1: size(vertices,1)]';

    figure('units', 'normalized', ...
        'outerposition', [0 0 0.5 0.5], 'color', [1 1 1]);

    % plot surface
    h = patch('Vertices', vertices, 'Faces', faces + 1, ...
        'FaceVertexCData', colorIndices, 'CDataMapping', 'direct', ...
        'FaceColor', 'flat', 'FaceLighting', 'gouraud', ...
        'EdgeColor', 'none');
    colormap(colorMatrix);

    % set properties
    set(gca, 'position', [0 0 1 1], 'units', 'inches');
    axis equal;
    axis off;
    
    % light
    lightHandle = camlight('headlight', 'infinite');
    set(gca, 'UserData', lightHandle);
    material dull;
    
    % rotation
    rotateHandle = rotate3d;
    set(rotateHandle, 'ActionPostCallback', @mypostcallback);
    set(rotateHandle, 'Enable', 'on');

end

function mypostcallback(obj, evd)
    lightHandle = get(evd.Axes, 'UserData');
    camlight(lightHandle, 'headlight');
end

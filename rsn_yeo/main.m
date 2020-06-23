clc, clear

atlas = 'lausanne120';

[RSN, Ratio, regionDescription, rsnDescription] = ...
    y_Yeo2lausanne('~/Documents/codes/fsaverage', atlas);

% remove unknown and corpuscallosum
[~, J] = ismember({'ctx-lh-unknown','ctx-lh-corpuscallosum',...
    'ctx-rh-unknown','ctx-rh-corpuscallosum'}, regionDescription);
J = nonzeros(J);
RSN(J) = '';
regionDescription(J) = '';
Ratio(J,:) = '';

save(['Yeo7_in_',atlas,'.mat'], 'RSN', 'Ratio', 'rsnDescription',...
    'regionDescription');

% % Display
% y_plotBrainMappHFF(RSN, regionDescription, 'lausanne120')


%% Divide sensory-motor and auditory networks
atlas = 'lausanne120';
load(['Yeo7_in_',atlas,'.mat']);

% get regions in SMN
idx = find(RSN ==2);
R_idx = regionDescription(idx);

% look for regions
div1 = contains(R_idx, 'temporal');
div2 = contains(R_idx, 'bankssts');
div3 = contains(R_idx, 'insula');
div = div1 + div2 + div3;

RSN(RSN > 2) = RSN(RSN > 2) + 1;
RSN(idx(div == 1)) = 3;
rsnDescription = [rsnDescription{1}; 'Somatomotor'; ...
    'Somatomotor-temporal'; rsnDescription(3:end)];

save(['Yeo7+1_in_',atlas,'.mat'], 'RSN', 'Ratio', 'rsnDescription',...
    'regionDescription');

% % Display
% y_plotBrainMappHFF(RSN, regionDescription, 'lausanne120')

function surfaceSmooth(srcFile, freesurfer_subj, hemi, fwhm)
% SURFACESMOOTH smoothes surface based on mri_surf2surf in Freesurfer
%
% Input:
%   srcFile: full path to the source curv file
%   freesurfer_subj: full path to the folder of FS output
%   hemi: hemisphere. e.g., 'lh', 'rh'
%   fwhm: smooth kernel in full width half maximum 
%
% This function is created by Yongbin Wei

if ~exist(srcFile, 'file')
    error('File does not exist');
    return
end

if nargin == 3
    warning('fwhm is not given. Using default settings');
    fwhm = 10;
end

[datapath, subj_name] = fileparts(freesurfer_subj);
[~, src_name, src_ext] = fileparts(srcFile);

mpath = fileparts(mfilename('fullpath'));

setenv('SUBJECTS_DIR', datapath);
cd(datapath);

txt = ['mri_surf2surf --s ',subj_name, ...
    ' --sval ', srcFile, ...
    ' --sfmt curv',...
    ' --fwhm ',num2str(fwhm),' --hemi ', hemi,...
    ' --label-trg ', subj_name,'/label/',hemi,'.cortex.label', ...
    ' --tval ', subj_name, '/surf/', src_name, src_ext, '.sm', num2str(fwhm), '.mgh'];
system(txt);

cd(mpath);

end
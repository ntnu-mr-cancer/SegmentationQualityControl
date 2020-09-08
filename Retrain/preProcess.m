%---- Data Pre-processing ----%
% 1- Normalize the original scans.
% 2- Correct the deep learning mask to make sure that they can be read.
function preProcess(basePath)
%% Normalize
% AutoRef method used
inptupath = fullfile(basePath,'Data','Cases','Original');
outputpath = fullfile(basePath,'Data','Cases''Normalized');
list = dir(fullfile(inptupath,'*.mhd'));
for ii = 1:numel(list)
    normalized = AutoRef(list(ii).folder,list(ii).name);
    StrDatax = elxIm3dToStrDatax(normalized);
    FilenameNorm = fullfile(outputpath,[list(ii).name '_normalized.mhd']);
    elxStrDataxToMetaIOFile(StrDatax, FilenameNorm, 0);
    clear normalized StrDatax
end
%% Prepare the deep learning segmentations

%% U-Net segmentations
% paths
inptupath = 'Path to the predicted segmentations by U-Net';
outputpath = fullfile(basePath,'Data','Segmentations','UNet_2D');
% list of cases
list = dir(fullfile(inptupath,'*.mhd'));
% loop over the cases
for ii = 1:numel(list)
    [StrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(inptupath,list(ii).name), 0);
    im3d = elxStrDataxToIm3d(StrData);
    StrData = elxIm3dToStrDatax(im3d);
    elxStrDataxToMetaIOFile(StrData, fullfile(outputpath,list(ii).name), 0);
end
%% V-Net segmentations
% paths
inptupath = 'Path to the predicted segmentations by V-Net';
outputpath = fullfile(basePath,'Data','Segmentations','VNet_3D');
% list of cases
list = dir(fullfile(inptupath,'*.mhd'));
% loop over the cases
for ii = 1:numel(list)
    [StrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(inptupath,list(ii).name), 0);
    elxStrDataxToMetaIOFile(StrData, fullfile(outputpath,[list(ii).name(1:7) '_segmentation.mhd']), 0); % might need to change list(ii).name(1:7) to what fits your naming system
end
%% nn-U-Net 2D segmentation
% Use SimpleITK from python to conver nii.gz to mhd
system(fullfile(basePath,'Codes','niigztomhdnnUNet2D.py'));

% Delete some tags to enable ElastixFromMatlab toolbox
dirlist = dir(fullfile('Path to the predicted segmentations by nn-U-Net 2D','*.mhd'));
for ii = 1:numel(dirlist)
    filename = fullfile(dirlist(ii).folder,dirlist(ii).name);
    % Read mhd header into cell A
    fid = fopen(filename,'r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid);
    % Change cell A and save in B
    B = {A{1:10},A{58:60}}; % new cell array with the wanted lines
    % Write cell B into mhd header
    fid = fopen(filename, 'w');
    for i = 1:numel(B)
        fprintf(fid,'%s\n', B{i});
    end
    fclose(fid);
end

%% nnUNet3d segmentation
% Use SimpleITK from python to conver nii.gz to mhd
system(fullfile(basePath,'Codes','niigztomhdnnUNet3D.py'));

% Delete some tags to enable ElastixFromMatlab toolbox
dirlist = dir(fullfile('Path to the predicted segmentations by nn-U-Net 3D','*.mhd'));
for ii = 1:numel(dirlist)
    filename = fullfile(dirlist(ii).folder,dirlist(ii).name);
    % Read mhd header into cell A
    fid = fopen(filename,'r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid);
    % Change cell A and save in B
    B = {A{1:10},A{58:60}}; % new cell array with the wanted lines
    % Write cell B into mhd header
    fid = fopen(filename, 'w');
    for i = 1:numel(B)
        fprintf(fid,'%s\n', B{i});
    end
    fclose(fid);
end
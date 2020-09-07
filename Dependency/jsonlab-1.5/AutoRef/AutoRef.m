%% AutoRef.m
% 
% this function is used to perform normalization at T2-weighted MRI images
% based on the paper by sunoqrot MRS, et al."Automated reference tissue 
% normalization of T2-weighted MR images of the prostate using object recognition" 
% https://link.springer.com/article/10.1007%2Fs10334-020-00871-3
%
% NOTE: when you use this function/method cite this articel:
% Sunoqrot, M.R.S., Nketiah, G.A., Selnæs, K.M. et al. Automated reference tissue
% normalization of T2-weighted MR images of the prostate using object recognition.
% Magn Reson Mater Phy (2020). https://doi.org/10.1007/s10334-020-00871-3
% 
% INPUT
% inputDirectory: the input directory of the image (string)
%(in DICOM or MetaIO (.mhd, .mha) format) containing the image name and format
% e.g. meatIO Image: 'C:/DataIn/image.mhd' Dicom folder:'C:/DicomImagesStackFolder'
%
% OUTPUT
% nomralized: the normalized image in 3D (structure)

function normalized = AutoRef(inputDirectory)
%% Add dependency
% the path to this function folder
basePath = which('AutoRef.m');
basePath = basePath(1:end-10);
% add all folders and subfolders in the path
addpath(genpath(basePath));

%% settings
global settings;

% base directory
settings.baseDirectory = basePath; % string; the dirctory to the space were the processing is going to happen

% dataset directory
settings.dataDirectory = inputDirectory; % string; the input directory of the image, containing the image e.g. 'C:/DataIn/image.mhd'

% preprocessing; 
settings.scalingMethod = 'ScaledPercentile'; % string; the scaling method: 'none' 'ScaledMax', 'ScaledMedian' or 'ScaledPercentile'
settings.scalingMethodArgs = {99,100/99}; % cell; arguments for the scaling Method options above: {[]},{scaleFactor}, {scaleFactor} or {percentile,scaleFactor}

% detect objects
settings.images = 'imagesLabels.mat'; % string; name of the repository containing the unlabeled images
settings.fatFocusRegionSlices ='lower34' ; % string; focus on 'lowerHalf' (0-50%), 'lower34' (0-75%), 'middle' (25-75%), 'upperHalf' (50-100%), 'upper34' (75-100%) of the image stack slices, or 'all' images
settings.fatFocusRegionRows = 'lowerHalf'; % string; focus on 'lowerHalf' (0-50%), 'lower34' (0-75%), 'middle' (25-75%), 'upperHalf' (50-100%), 'upper34' (75-100%)  of the 2D image raws, or 'all' raws
settings.muscleFocusRegionSlices = 'middle'; % string; focus on 'lowerHalf' (0-50%), 'lower34' (0-75%), 'middle' (25-75%), 'upperHalf' (50-100%), 'upper34' (75-100%)  of the image stack slices, or 'all' images
settings.muscleFocusRegionRows = 'middle'; % string; focus on 'lowerHalf' (0-50%), 'lower34' (0-75%), 'middle' (25-75%), 'upperHalf' (50-100%), 'upper34' (75-100%)  of the 2D image raws, or 'all' raws
settings.nrProcSlices = 10; % scalar (1-10); number of slices to process 

% find rois
settings.morphOpenPix = 1; % scalar; width (pixels) of disk element for morphological opening

% normalize
settings.nrEvalSlices = 3; % scalar (1-10), number of slices to be used
settings.lowHighPercentile = [10 90]; % 2 x 1 array; percentiles used ([low high]) for extracting the low and high intensity reference values

%% pre-process and write images
[bfc_image,imagesLabels,resizeInfo] = preProcessAutoRef();

%% load the trained object detectors
tempLoad = load(fullfile(settings.baseDirectory,'fatDetector.mat'));
fatDetector = tempLoad.fatDetector;
tempLoad = load(fullfile(settings.baseDirectory,'muscleDetector.mat'));
muscleDetector = tempLoad.muscleDetector;

%% detect objects in evaluation set
detectedFat = detectObjectsAutoRef('fat',fatDetector,imagesLabels,resizeInfo);
detectedMuscle = detectObjectsAutoRef('muscle',muscleDetector,imagesLabels,resizeInfo);

%% find ROIs
roiFat = findRoisAutoRef('fat',detectedFat,bfc_image);
roiMuscle = findRoisAutoRef('muscle',detectedMuscle,bfc_image);

%% normalize
normalized = normalizeAutoRef(roiFat,roiMuscle,bfc_image);

%% clean after
rmdir(fullfile(settings.baseDirectory,'tempImages'),'s')
clearvars -except normalized
end

%% preProcessAutoRef.m
% this function is used to
% 1- read the images, the images should be either in DICOM or MetaIO format
% 2- resize the images to new grid: 384 x 384 pixels of 0.5 x 0.5 mm
% 3- scale the images according to the chosen scaling method
% 4- write the images to file so they can be used for the object detector
%
% OUTPUT
% bfc_image: the bias field corrected image in 3D (structure)
% imagesLabels: contains the full directory for each of the written images to be used by the object dector (table)
% resizeInfo: contains the scaling info to be used to rescale the image later to its original size(table)

function [bfc_image,imagesLabels,resizeInfo] = preProcessAutoRef()
% parse input
global settings;
scalingMethod = settings.scalingMethod;
scalingMethodArgs = settings.scalingMethodArgs;

%% run
% folder for output images
if ~exist(fullfile(settings.baseDirectory,'tempImages'),'dir')
    mkdir(fullfile(settings.baseDirectory,'tempImages'));
end

% change input format to .mhd
if contains(settings.dataDirectory,'.mhd')
    [orig_image, ~, ~] = elxMetaIOFileToStrDatax(settings.dataDirectory, 0);
    orig_image = elxStrDataxToIm3d(orig_image);
else
    orig_image = loadImage3d(settings.dataDirectory);
end

% apply ITK N4 bias field correction
bfc_image = n4BiasFieldCorrection(orig_image);

% resize fixed image to new grid: 384 x 384 pixels of 0.5 x 0.5 mm
plane_dim = [size(bfc_image.Data,1) size(bfc_image.Data,2)];
plane_res = [sum(bfc_image.A(1:3,2).^2) sum(bfc_image.A(1:3,1).^2)].^(1/2);
grid_factors = [0.5 0.5]./plane_res;

% calculate roi offset in original image space
new_rows = round(plane_dim(1)/grid_factors(1));
new_cols = round(plane_dim(2)/grid_factors(2));
roi_row_shift = -(384-new_rows)/2*grid_factors(1);
roi_col_shift = -(384-new_cols)/2*grid_factors(2);

% assign to resize_info
scale = grid_factors;
shift = [roi_row_shift roi_col_shift];

% do the thing
im = bfc_image.Data;
switch scalingMethod
    case 'none'
    case 'ScaledMax'
        scaleFactor = scalingMethodArgs{1};
        im = im/(max(im(:))*scaleFactor);
    case 'ScaledMedian'
        scaleFactor = scalingMethodArgs{1};
        im = im/(median(im(:))*scaleFactor);
    case 'ScaledPercentile'
        prct = scalingMethodArgs{1};
        scaleFactor = scalingMethodArgs{2}; 
        im = im/(prctile(im(:),prct)*scaleFactor);
end

for ii=1:size(bfc_image.Data,3)
    slice = im(:,:,ii);
    new_rows = round(plane_dim(1)/grid_factors(1));
    new_cols = round(plane_dim(2)/grid_factors(2));
    new_img = resizem(slice,[new_rows new_cols]);
    if new_rows < 384
        new_img = padarray(new_img,[floor((384-new_rows)/2) 0],0,'pre');
        new_img = padarray(new_img,[ceil((384-new_rows)/2) 0],0,'post');
        new_rows = size(new_img,1);
    elseif new_rows > 384
        new_img = imcrop(new_img,[1 floor((new_rows-384)/2)+1 new_cols 384-1]);
        new_rows = size(new_img,1);
    end
    if new_cols < 384
        new_img = padarray(new_img,[0 floor((384-new_cols)/2)],0,'pre');
        new_img = padarray(new_img,[0 ceil((384-new_cols)/2)],0,'post');
    elseif new_cols > 384
        new_img = imcrop(new_img,[floor((new_cols-384)/2)+1 1 384-1 new_rows]);
    end
    imwrite(new_img,fullfile(settings.baseDirectory,'tempImages',sprintf('%s_%02i.tiff','slice',ii)));
end
    
% make images lables file 
warning('off','all')
images = table([]);
images.Properties.VariableNames = {'imageFilename'};
dirtype = dir(fullfile(settings.baseDirectory,'tempImages','*.tiff'));
nametype = {dirtype.name}.';
for ii = 1:size(nametype,1)
    images.imageFilename{ii} = (fullfile(settings.baseDirectory,'tempImages',nametype{ii}));  
end 
imagesLabels = images;
resizeInfo = table(scale,shift);
end

%% detectObjectsAutoRef.m
% 
% this function detects fat or muscle objects
%
% INPUT
% tissue_type: 'fat' or 'muscle'
% detector: a trained object recognition detector
% imagesLabels: the full directory for each of the written images (table)
% resize_info: factors for scaling and translation of the ROI (table) 
%
% OUTPUT
% detected_objects: ROIs most likely containing the object (table)

function detected_objects = detectObjectsAutoRef(tissue_type,detector,imagesLabels,resize_info)

% parse input
global settings;
switch tissue_type
    case 'fat'
        focus_region_slices = settings.fatFocusRegionSlices;
        focus_region_rows = settings.fatFocusRegionRows;
    case 'muscle'
        focus_region_slices = settings.muscleFocusRegionSlices;
        focus_region_rows = settings.muscleFocusRegionRows;
end

% cut off start of filenames
start_idx = numel(settings.baseDirectory)+1;
new_image_names = imagesLabels.imageFilename;
for ii=1:size(new_image_names,1)
    new_image_names{ii} = new_image_names{ii}(start_idx:end);
end

% detect objects
input = imagesLabels;
bboxes = zeros(size(input,1),4);
scores = zeros(size(input,1),1);
switch focus_region_slices
    case 'all'
        slices = 1:size(input,1);
    case 'lowerHalf'
        slices = 1:ceil(size(input,1)/2);
    case 'lower34'
        slices = 1:ceil(size(input,1)/4*3);
    case 'middle'
        slices = floor(size(input,1)/4):ceil(size(input,1)/4*3);
    case 'upperHalf'
        slices = floor(size(input,1)/2):size(input,1);
    case 'upper34'
        slices = floor(size(input,1)/4):size(input,1);
end

switch focus_region_rows
    case 'all'
        rows = 1:384;
    case 'lowerHalf'
        rows = floor(384/2+1):384;
    case 'lower34'
        rows = floor(384/4+1):384;
    case 'middle'
        rows = floor(384/4+1):ceil(384/4*3);
    case 'upperHalf'
        rows = 1:ceil(384/2+1);
    case 'upper34'
        rows = 1:ceil(384/4*3+1);
end

for jj=slices
    imgtemp = imread(input.imageFilename{jj});
    img = zeros(size(imgtemp));
    img(rows,:) = imgtemp(rows,:);
    img = uint8(img);
    [tmp_bboxes,tmp_scores] = detect(detector,img);
    if not(isempty(tmp_scores))
        [~,maxprobidx] = max(tmp_scores);
        bboxes(jj,:) = tmp_bboxes(maxprobidx,:);
        scores(jj,1) = tmp_scores(maxprobidx,1);
    end
end

% sort and show detected objects, and convert to original image space
[~,slice_idx] = sort(scores,'descend');
nr_detected_slices = min(sum(scores>0),settings.nrProcSlices);
sliceNrs = {slice_idx(1:nr_detected_slices)};
boundingBoxes = {round(bboxes(slice_idx(1:nr_detected_slices),[2 1 4 3]) .* ...
repmat(resize_info.scale,[nr_detected_slices 2]) + ...
repmat([resize_info.shift 0 0],[nr_detected_slices 1]))};
predictionScores = {scores(slice_idx(1:nr_detected_slices),:)};
    
detected_objects = table(sliceNrs,boundingBoxes,predictionScores);
end

%% findRoisAutoRef.m
% 
% this function finds the fat or muscle rois in detected objects
%
% INPUT
% tissue_type: 'fat' or 'muscle'
% detected_object: detected fat or muscle objects (table)
% bfc_image: the bias field corrected image in 3D (structure)
%
% OUTPUT
% roi: high or low intensity roi (table)

function roi = findRoisAutoRef(tissue_type,detected_objects,bfc_image)

% parse input
global settings;
switch tissue_type
    case 'fat'
        intensity = 'high';
        focus_region_rows = settings.fatFocusRegionRows;
    case 'muscle'
        intensity = 'low';
        focus_region_rows = settings.muscleFocusRegionRows;
end

% find rois and image intensities
detected_boundingBoxes = detected_objects.boundingBoxes{:};
detected_sliceNrs = detected_objects.sliceNrs{:}; 

% load image
im3d = bfc_image.Data;

switch focus_region_rows
    case 'all'
        rows = 1:size(im3d,1);
    case 'lowerHalf'
        rows = floor(size(im3d,1)/2+1):size(im3d,1);
    case 'lower34'
        rows = floor(size(im3d,1)/4+1):size(im3d,1);
    case 'middle'
        rows = floor(size(im3d,1)/4+1):ceil(size(im3d,1)/4*3);
    case 'upperHalf'
        rows = 1:ceil(size(im3d,1)/2+1);
    case 'upper34'
        rows = 1:ceil(size(im3d,1)/4*3+1);
end

% detect outliers
iqr = prctile(im3d(:),75) - prctile(im3d(:),25);
im3d_wo_outliers = im3d;
im3d_wo_outliers(im3d>prctile(im3d(:),75)+3*iqr) = nan;

% rois & intensities
bboxes = detected_boundingBoxes;
slices = detected_sliceNrs;

% pre-allocating
roiIdx = cell(numel(slices),1);
roiInt = cell(numel(slices),1);

for jj=1:numel(slices)

    idx = slices(jj);
    im2d = im3d(:,:,idx);
    im2d_wo_outliers = im3d_wo_outliers(:,:,idx);

    row_start = max(bboxes(jj,1),min(rows));
    row_end = min(bboxes(jj,1)+bboxes(jj,3)-1,max(rows));
    col_start = max(bboxes(jj,2),1);
    col_end = min(bboxes(jj,2)+bboxes(jj,4)-1,size(im2d,2));
    roi = im2d(row_start:row_end,col_start:col_end);
    roi_in = im2d_wo_outliers(row_start:row_end,col_start:col_end);
    level = multithresh(roi_in,1);
    seg_roi = imquantize(roi,level);

    switch intensity
        case 'high'
            seg_roi(isnan(roi_in)) = 1;
            seg_roi = seg_roi == 2;
        case 'low'
            seg_roi(isnan(roi_in)) = 2;
            seg_roi = seg_roi == 1;
    end

    se = strel('disk',settings.morphOpenPix);
    seg_roi = imopen(seg_roi,se);
    seg_roi = bwareafilt(seg_roi,1);

    % back to original image space
    roi3d = false(size(im3d));
    roi3d(row_start:row_end,col_start:col_end,idx) = seg_roi;
    roiIdx{jj} = find(roi3d);
    roiInt{jj} = im3d(roiIdx{jj});        
end
roi = table(roiIdx,roiInt);
end

%% normalizeAutoRef.m
%
% this function apply the normalization using AutoRef
%
% INPUT
% roi_high: high intensity rois, usually fat (table)
% roi_low: low intensity rois, usually muscle (table)
% bfc_image: the bias field corrected image in 3D (structure)
%
% OUTPUT
% nomralized: the normalized image in 3D (structure)

function normalized = normalizeAutoRef(roi_high,roi_low,bfc_image)
% parse input
global settings;

% initialize reference values
ref_hir = 121;
ref_lir = 40;

% determine number of slices
nr_slices = min([settings.nrEvalSlices numel(roi_low.roiIdx) numel(roi_high.roiIdx)]);

% load image
normalized = bfc_image;
im3d = normalized.Data;

% normalize by AutoRef (Our proposed method)
g_hir = prctile(vertcat(roi_high.roiInt{1:nr_slices}),settings.lowHighPercentile(2));
g_lir = prctile(vertcat(roi_low.roiInt{1:nr_slices}),settings.lowHighPercentile(1));
normalized.Data = (ref_hir-ref_lir)/(g_hir-g_lir)*(im3d-g_lir)+ref_lir;
end

function im3d_bfc = n4BiasFieldCorrection(im3d)
% parse input
global settings;

% make tmporary folder to write in
tempFolder = fullfile(settings.baseDirectory,'BFC');
mkdir(tempFolder);

% convert images to StrDatax and write to meta IO file
tempIn = fullfile(tempFolder,'tmpIn.mhd');
tempOut = fullfile(tempFolder,'tmpOut.mhd');
StrDatax = elxIm3dToStrDatax(im3d);
elxStrDataxToMetaIOFile(StrDatax,tempIn,0);

% do bias field correction from command line
command = ['c3d ' tempIn ' -biascorr -o ' tempOut];
% If you are runing the function on linux and did not work use:
% command = ['Full directory to c3d ' tempIn ' -biascorr -o ' tempOut]; e.g  command = ['/mnt/work/software/c3d/bin/c3d ' tempIn ' -biascorr -o ' tempOut];
system(command);

% read in corrected image
StrDatax_bfc = elxMetaIOFileToStrDatax(tempOut,0);
im3d_bfc = elxStrDataxToIm3d(StrDatax_bfc);

% clean up
rmdir(tempFolder,'s');
end

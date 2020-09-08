%---- Run the Analysis ----%
% Master code to run the pre-processing, training, optimizing and testing the data.
% And reporting the results.
%% Clear
clear
close all
clc
%% Settings
% Random generator seed
rng(1)
% Paths
basePath = 'C:\Study\Analysis';
originalScansPath = 'C:\Study\OriginalScansPath';
% Add path
addpath(genpath(basePath));
%% Make Folders
if ~exist(fullfile(basePath,'Data'),'dir')
    mkdir(fullfile(basePath,'Data','Original')) % to put your original scans here
    mkdir(fullfile(basePath,'Data','Normalized')) % to put your Normalized scans here
    mkdir(fullfile(basePath,'Data','Segmentations','Manual')) % to put your Manual segmentations here
    mkdir(fullfile(basePath,'Data','Segmentations','UNet_2D')) % to put your segmentations from "U-Net" her
    mkdir(fullfile(basePath,'Data','Segmentations','VNet_3D')) % to put your segmentations from "V-Net" her
    mkdir(fullfile(basePath,'Data','Segmentations','nnUNet_2D')) % to put your segmentations from "nnU-Net 2D" her
    mkdir(fullfile(basePath,'Data','Segmentations','nnUNet_3D')) % to put your segmentations from "nnU-Net 3D" her
    mkdir(fullfile(basePath,'Data','Features','Manual')) % to put the extracted features from Manual segmentations here
    mkdir(fullfile(basePath,'Data','Features','UNet_2D')) % to put the extracted features from "U-Net" her
    mkdir(fullfile(basePath,'Data','Features','VNet_3D')) % to put the extracted features from "V-Net" her
    mkdir(fullfile(basePath,'Data','Features','nnUNet_2D')) % to put the extracted features from "nnU-Net 2D" her
    mkdir(fullfile(basePath,'Data','Features','nnUNet_3D')) % to put the extracted features from "nnU-Net 3D" her
end
%% Segmentation
% Make manual segmentations
% Hold segmentation using the
% U-Net https://github.com/mirzaevinom/promise12_segmentation
% V-Net https://github.com/huangmozhilv/promise12_vnet_pytorch
% nnU-Net 2D and 3D (two diffrent models) https://github.com/MIC-DKFZ/nnUNet/tree/c3347d7e4623b5effc1a6728a7799fa9b1eeea8d
%% Organize data
% Put the original scans (.mhd) in the "fullfile(basePath,'Data','Original')"
copy(originalScansPath,fullfile(basePath,'Data','Original'))
%% Pre-processing
disp('-Pre-prcoessing')
preProcess(basePath)
%% Features Extraction
disp('-Feature Extraction')
if ~exist('features.mat','file')
    features = featureExtraction(basePath);
else
    load('features.mat')
end
%% Getting Responses (Scores)
disp('-Getting Responses')
disp('  -Calculate Factors')
% Calculate factors
% We recommend using the factors we provide, if you have a second reader
% manual segmentations then you can run "calculateFactors"
% rename one of factors_PROSTATEx.mat or factors_InHouse.mat as factor (from two diffrent
% datasets), so maybe you can try both and see what gives you best results.
% factros_PROSTATEx is calculated using PROSTATEx datset, while factors_InHouse calculated
% using an In-house collected dataset.
% You can use also the factors calculated from PROMISE12 challenge
% factors_Promise12.mat
if ~exist('factors.mat','file')
    % If you want to use the factors calculated using your own data
    factors = calculateFactors(basePath);
%     % If you want to use the factors calculated using PROMISE12 data
%     factors = calculateFactorsP12(basePath);
else
    load('factors.mat')
end
% Calculate scores
disp('  -Calculate scores')
if ~exist('scores.mat','file')
    scores = calculateScores(factors,basePath);
else
    load('scores.mat')
end
%% Prepare Data
disp('-Prepare Data')
if ~exist('prep.mat','file')
    prep = prepareData(features,scores,basePath);
else
    load('prep.mat')
end
%% Optimize Parameters
% check one option a time
% so you might need to stop your code here
% and run this section multiple times
disp('-Optimize Parameters')
if ~exist('optimize.mat','file')
    optimize = optimizeParm(prep);
else
    load('optimize.mat')
end
lambda = optimize.lambda;
%% Evaluate All The Models
disp('-Make Models')
if ~exist('models.mat','file')
    models = makeModels(prep,lambda);
else
    load('models.mat')
end
%% Report
disp('-Report')
pathR = fullfile(basePath,'Report');
if ~exist('report.mat','file')
    report = makeReport(features,models,pathR);
else
    load('report.mat')
end
disp('--FINISHED Analysis--')

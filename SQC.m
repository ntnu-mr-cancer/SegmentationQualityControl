%------------------------------------------------
% Segmentation Quality Score
% by Mohammed Sunoqrot, NTNU, Norway 
%
% Input:
%   scanPath: The path of the Image you run the segmentation on. The case
%             must be in .mhd, .mha or .mat format. (string)
%   segPath: The path of the resulted segmentation. (string)
%   normStatus: You have to set a number (1,2 or 3) (numeric)
%       1- The provided image is Not normalized.(default)
%       2- The provided image is a Normalized scan in .mhd 
%       3- The provided image is a Normalized image as Im3d (matlab)
%   qualityClassThr: The threshould, which any qualityScore less than it
%   would be considered NOT acceptable, and any value eqault or higher than
%   it will be considered Acceptable. (numeric)
%
% Output:
%   qualityScore: The segmentation quality score. (numeric)
%   qualityClass: The segmentaion quality class. (string)
%
% Usage Example:
%   Not normalized:
%
%   scanPath = 'C:\Data\Case001.mhd';
%   segPath = 'C:\Data\Case001_segmentation.mhd';
%   [qualityScore,qualityClass] = SQC(scanPath,segPath,1,85)
%
%   Normalized and saved as .mhd/.mha:
%
%   scanPath = 'C:\Data\Case001_normalized.mhd';
%   segPath = 'C:\Data\Case001_segmentation.mhd';
%   [qualityScore,qualityClass] = SQC(scanPath,segPath,2,85)
%
%   Normalized and saved as .mat:
%
%   scanPath = 'C:\Data\Case001_normalized.mat';
%   segPath = 'C:\Data\Case001_segmentation.mhd';
%   [qualityScore,qualityClass] = SQC(scanPath,segPath,3,85)
%------------------------------------------------
function [qualityScore,qualityClass] = SQC(scanPath,segPathIn,normStatus,qualityClassThr)
%% Base path
basePath = which('SQC.m');
basePath = basePath(1:end-6);
%% Add Dependency
addpath(genpath(fullfile(basePath,'Dependency')));
% Make temporary folders
tempPath = fullfile(basePath,'temp');
tempFEPath = fullfile(basePath,'tempFE');
mkdir(tempPath)
mkdir(tempFEPath)
%% Give a pseudonym
CaseNumber = ['Case' num2str(randi([100 999]))];
%% Segmentation preparing
segPath = segPrep(segPathIn,CaseNumber,tempPath,1);
%% Normalize using AutoRef
FileCaseNumberNorm = checkNormalization(scanPath,normStatus,CaseNumber,tempPath);
%% Feature extraction
% Wrtie paths to txt file to read in python
FileCaseNumberPaths = fullfile(basePath,'paths.txt');
fileID = fopen(FileCaseNumberPaths,'w');
fprintf(fileID,'%s\n',FileCaseNumberNorm);
fprintf(fileID,'%s\n',segPath);
fprintf(fileID,'%s\n',tempFEPath);
fprintf(fileID,'%s\n',CaseNumber);
fprintf(fileID,'%s\n',tempPath);
fclose(fileID);
% Run Pyradiomics feature extraction script from python And organize the resulted features
features = featureExtraction(basePath,CaseNumber);
% Clean after
rmdir(tempPath,'s')
rmdir(tempFEPath,'s')
delete(FileCaseNumberPaths)
rehash()
%% Get Quality Score
qualityScore = getQS(basePath,features);
%% Get Quality Class
qualityClass = getQC(qualityScore,qualityClassThr);
end

%%---- Segmentation preparing ----%
% Make sure that the segmentation can be read
% Input:
%   optionM (numeric): default : 1.
%       for segmentation method nnUNet_2D : 0 or any number but 1.
function segPathOut = segPrep(segPathIn,CaseNumber,tempPath,optionM)
if optionM ==1
    [StrDatax, ~, ~] = elxMetaIOFileToStrDatax(segPathIn, 0);
    segPathOut = fullfile(tempPath,[CaseNumber '_segmentation.mhd']);
    elxStrDataxToMetaIOFile(StrDatax, segPathOut, 0);
% else
%     % Copy to new directory
%     copyfile(segPathIn,tempPath)
%     % New name
%     segPathOut = fullfile(tempPath,[CaseNumber '_segmentation.mhd']);
%     % Use SimpleITK from python to conver nii.gz to mhd
%     system("niigztomhdnnUNet.py");
%     % Read mhd header into cell A
%     fid = fopen(segPathOut,'r');
%     i = 1;
%     tline = fgetl(fid);
%     A{i} = tline;
%     while ischar(tline)
%         i = i+1;
%         tline = fgetl(fid);
%         A{i} = tline;
%     end
%     fclose(fid);
%     % Change cell A and save in B
%     B = {A{1:10},A{58:60}}; % new cell array with the wanted lines
%     % Write cell B into mhd header
%     fid = fopen(segPathOut, 'w');
%     for i = 1:numel(B)
%             fprintf(fid,'%s\n', B{i});
%     end
%     fclose(fid);   
end
end

%% ---- Check Normalization ----%
% 1- If the image is not normalized, normalize it with AutoRef method
% 2- Give a random name to the case in process
function FileCaseNumberNorm = checkNormalization(scanPath,normStatus,CaseNumber,tempPath)
if normStatus == 1 % Not normalized scans
    normalized = AutoRef(scanPath);
    % Save the normalized scan in temp folder to be used in feature extraction
    StrDatax = elxIm3dToStrDatax(normalized);
    FileCaseNumberNorm = fullfile(tempPath,[CaseNumber '_normalized.mhd']);
    elxStrDataxToMetaIOFile(StrDatax, FileCaseNumberNorm, 0);
    elseif normStatus == 2  % Normalized scans as .mhd folder
    [StrDatax, ~, ~] = elxMetaIOFileToStrDatax(scanPath, 0);
    FileCaseNumberNorm = fullfile(tempPath,[CaseNumber '_normalized.mhd']);
    elxStrDataxToMetaIOFile(StrDatax, FileCaseNumberNorm, 0);
elseif normStatus == 3 % Normalized scans as Im3d matlab variable
    % Save the normalized scan in temp folder to be used in feature extraction
    l = load(scanPath);
    StrDatax = elxIm3dToStrDatax(l.nIm.autoref);
    FileCaseNumberNorm = fullfile(tempPath,[CaseNumber '_normalized.mhd']);
    elxStrDataxToMetaIOFile(StrDatax, FileCaseNumberNorm, 0);
else
    msg = 'Select 1, 2 or 3 to specifiy the normalization status.';
    error(msg)
end
end

%---- Features extraction ----%
% 1- Extrat features usign Deep learning masks
%    Using pyradiomics from python.
% 2- Organize the features in tables and one strucutre
function features = featureExtraction(basePath,CaseNumber)
addpath(genpath(fullfile(pwd,'Codes')));
%% Extract features
% Use Pyradiomics (V 2.2) package from python (3.7) 
system('python pyradiomicsFeatureExtraction.py');
%% Organize features
% region classes
region_classes = {'wholeprostate','apex','base'};
% feature classes
feature_classes = {'firstorder','shape','glcm','glrlm','glszm','ngtdm','gldm'};
% Fill arrays
for rr = 1:length(region_classes)
    for ff = 1:length(feature_classes)
        % create table
        table_name = sprintf('table_%s_%s',region_classes{rr},feature_classes{ff});
        eval([table_name ' = table;']);
        % get jsonname
        json_name = sprintf('%s_%s_%s.json',CaseNumber,region_classes{rr},feature_classes{ff});
        % read in and convert
        if exist(fullfile(basePath,'tempFE',json_name),'file')
            data = loadjson(fullfile(basePath,'tempFE',json_name));
            names = fieldnames(data);
            fdata = rmfield(data,names(~contains(names,feature_classes{ff})));
            colNames = fieldnames(fdata);
            % preallocate cell array
            colNamesNew = cell(numel(colNames),1);
            % loop to get variables names array
            for jj = 1:numel(colNames)
                colNamesNew{jj,:} = colNames{jj}(10:end);
            end
            % create temp table for each case
            tmp_table = struct2table(fdata);
            tmp_table.Properties.RowNames = {sprintf(CaseNumber)};
            tmp_table.Properties.VariableNames = colNamesNew;
            % add the tables together
            eval([table_name ' = [' table_name '; tmp_table];']);
            clear colNames colNamesNew
        end
%         % if not empty, save file
%         if not(isempty(eval(table_name)))
%             save(fullfile(basePath,'tempFE',table_name),table_name);
%         end
    end
end

%% Combine tables based on region classes
% Whole prostate
features_table_wholeprostate = [table_wholeprostate_firstorder,table_wholeprostate_shape,...
    table_wholeprostate_glcm,table_wholeprostate_glrlm,table_wholeprostate_glszm,...
    table_wholeprostate_ngtdm,table_wholeprostate_gldm];
% Rename variables
vn = cell(1,size(features_table_wholeprostate,2));
for kk = 1:size(features_table_wholeprostate,2)
    vn{kk} = [features_table_wholeprostate.Properties.VariableNames{kk} '_WP'];
end
features_table_wholeprostate.Properties.VariableNames = vn;
% Apex
features_table_apex = [table_apex_firstorder,table_apex_shape,...
    table_apex_glcm,table_apex_glrlm,table_apex_glszm,...
    table_apex_ngtdm,table_apex_gldm];
% Rename variables
vn = cell(1,size(features_table_apex,2));
for kk = 1:size(features_table_apex,2)
    vn{kk} = [features_table_apex.Properties.VariableNames{kk} '_Apex'];
end
features_table_apex.Properties.VariableNames = vn;
% Base
features_table_base = [table_base_firstorder,table_base_shape,...
    table_base_glcm,table_base_glrlm,table_base_glszm,...
    table_base_ngtdm,table_base_gldm];
% Rename variables
vn = cell(1,size(features_table_base,2));
for kk = 1:size(features_table_base,2)
    vn{kk} = [features_table_base.Properties.VariableNames{kk} '_Base'];
end
features_table_base.Properties.VariableNames = vn;
% Combine All
features_table_all = [features_table_wholeprostate,features_table_apex,features_table_base];
% Assign to structure
features = features_table_all;
end

%---- Get Quality score ----%
% Use the train model to predict quality score
function qualityScore = getQS(basePath,features)
% Load trained model
ld = load(fullfile(basePath,'trainedModel.mat'));
trainedModel = ld.trainedModel;
% Change predictors format
predictors = table2array(features);
% Predict Quality Score
qualityScore = predictors*trainedModel.coef + trainedModel.Intercept; 
if qualityScore < 0
    qualityScore = 0;
elseif qualityScore > 100
    qualityScore = 100;
end
end

%---- Get Quality class ----%
% Use the quality score with a specified threshould to determine if the segmentation is acceptable or not  
function qualityClass = getQC(qualityScore,qualityClassThr)
qcl = qualityScore<qualityClassThr;
if qcl == 1
    qualityClass = 'NOT Acceptable';
else
    qualityClass = 'Acceptable';
end
end
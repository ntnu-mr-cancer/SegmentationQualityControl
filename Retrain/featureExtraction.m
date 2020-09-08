%---- Features extraction ----%
% 1- Extrat features usign Deep learning masks
%    Using pyradiomics from python.
% 2- Organize the features in tables and one strucutre
function features = featureExtraction(basePath)
addpath(genpath(fullfile(pwd,'Codes')));
%% Extract features
% Use Pyradiomics (V 2.2) package from python (3.7)
% Make sure to adjust the python scripts paths
%---Manual
system(fullfile(basePath,'Codes','pyradiomicsFeaturesExtractionManualWithRegions.py'));
%---UNet2D
system(fullfile(basePath,'Codes','pyradiomicsFeaturesExtractionUNetWithRegions.py'));
%---VNet2D
system(fullfile(basePath,'Codes','pyradiomicsFeaturesExtractionVNetWithRegions.py'));
%---nnUNet2D
system(fullfile(basePath,'Codes','pyradiomicsFeaturesExtractionnnUNet2DWithRegions.py'));
%---nnUNet3D
system(fullfile(basePath,'Codes','pyradiomicsFeaturesExtractionnnUNet3DWithRegions.py'));

%% Organize features
%% settings
basePath = fullfile(basePath,'Data','Features');
casePath = fullfile(basePath,'Data','Cases','Original');
maskTypeList = dir(fullfile(basePath,'Data','Segmentations'));
maskTypeList = {maskTypeList(3:7).name}.';
for ii = 1:numel(maskTypeList)
    % directory
    dir_name = fullfile(basePath,maskTypeList{ii});
    % region classes
    region_classes = {'wholeprostate','apex','middle','base'};
    % feature classes
    feature_classes = {'firstorder','shape','glcm','glrlm','glszm','ngtdm','gldm'};
    % cases names
    namedir = dir(fullfile(casePath, '*.mhd'));
    name = {namedir.name}.';
    %% fill arrays
    for rr = 1:length(region_classes)
        for ff = 1:length(feature_classes)
            % create table
            table_name = sprintf('table_%s_%s',region_classes{rr},feature_classes{ff});
            eval([table_name ' = table;']);
            for pp = 1:numel(name)
                % get jsonname
                json_name = sprintf('%s_%s_%s.json',name{pp, 1}(1:end-4),region_classes{rr},feature_classes{ff});
                % read in and convert
                if exist(fullfile(dir_name,json_name),'file')
                    data = loadjson(fullfile(dir_name,json_name));
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
                    tmp_table.Properties.RowNames = {sprintf(name{pp, 1}(1:end-4))};
                    tmp_table.Properties.VariableNames = colNamesNew;
                    % add the tables together
                    eval([table_name ' = [' table_name '; tmp_table];']);
                    clear colNames colNamesNew
                end
            end
            % if not empty, save file
            if not(isempty(eval(table_name)))
                save(fullfile(dir_name,table_name),table_name);
            end
        end
    end
    % combine tables based on region classes
    
    % Whole prostate
    features_table_wholeprostate = [table_wholeprostate_firstorder,table_wholeprostate_shape,...
        table_wholeprostate_glcm,table_wholeprostate_glrlm,table_wholeprostate_glszm,...
        table_wholeprostate_ngtdm,table_wholeprostate_gldm];
    % rename variables
    vn = cell(1,size(features_table_wholeprostate,2));
    for kk = 1:size(features_table_wholeprostate,2)
        vn{kk} = [features_table_wholeprostate.Properties.VariableNames{kk} '_WP'];
    end
    features_table_wholeprostate.Properties.VariableNames = vn;
    % Apex
    features_table_apex = [table_apex_firstorder,table_apex_shape,...
        table_apex_glcm,table_apex_glrlm,table_apex_glszm,...
        table_apex_ngtdm,table_apex_gldm];
    % rename variables
    vn = cell(1,size(features_table_apex,2));
    for kk = 1:size(features_table_apex,2)
        vn{kk} = [features_table_apex.Properties.VariableNames{kk} '_Apex'];
    end
    features_table_apex.Properties.VariableNames = vn;
    % Middle
    features_table_middle = [table_middle_firstorder,table_middle_shape,...
        table_middle_glcm,table_middle_glrlm,table_middle_glszm,...
        table_middle_ngtdm,table_middle_gldm];
    % rename variables
    vn = cell(1,size(features_table_middle,2));
    for kk = 1:size(features_table_middle,2)
        vn{kk} = [features_table_middle.Properties.VariableNames{kk} '_Middle'];
    end
    features_table_middle.Properties.VariableNames = vn;
    % Base
    features_table_base = [table_base_firstorder,table_base_shape,...
        table_base_glcm,table_base_glrlm,table_base_glszm,...
        table_base_ngtdm,table_base_gldm];
    % rename variables
    vn = cell(1,size(features_table_base,2));
    for kk = 1:size(features_table_base,2)
        vn{kk} = [features_table_base.Properties.VariableNames{kk} '_Base'];
    end
    features_table_base.Properties.VariableNames = vn;
    % Combine A+M+B
    features_table_AMB = [features_table_apex,features_table_middle,...
        features_table_base];
    % Combine All
    features_table_all = [features_table_wholeprostate,features_table_apex,features_table_base];
    
    % Assign to structure
    features.(maskTypeList{ii}).wholeprostate = features_table_wholeprostate;
    features.(maskTypeList{ii}).apex = features_table_apex;
    features.(maskTypeList{ii}).middle = features_table_middle;
    features.(maskTypeList{ii}).base = features_table_base;
    features.(maskTypeList{ii}).AMB = features_table_AMB;
    features.(maskTypeList{ii}).all = features_table_all;
end
% Save features structure
save('features.mat','features')
end
%---- Calculate the segmentation evalation metrics ----%
% 1- Calculate the metrics for all the cases
% 2- Calcluate the total score of the cases
function scores = calculateScores(factors,basePath)
%% Add directories to the path
addpath(genpath(fullfile(pwd,'Codes')));
%% Calculate the metrics for all of the cases
% Get a list with the investigated deep learning segmentation models
segMethods = {'UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D'};
% The reference masks list
referenceMaskeDir = dir(fullfile(basePath,'Data','Segmentations','Manual','*.mhd'));
% The estimated masks path
pathEsMask = fullfile(basePath,'Data','Segmentations');
%% Loop over each of the deep learning segmentation methods
for ii = 1:numel(segMethods)
    % Get the segmentation model directories
    segMethod = segMethods{ii};
    estimatedMaskDir = dir(fullfile(pathEsMask,segMethod,'*.mhd'));
    % Loop over the cases
    for jj = 1:numel(estimatedMaskDir)
        % MetaIO to Structured data
        [referenceMaskStrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(referenceMaskeDir(jj).folder,referenceMaskeDir(jj).name), 0);
        [estimatedMaskStrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(estimatedMaskDir(jj).folder,estimatedMaskDir(jj).name), 0);
        % Structured data to 3D image structure
        referenceMask = elxStrDataxToIm3d(referenceMaskStrData);
        estimatedMask = elxStrDataxToIm3d(estimatedMaskStrData);
        % Region classes
        region_classes = {'wholeprostate','apex','middle','base'};
        
        %% Assign slices based on region class
        %% Reference mask
        % Get the slices contains mask
        rNrVoxels = squeeze(sum(sum(referenceMask.Data)));
        rfSlices = find(rNrVoxels>0);
        rSlices = rfSlices(1):rfSlices(end);
        
        % Assign the regions' slices
        rNSl = length(rSlices);
        rdNSl = rNSl/3;
        rfNSl = fix(rdNSl);
        
        rNS.wholeprostate = rSlices(1:length(rSlices));
        rNS.apex = rSlices(1:rfNSl);
        rNS.middle = rSlices(rfNSl+1:rNSl-rfNSl);
        rNS.base = rSlices(rNSl-rfNSl+1:rNSl);
        
        % Slices to be excluded when deal with a specific region
        rExclude.wholeprostate = [];
        rExclude.apex = [rNS.middle,rNS.base];
        rExclude.middle = [rNS.apex,rNS.base];
        rExclude.base = [rNS.apex,rNS.middle];
        
        %% Estimaed mask
        % Get the slices contains mask
        eNrVoxels = squeeze(sum(sum(estimatedMask.Data)));
        efSlices = find(eNrVoxels>0);
        eSlices = efSlices(1):efSlices(end);
        
        % Assign the regions' slices
        eNSl = length(eSlices);
        edNSl = eNSl/3;
        efNSl = fix(edNSl);
        
        eNS.wholeprostate = eSlices(1:length(eSlices));
        eNS.apex = eSlices(1:efNSl);
        eNS.middle = eSlices(efNSl+1:eNSl-efNSl);
        eNS.base = eSlices(eNSl-efNSl+1:eNSl);
        
        % Slices to be excluded when deal with a specific region
        eExclude.wholeprostate = [];
        eExclude.apex = [eNS.middle,eNS.base];
        eExclude.middle = [eNS.apex,eNS.base];
        eExclude.base = [eNS.apex,eNS.middle];
        
        %% Calculate the metrics
        % Reference mask
        rm = referenceMask;
        rmR = rm.Data;
        % Esitmated mask
        em = estimatedMask;
        emR = em.Data;
        % Loop over the regions
        for kk = 1:numel(region_classes)
            region_class = region_classes{kk};
            % Reference mask input
            rm.Data = rmR;
            rm.Data(:,:,rExclude.(region_class)) = 0;
            % Esitmated mask input
            em.Data = emR;
            em.Data(:,:,eExclude.(region_class)) = 0;
            % % Feed to getMetrics function
            metrics.(region_class).(segMethod)(jj) =...
                getMetrics(rm,em,rmR,emR,rExclude.(region_class),eExclude.(region_class));
            clear rm.Data em.Data
        end
    end
    %% Calculate scores from metrics
    % wholeprostate
    scores.(segMethod).wholeprostate.DSC = max([ones(numel(estimatedMaskDir),1),[metrics.wholeprostate.(segMethod).DSC].']*factors.wholeprostate_DSC,0);
    scores.(segMethod).wholeprostate.aRVD = max([ones(numel(estimatedMaskDir),1),abs([metrics.wholeprostate.(segMethod).aRVD].')]*factors.wholeprostate_aRVD,0);
    scores.(segMethod).wholeprostate.HD95 = max([ones(numel(estimatedMaskDir),1),[metrics.wholeprostate.(segMethod).HD95].']*factors.wholeprostate_HD95,0);
    scores.(segMethod).wholeprostate.ASD = max([ones(numel(estimatedMaskDir),1),[metrics.wholeprostate.(segMethod).ASD].']*factors.wholeprostate_ASD,0);
    
    scores.(segMethod).wholeprostate_score = mean([scores.(segMethod).wholeprostate.DSC,scores.(segMethod).wholeprostate.aRVD,...
        scores.(segMethod).wholeprostate.HD95,scores.(segMethod).wholeprostate.ASD],2);
    % apex
    scores.(segMethod).apex.DSC = max([ones(numel(estimatedMaskDir),1),[metrics.apex.(segMethod).DSC].']*factors.apex_DSC,0);
    scores.(segMethod).apex.aRVD = max([ones(numel(estimatedMaskDir),1),abs([metrics.apex.(segMethod).aRVD].')]*factors.apex_aRVD,0);
    scores.(segMethod).apex.HD95 = max([ones(numel(estimatedMaskDir),1),[metrics.apex.(segMethod).HD95].']*factors.apex_HD95,0);
    scores.(segMethod).apex.ASD = max([ones(numel(estimatedMaskDir),1),[metrics.apex.(segMethod).ASD].']*factors.apex_ASD,0);
    
    scores.(segMethod).apex_score = mean([scores.(segMethod).apex.DSC,scores.(segMethod).apex.aRVD,...
        scores.(segMethod).apex.HD95,scores.(segMethod).apex.ASD],2);
    
    % base
    scores.(segMethod).base.DSC = max([ones(numel(estimatedMaskDir),1),[metrics.base.(segMethod).DSC].']*factors.base_DSC,0);
    scores.(segMethod).base.aRVD = max([ones(numel(estimatedMaskDir),1),abs([metrics.base.(segMethod).aRVD].')]*factors.base_aRVD,0);
    scores.(segMethod).base.HD95 = max([ones(numel(estimatedMaskDir),1),[metrics.base.(segMethod).HD95].']*factors.base_HD95,0);
    scores.(segMethod).base.ASD = max([ones(numel(estimatedMaskDir),1),[metrics.base.(segMethod).ASD].']*factors.base_ASD,0);
    
    scores.(segMethod).base_score = mean([scores.(segMethod).base.DSC,scores.(segMethod).base.aRVD,...
        scores.(segMethod).base.HD95,scores.(segMethod).base.ASD],2);
    
    % total score
    scores.(segMethod).total_score = mean([scores.(segMethod).wholeprostate.DSC,scores.(segMethod).wholeprostate.aRVD,scores.(segMethod).wholeprostate.HD95,scores.(segMethod).wholeprostate.ASD,...
        scores.(segMethod).apex.DSC,scores.(segMethod).apex.aRVD,scores.(segMethod).apex.HD95,scores.(segMethod).apex.ASD,...
        scores.(segMethod).base.DSC,scores.(segMethod).base.aRVD,scores.(segMethod).base.HD95,scores.(segMethod).base.ASD],2);
end

%% Combine in one
% Get a list with the investigated deep learning segmentation models
segMethods = {'UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D'};
%% Loop over each of the deep learning segmentation methods
for ii = 1:numel(segMethods)
    % Get the segmentation model directories
    segMethod = segMethods{ii};
    %% Calculate scores from metrics
    % wholeprostate
    scores.All.(segMethod).wholeprostate.DSC = [scores.(segMethod).wholeprostate.DSC;scores.MRGB.(segMethod).wholeprostate.DSC];
    scores.All.(segMethod).wholeprostate.aRVD = [scores.(segMethod).wholeprostate.aRVD;scores.MRGB.(segMethod).wholeprostate.aRVD];
    scores.All.(segMethod).wholeprostate.HD95 = [scores.(segMethod).wholeprostate.HD95;scores.MRGB.(segMethod).wholeprostate.HD95];
    scores.All.(segMethod).wholeprostate.ASD = [scores.(segMethod).wholeprostate.ASD;scores.MRGB.(segMethod).wholeprostate.ASD];
    
    scores.All.(segMethod).wholeprostate_score = mean([scores.All.(segMethod).wholeprostate.DSC,scores.All.(segMethod).wholeprostate.aRVD,...
        scores.All.(segMethod).wholeprostate.HD95,scores.All.(segMethod).wholeprostate.ASD],2);
    % apex
    scores.All.(segMethod).apex.DSC = [scores.(segMethod).apex.DSC;scores.MRGB.(segMethod).apex.DSC];
    scores.All.(segMethod).apex.aRVD = [scores.(segMethod).apex.aRVD;scores.MRGB.(segMethod).apex.aRVD];
    scores.All.(segMethod).apex.HD95 = [scores.(segMethod).apex.HD95;scores.MRGB.(segMethod).apex.HD95];
    scores.All.(segMethod).apex.ASD = [scores.(segMethod).apex.ASD;scores.MRGB.(segMethod).apex.ASD];
    
    scores.All.(segMethod).apex_score = mean([scores.All.(segMethod).apex.DSC,scores.All.(segMethod).apex.aRVD,...
        scores.All.(segMethod).apex.HD95,scores.All.(segMethod).apex.ASD],2);
    
    % base
    scores.All.(segMethod).base.DSC = [scores.(segMethod).base.DSC;scores.MRGB.(segMethod).base.DSC];
    scores.All.(segMethod).base.aRVD = [scores.(segMethod).base.aRVD;scores.MRGB.(segMethod).base.aRVD];
    scores.All.(segMethod).base.HD95 = [scores.(segMethod).base.HD95;scores.MRGB.(segMethod).base.HD95];
    scores.All.(segMethod).base.ASD = [scores.(segMethod).base.ASD;scores.MRGB.(segMethod).base.ASD];
    
    scores.All.(segMethod).base_score = mean([scores.All.(segMethod).base.DSC,scores.All.(segMethod).base.aRVD,...
        scores.All.(segMethod).base.HD95,scores.All.(segMethod).base.ASD],2);
    
    % total score
    scores.All.(segMethod).total_score = mean([scores.All.(segMethod).wholeprostate.DSC,scores.All.(segMethod).wholeprostate.aRVD,scores.All.(segMethod).wholeprostate.HD95,scores.All.(segMethod).wholeprostate.ASD,...
        scores.All.(segMethod).apex.DSC,scores.All.(segMethod).apex.aRVD,scores.All.(segMethod).apex.HD95,scores.All.(segMethod).apex.ASD,...
        scores.All.(segMethod).base.DSC,scores.All.(segMethod).base.aRVD,scores.All.(segMethod).base.HD95,scores.All.(segMethod).base.ASD],2);
end
save('scores.mat','scores')
end

%---- Calculate the factors from the evalation metrics ----%
% 1- Calculate the factors after solving linear equation to use them
%   later to generate a Total score for the segmenation accuracy
%   based on the evaluation metrics.
function factors = calculateFactors(basePath)
%% Add directories to path
addpath(genpath(fullfile(pwd,'Codes')));

%% Calculate metrics
% The reference masks directory
referenceMaskePath = fullfile(basePath,'Data','Segmentations','Manual');
% List of the cases segmented by the second reader
sReaderDir = dir('path to  a secod reader segmentations\*.mhd');
%% Loop over the cases
for ii = 1:numel(sReaderDir)
    % MetaIO to Structured data
    [referenceMaskStrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(referenceMaskePath,sReaderDir(ii).name), 0);
    [estimatedMaskStrData, ~, ~] = elxMetaIOFileToStrDatax(fullfile(sReaderDir(ii).folder,sReaderDir(ii).name), 0);
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
        % Feed to getMetrics function
        metricsSR.(region_class)(ii) =...
            getMetrics(rm,em,rmR,emR,rExclude.(region_class),eExclude.(region_class));
        clear rm.Data em.Data
    end
end
%% Calculate facotrs

%% Mean of the metrics
% Wholeprostate
wholeprostate_DSC_mean = mean([metricsSR.wholeprostate.DSC].');
wholeprostate_aRVD_mean = mean([metricsSR.wholeprostate.aRVD].');
wholeprostate_HD95_mean = mean([metricsSR.wholeprostate.HD95].');
wholeprostate_ASD_mean = mean([metricsSR.wholeprostate.ASD].');
% Apex
apex_DSC_mean = mean([metricsSR.apex.DSC].');
apex_aRVD_mean = mean([metricsSR.apex.aRVD].');
apex_HD95_mean = mean([metricsSR.apex.HD95].');
apex_ASD_mean = mean([metricsSR.apex.ASD].');
% Base
base_DSC_mean = mean([metricsSR.base.DSC].');
base_aRVD_mean = mean([metricsSR.base.aRVD].');
base_HD95_mean = mean([metricsSR.base.HD95].');
base_ASD_mean = mean([metricsSR.base.ASD].');

%% Solve equations
syms a b
% Wholeprostate
Y.wholeprostate_DSC = vpasolve([a + b == 100, a*wholeprostate_DSC_mean + b == 85], [a,b]);
Y.wholeprostate_aRVD = vpasolve([a + b == 100, a*wholeprostate_aRVD_mean + b == 85], [a,b]);
Y.wholeprostate_HD95 = vpasolve([a + b == 100, a*wholeprostate_HD95_mean + b == 85], [a,b]);
Y.wholeprostate_ASD = vpasolve([a + b == 100, a*wholeprostate_ASD_mean + b == 85], [a,b]);
% Apex
Y.apex_DSC = vpasolve([a + b == 100, a*apex_DSC_mean + b == 85], [a,b]);
Y.apex_aRVD = vpasolve([a + b == 100, a*apex_aRVD_mean + b == 85], [a,b]);
Y.apex_HD95 = vpasolve([a + b == 100, a*apex_HD95_mean + b == 85], [a,b]);
Y.apex_ASD = vpasolve([a + b == 100, a*apex_ASD_mean + b == 85], [a,b]);
% Base
Y.base_DSC = vpasolve([a + b == 100, a*base_DSC_mean + b == 85], [a,b]);
Y.base_aRVD = vpasolve([a + b == 100, a*base_aRVD_mean + b == 85], [a,b]);
Y.base_HD95 = vpasolve([a + b == 100, a*base_HD95_mean + b == 85], [a,b]);
Y.base_ASD = vpasolve([a + b == 100, a*base_ASD_mean + b == 85], [a,b]);

%% Assign to factors strucutre
% Wholeprostate
factors.PX.wholeprostate_DSC = double([Y.wholeprostate_DSC.b;Y.wholeprostate_DSC.a]);
factors.PX.wholeprostate_aRVD = double([Y.wholeprostate_aRVD.b;Y.wholeprostate_aRVD.a]);
factors.PX.wholeprostate_HD95 = double([Y.wholeprostate_HD95.b;Y.wholeprostate_HD95.a]);
factors.PX.wholeprostate_ASD = double([Y.wholeprostate_ASD.b;Y.wholeprostate_ASD.a]);
% Apex
factors.PX.apex_DSC = double([Y.apex_DSC.b;Y.apex_DSC.a]);
factors.PX.apex_aRVD = double([Y.apex_aRVD.b;Y.apex_aRVD.a]);
factors.PX.apex_HD95 = double([Y.apex_HD95.b;Y.apex_HD95.a]);
factors.PX.apex_ASD = double([Y.apex_ASD.b;Y.apex_ASD.a]);
% Base
factors.PX.base_DSC = double([Y.base_DSC.b;Y.base_DSC.a]);
factors.PX.base_aRVD = double([Y.base_aRVD.b;Y.base_aRVD.a]);
factors.PX.base_HD95 = double([Y.base_HD95.b;Y.base_HD95.a]);
factors.PX.base_ASD = double([Y.base_ASD.b;Y.base_ASD.a]);

%% Save factors
save('factors.mat','factors')
end
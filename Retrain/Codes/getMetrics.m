%% getMetrics
% input: to this function: im3d as in ElastixFromMatlab toolbox
% output: metric results
function metrics = getMetrics(referenceMask,estimatedMask,rmR,emR,rEX,eEX)
%% Define
% Estimated mask (Automted)voxels
ES = estimatedMask.Data(:);
% Sum of the estimated mask voxels
sES = sum(ES);
% Ground truth mask voxels
GT = referenceMask.Data(:);
% Sum of the ground truth mask voxels
sGT = sum(GT);
% Indexs with voxels
rmF = find(referenceMask.Data==1);
emF = find(estimatedMask.Data==1);
% if only one of the masks not there then metric to worst
if xor(numel(rmF)==0,numel(emF)==0)
    metrics.DSC = 0;
    metrics.JSC = 0;
    metrics.F1 = 0;
    metrics.aRVD = 100;
    metrics.HD95 = 100;
    metrics.ASD = 100;
    metrics.RMSSD = 100;
    
    % if both of the masks there then calculate the metric
else
    %% Dice similarity coefficient (DSC)
    metrics.DSC = dice(GT,ES);
    %% Absolute Relative volume difference (RVD)
    metrics.aRVD = abs(((sES/sGT)-1)*100); % according to Heinmann et al
    %% Jaccard similarity coefficient (JSC)
    metrics.JSC = sum(ES & GT)/sum(ES | GT);
    %% F1 score
    % Precision
    Precision = (sum(ES & GT)/sES)*100;
    % Recall
    Recall = (sum(ES & GT)/sGT)*100;
    if Precision==0&&Recall==0
        metrics.F1 = 0;
    else
        metrics.F1 = 2*((Precision*Recall)/(Precision+Recall));
    end
    
    %% Surface Distance metrics
    % this section is copied and modified from https://github.com/emrekavur/CHAOS-evaluation/blob/master/Matlab
    %--Extract border voxels
    % Esitmated mask
    fES = emR & ~imerode(emR,strel('sphere',1));
    fES(:,:,eEX) = 0;
    fESIdx = find(fES==1);
    [x1,y1,z1] = ind2sub(size(fES),fESIdx);
    BorderVoxelsES = [x1,y1,z1];
    
    % Ground truth mask
    fGT = rmR & ~imerode(rmR,strel('sphere',1));
    fGT(:,:,rEX) = 0;
    fGTIdx = find(fGT==1);
    [x2,y2,z2] = ind2sub(size(fGT),fGTIdx);
    BorderVoxelsGT = [x2,y2,z2];
    
    %--Transforms index points to the real world coordinates
    % Esitmated mask
    realPointsES = zeros(size(BorderVoxelsES,1),size(BorderVoxelsES,2));
    for i = 1:size(BorderVoxelsES,1)
        P = estimatedMask.A*[BorderVoxelsES(i,1),BorderVoxelsES(i,2),BorderVoxelsES(i,3),1]';
        realPointsES(i,:) = P(1:3)';
    end
    % Ground truth mask
    realPointsGT = zeros(size(BorderVoxelsGT,1),size(BorderVoxelsGT,2));
    for i = 1:size(BorderVoxelsGT,1)
        P = referenceMask.A*[BorderVoxelsGT(i,1),BorderVoxelsGT(i,2),BorderVoxelsGT(i,3),1]';
        realPointsGT(i,:) = P(1:3)';
    end
    %--Distance between border voxels
    % Esitmated mask
    MdlKDT_ES = KDTreeSearcher(realPointsES);
    [~,distIndex1] = knnsearch(MdlKDT_ES,realPointsGT);
    distIndex1 = distIndex1';
    % Ground truth mask
    MdlKDT_GT = KDTreeSearcher(realPointsGT);
    [~,distIndex2] = knnsearch(MdlKDT_GT,realPointsES);
    distIndex2 = distIndex2';
    %% 95% Maximum Symmetric Surface Distance (MSSD) / Haussdorf distance (95%)
    metrics.HD95 = max([prctile(distIndex1,95),prctile(distIndex2,95)]);
    %% Average Symmetric Surface Distance (ASD)/average boundary distance (ABD)
    metrics.ASD = (sum(distIndex1)+sum(distIndex2))/(size(distIndex1,2)+size(distIndex2,2));
    %% Root Mean Square Symmetric Surface Distance (RMSSD)
    metrics.RMSSD = sqrt((sum(distIndex1.^2)+sum(distIndex2.^2)))*sqrt(1/(size(distIndex1,2)+size(distIndex2,2)));
    
end
end
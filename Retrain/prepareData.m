%---- Data preparations for classifiers----%
% Prepare the data to be used in the model training and testing
function prep = prepareData(features,scores)
% supress warnings
warning('off','all')

%% Add directories to the path
addpath(genpath(pwd));

%% Settings
% Cases path
CasesPath = fullfile(basePath,'Data','Cases','Normalized');
% Segmentation methods
segMethods = {'UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D'};

%% Split data and assign train/test responses and predictors
% List of the Cases
CND = dir(fullfile(CasesPath,'*.mhd'));
list = cell(numel(CND),1);
for jj = 1:numel(CND)
    list{jj,:} = CND(jj).name(1:7); % you might need to change .name(1:7) to name(1:what fits)
end

% Intetial differences between poor Cases in train and test
dif_UNet_2D = 10;
dif_VNet_3D = 10;
dif_nnUNet_2D = 10;
dif_nnUNet_3D = 10;

% Intetial random generator seed
rr = 1;

% While loop untill the differences between  percentage of
% poor Cases in train and test <1
while dif_UNet_2D>1 || dif_VNet_3D>1 || dif_nnUNet_2D>1 || dif_nnUNet_3D>1
    % Set random generator seed
    rng(rr)
    
    % Split the data to train (75%) and test (25%)
    [m,~] = size(list);
    P = 0.75; % precentage of training data
    idx = randperm(m)  ;
    trainIdx = sort(idx(1:round(P*m)))' ;
    testIdx = sort(idx(round(P*m)+1:end))';
    
    % Loop over the methods
    for ii = 1:numel(segMethods)
        segMethod = segMethods{ii};
        
        % Assing train/test Cases
        prep.(segMethod).Cases = list;
        prep.(segMethod).train.Cases = prep.(segMethod).Cases(trainIdx);
        prep.(segMethod).test.Cases = prep.(segMethod).Cases(testIdx);
        
        % Scores
        % WP
        prep.(segMethod).train.scores.wp = scores.All.(segMethod).wholeprostate_score(trainIdx,:);
        prep.(segMethod).test.scores.wp = scores.All.(segMethod).wholeprostate_score(testIdx,:);
        prep.(segMethod).All.scores.wp = scores.All.(segMethod).wholeprostate_score;
        % Apex
        prep.(segMethod).train.scores.apex = scores.All.(segMethod).apex_score(trainIdx,:);
        prep.(segMethod).test.scores.apex = scores.All.(segMethod).apex_score(testIdx,:);
        prep.(segMethod).All.scores.apex = scores.All.(segMethod).apex_score;
        % Base
        prep.(segMethod).train.scores.base = scores.All.(segMethod).base_score(trainIdx,:);
        prep.(segMethod).test.scores.base = scores.All.(segMethod).base_score(testIdx,:);
        prep.(segMethod).All.scores.base = scores.All.(segMethod).base_score;
        % Total
        prep.(segMethod).train.scores.total = scores.All.(segMethod).total_score(trainIdx,:);
        prep.(segMethod).test.scores.total = scores.All.(segMethod).total_score(testIdx,:);
        prep.(segMethod).All.scores.total = scores.All.(segMethod).total_score;
        
        % Predictors(Features)
        prep.(segMethod).train.predictors = features.(segMethod).all(trainIdx,:);
        prep.(segMethod).test.predictors = features.(segMethod).all(testIdx,:);
        prep.(segMethod).All.predictors = features.(segMethod).all;
        
        % Distripution
        prep.(segMethod).train.pd = (numel(find(prep.(segMethod).train.responses==1))/...
            numel(prep.(segMethod).train.responses))*100;
        prep.(segMethod).test.pd = (numel(find(prep.(segMethod).test.responses==1))/...
            numel(prep.(segMethod).test.responses))*100;
    end
    
    % Check the difference between percentage of poor Cases in train and test
    dif_UNet_2D = abs(prep.UNet_2D.train.pd - prep.UNet_2D.test.pd);
    dif_VNet_3D = abs(prep.VNet_3D.train.pd - prep.VNet_3D.test.pd);
    dif_nnUNet_2D = abs(prep.nnUNet_2D.train.pd - prep.nnUNet_2D.test.pd);
    dif_nnUNet_3D = abs(prep.nnUNet_3D.train.pd - prep.nnUNet_3D.test.pd);
    
    % Add 1 to the random generator seed
    rr = rr+1;
end

%% Add "All" to structure
%% Train
% Cases
for ii = 1:numel(segMethods)
    segMethod = segMethods{ii};
    for jj = 1:numel(prep.(segMethod).train.Cases)
        tmpNameTr.(segMethod){jj} = [(segMethod) '_' prep.(segMethod).train.Cases{jj}];
    end
end
prep.All.train.Cases = [tmpNameTr.(segMethods{1}),tmpNameTr.(segMethods{2}),...
    tmpNameTr.(segMethods{3}),tmpNameTr.(segMethods{4})]';

% predictors
prep.All.train.predictors = array2table([table2array(prep.(segMethods{1}).train.predictors);...
    table2array(prep.(segMethods{2}).train.predictors);...
    table2array(prep.(segMethods{3}).train.predictors);...
    table2array(prep.(segMethods{4}).train.predictors)]);
prep.All.train.predictors.Properties.VariableNames =...
    prep.(segMethods{1}).train.predictors.Properties.VariableNames;
prep.All.train.predictors.Properties.RowNames = prep.All.train.Cases;

% scores
prep.All.train.scores.wp = [prep.(segMethods{1}).train.scores.wp;prep.(segMethods{2}).train.scores.wp;...
    prep.(segMethods{3}).train.scores.wp;prep.(segMethods{4}).train.scores.wp];
prep.All.train.scores.apex = [prep.(segMethods{1}).train.scores.apex;prep.(segMethods{2}).train.scores.apex;...
    prep.(segMethods{3}).train.scores.apex;prep.(segMethods{4}).train.scores.apex];
prep.All.train.scores.base = [prep.(segMethods{1}).train.scores.base;prep.(segMethods{2}).train.scores.base;...
    prep.(segMethods{3}).train.scores.base;prep.(segMethods{4}).train.scores.base];
prep.All.train.scores.total = [prep.(segMethods{1}).train.scores.total;prep.(segMethods{2}).train.scores.total;...
    prep.(segMethods{3}).train.scores.total;prep.(segMethods{4}).train.scores.total];
%% Test
% Cases
for ii = 1:numel(segMethods)
    segMethod = segMethods{ii};
    for jj = 1:numel(prep.(segMethod).test.Cases)
        tmpNameTs.(segMethod){jj} = [(segMethod) '_' prep.(segMethod).test.Cases{jj}];
    end
end
prep.All.test.Cases = [tmpNameTs.(segMethods{1}),tmpNameTs.(segMethods{2}),...
    tmpNameTs.(segMethods{3}),tmpNameTs.(segMethods{4})]';

% predictors
prep.All.test.predictors = array2table([table2array(prep.(segMethods{1}).test.predictors);...
    table2array(prep.(segMethods{2}).test.predictors);...
    table2array(prep.(segMethods{3}).test.predictors);...
    table2array(prep.(segMethods{4}).test.predictors)]);
prep.All.test.predictors.Properties.VariableNames =...
    prep.(segMethods{1}).test.predictors.Properties.VariableNames;
prep.All.test.predictors.Properties.RowNames = prep.All.test.Cases;

% scores
prep.All.test.scores.wp = [prep.(segMethods{1}).test.scores.wp;prep.(segMethods{2}).test.scores.wp;...
    prep.(segMethods{3}).test.scores.wp;prep.(segMethods{4}).test.scores.wp];
prep.All.test.scores.apex = [prep.(segMethods{1}).test.scores.apex;prep.(segMethods{2}).test.scores.apex;...
    prep.(segMethods{3}).test.scores.apex;prep.(segMethods{4}).test.scores.apex];
prep.All.test.scores.base = [prep.(segMethods{1}).test.scores.base;prep.(segMethods{2}).test.scores.base;...
    prep.(segMethods{3}).test.scores.base;prep.(segMethods{4}).test.scores.base];
prep.All.test.scores.total = [prep.(segMethods{1}).test.scores.total;prep.(segMethods{2}).test.scores.total;...
    prep.(segMethods{3}).test.scores.total;prep.(segMethods{4}).test.scores.total];
%% All
% Cases
for ii = 1:numel(segMethods)
    segMethod = segMethods{ii};
    for jj = 1:numel(prep.(segMethod).Cases)
        tmpNameAll.(segMethod){jj} = [(segMethod) '_' prep.(segMethod).Cases{jj}];
    end
end
prep.All.Cases = [tmpNameAll.(segMethods{1}),tmpNameAll.(segMethods{2}),...
    tmpNameAll.(segMethods{3}),tmpNameAll.(segMethods{4})]';

% predictors
prep.All.predictors = array2table([table2array(prep.(segMethods{1}).All.predictors);...
    table2array(prep.(segMethods{2}).All.predictors);...
    table2array(prep.(segMethods{3}).All.predictors);...
    table2array(prep.(segMethods{4}).All.predictors)]);
prep.All.predictors.Properties.VariableNames =...
    prep.(segMethods{1}).All.predictors.Properties.VariableNames;
prep.All.predictors.Properties.RowNames = prep.All.Cases;

% scores
prep.All.All.scores.wp = [prep.(segMethods{1}).All.scores.wp;prep.(segMethods{2}).All.scores.wp;...
    prep.(segMethods{3}).All.scores.wp;prep.(segMethods{4}).All.scores.wp];
prep.All.All.scores.apex = [prep.(segMethods{1}).All.scores.apex;prep.(segMethods{2}).All.scores.apex;...
    prep.(segMethods{3}).All.scores.apex;prep.(segMethods{4}).All.scores.apex];
prep.All.All.scores.base = [prep.(segMethods{1}).All.scores.base;prep.(segMethods{2}).All.scores.base;...
    prep.(segMethods{3}).All.scores.base;prep.(segMethods{4}).All.scores.base];
prep.All.All.scores.total = [prep.(segMethods{1}).All.scores.total;prep.(segMethods{2}).All.scores.total;...
    prep.(segMethods{3}).All.scores.total;prep.(segMethods{4}).All.scores.total];

% assign segMethods
prep.segMethods = {'UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D','All'};


%% Organize data in tables
segMethods = {'All','UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D'};
for kk = 1:numel(segMethods)
    segMethod = segMethods{kk};
    % Train
    tmp_str = prep.(segMethod).train.Cases;
    tableTrain = table('Size',[numel(tmp_str),2],'VariableTypes',{'string','string'},'VariableNames',{'dataset','method'});
    for ii=1:numel(tmp_str)
        caseNr = str2double(tmp_str{ii}(end-2:end));
        if caseNr>338 % if you are using two different datasets you can name them according to the number
            tableTrain.dataset(ii) = 'Data';
        else
            tableTrain.dataset(ii) = 'Data';
        end
        if kk>1
            tableTrain.method(ii) = segMethod;
        else
            tableTrain.method(ii) = tmp_str{ii}(1:end-8);
        end
    end
    prep.(segMethod).tableTrain = tableTrain;
    % Test
    tmp_str = prep.(segMethod).test.Cases;
    tableTest = table('Size',[numel(tmp_str),2],'VariableTypes',{'string','string'},'VariableNames',{'dataset','method'});
    for ii = 1:numel(tmp_str)
        caseNr = str2double(tmp_str{ii}(end-2:end));
        if caseNr>338 % if you are using two different datasets you can name them according to the number
            tableTest.dataset(ii) = 'Data';
        else
            tableTest.dataset(ii) = 'Data';
        end
        if kk>1
            tableTest.method(ii) = segMethod;
        else
            tableTest.method(ii) = tmp_str{ii}(1:end-8);
        end
    end
    prep.(segMethod).tableTest = tableTest;
    
    clearvars -except prep segMethods kk
end
%% Save
save('prep.mat','prep')
end
%%--- Evaluate the genral model ---%%
function models = makeModels(prep,lambda)
%% Settings
% Addpath
addpath(genpath('C:\Data\PhD\Research\Studies\Segmentation_QC\Analysis\Codes'));
% Random generator seed
rng(1)
%% General
disp('     -Evaluate: Genral Model')
%% Organize data
% predictors
train.All.predictors = table2array(prep.All.train.predictors);
test.All.predictors = table2array(prep.All.test.predictors);

% names of the features columns
predictorsV = prep.All.train.predictors;
predictorsV = predictorsV.Properties.VariableNames;

% responses
train.All.responses = prep.All.train.scores.total;
test.All.responses = prep.All.test.scores.total;

%% Train
[train.All.B,train.All.FitInfo] =...
    lasso(train.All.predictors ,train.All.responses,'CV',5','Lambda',lambda);

%% Optimize
% you can change it to fit your optimization results
idxLambda = 1;
train.All.Intercept = train.All.FitInfo.Intercept(idxLambda);
train.All.coef = train.All.B(:,idxLambda);
train.All.chosenVariables = predictorsV(train.All.coef~=0);

train.All.yhat = train.All.predictors*train.All.coef + train.All.Intercept;

% capping
train.All.yhat(train.All.yhat>100) = 100;
train.All.yhat(train.All.yhat<0) = 0;

%% Test
test.All.yhat = test.All.predictors*train.All.coef + train.All.Intercept;
% capping
test.All.yhat(test.All.yhat>100) = 100;
test.All.yhat(test.All.yhat<0) = 0;

% save
models.train = train;
models.test = test;
save('models.mat','models')
end
    %%--- Tune the parameters ---%%
    % Generate models with different parameters to tune
    function optimize = optimizeParm(prep)
    %% Settings
    % Random generator seed
    rng(1)
    sMethods = {'All','UNet_2D','nnUNet_2D','VNet_3D','nnUNet_3D'};
    for ii = 1%:numel(sMethods)
        %% Organize data
        % current method
        sMethod = sMethods{ii};
        disp(['         -C1: ' sMethod])
        % idx
        [idxTrain,~] = idxTrs(prep,'All',sMethod);

        % predictors
        predictors.total = table2array(prep.All.train.predictors(idxTrain,:));
        predictors.wp = table2array(prep.All.train.predictors(idxTrain,1:107));
        predictors.apex = table2array(prep.All.train.predictors(idxTrain,108:214));
        predictors.base = table2array(prep.All.train.predictors(idxTrain,215:end));

        % responses
        responses.total = prep.All.train.scores.total(idxTrain,:);
        responses.wp = prep.All.train.scores.wp(idxTrain,:);
        responses.apex = prep.All.train.scores.apex(idxTrain,:);
        responses.base = prep.All.train.scores.base(idxTrain,:);

        % weights
        wTrain = abs(1+(responses.total-mean(responses.total)).^2);
        wTrain = wTrain/sum(wTrain);
        %% Test diffrent settings
        % choose one of the models a time 
        lambdaChoices = [1e-5 2e-5 5e-5 1e-4 2e-4 5e-4 1e-3 2e-3 5e-3 1e-2 2e-2 5e-2 1e-1 2e-1 5e-1 1e-0 2e-0 5e-0 1e1 2e1 5e1];
    %     % Option 1: 'Weights': True Intercept: True
    %     [C1.(sMethod).wT.iT.B,C1.(sMethod).wT.iT.FitInfo] = lasso(predictors.total,responses.total,'Weights',wTrain,...
    %         'Intercept',true,'CV',5','Lambda',lambdaChoices);
    %     % Option 2: 'Weights': True, Intercept: False
    %     [C1.(sMethod).wT.iF.B,C1.(sMethod).wT.iF.FitInfo] = lasso(predictors.total,responses.total,'Weights',wTrain,...
    %         'Intercept',false,'CV',5','Lambda',lambdaChoices);
    %     % Option 3: 'Weights': False Intercept: True
    %     [C1.(sMethod).wF.iT.B,C1.(sMethod).wF.iT.FitInfo] = lasso(predictors.total,responses.total,'Intercept',true,...
    %         'CV',5','Lambda',...
    %         lambdaChoices);
        % Option 4: 'Weights': False, Intercept: False
        [C1.(sMethod).wF.iF.B,C1.(sMethod).wF.iF.FitInfo] = lasso(predictors.total,responses.total,'Intercept',false,....
            'CV',5','Lambda',...
            lambdaChoices);
    end

    %% Check
        % Make and visually check Bland-Altman plot to see if the distripution
        % is ok, also make sure that the chosen Lambda is the one with the
        % lowest error, while the Bland-Altman acceptable
    B = C1.(sMethod).wF.iF.B; % change when you change the model
    FitInfo = C1.(sMethod).wF.iF.FitInfo; % change when you change the model
    lassoPlot(B,FitInfo,'PlotType','CV');

    idxLambda = FitInfo.IndexMinMSE; %Index1SE; %IndexMinMSE  % Inestigate both

    coef = B(:,idxLambda);
    B0 = FitInfo.Intercept(idxLambda);

    yhat = predictors.total*coef + B0;

    % Generate figure with symbols
    tit = 'Lasso Train'; % figure title
    corrinfo = {'n','SSE','RMSE','r','r2','p','rho','rho (p)','eq'}; % stats to display of correlation scatter plot

    [cr, fig, statsStruct] = BlandAltman(responses.total, yhat,tit,'corrInfo',corrinfo,...
        'forceZeroIntercept','off','showFitCI',' on','diffValueMode','Percent','symbols','o','axesLimits',0,'baStatsMode','Non-parametric');
    % Display statistical results that were returned from analyses
    disp('Statistical results:');
    disp(statsStruct);

    % save
    optimize = C1;
    save('optimize.mat','optimize')
    end
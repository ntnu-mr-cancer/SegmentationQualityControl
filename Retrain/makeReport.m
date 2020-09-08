function report = makeReport(features,models,pathR)
warning('off')
%% Settings
% Stats
settings.stats = 1;
% Tables
settings.tables = 1;
% Models details
settings.mdl = 1;
% Selected Features
settings.selectedFeatures = 1;
% Plot difference plot
settings.diff = 1;
% Plot linear fit
settings.linearFit = 1;

% Sets
das = {'All'}; % if you have more than one dataset you can change this
tts = {'train','test'};
sMethods = {'All','UNet_2D','VNet_3D','nnUNet_2D','nnUNet_3D'};
sMLabel = {'All','U-Net','V-Net','nnU-Net-2D','nnU-Net-3D'};

% Make report directory
if ~exist(pathR,'dir')
    mkdir(pathR)
    mkdir(fullfile(pathR,'tif'))
end

%% Stats
if settings.stats
    %--- General Model ---%
    % Loop over datasets
    for ii = 1
        da = das{ii};
        for jj = 1:numel(tts)
            % Trains or Test
            tt = tts{jj};
            % Loop over methods
            for kk = 1
                % Current segmentation method
                sMethod = sMethods{kk};
                % Get stats
                stats.All.(da).(tt).(sMethod) = modelStats(models.(tt).(sMethod).responses,...
                    models.(tt).(sMethod).yhat);
                % Add slope and intercept to stats
                % Get fitted values
                [coeffs,~] = polyfit(models.(tt).(sMethod).responses, models.(tt).(sMethod).yhat, 1);
                stats.All.(da).(tt).(sMethod).intercept = coeffs(2);
                stats.All.(da).(tt).(sMethod).slope = coeffs(1);
            end
        end
    end
    report.stats = stats;
end

%% Tables
if settings.tables
    %--- General Model ---%
    for ii = 1
        da = das{ii};
        % Loop over split
        for jj = 1:numel(tts)
            % Trains or Test
            tt = tts{jj};
            % Make summary table
            tables.All.(da).(tt) = table;
            for kk = 1:numel(sMethods)
                sMethod = sMethods{kk};
                tables.All.(da).(tt).Method(kk) = sMLabel(kk);
                tables.All.(da).(tt).NrElements(kk) = stats.All.(da).(tt).(sMethod).N;
                tables.All.(da).(tt).MAE(kk) = round(stats.All.(da).(tt).(sMethod).MAE,2);
                tables.All.(da).(tt).scoresSTDPredicted(kk) = round(stats.All.(da).(tt).(sMethod).scoresSTDPredicted,2);
                tables.All.(da).(tt).scoresIQRPredicted(kk) = round(stats.All.(da).(tt).(sMethod).scoresIQRPredicted,2);
                tables.All.(da).(tt).slope(kk) = round(stats.All.(da).(tt).(sMethod).slope,2);
                tables.All.(da).(tt).intercept(kk) = round(stats.All.(da).(tt).(sMethod).intercept,2);
                tables.All.(da).(tt).rho(kk) = round(stats.All.(da).(tt).(sMethod).rho,2);
                tables.All.(da).(tt).rhoP(kk) = round(stats.All.(da).(tt).(sMethod).rhoP,2);
            end
        end
    end
    
    
    % Organize final tables
    tableV = {'Model','N',['MAE' char(177) 'SD'],'IQR','Slope','Intercept','Rho','Correlation p-value'};
    % General Model
    tables.GeneralModel = tables.All.All.test(1,[1:3,5:end]);
    tables.GeneralModel.Properties.VariableNames = tableV;
    tables.GeneralModel.("MAE±SD") = [num2str(tables.GeneralModel.("MAE±SD")) char(177) num2str(tables.All.All.test.scoresSTDPredicted(1))];
    tables.GeneralModel.IQR = num2str(tables.GeneralModel.IQR);
    tables.GeneralModel.Slope = num2str(tables.GeneralModel.Slope);
    tables.GeneralModel.Intercept = num2str(tables.GeneralModel.Intercept);
    tables.GeneralModel.Rho = num2str(tables.GeneralModel.Rho);
    if tables.GeneralModel.("Correlation p-value")<0.001
        tables.GeneralModel.("Correlation p-value") = '<0.001';
    end
    writetable(tables.GeneralModel,fullfile(pathR,'General Model Table.xlsx'))
    
    %     % Derived from the General Model
    %     tableV = {'Sub-results','N',['MAE' char(177) 'SD'],'IQR','Slope','Intercept','Rho','Correlation p-value'};
    %     nModels = {'PROSTATEx - U-Net','PROSTATEx - V-Net','PROSTATEx - nnU-Net-2D','PROSTATEx - nnU-Net-3D',...
    %         'In-house - U-Net','In-house - V-Net','In-house - nnU-Net-2D','In-house - nnU-Net-3D'};
    %     tables.SubResultsGeneralModel = [tables.All.PX.test(2:end,[1:3,5:end]);...
    %         tables.All.MRGB.test(2:end,[1:3,5:end])];
    %     tables.SubResultsGeneralModel.Properties.VariableNames = tableV;
    %     tables.SubResultsGeneralModel.("Sub-results") = nModels';
    %     tables.SubResultsGeneralModel.("MAE±SD") = [num2str(tables.SubResultsGeneralModel.("MAE±SD")) repmat(char(177),8,1)...
    %         num2str([tables.All.PX.test{2:end,4};tables.All.MRGB.test{2:end,4}])];
    %     tables.SubResultsGeneralModel.IQR = num2str(tables.SubResultsGeneralModel.IQR);
    %     tables.SubResultsGeneralModel.Slope = num2str(tables.SubResultsGeneralModel.Slope);
    %     tables.SubResultsGeneralModel.Intercept = num2str(tables.SubResultsGeneralModel.Intercept);
    %     tables.SubResultsGeneralModel.Rho = num2str(tables.SubResultsGeneralModel.Rho);
    %     if tables.SubResultsGeneralModel.("Correlation p-value")<0.001
    %         tables.SubResultsGeneralModel.("Correlation p-value") = repmat('<0.001',8,1);
    %     end
    %     writetable(tables.SubResultsGeneralModel,fullfile(pathR,'Sub-results General Model Table.xlsx'))
    
    report.tables = tables;
end

%% Models details
if settings.mdl
    %--- General Model ---%
    mdl.All = table;
    mdl.All.Feature(1) = {'Intercept'};
    mdl.All.Coefficient(1) = round(models.train.All.Intercept,3);
    tempCoef = models.train.All.coef(models.train.All.coef~=0);
    for mm = 1:numel(tempCoef)
        mdl.All.Feature(mm+1) = models.train.All.chosenVariables(mm);
        if tempCoef(mm)> 0.01
            mdl.All.Coefficient(mm+1) = round(tempCoef(mm),3);
        else
            mdl.All.Coefficient(mm+1) = tempCoef(mm);
        end
    end
    writetable(mdl.All,fullfile(pathR,'General Model Details.xlsx'))
    
    report.mdl = mdl;
end

%% Selected Features stats
if settings.selectedFeatures
    %--- General Model ---%
    FigH = figure('Name','Selected features-General Model','Position', get(0, 'Screensize'));
    
    % Summary models
    features.All = table;
    features.All.AllFeatures = numel(models.train.All.coef);
    features.All.ChosenFeatures = numel(models.train.All.chosenVariables);
    
    features.All.WP = numel(find(contains(models.train.All.chosenVariables,'WP')));
    features.All.Apex = numel(find(contains(models.train.All.chosenVariables,'Apex')));
    features.All.Base = numel(find(contains(models.train.All.chosenVariables,'Base')));
    
    features.All.firstorder = numel(find(contains(models.train.All.chosenVariables,'firstorder')));
    features.All.shape = numel(find(contains(models.train.All.chosenVariables,'shape')));
    features.All.glcm = numel(find(contains(models.train.All.chosenVariables,'glcm')));
    features.All.glrlm = numel(find(contains(models.train.All.chosenVariables,'glrlm')));
    features.All.glszm = numel(find(contains(models.train.All.chosenVariables,'glszm')));
    features.All.ngtdm = numel(find(contains(models.train.All.chosenVariables,'ngtdm')));
    features.All.gldm = numel(find(contains(models.train.All.chosenVariables,'gldm')));
    
    features.All.firstorderWP = numel(find(contains(models.train.All.chosenVariables,'firstorder')&contains(models.train.All.chosenVariables,'WP')));
    features.All.shapeWP = numel(find(contains(models.train.All.chosenVariables,'shape')&contains(models.train.All.chosenVariables,'WP')));
    features.All.glcmWP = numel(find(contains(models.train.All.chosenVariables,'glcm')&contains(models.train.All.chosenVariables,'WP')));
    features.All.glrlmWP = numel(find(contains(models.train.All.chosenVariables,'glrlm')&contains(models.train.All.chosenVariables,'WP')));
    features.All.glszmWP = numel(find(contains(models.train.All.chosenVariables,'glszm')&contains(models.train.All.chosenVariables,'WP')));
    features.All.ngtdmWP = numel(find(contains(models.train.All.chosenVariables,'ngtdm')&contains(models.train.All.chosenVariables,'WP')));
    features.All.gldmWP = numel(find(contains(models.train.All.chosenVariables,'gldm')&contains(models.train.All.chosenVariables,'WP')));
    
    features.All.firstorderApex = numel(find(contains(models.train.All.chosenVariables,'firstorder')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.shapeApex = numel(find(contains(models.train.All.chosenVariables,'shape')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.glcmApex = numel(find(contains(models.train.All.chosenVariables,'glcm')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.glrlmApex = numel(find(contains(models.train.All.chosenVariables,'glrlm')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.glszmApex = numel(find(contains(models.train.All.chosenVariables,'glszm')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.ngtdmApex = numel(find(contains(models.train.All.chosenVariables,'ngtdm')&contains(models.train.All.chosenVariables,'Apex')));
    features.All.gldmApex = numel(find(contains(models.train.All.chosenVariables,'gldm')&contains(models.train.All.chosenVariables,'Apex')));
    
    features.All.firstorderBase = numel(find(contains(models.train.All.chosenVariables,'firstorder')&contains(models.train.All.chosenVariables,'Base')));
    features.All.shapeBase = numel(find(contains(models.train.All.chosenVariables,'shape')&contains(models.train.All.chosenVariables,'Base')));
    features.All.glcmBase = numel(find(contains(models.train.All.chosenVariables,'glcm')&contains(models.train.All.chosenVariables,'Base')));
    features.All.glrlmBase = numel(find(contains(models.train.All.chosenVariables,'glrlm')&contains(models.train.All.chosenVariables,'Base')));
    features.All.glszmBase = numel(find(contains(models.train.All.chosenVariables,'glszm')&contains(models.train.All.chosenVariables,'Base')));
    features.All.ngtdmBase = numel(find(contains(models.train.All.chosenVariables,'ngtdm')&contains(models.train.All.chosenVariables,'Base')));
    features.All.gldmBase = numel(find(contains(models.train.All.chosenVariables,'gldm')&contains(models.train.All.chosenVariables,'Base')));
    
    % Plot a stacked bar plot
    
    y = [features.All.firstorderWP,features.All.shapeWP,features.All.glcmWP,features.All.glrlmWP,features.All.glszmWP,features.All.gldmWP,features.All.ngtdmWP;...
        features.All.firstorderApex,features.All.shapeApex,features.All.glcmApex,features.All.glrlmApex,features.All.glszmApex,features.All.gldmApex,features.All.ngtdmApex;...
        features.All.firstorderBase,features.All.shapeBase,features.All.glcmBase,features.All.glrlmBase,features.All.glszmBase,features.All.gldmBase,features.All.ngtdmBase];
    bar(y,'stacked')
    xticklabels({'Whole Prostate','Apex','Base'})
    legend('Firstorder','Shape','GLCM','GLRLM','GLSZM','GLDM','NGTDM')
    ylabel('Number of selected features')
    ylim([0,65])
    % A loop that does num2str conversion only if value is >0
    for i = 1:size(y,1)
        for j = 1:size(y,2)
            if y(i,j)>0
                labels_stacked = num2str(y(i,j),'%d');
                hText = text(i, sum(y(i,1:j),2)-(y(i,j)/2), labels_stacked);
                set(hText, 'VerticalAlignment','middle', 'HorizontalAlignment', 'center','FontSize',10, 'Color','w');
            end
        end
        labels_stacked2 = num2str(sum(y(i,:)),'%d');
        hText2 = text(i, sum(y(i,1:size(y,2)),2)+5, labels_stacked2);
        set(hText2, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',10, 'Color','k');
    end
    title('General Model')
    savefig(fullfile(pathR,'Selected features-General Model.fig'))
    F = getframe(FigH);
    imwrite(F.cdata, fullfile(pathR,'tif','Selected features-General Model.tif'), 'tif')
    close all
    
    report.features = features;
end

%% Plot difference plot
if settings.diff
    %--- General model ---%
    FigH = figure('Name','Difference - General Model','Position', get(0, 'Screensize'));
    AE = models.test.All.yhat-models.test.All.responses;
    scatter(models.test.All.responses,AE,'filled','k','MarkerFaceAlpha',0.4)
    yline(round(mean(AE),2),'--b', 'LineWidth',2);
    xlabel('Reference Quality Score')
    ylabel('Estimated Quality Score - Reference Quality Score')
    legend('Data','Mean','Location','southeast')
    title('General Model')
    savefig(fullfile(pathR,'Difference - General Model.fig'))
    F = getframe(FigH);
    imwrite(F.cdata, fullfile(pathR,'tif','Difference - General Model.tif'), 'tif')
    close all
    
    %     %--- Derived from the General Model ---%
    %     rr.m1 = datasets.All.PX.test.UNet_2D.responses;
    %     rr.m2 = datasets.All.PX.test.VNet_3D.responses;
    %     rr.m3 = datasets.All.PX.test.nnUNet_2D.responses;
    %     rr.m4 = datasets.All.PX.test.nnUNet_3D.responses;
    %     rr.m5 = datasets.All.MRGB.test.UNet_2D.responses;
    %     rr.m6 = datasets.All.MRGB.test.VNet_3D.responses;
    %     rr.m7 = datasets.All.MRGB.test.nnUNet_2D.responses;
    %     rr.m8 = datasets.All.MRGB.test.nnUNet_3D.responses;
    %
    %     yy.m1 = datasets.All.PX.test.UNet_2D.yhat;
    %     yy.m2 = datasets.All.PX.test.VNet_3D.yhat;
    %     yy.m3 = datasets.All.PX.test.nnUNet_2D.yhat;
    %     yy.m4 = datasets.All.PX.test.nnUNet_3D.yhat;
    %     yy.m5 = datasets.All.MRGB.test.UNet_2D.yhat;
    %     yy.m6 = datasets.All.MRGB.test.VNet_3D.yhat;
    %     yy.m7 = datasets.All.MRGB.test.nnUNet_2D.yhat;
    %     yy.m8 = datasets.All.MRGB.test.nnUNet_3D.yhat;
    %
    %     FigH = figure('Name','Difference - Sub-results from General Model','Position', get(0, 'Screensize'));
    %     for dd = 1:8
    %         subplot(4,2,dd)
    %         % Get fitted values
    %         mm = ['m' num2str(dd)];
    %
    %         AE = yy.(mm)-rr.(mm);
    %         scatter(rr.(mm),AE,'filled','k','MarkerFaceAlpha',0.4)
    %         yline(round(mean(AE),2),'--b', 'LineWidth',2);
    %         xlabel('Reference Quality Score')
    %         ylabel('Estimated Quality Score - Reference Quality Score')
    %         if dd==1
    %             legend('Data','Mean','Location','southeast')
    %         end
    %         title([dasLabel{ii} ' - ' sMLabel{kk} '  Model'])
    %     end
    %     sgtitle('Sub-results from General Model')
    %     savefig(fullfile(pathR,'Difference - Sub-results from General Model.fig'))
    %     F = getframe(FigH);
    %     imwrite(F.cdata, fullfile(pathR,'tif','Difference - Sub-results from General Model.tif'), 'tif')
    %     close all
    
end

%% Plot linear fit
if settings.linearFit
    %--- General Model ---%
    % Get fitted values
    FigH = figure('Name','Linear fit-General Model','Position', get(0, 'Screensize'));
    % Get fitted values
    [coeffs,S] = polyfit(models.test.All.responses, models.test.All.yhat, 1);
    fittedX = linspace(0, 100);
    [fittedY,delta] = polyval(coeffs, fittedX, S);
    % Plot the fitted line
    scatter(models.test.All.responses, models.test.All.yhat,...
        'filled','k','MarkerFaceAlpha',0.4)
    hold on;
    plot(fittedX, fittedY, 'r-', 'LineWidth', 2);
    p = plot(fittedX, fittedY+2*delta,'m--',fittedX, fittedY-2*delta,'m--');
    xlim([25, 100]);
    ylim([0, 100]);
    xlabel('Reference Quality Score')
    ylabel('Estimated Quality Score')
    title('General Model')
    refline([1 0])
    set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    legend('Data','Linear Fit','95% Prediction Interval','Unity Line','Location','southeast')
    hold off;
    savefig(fullfile(pathR,'Linear fit-General Model.fig'))
    F = getframe(FigH);
    imwrite(F.cdata, fullfile(pathR,'tif','Linear fit-General Model.tif'), 'tif')
    close all
    
    %     %--- Derived from the General Model ---%
    %     rr.m1 = datasets.All.PX.test.UNet_2D.responses;
    %     rr.m2 = datasets.All.PX.test.VNet_3D.responses;
    %     rr.m3 = datasets.All.PX.test.nnUNet_2D.responses;
    %     rr.m4 = datasets.All.PX.test.nnUNet_3D.responses;
    %     rr.m5 = datasets.All.MRGB.test.UNet_2D.responses;
    %     rr.m6 = datasets.All.MRGB.test.VNet_3D.responses;
    %     rr.m7 = datasets.All.MRGB.test.nnUNet_2D.responses;
    %     rr.m8 = datasets.All.MRGB.test.nnUNet_3D.responses;
    %
    %     yy.m1 = report.datasets.All.PX.test.UNet_2D.yhat;
    %     yy.m2 = report.datasets.All.PX.test.VNet_3D.yhat;
    %     yy.m3 = report.datasets.All.PX.test.nnUNet_2D.yhat;
    %     yy.m4 = report.datasets.All.PX.test.nnUNet_3D.yhat;
    %     yy.m5 = report.datasets.All.MRGB.test.UNet_2D.yhat;
    %     yy.m6 = report.datasets.All.MRGB.test.VNet_3D.yhat;
    %     yy.m7 = report.datasets.All.MRGB.test.nnUNet_2D.yhat;
    %     yy.m8 = report.datasets.All.MRGB.test.nnUNet_3D.yhat;
    %
    %     nModels = {'PROSTATEx - U-Net','PROSTATEx - V-Net','PROSTATEx - nnU-Net-2D','PROSTATEx - nnU-Net-3D',...
    %         'In-house - U-Net','In-house - V-Net','In-house - nnU-Net-2D','In-house - nnU-Net-3D'};
    %
    %     FigH = figure('Name','Linear fit-Sub-results from General Model','Position', get(0, 'Screensize'));
    %     for dd = 1:8
    %         subplot(4,2,dd)
    %         % Get fitted values
    %         mm = ['m' num2str(dd)];
    %         [coeffs,S] = polyfit(rr.(mm), yy.(mm), 1);
    %         fittedX = linspace(0, 100);
    %         [fittedY,delta] = polyval(coeffs, fittedX, S);
    %         % Plot the fitted line
    %         scatter(rr.(mm), yy.(mm),...
    %             'filled','k','MarkerFaceAlpha',0.4)
    %         hold on;
    %         plot(fittedX, fittedY, 'r-', 'LineWidth', 2);
    %         p = plot(fittedX, fittedY+2*delta,'m--',fittedX, fittedY-2*delta,'m--');
    %         xlim([25, 100]);
    %         ylim([0, 100]);
    %         xlabel('Reference Quality Score')
    %         ylabel('Estimated Quality Score')
    %         title([nModels{dd} '  Model'])
    %         refline([1 0])
    %         set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %         if dd==1
    %             legend('Data','Linear Fit','95% Prediction Interval','Unity Line','Location','southeast')
    %         end
    %         hold off;
    %     end
    %     sgtitle('Sub-results from General Model')
    %     savefig(fullfile(pathR,'Linear fit-Sub results from General Model.fig'))
    %     F = getframe(FigH);
    %     imwrite(F.cdata, fullfile(pathR,'tif','Linear fit-Sub results from General Model.tif'), 'tif')
    %     close all
    
end

%% Save
save('report.mat','report')
end
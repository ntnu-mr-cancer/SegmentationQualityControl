% To calculate some of the stats to evaluate model performance
function stats = modelStats(actual,predicted)
%% Number of elements (N)
stats.N = numel(actual);
%% Scores
% Mean scores (Reference)
stats.scoresMeanTruth = mean(actual);
% Median scores (Reference)
stats.scoresMedianTruth = median(actual);
% STD scores (Reference)
stats.scoresSTDTruth = std(actual);
% IQR(Reference)
stats.scoresIQRTruth = iqr(actual);

% Mean scores (Predicted)
stats.scoresMeanPredicted = mean(predicted);
% Median scores (Predicted)
stats.scoresMedianPredicted = median(predicted);
% STD scores (Predicted)
stats.scoresSTDPredicted = std(predicted);
% IQR(Predicted)
stats.scoresIQRPredicted = iqr(predicted);
%% Error
% Mean absolute error (MAE)
stats.MAE = mean(abs(actual - predicted));
% Mean square error (MSE)
stats.MSE = mean((actual - predicted).^2);
% Root mean squared error (RMSE)
stats.RMSE = sqrt(stats.MSE);
% Mean absolute percentage error (MAPE)
stats.MAPE = mean(abs((actual - predicted)./actual))*100;
% Mean percentage error (MPE)
stats.MPE = mean((actual - predicted)./actual)*100;

% MAE Standar deviation (MAESD)
stats.MAESD = std(abs(actual - predicted));
%% Correlation
% Correlation coefficients
[r, p] = corrcoef(actual,predicted);
% R
stats.r = r(1,2);
% R squared (r2)
stats.r2 = stats.r^2;
% correlation p-val (corrP)
stats.corrP = p(1,2);

% Linear correlation
% rho and rho p-val (rhoP)
[stats.rho, stats.rhoP] = corr(actual,predicted,'type','Spearman');
end
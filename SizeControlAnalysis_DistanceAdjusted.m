distances = DistancefromCenter(X > 0 & Y > 0 & Z > 0);
sizes = Xclean;
times = Yclean;

sizes = sizes(times < yAxisCutoff);
distances = distances(times < yAxisCutoff);
times = times(times < yAxisCutoff);

lm_distanceDependence = fitlm(distances , sizes)
sizes_adjusted = sizes - distances*lm_distanceDependence.Coefficients.Estimate(2);

xAxis = 'Birth sizes adjusted by distance from center';
yAxis = 'G1 length (frames)';


figure ('Name', [yAxis,' vs ',xAxis])
hold on
scatter(sizes_adjusted,times)
%This fit is plottable
fit_adj = polyfit(sizes_adjusted,times,1)
lm_adj = fitlm(sizes_adjusted,times)
lm = lm_adj;
disp(sprintf('\n'));
plot(0:max(sizes_adjusted),polyval(fit_adj,0:max(sizes_adjusted)))
axis([0 inf 0 inf])
xlabel(xAxis)
ylabel(yAxis)
lm_r2 = lm.Rsquared.Ordinary;
lm_pValue = lm.Coefficients.pValue(2);
str1 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue)];
if (lm.Coefficients.Estimate(2) > 0)
    dim = dimTopLeft;
else
    dim = dimTopRight;
end
annotation('textbox',dim,'String',str1,'FitBoxToText','on');
hold off
% X = NetG1SIntDen1;
% Y = SG2lengthframes1;
% Z = NetjustbeforeMnucleusintactIntDen1;
dimTopRight = [0.65 0.82 0.1 0.1];
dimTopLeft = [0.15 0.82 0.1 0.1];
dimBottomLeft = [0.15 0.15 0.1 0.1];

X = input('Independent variable (size): ');
xAxis = input('Independent variable axis title: ','s');
Y = input('Dependent variable (time): ');
yAxis = input('Dependent variable (time) axis title: ','s');
Z = input('Dependent variable (later size - initial size): ');
zAxis = input('Dependent variable (growth) axis title: ','s');

%Eliminates NaNs and restricts to cells with all positive values
%That means only cells that grew during G1 or entire cycle
Xclean = X(X > 0 & Y > 0 & Z > 0);
Yclean = Y(X > 0 & Y > 0 & Z > 0);
Zclean = Z(X > 0 & Y > 0 & Z > 0);

figure ('Name', [yAxis ' vs ' xAxis])
hold on
scatter(Xclean,Yclean)
%This fit is plottable
fit1 = polyfit(Xclean,Yclean,1)
lm1 = fitlm(Xclean,Yclean)
lm = lm1;
disp(sprintf('\n'));
domainXclean = linspace(0,max(Xclean),100);
plot(domainXclean,polyval(fit1,domainXclean))
axis([0 inf 0 inf])
xlabel(xAxis)
ylabel(yAxis)
lm_r2 = lm.Rsquared.Ordinary;
lm_pValue = lm.Coefficients.pValue(2);
lm_slope = lm.Coefficients.Estimate(2);
str1 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
if (lm.Coefficients.Estimate(2) > 0)
    dim = dimTopLeft;
else
    dim = dimBottomLeft;
end
annotation('textbox',dim,'String',str1,'FitBoxToText','on');
hold off

figure ('Name', [zAxis ' vs ' xAxis])
hold on
scatter(Xclean,Zclean)
%This fit is plottable
fit2 = polyfit(Xclean,Zclean,1)
lm2 = fitlm(Xclean,Zclean)
lm = lm2;
disp(sprintf('\n'));
plot(domainXclean,polyval(fit2,domainXclean))
axis([0 inf 0 inf])
xlabel(xAxis)
ylabel(zAxis)
lm_r2 = lm.Rsquared.Ordinary;
lm_pValue = lm.Coefficients.pValue(2);
lm_slope = lm.Coefficients.Estimate(2);
str2 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
if (lm.Coefficients.Estimate(2) > 0)
    dim = dimTopLeft;
else
    dim = dimBottomLeft;
end
annotation('textbox',dim,'String',str2,'FitBoxToText','on');
hold off


yAxisCutoff = input('Maximum relevant length: ');
figure ('Name' , [yAxis ' < ' num2str(yAxisCutoff) ' vs ' xAxis])
hold on
Xcleaner = Xclean(Yclean<yAxisCutoff);
Ycleaner = Yclean(Yclean<yAxisCutoff);
scatter(Xcleaner,Ycleaner)
fit3 = polyfit(Xcleaner,Ycleaner,1);
lm3 = fitlm(Xcleaner,Ycleaner)
lm = lm3;
disp(sprintf('\n'));
domainXcleaner = linspace(0,max(Xcleaner),100);
plot(domainXcleaner,polyval(fit3,domainXcleaner))
axis([0 inf 0 inf])
xlabel(xAxis)
ylabel(yAxis)
lm_r2 = lm.Rsquared.Ordinary;
lm_pValue = lm.Coefficients.pValue(2);
lm_slope = lm.Coefficients.Estimate(2);
str3 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
if (lm.Coefficients.Estimate(2) > 0)
    dim = dimTopLeft;
else
    dim = dimBottomLeft;
end
annotation('textbox',dim,'String',str3,'FitBoxToText','on');
hold off



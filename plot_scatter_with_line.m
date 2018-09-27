
function fig = plot_scatter_with_line(x,y,varargin)
fig = figure();
hold on
scatter(x,y)
if length(varargin) > 0 && strcmp(varargin{1},'no_intercept')
    lm = fitlm(x,y,'Intercept',false);
    fit = [lm.Coefficients.Estimate(1),0];
    lm_r2 = lm.Rsquared.Ordinary;
    lm_pValue = lm.Coefficients.pValue(1);
    lm_slope = lm.Coefficients.Estimate(1);
else
    lm = fitlm(x,y,'Intercept',true);
    fit = [lm.Coefficients.Estimate(2),lm.Coefficients.Estimate(1)];
    lm_r2 = lm.Rsquared.Ordinary;
    lm_pValue = lm.Coefficients.pValue(2);
    lm_slope = lm.Coefficients.Estimate(2);
end
domain = linspace(min(x),max(x),100);
plot(domain,polyval(fit,domain))
str = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
if (lm_slope > 0)
    dim = [0.15 0.82 0.1 0.1];
else
    dim = [0.15 0.15 0.1 0.1];
end
annotation('textbox',dim,'String',str,'FitBoxToText','on');
hold off
end

function fig = plot_scatter_with_line(x,y)
    fig = figure()
    hold on
    scatter(x,y)
    fit = polyfit(x,y,1);
    lm = fitlm(x,y);
    domain = linspace(min(x),max(x),100);
    plot(domain,polyval(fit,domain))
    lm_r2 = lm.Rsquared.Ordinary;
    lm_pValue = lm.Coefficients.pValue(2);
    lm_slope = lm.Coefficients.Estimate(2);
    str = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
    if (lm.Coefficients.Estimate(2) > 0)
        dim = [0.15 0.82 0.1 0.1];
    else
        dim = [0.15 0.15 0.1 0.1];
    end
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    hold off
end
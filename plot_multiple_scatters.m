function fig = plot_multiple_scatters(x,y,gooddata,expt1,expt2,expt3)
%Input: x and y are vectors of equal length
%Input: gooddata is a logical array of the same length that indicates which
%data should be included (i.e., gooddata)
%Input: expt1, expt2, expt3, are three logical vectors indicating which expt
%the data come from so they can be plotted in different colors

xname = inputname(1);
yname = inputname(2);

domain = linspace(min(x(gooddata)),max(x(gooddata)),100);
fit_all = polyfit(x(gooddata), y(gooddata), 1);
fit1 = polyfit(x(gooddata & expt1), y(gooddata & expt1), 1);
fit2 = polyfit(x(gooddata & expt2), y(gooddata & expt2), 1);
fit3 = polyfit(x(gooddata & expt3), y(gooddata & expt3), 1);
lm_all = fitlm(x(gooddata), y(gooddata));
lm1 = fitlm(x(gooddata & expt1), y(gooddata & expt1));
lm2 = fitlm(x(gooddata & expt2), y(gooddata & expt2));
lm3 = fitlm(x(gooddata & expt3), y(gooddata & expt3));

fig = figure()
hold on
plot(domain,polyval(fit_all,domain),'k')
plot(domain,polyval(fit1,domain),'r')
plot(domain,polyval(fit2,domain),'g')
plot(domain,polyval(fit3,domain),'b')
xlabel(xname);
ylabel(yname);
legend('Overall','Expt1','Expt2','Expt3')
axis([0 inf 0 inf])
scatter(x(gooddata & expt1), y(gooddata & expt1),'r', 'full')
scatter(x(gooddata & expt2), y(gooddata & expt2),'g', 'full')
scatter(x(gooddata & expt3), y(gooddata & expt3),'b', 'full')
hold off

figure()
hold on
plot(domain,polyval(fit_all,domain),'k')
xlabel(xname);
ylabel(yname);
legend('Overall')
axis([0 inf 0 inf])
scatter(x(gooddata), y(gooddata),'k', 'full')
hold off

disp('Hello')
disp(yname)
disp([yname ' vs ' xname])
disp(['Overall p-value = ' num2str(lm_all.Coefficients.pValue(2))])


end
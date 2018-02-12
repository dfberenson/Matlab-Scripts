function fig = plot_multiple_histograms(x,gooddata,expt1,expt2,expt3)

fig = figure()
hold on
histogram(x(gooddata & expt1),10,'FaceColor','r','FaceAlpha',0.9)
histogram(x(gooddata & expt2),10,'FaceColor','g','FaceAlpha',0.6)
histogram(x(gooddata & expt3),10,'FaceColor','b','FaceAlpha',0.3)
xlabel(inputname(1));
ylabel('Count')
legend('Expt1','Expt2','Expt3')

group = get_group_variable({expt1,expt2,expt3});
[p,tbl,stats] = anova1(x(gooddata),group(gooddata),'off');
f_stat = tbl{2,5};
dim = [0.65 0.6 0.1 0.1];
annotation('textbox',dim,'String',['F value = ' num2str(f_stat)],'FitBoxToText','on');

hold off
end
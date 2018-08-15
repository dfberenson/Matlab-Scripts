
function fig = plot_scatter_with_logit(x,y)
fig = figure();
hold on
yyaxis left
scatter(x,y)
ylabel('Binary outcome')
yyaxis right
fit = glmfit(x,y,'binomial');
domain = linspace(min(x),max(x),100);
plot(domain,glmval(fit,domain,'logit'))
ylabel('Probability')
hold off
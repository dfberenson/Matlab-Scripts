
function fig = plot_scatter_with_logit(X,Y)
fig = figure();
hold on
yyaxis left
scatter(X,Y)
ylabel('Binary outcome')
yyaxis right
fit = glmfit(X,Y,'binomial');
domain = linspace(min(X),max(X),100);
plot(domain,glmval(fit,domain,'logit'))
ylabel('Probability')
axis([-inf inf 0 0.2])
hold off
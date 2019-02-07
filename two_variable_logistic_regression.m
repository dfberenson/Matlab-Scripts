

function [fig,x_and_y_pvals] = two_variable_logistic_regression(X,Y,Z,X_low_prctile,X_high_prctile,Y_low_prctile,Y_high_prctile)

if ~iscolumn(X)
    X = X';
end
if ~iscolumn(Y)
    Y = Y';
end
if ~iscolumn(Z)
    Z = Z';
end
assert(size(X,2) == 1 && size(Y,2) == 1 && size(Z,2) == 1)

assert(length(X) == length(Y) && length(Y) == length(Z))

data_within_prctiles = X >= prctile(X,X_low_prctile) & X <= prctile(X,X_high_prctile) & Y >= prctile(Y,Y_low_prctile) & Y <= prctile(Y,Y_high_prctile);
X = X(data_within_prctiles);
Y = Y(data_within_prctiles);
Z = Z(data_within_prctiles);

[b,dev,stats] = glmfit([X Y], Z, 'binomial');
x_and_y_pvals = stats.p(2:3);
domain_granularity = 50;
x_domain = linspace(prctile(X,1), prctile(X,99), domain_granularity)';
y_domain = linspace(prctile(Y,1), prctile(Y,99), domain_granularity)';

[x_grid,y_grid] = meshgrid(x_domain,y_domain);
linearized_x_grid = reshape(x_grid,[domain_granularity^2,1]);
linearized_y_grid = reshape(y_grid,[domain_granularity^2,1]);

fitted_vals = glmval(b, [linearized_x_grid,linearized_y_grid], 'logit');
fitted_vals_grid = reshape(fitted_vals,[domain_granularity domain_granularity]);

fig  = figure();
box on
hold on
axis('square')
surf(x_domain,y_domain,fitted_vals_grid);

end
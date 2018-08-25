

function fig = two_variable_logistic_regression(X,Y,Z)

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

fit = glmfit([X Y], Z, 'binomial');
domain_granularity = 50;
x_domain = linspace(min(X), max(X), domain_granularity)';
y_domain = linspace(min(Y), max(Y), domain_granularity)';

[x_grid,y_grid] = meshgrid(x_domain,y_domain);
linearized_x_grid = reshape(x_grid,[domain_granularity^2,1]);
linearized_y_grid = reshape(y_grid,[domain_granularity^2,1]);

fitted_vals = glmval(fit, [linearized_x_grid,linearized_y_grid], 'logit');
fitted_vals_grid = reshape(fitted_vals,[domain_granularity domain_granularity]);

fig  = figure();
hold on
surf(x_domain,y_domain,fitted_vals_grid);

end
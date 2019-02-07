

function [fig,x_and_y_and_z_pvals] = three_variable_logistic_regression(X,Y,Z,Q)

if ~iscolumn(X)
    X = X';
end
if ~iscolumn(Y)
    Y = Y';
end
if ~iscolumn(Z)
    Z = Z';
end
if ~iscolumn(Q)
    Q = Q';
end
assert(size(X,2) == 1 && size(Y,2) == 1 && size(Z,2) == 1 && size(Q,2) == 1)

assert(length(X) == length(Y) && length(Y) == length(Z) && length(Z) == length(Q))

[b,dev,stats] = glmfit([X Y Z], Q, 'binomial');
x_and_y_and_z_pvals = stats.p(2:4);
domain_granularity = 50;
x_domain = linspace(prctile(X,1), prctile(X,99), domain_granularity)';
y_domain = linspace(prctile(Y,1), prctile(Y,99), domain_granularity)';
z_domain = linspace(prctile(Z,1), prctile(Z,99), domain_granularity)';

[x_grid,y_grid,z_grid] = meshgrid(x_domain,y_domain,z_domain);
linearized_x_grid = reshape(x_grid,[domain_granularity^3,1]);
linearized_y_grid = reshape(y_grid,[domain_granularity^3,1]);
linearized_z_grid = reshape(z_grid,[domain_granularity^3,1]);

fitted_vals = glmval(b, [linearized_x_grid,linearized_y_grid,linearized_z_grid], 'logit');
fitted_vals_grid = reshape(fitted_vals,[domain_granularity domain_granularity domain_granularity]);

fig  = figure();
hold on
% axis([prctile(X,1), prctile(X,99),prctile(Y,1), prctile(Y,99), prctile(Z,1), prctile(Z,99)],'square')


xslice = [prctile(X,99), prctile(X,50)];                            % define the cross sections to view
yslice = [prctile(Y,99), prctile(Y,50)];
zslice = prctile(Z,1);

slice(x_domain, y_domain, z_domain, fitted_vals_grid, xslice, yslice, zslice)    % display the slices
view(-34,24)

end
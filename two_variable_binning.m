
function [means, error_below, error_above, Ns, fig] = two_variable_binning(X,Y,Z,X_low_prctile,X_high_prctile,Y_low_prctile,Y_high_prctile)

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

times_to_bootstrap = 1000;
numbins = 6;
x_bincenters = linspace(min(X),max(X),numbins);
y_bincenters = linspace(min(Y),max(Y),numbins);

x_bindistance = mean(diff(x_bincenters));
x_stdev_bindistance = std(diff(x_bincenters));
assert(x_stdev_bindistance / x_bindistance < 0.01, 'Bins must be evenly spaced')

y_bindistance = mean(diff(y_bincenters));
y_stdev_bindistance = std(diff(y_bincenters));
assert(y_stdev_bindistance / y_bindistance < 0.01, 'Bins must be evenly spaced')

means = zeros(numbins,numbins);
error_below = zeros(numbins,numbins);
error_above = zeros(numbins,numbins);
Ns = zeros(numbins,numbins);

% Put Y on y-axis (row number)
for i = 1:numbins
    y_thisbinmin = y_bincenters(i) - y_bindistance/2;
    y_thisbinmax = y_bincenters(i) + y_bindistance/2;
    y_indices_in_bin = y_thisbinmin <= Y & Y <= y_thisbinmax;
    
    % Put X on x-axis (column number)
    for j = 1:numbins
        x_thisbinmin = x_bincenters(j) - x_bindistance/2;
        x_thisbinmax = x_bincenters(j) + x_bindistance/2;
        x_indices_in_bin = x_thisbinmin <= X & X <= x_thisbinmax;
        
        Zs_in_bin = Z(x_indices_in_bin & y_indices_in_bin);
        means(i,j) = mean(Zs_in_bin);
        Ns(i,j) = length(Zs_in_bin);
        for b = 1:times_to_bootstrap
            resampled = datasample(Zs_in_bin,length(Zs_in_bin));
            bootstrapped_means(b) = mean(resampled);
        end
        
        error_below(i,j) = means(i,j) - prctile(bootstrapped_means,5);
        error_above(i,j) = prctile(bootstrapped_means,95) - means(i,j);
        
        % If the error is zero and there are fewer than 20 cells in the
        % bin, set the error to 1 instead.
        if error_below(i,j) == 0 && Ns(i,j) < 20
            error_below(i,j) = 1;
        end
        if error_above(i,j) == 0 && Ns(i,j) < 20
            error_above(i,j) = 1;
        end
    end
end

fig  = figure();
% To make the plot in 3d, get rid of hold on / box on
hold on
box on
surf(x_bincenters,y_bincenters,means);



% surf(means - error_below)
% surf(means + error_above)
% 
% for i = 1:numbins
%     for j = 1:numbins
% %         h = scatter3(x_bincenters(j),y_bincenters(i),means(i,j))
%         h = plot3([x_bincenters(j) x_bincenters(j)],[y_bincenters(i) y_bincenters(i)],[means(i,j) - error_below(i,j), means(i,j) + error_below(i,j)]);
%         set(h, 'LineWidth',0.5,'Color','k');
%     end
% end

% gca();
% axis([-inf inf -inf inf 0 1]);

% fig  = figure();
% surf(x_bincenters,y_bincenters,Ns);
% hold on

end
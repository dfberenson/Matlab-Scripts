
function [means, error_below, error_above, Ns] = bootstrap(X,Y,bincenters)

times_to_bootstrap = 1000;

numbins = length(bincenters);
all_bindistances = diff(bincenters);
bindistance = mean(all_bindistances);
stdev_bindistance = std(all_bindistances);
assert(stdev_bindistance / bindistance < 0.01, 'Bins must be evenly spaced');

means = zeros(numbins,1);
error_below = zeros(numbins,1);
error_above = zeros(numbins,1);
Ns = zeros(numbins,1);

for i = 1:numbins
    thisbinmin = bincenters(i) - bindistance/2;
    thisbinmax = bincenters(i) + bindistance/2;
    Ys_in_bin = Y(thisbinmin<=X & X<=thisbinmax);
    means(i) = mean(Ys_in_bin);
    Ns(i) = length(Ys_in_bin);
    for b = 1:times_to_bootstrap
        resampled = datasample(Ys_in_bin,length(Ys_in_bin));
        bootstrapped_means(b) = mean(resampled);
    end
    
    error_below(i) = means(i) - prctile(bootstrapped_means,5);
    error_above(i) = prctile(bootstrapped_means,95) - means(i);
    
end

end
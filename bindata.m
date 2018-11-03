
function [means,stdevs,stderrs] = bindata(X,Y,bincenters)

numbins = length(bincenters);
all_bindistances = diff(bincenters);
bindistance = mean(all_bindistances);
stdev_bindistance = std(all_bindistances);
assert(stdev_bindistance / bindistance < 0.01, 'Bins must be evenly spaced');  

means = zeros(numbins,1);
stdevs = zeros(numbins,1);
Ns = zeros(numbins,1);
stderrs = zeros(numbins,1);

for i = 1:numbins
    thisbinmin = bincenters(i) - bindistance/2;
    thisbinmax = bincenters(i) + bindistance/2;   
    means(i) = mean(Y(thisbinmin<=X & X<=thisbinmax));
    stdevs(i) = std(Y(thisbinmin<=X & X<=thisbinmax));
    Ns(i) = length(Y(thisbinmin<=X & X<=thisbinmax));
    stderrs(i) = stdevs(i)/sqrt(Ns(i));
end

end
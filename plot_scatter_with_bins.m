

function fig = plot_scatter_with_bins(x,y,numbins,gooddata)

if ~exist('gooddata')
    gooddata = logical(ones(1,length(x)));
end
if ~exist('numbins')
    numbins = 8;
end

x = x(gooddata);
y = y(gooddata);

minbin = min(x);
maxbin = max(x);


binsizes = linspace(minbin,maxbin,numbins+1);
bincenters = zeros(numbins,1);
means = zeros(numbins,1);
stdevs = zeros(numbins,1);
Ns = zeros(numbins,1);
stderrs = zeros(numbins,1);

for i = 1:numbins
    thisbinmin = binsizes(i);
    thisbinmax = binsizes(i+1);
    bincenters(i) = (thisbinmin + thisbinmax)/2;
    means(i) = mean(y(thisbinmin<=x & x<=thisbinmax));
    stdevs(i) = std(y(thisbinmin<=x & x<=thisbinmax));
    Ns(i) = length(y(thisbinmin<=x & x<=thisbinmax));
    stderrs(i) = stdevs(i)/sqrt(Ns(i));
end

fig = figure()
hold on
scatter(x,y,'MarkerFaceColor','k','MarkerEdgeColor','k')
errorbar(bincenters,means,stderrs,'-k')
xlabel(inputname(1));
ylabel(inputname(2));
axis([0 inf -inf inf])
%legend('Data','Means +/- std. error')
hold off
end
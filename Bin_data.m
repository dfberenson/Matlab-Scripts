X = input('What is the x-axis variable? ');
xAxis = input('Label for x-axis: ','s');
Y = input('What is the y-axis variable? ');
yAxis = input('Label for y-axis: ','s');


Xclean = X(X > 0 & Y > 0);
Yclean = Y(X > 0 & Y > 0);

X = Xclean;
Y = Yclean;

numbins = 7;
minbin = 3950;
maxbin = 9950;
binsizes = linspace(minbin,maxbin,numbins);
bincenters = linspace(0,1,numbins-1);
means = linspace(0,1,numbins-1);
stdevs = linspace(0,1,numbins-1);
for n = 1:numbins-1
    if n < numbins
        thisbinmin = binsizes(n);
        thisbinmax = binsizes(n+1);
        bincenters(n) = (thisbinmin + thisbinmax)/2;
        means(n) = mean(Y(thisbinmin<=X & X<=thisbinmax));
        stdevs(n) = std(Y(thisbinmin<=X & X<=thisbinmax));
    end
end

figure()
hold on
scatter(X,Y)
errorbar(bincenters,means,stdevs)
xlabel(xAxis)
ylabel(yAxis)
axis([0 inf 0 inf])
hold off

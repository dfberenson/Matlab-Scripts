X = input('What is the x-axis variable? ');
xAxis = input('Label for x-axis: ','s');
Y = input('What is the y-axis variable? ');
yAxis = input('Label for y-axis: ','s');


Xclean = X(X > 0 & Y > 0);
Yclean = Y(X > 0 & Y > 0);

X = Xclean;
Y = Yclean;

figure()
scatter(X,Y)
numbins = input('How many bins: ');
minbin = input('Bin minimum: ');
maxbin = input('Bin maximum: ');
close()

% numbins = 7;
% minbin = 3950;
% maxbin = 9950;


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
    means(i) = mean(Y(thisbinmin<=X & X<=thisbinmax));
    stdevs(i) = std(Y(thisbinmin<=X & X<=thisbinmax));
    Ns(i) = length(Y(thisbinmin<=X & X<=thisbinmax));
    stderrs(i) = stdevs(i)/sqrt(Ns(i));
end

% figure()
% hold on
% scatter(X,Y)
% errorbar(bincenters,means,stdevs)
% xlabel(xAxis)
% ylabel(yAxis)
% axis([0 inf 0 inf])
% %legend('Data','Means +/- std. dev')
% hold off

figure()
hold on
scatter(X,Y)
errorbar(bincenters,means,stderrs)
xlabel(xAxis)
ylabel(yAxis)
axis([0 inf 0 inf])
%legend('Data','Means +/- std. error')
hold off
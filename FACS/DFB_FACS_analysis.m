

%Analyze FACS data
%Import CSV data column vectors A,B,C,D etc.
%X is the x-axis vector on which data will be binned

% folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\161003_HMEC_size-sensors';
% expt = 'HMEC-1G-EF1a-mCherry_60504_Single Cells_Single Cells';

folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\161012_HMEC_size-sensors+CFSE';
expt = 'HMEC-FSC-SSC-CFSE-mCherry_1G(EF1a)+CFSE_62955_HMEC-1G-EF1a-mCherry+CFSE_Single Cells';

% folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\180316_HMEC_size-sensors_EGF_Palbo\GatedAndCompensated';
% expt = 'PlusEGF-MinusPalbo';
% 
% folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\180405_HMEC_size-sensors_EGF_Palbo\GatedAndUncompensated_mCherry-hi';
% expt = 'PlusEGF-PlusPalbo';

T = readtable([folder '\' expt '.csv']);

FSC = T.FSC_A;
SSC = T.SSC_A;
% GFP = T.GFP_compensated;
if any(strcmp(T.Properties.VariableNames,'mCherry_A'))
    mCherry = T.mCherry_A;
elseif any(strcmp(T.Properties.VariableNames,'Comp_mCherry_A'))
    mCherry = T.Comp_mCherry_A;
end
if any(strcmp(T.Properties.VariableNames,'Comp_CFSE_A')) || any(strcmp(T.Properties.VariableNames,'Comp_CSFE_A'))
    CFSE = T.Comp_CSFE_A;
end


% A = T.FSC_A;
% B = T.SSC_A;
% C = T.mCherry_compensated;

% X = B;
% Y = C;
X = input('What is the x-axis variable? ');
x_axis_label = input('Label for x-axis: ','s');
Y = input('What is the y-axis variable? ');
y_axis_label = input('Label for y-axis: ','s');

[numcells,one] = size(X);

%Create a vector with 'numbins' equally spaced bins
numbins = 100;
binsizes = linspace(min(X) , max(X) , numbins + 1);
%Delete the first bin since it will contain zero observations
binsizes(1) = [];

%Sort X and then keep data in Y properly paired with it 
[X,index] = sort(X);
Y = Y(index);

%Create an index for all the data (m)
%And an empty cell array to contain the data
m = 1;
binneddataY = cell(1,numbins);

%Go through each bin
for n = 1 : numbins
    %Assign data in Y to the appropriate bin
    while X(m) < binsizes (n)
        binneddataY{n} = [binneddataY{n} ; Y(m)];
        m = m+1;
    end
end

%Calculate statistics for each bin
allBinsAvgY = [];
allBinsStdDevY = [];
allBinsStdErrorY = [];
%Determine which is the last bin with at least 'minFullBinObs' observations
minFullBinObs = 50;
lastFullBin = 1;

%Go through each bin
for n = 1 : numbins
    %Calculate statistics for this bin and append to list
    thisbin = binneddataY{n};
    avg = mean(thisbin);
    allBinsAvgY = [allBinsAvgY , avg];
    allBinsStdDevY = [allBinsStdDevY, std(thisbin)];
    stderror = std(thisbin) / sqrt(length(thisbin));
    allBinsStdErrorY = [allBinsStdErrorY, stderror];
    %Record if this bin has at least 'minFullBinObs' observations
    if length(thisbin) >= minFullBinObs
        lastFullBin = n;
    end
end

%Linear fit to data in region up until bins are no longer fairly full
%This fit is plottable
fit1 = polyfit(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)) , 1);
ndensitybins = [200 200];
density = hist3([X,Y],ndensitybins) / numcells;

%A new linear fit
%This fit provides statistics like R^2
linearfit = fitlm(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)))
disp(sprintf('\n'));

%Label figure
figTitle = 'FACS analysis of lentiviral mCherry versus scatter';
figTitle = input('Title for figure: ','s');

%Plot data and linear fit
figure ('Name','Data')
hold on
%contour (density);
%plot (binsizes,allbinsavgY)
title(figTitle)
xlabel(x_axis_label)
ylabel(y_axis_label)

shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
scatter (X,Y,0.1,'r')
shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'g-')
plot(0:max(X),polyval(fit1,0:max(X)))
axis([0 inf 0 inf])
hold off
saveas(gcf,[folder '\' y_axis_label '_vs_' x_axis_label '_unzoomed.png']);

figure ('Name','Data')
hold on
%contour (density);
%plot (binsizes,allbinsavgY)
title(figTitle)
xlabel(x_axis_label)
ylabel(y_axis_label)

shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
scatter (X,Y,0.1,'r')
shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'g-')
plot(0:max(X),polyval(fit1,0:max(X)))

%Determine zoom to show most of the data
xAxisMax = binsizes(lastFullBin);
yAxisMax = max(allBinsAvgY(binsizes < xAxisMax)) + max(allBinsStdDevY(binsizes < xAxisMax));
axis([0 xAxisMax 0 yAxisMax])
hold off
saveas(gcf,[folder '\' y_axis_label '_vs_' x_axis_label '_zoomed.png']);

figure()
pctile_025 = quantile(X,0.025);
pctile_975 = quantile(X,0.975);
qqplot(X,Y)
axis([pctile_025 pctile_975 -inf inf])
title([figTitle ' QQ plot, 2.5th-97.5th percentiles'])
xlabel(x_axis_label)
ylabel(y_axis_label)
saveas(gcf,[folder '\' y_axis_label '_vs_' x_axis_label '_QQ.png']);

figure()
pctile_025 = quantile(X,0.025);
pctile_975 = quantile(X,0.975);
qqplot(X)
axis([-2 2 -inf inf])
title([x_axis_label ' QQ plot, 2.5th-97.5th percentiles'])
xlabel('Normal quantiles')
ylabel(x_axis_label)
saveas(gcf,[folder '\' x_axis_label '_normal_QQ.png']);

figure()
pctile_025 = quantile(Y,0.025);
pctile_975 = quantile(Y,0.975);
qqplot(Y)
axis([-2 2 -inf inf])
title([y_axis_label ' QQ plot, 2.5th-97.5th percentiles'])
xlabel('Normal quantiles')
ylabel(y_axis_label)
saveas(gcf,[folder '\' y_axis_label '_normal_QQ.png']);
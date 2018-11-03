
clear all
close all

% Plot CFSE vs mCherry for cell line 1G

table_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\161012_HMEC_size-sensors+CFSE\HMEC-FSC-SSC-CFSE-mCherry_1G(EF1a)+CFSE_62955_HMEC-1G-EF1a-mCherry+CFSE_Single Cells.csv';
T = readtable(table_fpath);

raw_X = T.Comp_CSFE_A;
raw_Y = T.Comp_mCherry_A;
x_axis_label = 'CFSE';
y_axis_label = 'prEF1a-mCherry-NLS';

median_X = median(raw_X);
median_Y = median(raw_Y);

X = raw_X / median_X;
Y = raw_Y / median_Y;

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
minFullBinObs = 1;
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


x_percentile_025 = prctile(X,2.5);
x_percentile_975 = prctile(X,97.5);
y_percentile_010 = prctile(Y,1);
y_percentile_990 = prctile(Y,99);
central_X = X(X > x_percentile_025 & X < x_percentile_975);
central_Y = Y(X > x_percentile_025 & X < x_percentile_975);

%Linear fit to data in region up until bins are no longer fairly full
%This fit is plottable
fit1 = polyfit(central_X,central_Y,1);
ndensitybins = [200 200];
density = hist3([X,Y],ndensitybins) / numcells;

%A new linear fit
%This fit provides statistics like R^2
linearfit = fitlm(central_X,central_Y)
linearfit_r2 = linearfit.Rsquared.Ordinary;
linearfit_pValue = linearfit.Coefficients.pValue(2);
linearfit_slope = linearfit.Coefficients.Estimate(2);
disp(sprintf('\n'));

x_percentile_025 = prctile(X,2.5);
x_percentile_975 = prctile(X,97.5);
y_percentile_010 = prctile(Y,1);
y_percentile_990 = prctile(Y,99);

figure
hold on
xlabel(x_axis_label)
ylabel(y_axis_label)
shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'r-')
plot(0:max(X),polyval(fit1,0:max(X)),'k')
axis([x_percentile_025 x_percentile_975 y_percentile_010 y_percentile_990])
hold off
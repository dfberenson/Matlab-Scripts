
clear all
close all

% Plot SSC vs CFSE for cell line 1G

table_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\181213_HMEC_D5_CFSE\export_Specimen_001_D5+CFSE_001_CFSE+.csv';
T = readtable(table_fpath);

raw_X = T.SSC_A;
raw_Y = T.Comp_B525_A;
x_axis_label = 'SSC';
y_axis_label = 'CFSE';

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

% figure
% hold on
% xlabel(x_axis_label)
% ylabel(y_axis_label)
% shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
% shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'r-')
% plot(0:max(X),polyval(fit1,0:max(X)),'k')
% axis([x_percentile_025 x_percentile_975 y_percentile_010 y_percentile_990])
% hold off

figure
box on
hold on
ax = gca();
xlabel(x_axis_label)
ylabel(y_axis_label)
plot(0:0.1:2.5,0:0.1:2.5,'-b')
plot(0:0.1:2.5,polyval(fit1,0:0.1:2.5),'--k')
shadedErrorBar(binsizes(binsizes > x_percentile_025 & binsizes < x_percentile_975),allBinsAvgY(binsizes > x_percentile_025 & binsizes < x_percentile_975),allBinsStdDevY(binsizes > x_percentile_025 & binsizes < x_percentile_975),'m-',1)
shadedErrorBar(binsizes(binsizes > x_percentile_025 & binsizes < x_percentile_975),allBinsAvgY(binsizes > x_percentile_025 & binsizes < x_percentile_975),allBinsStdErrorY(binsizes > x_percentile_025 & binsizes < x_percentile_975),'r-')
% h = findobj(gca);
% legend([h(2),h(5),h(9),h(10)],{'Binned means','Standard error','Standard deviation','Linear fit'},'Location','SE')
axis([0 2.5 0 2.5],'square')
xticks([0 1 2])
yticks([0 1 2])
ax.FontSize = 64;
hold off
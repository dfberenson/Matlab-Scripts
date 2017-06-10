foldername = 'C:\Users\Skotheim Lab\Desktop\Test images\Many-cell measurements\DFB_170530_HMEC_1GFiii_photobleaching measurements';
filename = 'AllIntegratedIntensities';
filepath = [foldername '\' filename '.xlsx'];

datastruct = importdata(filepath);
headers = datastruct.colheaders;
data = datastruct.data;

%Create a bunch of paired arrays X(n),Y(n) that are the ECDFs for the data,
%By using the function [Y(n),X(n) = ecdf(data(n));
%Then plot each as plot(X(n),Y(n)] and choose appropriate color and line
%shape
X = cell(1,length(headers));
Y = cell(1,length(headers));
allexptnames = cell(1,length(headers));
linestyles = {'r-','r--','b-','b--','g-','g--'};
%linestyles = {'r-','r--','r:','b-','b--','b:','g-','g:'};
percentile95 = 0;

hold on
for expt = 1:length(headers)
    thesedata = data(:,expt);
    thesedata = thesedata(~isnan(thesedata));
    thisexptname = headers(expt);
    [Y{expt},X{expt}] = ecdf(thesedata);
    plot(X{expt},Y{expt},linestyles{expt})
    percentile95 = max(percentile95 , min(X{expt}(Y{expt} > 0.95)));
end

xlabel('Observed size')
ylabel('Cumulative frequency')
axis([0 percentile95 0 inf])
legend(headers,'Location','SE')


%data = input('Enter the data within square brackets: ');
% data1 = mCherryA;
% normalized_data1 = data1/mean(data1);
% data2 = SizebirthIntDen;
% normalized_data2 = data2/mean(data2);
% figure()
% hold on
% cdfplot(normalized_data1)
% cdfplot(normalized_data2)
% axis([0 inf 0 inf])
% %xlabel(input('x-axis label: ' , 's'));
% ylabel('Cumulative probability');
% legend('mCherry','Birth size','Location','SE')
% hold off

% 
% 
% cdfplot(FSCA/mean(FSCA))
% hold on
% cdfplot(SSCA/mean(SSCA))
% cdfplot(CompmCherryA/mean(CompmCherryA))
% cdfplot(CompCSFEA/mean(CompCSFEA))
% cdfplot(fijimeasurements/mean(fijimeasurements))
% cdfplot(cellprofmeasurements(cellprofmeasurements>0.02)/mean(cellprofmeasurements(cellprofmeasurements>0.02)))
% cdfplot(totalvoldata/mean(totalvoldata))
% cdfplot(x/mean(x))
% ylabel('Cumulative probability');
% xlabel('Size measurement');
% legend('FSC','SSC','mCherry by FACS','CFSE by FACS','mCherry by FIJI','mCherry by CellProfiler (>0.02 only)','Coulter counter Apr06 (diam > 12 only)','Coulter counter Apr19 (diam > 12 only)','Location','SE')
% hold off
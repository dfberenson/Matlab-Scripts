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



cdfplot(FSCA/mean(FSCA))
hold on
cdfplot(SSCA/mean(SSCA))
cdfplot(CompmCherryA/mean(CompmCherryA))
cdfplot(CompCSFEA/mean(CompCSFEA))
cdfplot(fijimeasurements/mean(fijimeasurements))
cdfplot(cellprofmeasurements(cellprofmeasurements>0.02)/mean(cellprofmeasurements(cellprofmeasurements>0.02)))
cdfplot(totalvoldata/mean(totalvoldata))
cdfplot(x/mean(x))
ylabel('Cumulative probability');
xlabel('Size measurement');
legend('FSC','SSC','mCherry by FACS','CFSE by FACS','mCherry by FIJI','mCherry by CellProfiler (>0.02 only)','Coulter counter Apr06 (diam > 12 only)','Coulter counter Apr19 (diam > 12 only)','Location','SE')
hold off
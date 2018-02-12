
foldername = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data';
filename = 'DFB_170802-0907_HMEC_1GFiii_palbo all manual measurements';

table = readtable([foldername '\' filename '.xlsx'], 'ReadVariableNames' , true);
ancestorcells = table2array(table(:,'AncestorCell'));
expt1 = ancestorcells < 100;
expt2 = ancestorcells >= 100 & ancestorcells < 200;
expt3 = ancestorcells > 200;
g1length = table2array(table(:,'G1Length'))/6;
sg2length = table2array(table(:,'SG2Length'))/6;
totalcyclelength = table2array(table(:,'TotalCycleLength'))/6;
enterS = logical(table2array(table(:,'EnterS')));
enterM = logical(table2array(table(:,'EnterM')));
birthsize = table2array(table(:,'BirthSize'));
g1ssize = table2array(table(:,'G1SSize'));
msize = table2array(table(:,'MSize'));
g1growth = g1ssize - birthsize;
sg2growth = msize - g1ssize;
totalcyclegrowth = msize - birthsize;



%Make plots with cells colorized by experiment date
%To examine expt-to-expt variability

domain = linspace(min(birthsize(enterS)),max(birthsize(enterS)),100);
fit_all = polyfit(birthsize(enterS), g1length(enterS), 1);
fit1 = polyfit(birthsize(enterS & expt1), g1length(enterS & expt1), 1);
fit2 = polyfit(birthsize(enterS & expt2), g1length(enterS & expt2), 1);
fit3 = polyfit(birthsize(enterS & expt3), g1length(enterS & expt3), 1);
lm_all = fitlm(birthsize(enterS), g1length(enterS));
lm1 = fitlm(birthsize(enterS & expt1), g1length(enterS & expt1));
lm2 = fitlm(birthsize(enterS & expt2), g1length(enterS & expt2));
lm3 = fitlm(birthsize(enterS & expt3), g1length(enterS & expt3));

%Use functions to make some useful plots

% close all

plot_multiple_scatters(birthsize,g1length,enterS,expt1,expt2,expt3);
plot_binned_data(birthsize,g1length,enterS,10);
plot_multiple_scatters(birthsize,g1ssize,enterS,expt1,expt2,expt3);
plot_binned_data(birthsize,g1ssize,enterS,10);
plot_multiple_scatters(birthsize,g1growth, enterS,expt1,expt2,expt3);
plot_binned_data(birthsize,g1growth,enterS,10);
plot_multiple_scatters(g1ssize,sg2length,enterM,expt1,expt2,expt3);
plot_binned_data(g1ssize,sg2length,enterM,10);
plot_multiple_scatters(g1ssize,msize,enterM,expt1,expt2,expt3);
plot_binned_data(g1ssize,msize,enterM,10);
plot_multiple_scatters(g1ssize,sg2growth,enterM,expt1,expt2,expt3);
plot_binned_data(g1ssize,sg2growth,enterM,10);
plot_multiple_scatters(birthsize,g1growth./g1length,enterS,expt1,expt2,expt3);
plot_binned_data(birthsize,g1growth./g1length,enterS,10);
plot_multiple_scatters(g1ssize,sg2growth./sg2length,enterM,expt1,expt2,expt3);
plot_binned_data(g1ssize,sg2growth./sg2length,enterM,10);

plot_multiple_histograms(birthsize,logical(ones(length(ancestorcells),1)),expt1,expt2,expt3);
plot_multiple_histograms(g1ssize,enterS,expt1,expt2,expt3);
plot_multiple_histograms(msize,enterM,expt1,expt2,expt3);
plot_multiple_histograms(g1length,enterS,expt1,expt2,expt3);
plot_multiple_histograms(sg2length,enterS,expt1,expt2,expt3);

figure,scatter(birthsize(enterS),g1growth(enterS),10,g1length(enterS),'filled')
xlabel('Birth size')
ylabel('G1 growth')
colormap('Cool')
colorbar()
fitlm([birthsize(enterS),g1length(enterS)],g1growth(enterS))
figure,scatter(g1ssize(enterM),sg2growth(enterM),10,sg2length(enterM),'filled')
xlabel('G1/S size')
ylabel('S/G2 growth')
colormap('Cool')
colorbar()
fitlm([g1ssize(enterM),sg2length(enterM)],sg2growth(enterM))

%Script versions of function plots
% figure()
% hold on
% plot(domain,polyval(fit_all,domain),'k')
% plot(domain,polyval(fit1,domain),'r')
% plot(domain,polyval(fit2,domain),'g')
% plot(domain,polyval(fit3,domain),'b')
% xlabel('Birth size')
% ylabel('G1 length (h)')
% legend('Overall','Expt1','Expt2','Expt3')
% scatter(birthsize(enterS & expt1), g1length(enterS & expt1),'r', 'full')
% scatter(birthsize(enterS & expt2), g1length(enterS & expt2),'g', 'full')
% scatter(birthsize(enterS & expt3), g1length(enterS & expt3),'b', 'full')
% hold off
% 
% figure()
% hold on
% plot(domain,polyval(fit_all,domain),'k')
% xlabel('Birth size')
% ylabel('G1 length (h)')
% legend('Overall','Expt1','Expt2','Expt3')
% scatter(birthsize(enterS), g1length(enterS),'k', 'full')
% hold off
% 
% figure()
% hold on
% histogram(birthsize(enterS & expt1),10,'FaceColor','r','FaceAlpha',0.9)
% histogram(birthsize(enterS & expt2),10,'FaceColor','g','FaceAlpha',0.6)
% histogram(birthsize(enterS & expt3),10,'FaceColor','b','FaceAlpha',0.3)
% xlabel('Birth size')
% ylabel('Count')
% legend('Expt1','Expt2','Expt3')
% hold off
% 
% figure()
% hold on
% histogram(g1length(enterS & expt1),10,'FaceColor','r','FaceAlpha',0.9)
% histogram(g1length(enterS & expt2),10,'FaceColor','g','FaceAlpha',0.6)
% histogram(g1length(enterS & expt3),10,'FaceColor','b','FaceAlpha',0.3)
% xlabel('G1 length (h)')
% ylabel('Count')
% legend('Expt1','Expt2','Expt3')
% hold off
% 
% 
% figure()
% hold on
% histogram(birthsize,10,'FaceColor','c','FaceAlpha',0.9)
% histogram(g1ssize(enterS),10,'FaceColor','y','FaceAlpha',0.6)
% histogram(msize(enterM),10,'FaceColor','m','FaceAlpha',0.4)
% legend('Birth size','G1/S size','G2/M size')
% xlabel('Size (AU)')
% ylabel('Count')
% hold off

% 
% %Code below prompts user to choose variables to plot, then plots with p
% %values
% 
% % X = NetG1SIntDen1;
% % Y = SG2lengthframes1;
% % Z = NetjustbeforeMnucleusintactIntDen1;
% dimTopRight = [0.65 0.82 0.1 0.1];
% dimTopLeft = [0.15 0.82 0.1 0.1];
% dimBottomLeft = [0.15 0.15 0.1 0.1];
% 
% X = input('Independent variable (size): ');
% xAxis = input('Independent variable axis title: ','s');
% Y = input('Dependent variable (time): ');
% yAxis = input('Dependent variable (time) axis title: ','s');
% Z = input('Dependent variable (later size - initial size): ');
% zAxis = input('Dependent variable (growth) axis title: ','s');
% 
% %Eliminates NaNs and restricts to cells with all positive values
% %That means only cells that grew during G1 or entire cycle
% Xclean = X(X > 0 & Y > 0 & Z > 0);
% Yclean = Y(X > 0 & Y > 0 & Z > 0);
% Zclean = Z(X > 0 & Y > 0 & Z > 0);
% 
% figure ('Name', [yAxis ' vs ' xAxis])
% hold on
% scatter(Xclean,Yclean)
% %This fit is plottable
% fit1 = polyfit(Xclean,Yclean,1)
% lm1 = fitlm(Xclean,Yclean)
% lm = lm1;
% disp(sprintf('\n'));
% domainXclean = linspace(0,max(Xclean),100);
% plot(domainXclean,polyval(fit1,domainXclean))
% axis([0 inf 0 inf])
% xlabel(xAxis)
% ylabel(yAxis)
% lm_r2 = lm.Rsquared.Ordinary;
% lm_pValue = lm.Coefficients.pValue(2);
% lm_slope = lm.Coefficients.Estimate(2);
% str1 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
% if (lm.Coefficients.Estimate(2) > 0)
%     dim = dimTopLeft;
% else
%     dim = dimBottomLeft;
% end
% annotation('textbox',dim,'String',str1,'FitBoxToText','on');
% hold off
% 
% figure ('Name', [zAxis ' vs ' xAxis])
% hold on
% scatter(Xclean,Zclean)
% %This fit is plottable
% fit2 = polyfit(Xclean,Zclean,1)
% lm2 = fitlm(Xclean,Zclean)
% lm = lm2;
% disp(sprintf('\n'));
% plot(domainXclean,polyval(fit2,domainXclean))
% axis([0 inf 0 inf])
% xlabel(xAxis)
% ylabel(zAxis)
% lm_r2 = lm.Rsquared.Ordinary;
% lm_pValue = lm.Coefficients.pValue(2);
% lm_slope = lm.Coefficients.Estimate(2);
% str2 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
% if (lm.Coefficients.Estimate(2) > 0)
%     dim = dimTopLeft;
% else
%     dim = dimBottomLeft;
% end
% annotation('textbox',dim,'String',str2,'FitBoxToText','on');
% hold off
% 
% 
% yAxisCutoff = input('Maximum relevant length: ');
% figure ('Name' , [yAxis ' < ' num2str(yAxisCutoff) ' vs ' xAxis])
% hold on
% Xcleaner = Xclean(Yclean<yAxisCutoff);
% Ycleaner = Yclean(Yclean<yAxisCutoff);
% scatter(Xcleaner,Ycleaner)
% fit3 = polyfit(Xcleaner,Ycleaner,1);
% lm3 = fitlm(Xcleaner,Ycleaner)
% lm = lm3;
% disp(sprintf('\n'));
% domainXcleaner = linspace(0,max(Xcleaner),100);
% plot(domainXcleaner,polyval(fit3,domainXcleaner))
% axis([0 inf 0 inf])
% xlabel(xAxis)
% ylabel(yAxis)
% lm_r2 = lm.Rsquared.Ordinary;
% lm_pValue = lm.Coefficients.pValue(2);
% lm_slope = lm.Coefficients.Estimate(2);
% str3 = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
% if (lm.Coefficients.Estimate(2) > 0)
%     dim = dimTopLeft;
% else
%     dim = dimBottomLeft;
% end
% annotation('textbox',dim,'String',str3,'FitBoxToText','on');
% hold off
% 
% 

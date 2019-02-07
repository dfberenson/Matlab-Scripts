
X = [1:100]';
Y = zeros(1,100)';
Y([5,16,37,50,54,60,65,67,72,75,78,81,84,87,90,91,93,94,97]) = 1;

X = [1:1000]';
Y = zeros(1,1000)';
Y([50,160,370,500,540,600,650,670,720,750,780,810,840,870,900,910,930,940,970]) = 1;

X = [1:10000]';
Y = zeros(1,10000)';
Y([500,1600,3700,5000,5400,6000,6500,6700,7200,7500,7800,8100,8400,8700,9000,9100,9300,9400,9700]) = 1;

fitglm(X,Y,'Distribution','binomial')


fitlm(X,Y)
[b,dev,stats] = glmfit(X,Y,'binomial');
stats.p
bin_discrete_outcomes_with_logit(X,Y);



% 
% 
% 
% 
% 
% 
% 
% imstack = readStack('E:\DFB_imaging_experiments\DFB_180905_HMEC_1G_CFSE_1\OneCell.tif');
% % imstack = readStack('E:\DFB_imaging_experiments\DFB_181028_HMEC_1E_CFSE_1\OneCell.tif');
% 
% [Y,X,C] = size(imstack);
% 
% im_phase = imstack(:,:,1);
% im_CFSE = imstack(:,:,2);
% im_mCherry = imstack(:,:,3);
% gaussian_filtered_mCherry = imgaussfilt(im_mCherry,gaussian_width);
% 
% minimum = min(gaussian_filtered_mCherry(:));
% maximum = max(gaussian_filtered_mCherry(:));
% 
% adjusted = double(gaussian_filtered_mCherry - minimum) / double(maximum - minimum);
% graythresh(adjusted) * double(maximum-minimum) + double(minimum)
% 
% otsu = graythresh(double(gaussian_filtered_mCherry) / double(max(gaussian_filtered_mCherry(:)))) * double(max(gaussian_filtered_mCherry(:)));
% 
% % 
% % x = rand(1000,1);
% % y = rand(1000,1);
% % scatter(x,y)
% % f1 = fitlm(x,y,'Intercept',true);
% % disp(['The R2 value for unforced fit is ' num2str(f1.Rsquared.Ordinary)])
% % f2 = fitlm(x,y,'Intercept',false);
% % disp(['The R2 value for forced fit is ' num2str(f2.Rsquared.Ordinary)])
% 
% 
% 
% % expt_length = 1000000
% % 
% % dredge = zeros(expt_length,1);
% % rip = zeros(expt_length,1);
% % 
% % dredge(1) = 100;
% % 
% % for t = 2:expt_length
% %     d_dredge = -0.1*rip(t-1)/(rip(t-1)+100);
% %     d_rip = 0.1*dredge(t-1)/(dredge(t-1)+100);
% %     dredge(t) = dredge(t-1) + d_dredge;
% %     rip(t) = rip(t-1) + d_rip;
% % end
% % 
% % yyaxis left
% % plot(dredge)
% % yyaxis right
% % plot(rip)
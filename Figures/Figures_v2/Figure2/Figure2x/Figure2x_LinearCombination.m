
clear all
close all


load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1.mat');

raw_X = all_mcherry_areas .^ 1.5;
x_axis_label = 'Nuclear volume';
raw_Y = all_mcherry_flat_integratedintensities_minusbackground;
y_axis_label = 'prEF1a-mCherry-NLS';
raw_Z = all_cfse_flat_integratedintensities_minusbackground;;
z_axis_label = 'CFSE';


% Try to isolate only single cells
min_CFSE_obj_area = 500;
max_CFSE_obj_area = 1500;
objs_with_CFSE_area_within_range = all_cfse_areas < max_CFSE_obj_area & all_cfse_areas > min_CFSE_obj_area;

X = raw_X(objs_with_CFSE_area_within_range);
Y = raw_Y(objs_with_CFSE_area_within_range);
Z = raw_Z(objs_with_CFSE_area_within_range);

X = X / median(X);
Y = Y / median(Y);
Z = Z / median(Z);

%A new linear fit
%This fit provides statistics like R^2
linearfit = fitlm([X,Y],Z,'Intercept',false)
linearfit_r2 = linearfit.Rsquared.Ordinary;
linearfit_pValue = linearfit.Coefficients.pValue(2);
linearfit_slope = linearfit.Coefficients.Estimate(2);
disp(sprintf('\n'));
disp(['R^2 = ' num2str(linearfit_r2)])

figure
hold on
scatter3(X,Y,Z)
xlabel(x_axis_label)
ylabel(y_axis_label)
zlabel(z_axis_label)
hold off
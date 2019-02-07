
clear all
close all


load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1.mat');

raw_X = all_cfse_flat_integratedintensities_minusbackground;;
x_axis_label = 'CFSE';
raw_Y = all_mcherry_flat_integratedintensities_minusbackground;
y_axis_label = 'prEF1a-mCherry-NLS';

% Try to isolate only single cells
min_CFSE_obj_area = 500;
max_CFSE_obj_area = 1500;
objs_with_CFSE_area_within_range = all_cfse_areas < max_CFSE_obj_area & all_cfse_areas > min_CFSE_obj_area;

X = raw_X(objs_with_CFSE_area_within_range);
Y = raw_Y(objs_with_CFSE_area_within_range);

figure
hold on
qqplot(X,Y)
axis([0 inf 0 inf])
xlabel(x_axis_label)
ylabel(y_axis_label)
hold off
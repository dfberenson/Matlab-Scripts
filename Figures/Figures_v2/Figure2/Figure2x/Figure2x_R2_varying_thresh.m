

clear all
close all

% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

r2_vals = struct;

for i = 1:length(possible_mCherry_thresholds)
    
    cfse_areas = data_at_each_thresh(i).all_cfse_areas;
    % Try to isolate only single cells
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 1500;
    objs_with_CFSE_area_within_range = cfse_areas < max_CFSE_obj_area & cfse_areas > min_CFSE_obj_area;
    
    nuclear_volumes = data_at_each_thresh(i).all_mcherry_areas .^ 1.5;
    mcherry_intensity = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
    cfse_intensity = data_at_each_thresh(i).all_cfse_flat_integratedintensities_minusbackground;
    
%     mcherry_mean_intensities = mcherry_intensity ./ data_at_each_thresh(i).all_mcherry_areas;
%     mcherry_mean_intensities = mcherry_mean_intensities(~isnan(mcherry_mean_intensities));
%     
%     mean_nuclear_volumes(i) = mean(nuclear_volumes);
%     mean_mcherry_intensities(i) = mean(mcherry_intensity);
%     mean_cfse_intensities(i) = mean(cfse_intensity);
%     mean_mcherry_mean_intensities(i) = mean(mcherry_mean_intensities);
%     stdev_mcherry_mean_intensities(i) = std(mcherry_mean_intensities);
    
    fit1 = fitlm(nuclear_volumes(objs_with_CFSE_area_within_range),cfse_intensity(objs_with_CFSE_area_within_range),'Intercept',false);
    fit2 = fitlm(nuclear_volumes(objs_with_CFSE_area_within_range),mcherry_intensity(objs_with_CFSE_area_within_range),'Intercept',false);
    fit3 = fitlm(cfse_intensity(objs_with_CFSE_area_within_range),mcherry_intensity(objs_with_CFSE_area_within_range),'Intercept',false);
    fit4 = fitlm(mcherry_intensity(objs_with_CFSE_area_within_range),cfse_intensity(objs_with_CFSE_area_within_range),'Intercept',false);

    
    r2_vals.nuclear_volume_vs_cfse_intensity(i) = fit1.Rsquared.Ordinary;
    r2_vals.nuclear_volume_vs_mcherry_intensity(i) = fit2.Rsquared.Ordinary;
    r2_vals.cfse_intensity_vs_mcherry_intensity(i) = fit3.Rsquared.Ordinary;
    r2_vals.mcherry_intensity_vs_cfse_intensity(i) = fit4.Rsquared.Ordinary;

end

% 
% figure
% hold on
% plot(possible_mCherry_thresholds,mean_nuclear_volumes)
% plot(possible_mCherry_thresholds,mean_mcherry_intensities)
% plot(possible_mCherry_thresholds,mean_mcherry_mean_intensities*100)
% hold off
% 
% figure
% plot(stdev_mcherry_mean_intensities)

figure
hold on
plot(possible_mCherry_thresholds,r2_vals.nuclear_volume_vs_cfse_intensity)
plot(possible_mCherry_thresholds,r2_vals.mcherry_intensity_vs_cfse_intensity)
axis([-inf inf 0.5 1])
xlabel('Segmentation threshold')
ylabel('R^2 value')
legend('Nuclear volume vs CFSE','prEF1a-mCherry-NLS vs CFSE')
hold off


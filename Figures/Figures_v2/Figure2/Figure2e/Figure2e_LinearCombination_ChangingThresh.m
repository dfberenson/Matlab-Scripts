

clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

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
    
    normalized_nuclear_volumes = nuclear_volumes(objs_with_CFSE_area_within_range) / mean(nuclear_volumes(objs_with_CFSE_area_within_range));
    normalized_mcherry_intensity = mcherry_intensity(objs_with_CFSE_area_within_range) / mean(mcherry_intensity(objs_with_CFSE_area_within_range));
    normalized_cfse_intensity = cfse_intensity(objs_with_CFSE_area_within_range) / mean(cfse_intensity(objs_with_CFSE_area_within_range));
    
    fit1 = fitlm(nuclear_volumes(objs_with_CFSE_area_within_range),cfse_intensity(objs_with_CFSE_area_within_range));
    fit4 = fitlm(mcherry_intensity(objs_with_CFSE_area_within_range),cfse_intensity(objs_with_CFSE_area_within_range));    
    fit_linearcombo = fitlm([normalized_nuclear_volumes,normalized_mcherry_intensity],normalized_cfse_intensity);
    
    r2_vals.nuclear_volume_vs_cfse_intensity(i) = fit1.Rsquared.Ordinary;
    r2_vals.mcherry_intensity_vs_cfse_intensity(i) = fit4.Rsquared.Ordinary;
    r2_vals.linearcombo(i) = fit_linearcombo.Rsquared.Ordinary;
    slope_wrt_nuc_vol(i) = fit_linearcombo.Coefficients.Estimate(1);
    slope_wrt_mcherry(i) = fit_linearcombo.Coefficients.Estimate(2);
end


figure
hold on
plot(possible_mCherry_thresholds,r2_vals.nuclear_volume_vs_cfse_intensity)
plot(possible_mCherry_thresholds,r2_vals.mcherry_intensity_vs_cfse_intensity)
plot(possible_mCherry_thresholds, r2_vals.linearcombo)
axis([-inf inf 0.3 0.7])
xlabel('Segmentation threshold')
ylabel('R^2 value')
legend('Nuclear volume vs CFSE','prEF1a-mCherry-NLS vs CFSE','Combination vs CFSE')
hold off

figure
hold on
plot(possible_mCherry_thresholds, slope_wrt_nuc_vol)
plot(possible_mCherry_thresholds, slope_wrt_mcherry)
ylabel('Regression coefficient')
legend('Nuclear volume','prEF1a-mCherry-NLS','Location','E')
xlabel('Segmentation threshold')
hold off

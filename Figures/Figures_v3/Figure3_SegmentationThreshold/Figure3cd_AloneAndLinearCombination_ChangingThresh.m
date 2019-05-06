
%% Without error bars

clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

r2_vals = struct;

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    
    cfse_areas = data_at_each_thresh(i).all_cfse_areas;
    % Try to isolate only single cells
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 1500;
    objs_with_CFSE_area_within_range = cfse_areas < max_CFSE_obj_area & cfse_areas > min_CFSE_obj_area;
    
    nuclear_volumes = data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    mcherry_intensity = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
    cfse_intensity = data_at_each_thresh(i).all_cfse_flat_integratedintensities_minusbackground;
    
    %     mcherry_mean_intensities = mcherry_intensity ./ data_at_each_thresh(i).all_mcherry_areas;
    %     mcherry_mean_intensities = mcherry_mean_intensities(~isnan(mcherry_mean_intensities));
    %
    
    normalized_nuclear_volumes = nuclear_volumes(objs_with_CFSE_area_within_range) / mean(nuclear_volumes(objs_with_CFSE_area_within_range));
    normalized_mcherry_intensity = mcherry_intensity(objs_with_CFSE_area_within_range) / mean(mcherry_intensity(objs_with_CFSE_area_within_range));
    normalized_cfse_intensity = cfse_intensity(objs_with_CFSE_area_within_range) / mean(cfse_intensity(objs_with_CFSE_area_within_range));
    
    fit1 = fitlm(normalized_nuclear_volumes,normalized_cfse_intensity);
    fit4 = fitlm(normalized_mcherry_intensity,normalized_cfse_intensity);
    fit_linearcombo = fitlm([normalized_nuclear_volumes,normalized_mcherry_intensity],normalized_cfse_intensity);
    
    r2_vals.nuclear_volume_vs_cfse_intensity(i) = fit1.Rsquared.Ordinary;
    r2_vals.mcherry_intensity_vs_cfse_intensity(i) = fit4.Rsquared.Ordinary;
    r2_vals.linearcombo(i) = fit_linearcombo.Rsquared.Ordinary;
    slope_wrt_nuc_vol(i) = fit_linearcombo.Coefficients.Estimate(2);
    slope_wrt_mcherry(i) = fit_linearcombo.Coefficients.Estimate(3);
end

figure
box on
hold on
plot(possible_mCherry_thresholds, slope_wrt_nuc_vol,'--k')
plot(possible_mCherry_thresholds, slope_wrt_mcherry,'-r')
ylabel('Regression coefficient')
% legend('Nuclear volume','prEF1a-mCherry-NLS','Location','E')
xlabel('Segmentation threshold')
axis([-inf inf 0 0.7],'square')
xticks([120 150 180 210 240 270 300])
ax = gca();
ax.FontSize = 16;
hold off


figure
box on
hold on
plot(possible_mCherry_thresholds,r2_vals.nuclear_volume_vs_cfse_intensity,'--k')
plot(possible_mCherry_thresholds,r2_vals.mcherry_intensity_vs_cfse_intensity,'-r')
plot(possible_mCherry_thresholds, r2_vals.linearcombo,'-b')
axis([-inf inf 0 0.7],'square')
xlabel('Segmentation threshold')
ylabel('R2 value')
xticks([120 150 180 210 240 270 300])
ax = gca();
ax.FontSize = 16;
% legend('Nuclear volume vs CFSE','prEF1a-mCherry-NLS vs CFSE','Combination vs CFSE')
hold off



%% With error bars

clear all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

r2_vals = struct;

volume_power = 1.5;
times_to_bootstrap = 1000;

for i = 1:length(possible_mCherry_thresholds)
    
    cfse_areas = data_at_each_thresh(i).all_cfse_areas;
    % Try to isolate only single cells
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 1500;
    objs_with_CFSE_area_within_range = cfse_areas < max_CFSE_obj_area & cfse_areas > min_CFSE_obj_area;
    num_objs = sum(objs_with_CFSE_area_within_range);
    
    nuclear_volumes = data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    mcherry_intensity = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
    cfse_intensity = data_at_each_thresh(i).all_cfse_flat_integratedintensities_minusbackground;
    
    %     mcherry_mean_intensities = mcherry_intensity ./ data_at_each_thresh(i).all_mcherry_areas;
    %     mcherry_mean_intensities = mcherry_mean_intensities(~isnan(mcherry_mean_intensities));
    %
    
    normalized_nuclear_volumes = nuclear_volumes(objs_with_CFSE_area_within_range) / mean(nuclear_volumes(objs_with_CFSE_area_within_range));
    normalized_mcherry_intensity = mcherry_intensity(objs_with_CFSE_area_within_range) / mean(mcherry_intensity(objs_with_CFSE_area_within_range));
    normalized_cfse_intensity = cfse_intensity(objs_with_CFSE_area_within_range) / mean(cfse_intensity(objs_with_CFSE_area_within_range));
        
    for b = 1:times_to_bootstrap
        disp(num2str(b))
        [normalized_nuclear_volumes_bootstrapped,idx] = datasample(normalized_nuclear_volumes,length(normalized_nuclear_volumes));
        normalized_mcherry_intensity_bootstrapped = normalized_mcherry_intensity(idx);
        normalized_cfse_intensity_bootstrapped = normalized_cfse_intensity(idx);
    
    fit1 = fitlm(normalized_nuclear_volumes_bootstrapped,normalized_cfse_intensity_bootstrapped);
    fit4 = fitlm(normalized_mcherry_intensity_bootstrapped,normalized_cfse_intensity_bootstrapped);
    fit_linearcombo = fitlm([normalized_nuclear_volumes_bootstrapped,normalized_mcherry_intensity_bootstrapped],normalized_cfse_intensity_bootstrapped);
    
    thisthresh_r2_nucvol_vs_cfse(b) = fit1.Rsquared.Ordinary;
    thisthresh_r2_mcherry_vs_cfse(b) = fit4.Rsquared.Ordinary;
    thisthresh_r2_linearcombo(b) = fit_linearcombo.Rsquared.Ordinary;
    thisthresh_slope_wrt_nucvol(b) = fit_linearcombo.Coefficients.Estimate(2);
    thisthresh_slope_wrt_mcherry(b) = fit_linearcombo.Coefficients.Estimate(3);
    end
    
    fit1 = fitlm(normalized_nuclear_volumes,normalized_cfse_intensity);
    fit4 = fitlm(normalized_mcherry_intensity,normalized_cfse_intensity);
    fit_linearcombo = fitlm([normalized_nuclear_volumes,normalized_mcherry_intensity],normalized_cfse_intensity);
    
    r2_vals.nuclear_volume_vs_cfse_intensity(i) = fit1.Rsquared.Ordinary;
    r2_vals.mcherry_intensity_vs_cfse_intensity(i) = fit4.Rsquared.Ordinary;
    r2_vals.linearcombo(i) = fit_linearcombo.Rsquared.Ordinary;
    slope_wrt_nuc_vol(i) = fit_linearcombo.Coefficients.Estimate(2);
    slope_wrt_mcherry(i) = fit_linearcombo.Coefficients.Estimate(3);
    
    r2_vals_uperror.nuclear_volume_vs_cfse_intensity(i) = prctile(thisthresh_r2_nucvol_vs_cfse,95) - fit1.Rsquared.Ordinary;
    r2_vals_downerror.nuclear_volume_vs_cfse_intensity(i) = fit1.Rsquared.Ordinary - prctile(thisthresh_r2_nucvol_vs_cfse,5);
    
    r2_vals_uperror.mcherry_intensity_vs_cfse_intensity(i) = prctile(thisthresh_r2_mcherry_vs_cfse,95) - fit4.Rsquared.Ordinary;
    r2_vals_downerror.mcherry_intensity_vs_cfse_intensity(i) = fit4.Rsquared.Ordinary - prctile(thisthresh_r2_mcherry_vs_cfse,5);
    
    r2_vals_uperror.linearcombo(i) = prctile(thisthresh_r2_linearcombo,95) - fit_linearcombo.Rsquared.Ordinary;
    r2_vals_downerror.linearcombo(i) = fit_linearcombo.Rsquared.Ordinary - prctile(thisthresh_r2_linearcombo,5);
    
    slope_uperror_wrt_nuc_vol(i) = prctile(thisthresh_slope_wrt_nucvol,95) - fit_linearcombo.Coefficients.Estimate(2);
    slope_downerror_wrt_nuc_vol(i) = fit_linearcombo.Coefficients.Estimate(2) - prctile(thisthresh_slope_wrt_nucvol,5);
    
    slope_uperror_wrt_mcherry(i) = prctile(thisthresh_slope_wrt_mcherry,95) - fit_linearcombo.Coefficients.Estimate(3);
    slope_downerror_wrt_mcherry(i) = fit_linearcombo.Coefficients.Estimate(3) - prctile(thisthresh_slope_wrt_mcherry,5);
end

figure
box on
hold on
shadedErrorBar(possible_mCherry_thresholds, slope_wrt_nuc_vol, [slope_uperror_wrt_nuc_vol; slope_downerror_wrt_nuc_vol], '--k')
shadedErrorBar(possible_mCherry_thresholds, slope_wrt_mcherry, [slope_uperror_wrt_mcherry; slope_downerror_wrt_mcherry],'-r')
ylabel('Regression coefficient')
% legend('Nuclear volume','prEF1a-mCherry-NLS','Location','E')
xlabel('Segmentation threshold')
axis([-inf inf 0 0.7],'square')
xticks([120 150 180 210 240 270 300])
ax = gca();
ax.FontSize = 16;
hold off


figure
box on
hold on
shadedErrorBar(possible_mCherry_thresholds,r2_vals.nuclear_volume_vs_cfse_intensity, [r2_vals_uperror.nuclear_volume_vs_cfse_intensity; r2_vals_downerror.nuclear_volume_vs_cfse_intensity], '--k')
shadedErrorBar(possible_mCherry_thresholds,r2_vals.mcherry_intensity_vs_cfse_intensity, [r2_vals_uperror.mcherry_intensity_vs_cfse_intensity; r2_vals_downerror.mcherry_intensity_vs_cfse_intensity], '-r')
shadedErrorBar(possible_mCherry_thresholds, r2_vals.linearcombo, [r2_vals_uperror.linearcombo; r2_vals_downerror.linearcombo], '-b')
axis([-inf inf 0 0.7],'square')
xlabel('Segmentation threshold')
ylabel('R2 value')
xticks([120 150 180 210 240 270 300])
ax = gca();
ax.FontSize = 16;
% legend('Nuclear volume vs CFSE','prEF1a-mCherry-NLS vs CFSE','Combination vs CFSE')
hold off



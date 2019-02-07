

clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_areas_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_areas;
    all_mcherry_intintens_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
end

[num_cells,~] = size(all_mcherry_areas_wrt_segmentation);

% It looks v bad if I scale it to each cell's median rather than to each
% cell's value at thresh = 150

% cellwise_median_areas = median(all_mcherry_areas_wrt_segmentation,2);
% cellwise_median_intintens = median(all_mcherry_intintens_wrt_segmentation,2);

% scaled_area_measurements = all_mcherry_areas_wrt_segmentation ./ cellwise_median_areas;
% scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation ./ cellwise_median_intintens;

chosen_normal_thresh_num = 5;

areas_at_chosen_normal_thresh = all_mcherry_areas_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_mcherry_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

scaled_area_measurements = all_mcherry_areas_wrt_segmentation ./ areas_at_chosen_normal_thresh;
scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation ./ intintens_at_chosen_normal_thresh;

scaled_area_measurements(isinf(scaled_area_measurements)) = NaN;
scaled_intintens_measurements(isinf(scaled_intintens_measurements)) = NaN;

threshwise_mean_scaled_areas = nanmean(scaled_area_measurements,1);
threshwise_mean_scaled_intintens = nanmean(scaled_intintens_measurements,1);
threshwise_stdev_scaled_areas = nanstd(scaled_area_measurements,1);
threshwise_stdev_scaled_intintens = nanstd(scaled_intintens_measurements,1);
threshwise_stderr_scaled_areas = threshwise_stdev_scaled_areas / sqrt(num_cells);
threshwise_stderr_scaled_intintens = threshwise_stdev_scaled_intintens /sqrt(num_cells);

% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_areas,threshwise_stdev_scaled_areas,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m');
%
%
% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_areas,threshwise_stderr_scaled_areas,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');

figure
hold on
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_areas,threshwise_stdev_scaled_areas,'k',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_areas,threshwise_stderr_scaled_areas,'k');
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');
h = findobj(gca,'Type','line');
legend([h(7),h(1)],'Nuclear Volume','prEF1a-mCherry-NLS')
xlabel('Segmentation threshold')
ylabel('Relative measurement value')
axis([-inf inf 0 inf])
hold off


%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_areas_wrt_segmentation(j,:) / areas_at_thresh_5(j))
% end
%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_intintens_wrt_segmentation(j,:) / intintens_at_thresh_5(j))
% end
%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_areas_wrt_segmentation(j,:) / cellwise_mean_areas(j))
% end
%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_intintens_wrt_segmentation(j,:) / cellwise_mean_intintens(j))
% end
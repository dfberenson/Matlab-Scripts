
clear all
close all

%% Scale each cell wrt to its own measurement at chosen normal threshold

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_volumes_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
end

[num_cells,~] = size(all_mcherry_volumes_wrt_segmentation);

chosen_normal_thresh_num = 9;

volumes_at_chosen_normal_thresh = all_mcherry_volumes_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_mcherry_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

% Scale each cell to its own measurement at chosen_normal_thresh_num (=180)
scaled_volume_measurements = all_mcherry_volumes_wrt_segmentation ./ volumes_at_chosen_normal_thresh;
scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation ./ intintens_at_chosen_normal_thresh;

scaled_volume_measurements(isinf(scaled_volume_measurements)) = NaN;
scaled_intintens_measurements(isinf(scaled_intintens_measurements)) = NaN;

threshwise_mean_scaled_volumes = nanmean(scaled_volume_measurements,1);
threshwise_mean_scaled_intintens = nanmean(scaled_intintens_measurements,1);
threshwise_stdev_scaled_volumes = nanstd(scaled_volume_measurements,1);
threshwise_stdev_scaled_intintens = nanstd(scaled_intintens_measurements,1);
threshwise_stderr_scaled_volumes = threshwise_stdev_scaled_volumes / sqrt(num_cells);
threshwise_stderr_scaled_intintens = threshwise_stdev_scaled_intintens /sqrt(num_cells);

% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m');
%
%
% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');

figure
box on
hold on
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');
h = findobj(gca,'Type','line');
% legend([h(7),h(1)],'Nuclear Volume','prEF1a-mCherry-NLS')
xlabel('Segmentation threshold')
ylabel('Relative measurement value')
xticks([120 180 240 300])
axis([-inf inf 0 inf],'square')
hold off


%% Scale each cell to the mean value at chosen normal threshold

clear all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')
% load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_181028_HMEC_1E_CFSE_1_ChangingThresh.mat')

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_volumes_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
end

[num_cells,~] = size(all_mcherry_volumes_wrt_segmentation);

chosen_normal_thresh_num = 9;


volumes_at_chosen_normal_thresh = all_mcherry_volumes_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_mcherry_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

% Scale each cell to all cells' median at chosen_normal_thresh_num (=180)
scaled_volume_measurements = all_mcherry_volumes_wrt_segmentation / mean(volumes_at_chosen_normal_thresh);
scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation / mean(intintens_at_chosen_normal_thresh);

scaled_volume_measurements(isinf(scaled_volume_measurements)) = NaN;
scaled_intintens_measurements(isinf(scaled_intintens_measurements)) = NaN;

threshwise_mean_scaled_volumes = nanmean(scaled_volume_measurements,1);
threshwise_mean_scaled_intintens = nanmean(scaled_intintens_measurements,1);
threshwise_stdev_scaled_volumes = nanstd(scaled_volume_measurements,1);
threshwise_stdev_scaled_intintens = nanstd(scaled_intintens_measurements,1);
threshwise_stderr_scaled_volumes = threshwise_stdev_scaled_volumes / sqrt(num_cells);
threshwise_stderr_scaled_intintens = threshwise_stdev_scaled_intintens /sqrt(num_cells);

% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m');
%
%
% figure
% hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');

figure
box on
hold on
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m',1);
shadedErrorBar(possible_mCherry_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');
h = findobj(gca,'Type','line');
% legend([h(7),h(1)],'Nuclear Volume','prEF1a-mCherry-NLS')
xlabel('Segmentation threshold')
ylabel('Relative measurement value')
xticks([120 180 240 300])
yticks([0 1 2])
axis([-inf inf 0 inf],'square')
ax = gca();
ax.FontSize = 16;
hold off





%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_volumes_wrt_segmentation(j,:) / volumes_at_thresh_5(j))
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
% plot(all_mcherry_volumes_wrt_segmentation(j,:) / cellwise_mean_volumes(j))
% end
%
% figure
% hold on
% for j = 1:379
% plot(all_mcherry_intintens_wrt_segmentation(j,:) / cellwise_mean_intintens(j))
% end
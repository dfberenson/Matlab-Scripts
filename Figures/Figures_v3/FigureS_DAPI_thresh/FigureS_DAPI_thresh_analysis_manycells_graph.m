%Scale each cell to the mean value at chosen normal threshold

%% mCherry segmentation and intensity

clear all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_190426_HMEC_1G_DAPI_2_ChangingThresh.mat');

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_volumes_wrt_segmentation(:,i) = mCherry_data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = mCherry_data_at_each_thresh(i).all_mcherry_flat_integrated_intensities_minusbackground;
end

[num_cells,~] = size(all_mcherry_volumes_wrt_segmentation);

chosen_normal_thresh_num = 11;


volumes_at_chosen_normal_thresh = all_mcherry_volumes_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_mcherry_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

% Scale each cell to all cells' median at chosen_normal_thresh_num (=180)
scaled_volume_measurements = all_mcherry_volumes_wrt_segmentation / nanmean(volumes_at_chosen_normal_thresh);
scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation / nanmean(intintens_at_chosen_normal_thresh);

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
yticks([0 1 2 3])
axis([-inf inf 0 3],'square')
ax = gca();
ax.FontSize = 16;
hold off

%% DAPI segmentation and intensity

clear all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_190426_HMEC_1G_DAPI_2_ChangingThresh.mat');

volume_power = 1.5;

for i = 1:length(possible_DAPI_thresholds)
    all_DAPI_volumes_wrt_segmentation(:,i) = DAPI_data_at_each_thresh(i).all_DAPI_areas .^ volume_power;
    all_DAPI_intintens_wrt_segmentation(:,i) = DAPI_data_at_each_thresh(i).all_DAPI_flat_integratedintensities_minusbackground;
end

[num_cells,~] = size(all_DAPI_volumes_wrt_segmentation);

chosen_normal_thresh_num = 13;


volumes_at_chosen_normal_thresh = all_DAPI_volumes_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_DAPI_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

% Scale each cell to all cells' median at chosen_normal_thresh_num (=180)
scaled_volume_measurements = all_DAPI_volumes_wrt_segmentation / nanmean(volumes_at_chosen_normal_thresh);
scaled_intintens_measurements = all_DAPI_intintens_wrt_segmentation / nanmean(intintens_at_chosen_normal_thresh);

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
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m');
%
%
% figure
% hold on
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');

figure
box on
hold on
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k',1);
shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m',1);
shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'b');
h = findobj(gca,'Type','line');
% legend([h(7),h(1)],'Nuclear Volume','prEF1a-DAPI-NLS')
xlabel('Segmentation threshold')
ylabel('Relative measurement value')
% xticks([120 180 240 300])
yticks([0 1 2 3])
axis([-inf inf 0 3],'square')
ax = gca();
ax.FontSize = 16;
hold off

%% DAPI segmentation and mCherry intensity

clear all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_190426_HMEC_1G_DAPI_2_ChangingThresh.mat');

volume_power = 1.5;

for i = 1:length(possible_DAPI_thresholds)
    all_DAPI_volumes_wrt_segmentation(:,i) = DAPI_data_at_each_thresh(i).all_DAPI_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = mCherry_data_from_DAPI_segmentation_at_each_thresh(i).all_mcherry_flat_integrated_intensities_from_DAPI_segmentation;
end

[num_cells,~] = size(all_DAPI_volumes_wrt_segmentation);

chosen_normal_thresh_num = 13;


volumes_at_chosen_normal_thresh = all_DAPI_volumes_wrt_segmentation(:,chosen_normal_thresh_num);
intintens_at_chosen_normal_thresh = all_mcherry_intintens_wrt_segmentation(:,chosen_normal_thresh_num);

% Scale each cell to all cells' median at chosen_normal_thresh_num (=180)
scaled_volume_measurements = all_DAPI_volumes_wrt_segmentation / nanmean(volumes_at_chosen_normal_thresh);
scaled_intintens_measurements = all_mcherry_intintens_wrt_segmentation / nanmean(intintens_at_chosen_normal_thresh);

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
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m');
%
%
% figure
% hold on
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');

figure
box on
hold on
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stdev_scaled_volumes,'k',1);
shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_volumes,threshwise_stderr_scaled_volumes,'k');
% shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stdev_scaled_intintens,'m',1);
shadedErrorBar(possible_DAPI_thresholds,threshwise_mean_scaled_intintens,threshwise_stderr_scaled_intintens,'r');
h = findobj(gca,'Type','line');
% legend([h(7),h(1)],'Nuclear Volume','prEF1a-DAPI-NLS')
xlabel('Segmentation threshold')
ylabel('Relative measurement value')
% xticks([120 180 240 300])
yticks([0 1 2 3])
axis([-inf inf 0 3],'square')
ax = gca();
ax.FontSize = 16;
hold off
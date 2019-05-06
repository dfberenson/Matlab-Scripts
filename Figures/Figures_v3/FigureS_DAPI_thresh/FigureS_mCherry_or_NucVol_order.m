
%% For mCherry and nuclear volume only

clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_180905_HMEC_1G_CFSE_1_ChangingThresh.mat')

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_volumes_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = data_at_each_thresh(i).all_mcherry_flat_integratedintensities_minusbackground;
end

% [sorted_volumes, vol_sort_idx] = sort(all_mcherry_volumes_wrt_segmentation);
% [sorted_intintens, intintens_sort_idx] = sort(all_mcherry_intintens_wrt_segmentation);

vol_tau = corr(all_mcherry_volumes_wrt_segmentation,'type','Kendall');
intintens_tau = corr(all_mcherry_intintens_wrt_segmentation,'type','Kendall');

(sum(vol_tau(:)) - length(possible_mCherry_thresholds)) / (length(possible_mCherry_thresholds)^2 - length(possible_mCherry_thresholds))
(sum(intintens_tau(:)) - length(possible_mCherry_thresholds)) / (length(possible_mCherry_thresholds)^2 - length(possible_mCherry_thresholds))

%% For mCherry and nuclear volume and DAPI and nuclear volume

clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\DFB_190426_HMEC_1G_DAPI_2_ChangingThresh.mat');

volume_power = 1.5;

for i = 1:length(possible_mCherry_thresholds)
    all_mcherry_volumes_wrt_segmentation(:,i) = mCherry_data_at_each_thresh(i).all_mcherry_areas .^ volume_power;
    all_mcherry_intintens_wrt_segmentation(:,i) = mCherry_data_at_each_thresh(i).all_mcherry_flat_integrated_intensities_minusbackground;
end

[nan_mcherry_rows,~] = find(isnan(all_mcherry_volumes_wrt_segmentation));
nan_mcherry_rows = unique(nan_mcherry_rows);

for i = 1:length(possible_DAPI_thresholds)
    all_DAPI_volumes_wrt_segmentation(:,i) = DAPI_data_at_each_thresh(i).all_DAPI_areas .^ volume_power;
    all_DAPI_intintens_wrt_segmentation(:,i) = DAPI_data_at_each_thresh(i).all_DAPI_flat_integratedintensities_minusbackground;
end

[nan_DAPI_rows,~] = find(isnan(all_DAPI_volumes_wrt_segmentation));
nan_DAPI_rows = unique(nan_DAPI_rows);

nan_rows = unique([nan_mcherry_rows; nan_DAPI_rows]);

all_good_mcherry_volumes_wrt_segmentation = all_mcherry_volumes_wrt_segmentation;
all_good_mcherry_volumes_wrt_segmentation(nan_rows,:) = [];
all_good_mcherry_intintens_wrt_segmentation = all_mcherry_intintens_wrt_segmentation;
all_good_mcherry_intintens_wrt_segmentation(nan_rows,:) = [];

all_good_DAPI_volumes_wrt_segmentation = all_DAPI_volumes_wrt_segmentation;
all_good_DAPI_volumes_wrt_segmentation(nan_rows,:) = [];
all_good_DAPI_intintens_wrt_segmentation = all_DAPI_intintens_wrt_segmentation;
all_good_DAPI_intintens_wrt_segmentation(nan_rows,:) = [];

% [sorted_mcherry_volumes, mcherry_vol_sort_idx] = sort(all_mcherry_volumes_wrt_segmentation);
% [sorted_mcherry_intintens, mcherry_intintens_sort_idx] = sort(all_mcherry_intintens_wrt_segmentation);
% 
% [sorted_DAPI_volumes, DAPI_vol_sort_idx] = sort(all_DAPI_volumes_wrt_segmentation);
% [sorted_DAPI_intintens, DAPI_intintens_sort_idx] = sort(all_DAPI_intintens_wrt_segmentation);

mcherry_vol_tau = corr(all_good_mcherry_volumes_wrt_segmentation,'type','Kendall');
mcherry_intintens_tau = corr(all_good_mcherry_intintens_wrt_segmentation,'type','Kendall');

(sum(mcherry_vol_tau(:)) - length(possible_mCherry_thresholds)) / (length(possible_mCherry_thresholds)^2 - length(possible_mCherry_thresholds))
(sum(mcherry_intintens_tau(:)) - length(possible_mCherry_thresholds)) / (length(possible_mCherry_thresholds)^2 - length(possible_mCherry_thresholds))

DAPI_vol_tau = corr(all_good_DAPI_volumes_wrt_segmentation,'type','Kendall');
DAPI_intintens_tau = corr(all_good_DAPI_intintens_wrt_segmentation,'type','Kendall');

(sum(DAPI_vol_tau(:)) - length(possible_DAPI_thresholds)) / (length(possible_DAPI_thresholds)^2 - length(possible_DAPI_thresholds))
(sum(DAPI_intintens_tau(:)) - length(possible_DAPI_thresholds)) / (length(possible_DAPI_thresholds)^2 - length(possible_DAPI_thresholds))

mcherry_cross_tau = corr(all_good_mcherry_volumes_wrt_segmentation, all_good_mcherry_intintens_wrt_segmentation, 'type', 'Kendall');
DAPI_cross_tau = corr(all_good_DAPI_volumes_wrt_segmentation, all_good_DAPI_intintens_wrt_segmentation, 'type', 'Kendall');

% Use the trace to sum down the diagonal
trace(mcherry_cross_tau) / length(possible_mCherry_thresholds)
trace(DAPI_cross_tau) / length(possible_DAPI_thresholds)

cross_vol_tau = corr(all_good_mcherry_volumes_wrt_segmentation, all_good_DAPI_volumes_wrt_segmentation, 'type', 'Kendall');
trace(cross_vol_tau) / length(possible_mCherry_thresholds)

cross_intens_tau = corr(all_good_mcherry_intintens_wrt_segmentation, all_good_DAPI_intintens_wrt_segmentation, 'type', 'Kendall');
trace(cross_intens_tau) / length(possible_mCherry_thresholds)

cross_mcherry_intens_DAPI_vol_tau = corr(all_good_mcherry_intintens_wrt_segmentation, all_good_DAPI_volumes_wrt_segmentation, 'type', 'Kendall');
trace(cross_mcherry_intens_DAPI_vol_tau) / length(possible_mCherry_thresholds)

cross_DAPI_intens_mcherry_vol_tau = corr(all_good_DAPI_intintens_wrt_segmentation, all_good_mcherry_volumes_wrt_segmentation, 'type', 'Kendall');
trace(cross_DAPI_intens_mcherry_vol_tau) / length(possible_mCherry_thresholds)

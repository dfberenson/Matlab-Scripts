
clear all
close all

num_channels = 3;
num_measurements = num_channels * 2;

tbl_with_fluor = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190212_190226_photobleaching.xlsx','Sheet','DFB_190212_HMEC_Rb-Clov_D5','ReadVariableNames',true);
intens_with_fluor = tbl_with_fluor.RawIntDen;

for i = 1 : length(intens_with_fluor) / num_measurements
    net_green_with_fluor(i) = intens_with_fluor(num_measurements*i-5) - intens_with_fluor(num_measurements*i-2);
    net_red_with_fluor(i) = intens_with_fluor(num_measurements*i-4) - intens_with_fluor(num_measurements*i-1);
    net_farred_with_fluor(i) = intens_with_fluor(num_measurements*i-3) - intens_with_fluor(num_measurements*i-0);
end

% figure
% hold on
% histogram(net_farred_with_fluor)

tbl_without_fluor = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190212_190226_photobleaching.xlsx','Sheet','DFB_190226_HMEC_1GFiii_D5','ReadVariableNames',true);
intens_without_fluor = tbl_without_fluor.RawIntDen;

for i = 1 : length(intens_without_fluor) / num_measurements
    net_green_without_fluor(i) = intens_without_fluor(num_measurements*i-5) - intens_without_fluor(num_measurements*i-2);
    net_red_without_fluor(i) = intens_without_fluor(num_measurements*i-4) - intens_without_fluor(num_measurements*i-1);
    net_farred_without_fluor(i) = intens_without_fluor(num_measurements*i-3) - intens_without_fluor(num_measurements*i-0);
end

% histogram(net_farred_without_fluor)

[h_after,p_after,ci_after,stats_after] = ttest2(net_farred_with_fluor,net_farred_without_fluor)

% figure
% hold on
% box on
% % ecdf(after_constantlight_intintens / median(before_constantlight_intintens))
% ecdf(net_farred_with_fluor / median(net_farred_with_fluor))
% ecdf(net_farred_without_fluor / median(net_farred_without_fluor))
% axis([0 5 0 1],'square')


mean_sizes_after = [mean(net_farred_with_fluor) mean(net_farred_without_fluor)];
stdev_sizes_after = [std(net_farred_with_fluor) std(net_farred_without_fluor)];
stderr_sizes_after = stdev_sizes_after ./ sqrt([length(net_farred_with_fluor) length(net_farred_without_fluor)]);

median_sizes_after = [median(net_farred_with_fluor) median(net_farred_without_fluor)];
first_quartile_after = [prctile(net_farred_with_fluor,25) prctile(net_farred_without_fluor, 25)];
third_quartile_after = [prctile(net_farred_with_fluor,75) prctile(net_farred_without_fluor, 75)];
diff_to_1q = median_sizes_after - first_quartile_after;
diff_to_3q = third_quartile_after - median_sizes_after;
asymmetric_errors = zeros(1,2,2);
asymmetric_errors(:,:,1) = diff_to_1q;
asymmetric_errors(:,:,2) = diff_to_3q;
% 
% figure
% hold on
% box on
% [bar,err] = barwitherr(stdev_sizes_after,mean_sizes_after,'k');
% bar.FaceColor = 'k';
% err.LineWidth = 2;
% err.CapSize = 40;
% axis([0.5 2.5 0 25000],'square')
% set(gca, 'XTick', [1 2])
% set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
% ylabel('prEF1a-E2-Crimson-NLS total intensity')
% yticks([0 10000 20000])
% hold off
% 
% figure
% hold on
% box on
% [bar,err] = barwitherr(stdev_sizes_after,median_sizes_after);
% bar.FaceColor = 'w';
% bar.LineWidth = 2;
% err.LineWidth = 2;
% err.Color = 'k';
% err.CapSize = 40;
% axis([0.5 2.5 0 25000],'square')
% set(gca, 'XTick', [1 2])
% set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
% ylabel('prEF1a-E2-Crimson-NLS total intensity')
% yticks([0 10000 20000])
% hold off


figure
hold on
box on
[bar,err] = barwitherr(asymmetric_errors,median_sizes_after,'k');
bar.FaceColor = 'w';
bar.LineWidth = 2;
err.LineWidth = 2;
err.Color = 'k';
err.CapSize = 40;
axis([0.5 2.5 0 25000],'square')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
ylabel('prEF1a-E2-Crimson-NLS total intensity')
yticks([0 10000 20000])
hold off

%% Automated segmentation attempt
% % The automated segmentation on these experiments (which were done with the phase objective,
% % not the nice objective) worked very poorly so instead I manually segmented.
% 
% clear all
% close all
% 
% expt_type = 'intermittent';
% 
% folder = 'H:\DFB_imaging_experiments_3';
% 
% if strcmp(expt_type,'intermittent')
%     expt = 'DFB_190212_HMEC_Rb-Clov_D5';
%     green_channel = 1;
% red_channel = 2;
% farred_channel = 3;
% elseif strcmp(expt_type,'dark')
%     expt = 'DFB_190226_HMEC_1GFiii_D5';
%     green_channel = 0;
% red_channel = 1;
% farred_channel = 2;
% end
% 
% farred_threshold = 450;
% 
% blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
% blank_field_mean = mean(blank_field(:));
% 
% % before_constantlight_intintens = [];
% % before_intermittentlight_intintens = [];
% before_nolight_intintens = [];
% % after_constantlight_intintens = [];
% % after_intermittentlight_intintens = [];
% after_nolight_intintens = [];
% 
% already_made_measurements = false;
% 
% if ~already_made_measurements
%     for pos = 11:12
%         
%         for time = {'before','after'}
%             
%             disp(['Analyzing position ' num2str(pos)])
%             %     if strcmp(time{1},'before')
%             %         imstack = readStack([folder '\' expt '_all\' expt '_before_1_MMStack_Pos' num2str(pos) '.ome.tif']);
%             %     elseif strcmp(time{1},'after')
%             %         imstack = readStack([folder '\' expt '_all\' expt '_after_1_MMStack_Pos' num2str(pos) '.ome.tif']);
%             %     end
%             if strcmp(expt_type,'intermittent')
%                 if strcmp(time{1},'before')
%                     im_green = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',green_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_red = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',red_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_farred = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',farred_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     
%                 elseif strcmp(time{1},'after')
%                     im_green = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',green_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',359) '_z' sprintf('%03d',0) '.tif']);
%                     im_red = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',red_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',359) '_z' sprintf('%03d',0) '.tif']);
%                     im_farred = imread([folder '\' expt '_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',farred_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',359) '_z' sprintf('%03d',0) '.tif']);
%                 end
%             elseif strcmp(expt_type,'dark')
%                 if strcmp(time{1},'before')
%                     im_green = imread([folder '\' expt ' all\' expt '_before_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',green_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_red = imread([folder '\' expt ' all\' expt '_before_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',red_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_farred = imread([folder '\' expt ' all\' expt '_before_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',farred_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                 elseif strcmp(time{1},'after')
%                     im_green = imread([folder '\' expt ' all\' expt '_after_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',green_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_red = imread([folder '\' expt ' all\' expt '_after_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',red_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                     im_farred = imread([folder '\' expt ' all\' expt '_after_1\Pos' num2str(pos) '\img_channel' sprintf('%03d',farred_channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',0) '_z' sprintf('%03d',0) '.tif']);
%                 end
%             end
%             [Y,X] = size(im_farred);
%             
%             raw_im_green = double(im_green);
%             raw_im_red = double(im_red);
%             raw_im_farred = double(im_farred);
%             
%             raw_im_red_mode = mode(raw_im_red(:));
%             raw_im_farred_mode = mode(raw_im_farred(:));
%             %     raw_im_green_mode = mode(raw_im_green(:));
%             % Can't just use the mode for green in a four-channel movie with
%             % Rb-Clover because the uneven background is overpowering. Instead use
%             % the darkfield value from the corners of the image.
%             raw_im_green_dark = 110;
%             
%             zeroed_im_red = raw_im_red - raw_im_red_mode;
%             zeroed_im_green = raw_im_green - raw_im_green_dark;
%             zeroed_im_farred = raw_im_farred - raw_im_farred_mode;
%             
%             flatfielded_im_red = zeroed_im_red * blank_field_mean ./ blank_field;
%             flatfielded_im_green = zeroed_im_green * blank_field_mean ./ blank_field;
%             flatfielded_im_farred = zeroed_im_farred * blank_field_mean ./ blank_field;
%             
%             
%             gaussian_width = 2;
%             strel_shape = 'disk';
%             strel_size = 3;
%             se = strel(strel_shape,strel_size);
%             
%             
%             %         figure()
%             gaussian_filtered_farred = imgaussfilt(raw_im_farred,gaussian_width);
%             %         imshow(gaussian_filtered_farred,[])
%             thresholded_farred = gaussian_filtered_farred > farred_threshold;
%             %     figure,imshow(thresholded_farred)
%             im_opened_farred = imopen(thresholded_farred,se);
%             %     figure,imshow(im_opened_farred)
%             im_closed_farred = imclose(im_opened_farred,se);
%             segmented_farred = im_closed_farred;
%             figure()
%             imshow(imoverlay_fast(im_farred*100, bwperim(segmented_farred), 'm'),[])
%             [farred_labels,num_objects_farred] = bwlabel(segmented_farred,4);
%             %
%             %             for c = 1:num_objects_farred
%             %
%             %                 thiscellmask = farred_labels == c;
%             %                 label_props = regionprops(thiscellmask,'Area','BoundingBox');
%             %
%             %
%             %                 % Expand bounding box in each direction to examine
%             %                 % local background.
%             %                 local_expansion = 100;
%             %
%             %                 boundingBox_vals = label_props.BoundingBox;
%             %                 x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
%             %                 x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
%             %                 y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
%             %                 y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
%             %
%             %                 boundingBox = segmented_farred(y_min:y_max, x_min:x_max);
%             %                 boundingBox_background_mask = boundingBox == 0;
%             %                 fullsize_im_local_background_mask = zeros(Y,X);
%             %                 fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
%             %
%             %                 red_raw_props = regionprops(thiscellmask,raw_im_red,'MeanIntensity');
%             %                 green_raw_props = regionprops(thiscellmask,raw_im_green,'MeanIntensity');
%             %                 red_flat_props = regionprops(thiscellmask,flatfielded_im_red,'MeanIntensity');
%             %                 green_flat_props = regionprops(thiscellmask,flatfielded_im_green,'MeanIntensity');
%             %                 farred_raw_props=  regionprops(thiscellmask,raw_im_farred,'MeanIntensity');
%             %                 farred_flat_props = regionprops(thiscellmask,flatfielded_im_farred,'MeanIntensity');
%             %
%             %                 red_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
%             %                 green_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
%             %                 red_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_red, 'MeanIntensity');
%             %                 green_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_green, 'MeanIntensity');
%             %                 farred_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_farred, 'MeanIntensity');
%             %                 farred_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_farred, 'MeanIntensity');
%             %
%             %                 areas(c) = label_props.Area;
%             %                 red_raw_integrated_intensity(c) = areas(c) * (red_raw_props.MeanIntensity - red_raw_background_props.MeanIntensity);
%             %                 green_raw_integrated_intensity(c) = areas(c) * (green_raw_props.MeanIntensity - green_raw_background_props.MeanIntensity);
%             %                 red_flat_integrated_intensity(c) = areas(c) * (red_flat_props.MeanIntensity - red_flat_background_props.MeanIntensity);
%             %                 green_flat_integrated_intensity(c) = areas(c) * (green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity);
%             %                 farred_raw_integrated_intensity(c) = areas(c) * (farred_raw_props.MeanIntensity - farred_raw_background_props.MeanIntensity);
%             %                 farred_flat_integrated_intensity(c) = areas(c) * (farred_flat_props.MeanIntensity - farred_flat_background_props.MeanIntensity);
%             %
%             %             end
%             %
%             %             if strcmp(time{1},'before')
%             %                 if ismember(pos,0:2)
%             %                     before_constantlight_intintens = [before_constantlight_intintens, farred_flat_integrated_intensity];
%             %                 elseif ismember(pos,3:5)
%             %                     before_intermittentlight_intintens = [before_intermittentlight_intintens, farred_flat_integrated_intensity];
%             %                 elseif ismember(pos,6:8)
%             %                     before_nolight_intintens = [before_nolight_intintens, farred_flat_integrated_intensity];
%             %                 end
%             %             elseif strcmp(time{1},'after')
%             %                 if ismember(pos,0:2)
%             %                     after_constantlight_intintens = [after_constantlight_intintens, farred_flat_integrated_intensity];
%             %                 elseif ismember(pos,3:5)
%             %                     after_intermittentlight_intintens = [after_intermittentlight_intintens, farred_flat_integrated_intensity];
%             %                 elseif ismember(pos,6:8)
%             %                     after_nolight_intintens = [after_nolight_intintens, farred_flat_integrated_intensity];
%             %                 end
%             %             end
%         end
%     end
%     
%     save([folder '\' expt '_all\Measurements.mat'])
% end



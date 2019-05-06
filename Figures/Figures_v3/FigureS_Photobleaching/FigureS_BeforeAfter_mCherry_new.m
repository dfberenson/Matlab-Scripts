
clear all
close all

% Automated segmentation

folder = 'H:\DFB_imaging_experiments_3';
expt = 'DFB_190306_HMEC_1GFiii_phototox\DFB_190306_HMEC_1GFiii_Day3_goodobj_2';
red_channel = 1;

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

red_threshold = 180;

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));

% before_constantlight_intintens = [];
% before_intermittentlight_intintens = [];
% before_nolight_intintens = [];
% after_constantlight_intintens = [];
after_intermittentlight_intintens = [];
after_nolight_intintens = [];

already_made_measurements = false;

if ~already_made_measurements
    for pos = 1:30
        
        if pos <= 20
            expt_type = 'intermittent';
        else
            expt_type = 'dark';
        end
        im_red = imread([folder '\' expt '\Pos' num2str(pos) '\img_channel' sprintf('%03d',red_channel) '_position' sprintf('%03d',pos) '_time000000000_z000.tif']);
        
        time = {'after'};
        
        disp(['Analyzing position ' num2str(pos)])
        
        [Y,X] = size(im_red);
        
        raw_im_red = double(im_red);
        raw_im_red_mode = mode(raw_im_red(:));
        zeroed_im_red = raw_im_red - raw_im_red_mode;
        
        flatfielded_im_red = zeroed_im_red * blank_field_mean ./ blank_field;
        
        gaussian_width = 2;
        strel_shape = 'disk';
        strel_size = 1;
        se = strel(strel_shape,strel_size);
        
        
        %         figure()
        gaussian_filtered_red = imgaussfilt(raw_im_red,gaussian_width);
        %         imshow(gaussian_filtered_red,[])
        thresholded_red = gaussian_filtered_red > red_threshold;
        %     figure,imshow(thresholded_red)
        im_opened_red = imopen(thresholded_red,se);
        %     figure,imshow(im_opened_red)
        im_closed_red = imclose(im_opened_red,se);
        segmented_red = im_closed_red;
        figure()
        imshow(imoverlay_fast(im_red*100, bwperim(segmented_red), 'm'),[])
        [red_labels,num_objects_red] = bwlabel(segmented_red,4);
        
        for c = 1:num_objects_red
            
            thiscellmask = red_labels == c;
            label_props = regionprops(thiscellmask,'Area','BoundingBox');
            
            
            % Expand bounding box in each direction to examine
            % local background.
            local_expansion = 100;
            
            boundingBox_vals = label_props.BoundingBox;
            x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
            x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
            y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
            y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
            
            boundingBox = segmented_red(y_min:y_max, x_min:x_max);
            boundingBox_background_mask = boundingBox == 0;
            fullsize_im_local_background_mask = zeros(Y,X);
            fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
            
            red_raw_props = regionprops(thiscellmask,raw_im_red,'MeanIntensity');
            red_flat_props = regionprops(thiscellmask,flatfielded_im_red,'MeanIntensity');
            
            red_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
            red_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_red, 'MeanIntensity');
            
            areas(c) = label_props.Area;
            red_raw_integrated_intensity(c) = areas(c) * (red_raw_props.MeanIntensity - red_raw_background_props.MeanIntensity);
            red_flat_integrated_intensity(c) = areas(c) * (red_flat_props.MeanIntensity - red_flat_background_props.MeanIntensity);
        end
        
        if strcmp(time{1},'before')
            %                             if ismember(pos,0:2)
            %                                 before_constantlight_intintens = [before_constantlight_intintens, farred_flat_integrated_intensity];
            %                             elseif ismember(pos,3:5)
            %                                 before_intermittentlight_intintens = [before_intermittentlight_intintens, farred_flat_integrated_intensity];
            %                             elseif ismember(pos,6:8)
            %                                 before_nolight_intintens = [before_nolight_intintens, farred_flat_integrated_intensity];
            %                             end
        elseif strcmp(time{1},'after')
            if strcmp(expt_type,'intermittent')
                after_intermittentlight_intintens = [after_intermittentlight_intintens, red_flat_integrated_intensity];
            elseif strcmp(expt_type,'dark')
                after_nolight_intintens = [after_nolight_intintens, red_flat_integrated_intensity];
            end
        end
    end
    save([folder '\' expt '_all\Measurements.mat'])
end

%% Plot

load([folder '\' expt '_all\Measurements.mat'])

[h_after,p_after,ci_after,stats_after] = ttest2(after_intermittentlight_intintens,after_nolight_intintens)

% figure
% hold on
% box on
% % ecdf(after_constantlight_intintens / median(before_constantlight_intintens))
% ecdf(after_intermittentlight_intintens / median(after_intermittentlight_intintens))
% ecdf(after_nolight_intintens / median(after_nolight_intintens))
% axis([0 5 0 1],'square')


mean_sizes_after = [mean(after_intermittentlight_intintens) mean(after_nolight_intintens)];
stdev_sizes_after = [std(after_intermittentlight_intintens) std(after_nolight_intintens)];
stderr_sizes_after = stdev_sizes_after ./ sqrt([length(after_intermittentlight_intintens) length(after_nolight_intintens)]);

median_sizes_after = [median(after_intermittentlight_intintens) median(after_nolight_intintens)];
first_quartile_after = [prctile(after_intermittentlight_intintens,25) prctile(after_nolight_intintens, 25)];
third_quartile_after = [prctile(after_intermittentlight_intintens,75) prctile(after_nolight_intintens, 75)];
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
axis([0.5 2.5 0 100000],'square')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
ylabel('prEF1a-mCrimson-NLS total intensity')
yticks([0 50000 100000])
hold off
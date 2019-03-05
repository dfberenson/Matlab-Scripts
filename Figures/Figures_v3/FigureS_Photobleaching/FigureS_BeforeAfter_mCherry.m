
clear all
close all

folder = 'E:\DFB_imaging_experiments';
expt = 'DFB_170530_HMEC_1GFiii_photobleaching';

green_channel = 2;
red_channel = 3;
red_threshold = 400;

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));

before_constantlight_intintens = [];
before_intermittentlight_intintens = [];
before_nolight_intintens = [];
after_constantlight_intintens = [];
after_intermittentlight_intintens = [];
after_nolight_intintens = [];

already_made_measurements = true;

if ~already_made_measurements
for pos = 0:8
% pos = 1;

for time = {'before','after'}
    
    disp(['Analyzing position ' num2str(pos)])
    if strcmp(time{1},'before')
        imstack = readStack([folder '\' expt '_all\' expt '_before_1_MMStack_Pos' num2str(pos) '.ome.tif']);
    elseif strcmp(time{1},'after')
        imstack = readStack([folder '\' expt '_all\' expt '_after_1_MMStack_Pos' num2str(pos) '.ome.tif']);
    end
    
    [Y,X,C] = size(imstack);
    
        im_red = imstack(:,:,red_channel);
    im_green = imstack(:,:,green_channel);    
    raw_im_red = double(im_red);
    raw_im_green = double(im_green);
    
    
    raw_im_red_mode = mode(raw_im_red(:));
    raw_im_green_mode = mode(raw_im_green(:));
    
    zeroed_im_red = raw_im_red - raw_im_red_mode;
    zeroed_im_green = raw_im_green - raw_im_green_mode;
    
    flatfielded_im_red = zeroed_im_red * blank_field_mean ./ blank_field;
    flatfielded_im_green = zeroed_im_green * blank_field_mean ./ blank_field;
    
    
    
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
        green_raw_props = regionprops(thiscellmask,raw_im_green,'MeanIntensity');
        red_flat_props = regionprops(thiscellmask,flatfielded_im_red,'MeanIntensity');
        green_flat_props = regionprops(thiscellmask,flatfielded_im_green,'MeanIntensity');
        
        red_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
        green_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
        red_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_red, 'MeanIntensity');
        green_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_green, 'MeanIntensity');
        
        areas(c) = label_props.Area;
        red_raw_integrated_intensity(c) = areas(c) * (red_raw_props.MeanIntensity - red_raw_background_props.MeanIntensity);
        green_raw_integrated_intensity(c) = areas(c) * (green_raw_props.MeanIntensity - green_raw_background_props.MeanIntensity);
        red_flat_integrated_intensity(c) = areas(c) * (red_flat_props.MeanIntensity - red_flat_background_props.MeanIntensity);
        green_flat_integrated_intensity(c) = areas(c) * (green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity);
        
    end
    
    if strcmp(time{1},'before')
        if ismember(pos,0:2)
            before_constantlight_intintens = [before_constantlight_intintens, red_flat_integrated_intensity];
        elseif ismember(pos,3:5)
            before_intermittentlight_intintens = [before_intermittentlight_intintens, red_flat_integrated_intensity];
        elseif ismember(pos,6:8)
            before_nolight_intintens = [before_nolight_intintens, red_flat_integrated_intensity];
        end
    elseif strcmp(time{1},'after')
        if ismember(pos,0:2)
            after_constantlight_intintens = [after_constantlight_intintens, red_flat_integrated_intensity];
        elseif ismember(pos,3:5)
            after_intermittentlight_intintens = [after_intermittentlight_intintens, red_flat_integrated_intensity];
        elseif ismember(pos,6:8)
            after_nolight_intintens = [after_nolight_intintens, red_flat_integrated_intensity];
        end
    end
end
end

save([folder '\' expt '_all\Measurements.mat'])
end

%% Plot

load('E:\DFB_imaging_experiments\DFB_170530_HMEC_1GFiii_photobleaching_all\Measurements.mat')

% figure
% hold on
% histogram(before_constantlight_intintens)
% histogram(after_constantlight_intintens)

% 
% figure
% hold on
% histogram(before_intermittentlight_intintens)
% histogram(after_intermittentlight_intintens)
% 
% 
% figure
% hold on
% histogram(before_nolight_intintens)
% histogram(after_nolight_intintens)
% 
% figure
% hold on
% % histogram(before_constantlight_intintens)
% histogram(before_intermittentlight_intintens)
% histogram(before_nolight_intintens)
% 
% figure
% hold on
% % histogram(after_constantlight_intintens)
% histogram(after_intermittentlight_intintens)
% histogram(after_nolight_intintens)
% 
% % median(before_constantlight_intintens)
% median(before_intermittentlight_intintens)
% median(before_nolight_intintens)
% % median(after_constantlight_intintens)
% median(after_intermittentlight_intintens)
% median(after_nolight_intintens)
% 
% figure
% hold on
% box on
% % ecdf(before_constantlight_intintens)
% ecdf(before_intermittentlight_intintens)
% ecdf(before_nolight_intintens)
% axis([0 20000 0 1],'square')
% 
% figure
% hold on
% box on
% % ecdf(after_constantlight_intintens)
% ecdf(after_intermittentlight_intintens)
% ecdf(after_nolight_intintens)
% axis([0 20000 0 1],'square')
% xlabel('prEF1-mCherry-NLS intensity')
% ylabel('Cumulative fraction')
% yticks([0 0.5 1])
% 
% figure
% hold on
% box on
% % ecdf(after_constantlight_intintens / median(before_constantlight_intintens))
% ecdf(after_intermittentlight_intintens / median(before_intermittentlight_intintens))
% ecdf(after_nolight_intintens / median(before_nolight_intintens))
% axis([0 5 0 1],'square')

% all_before = [before_constantlight_intintens, before_intermittentlight_intintens, before_nolight_intintens];
% all_after = [after_constantlight_intintens, after_intermittentlight_intintens, after_nolight_intintens];
% 
% all_groups_before = [zeros(1,length(before_constantlight_intintens)), ones(1,length(before_intermittentlight_intintens)), 2*ones(1,length(before_nolight_intintens))];
% all_groups_after = [zeros(1,length(after_constantlight_intintens)), ones(1,length(after_intermittentlight_intintens)), 2*ones(1,length(after_nolight_intintens))];
% 
% [p_before,tbl_before,stats_before] = anova1(all_before,all_groups_before);
% mc_before = multcompare(stats_before);
% 
% [p_after,tbl_after,stats_after] = anova1(all_after,all_groups_after);
% mc_after = multcompare(stats_after);

% [h_before,p_before,ci_before,stats_before] = ttest2(before_intermittentlight_intintens, before_nolight_intintens)
[h_after,p_after,ci_after,stats_after] = ttest2(after_intermittentlight_intintens, after_nolight_intintens)
% [h_after_norm,p_after_norm,ci_after_norm,stats_after_norm] = ttest2(after_intermittentlight_intintens / median(before_intermittentlight_intintens), after_nolight_intintens / median(before_nolight_intintens))

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
% axis([0.5 2.5 0 14000],'square')
% set(gca, 'XTick', [1 2])
% set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
% ylabel('prEF1a-mCherry-NLS total intensity')
% yticks([0 7000 14000])
% hold off

% figure
% hold on
% box on
% [bar,err] = barwitherr(stdev_sizes_after,median_sizes_after,'k');
% bar.FaceColor = 'k';
% err.LineWidth = 2;
% err.CapSize = 40;
% axis([0.5 2.5 0 14000],'square')
% set(gca, 'XTick', [1 2])
% set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
% ylabel('prEF1a-mCherry-NLS total intensity')
% yticks([0 7000 14000])
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
axis([0.5 2.5 0 10000],'square')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Illumination' 'No illumination'})
ylabel('prEF1a-mCherry-NLS total intensity')
yticks([0 5000 10000])
hold off

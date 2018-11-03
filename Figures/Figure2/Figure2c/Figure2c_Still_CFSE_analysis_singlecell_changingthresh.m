

clear all
close all

% imstack = readStack('E:\DFB_imaging_experiments\DFB_180905_HMEC_1G_CFSE_1\TwoCells.tif');
imstack = readStack('E:\DFB_imaging_experiments\DFB_180905_HMEC_1G_CFSE_1\TwoCells_2.tif');

[Y,X,C] = size(imstack);

im_phase = imstack(:,:,1);
im_CFSE = imstack(:,:,2);
im_mCherry = imstack(:,:,3);

gaussian_width = 2;
CFSE_threshold = 200;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

num_segmentation_tries = 25;
possible_mCherry_thresholds = linspace(120,300,num_segmentation_tries);

f = figure('Name','Segmentation at varying thresholds')

for try_num = 1:num_segmentation_tries
    
    mCherry_threshold = possible_mCherry_thresholds(try_num);
    
    gaussian_filtered_mCherry = imgaussfilt(im_mCherry,gaussian_width);
    thresholded_mCherry = gaussian_filtered_mCherry > mCherry_threshold;
    im_opened_mCherry = imopen(thresholded_mCherry,se);
    im_closed_mCherry = imclose(im_opened_mCherry,se);
    segmented_mCherry = im_closed_mCherry;
    [mCherry_labels,num_objects_mCherry] = bwlabel(segmented_mCherry,4);
    
    mCherry_rgb = uint16(zeros(Y,X,3));
    mCherry_rgb(:,:,1) = im_mCherry*100;
    
    outlined_mCherry = imoverlay_fast(mCherry_rgb,bwperim(mCherry_labels),'w');
    figure(f)
    subplot(sqrt(num_segmentation_tries),sqrt(num_segmentation_tries),try_num)
    outlined_mCherry_toshow = outlined_mCherry(100:200,100:300,:);
    imshow(outlined_mCherry_toshow,[])
    title(num2str(mCherry_threshold))
    
    if any(mCherry_threshold == [120 150 180 210 240 300])
    figure,imshow(outlined_mCherry_toshow,[])
    title(mCherry_threshold)
    end
    
    raw_mcherry_props = regionprops(mCherry_labels,im_mCherry,'Area','MeanIntensity','Centroid','BoundingBox');
    
    for j = 1:num_objects_mCherry
        
        boundingBox_vals = raw_mcherry_props(j).BoundingBox;
        local_expansion = 100;
        x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
        x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
        y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
        y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
        boundingBox = segmented_mCherry(y_min:y_max, x_min:x_max);
        boundingBox_background_mask = boundingBox == 0;
        %                 imshow(boundingBox_background_mask,[])
        fullsize_im_local_background_mask = zeros(Y,X);
        fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
        raw_mean_background = regionprops(fullsize_im_local_background_mask, im_mCherry, 'MeanIntensity');
        
        area_measurements(try_num,j) = raw_mcherry_props(j).Area;
        intensity_measurements(try_num,j) = raw_mcherry_props(j).Area * (raw_mcherry_props(j).MeanIntensity - raw_mean_background.MeanIntensity);
    end
end

for j = 1:num_objects_mCherry
    scaled_area_measurements(:,j) = area_measurements(:,j) / area_measurements(5,j);
    scaled_intensity_measurements(:,j) = intensity_measurements(:,j) / intensity_measurements(5,j);
    
    figure
    hold on
    plot(possible_mCherry_thresholds,scaled_area_measurements(:,j) .^ 1.5,'k-')
    plot(possible_mCherry_thresholds,scaled_intensity_measurements(:,j),'r--')
    legend('Nuclear Volume','prEF1a-mCherry-NLS')
    xlabel('Segmentation threshold')
    ylabel('Relative measurement value')
    axis([-inf inf 0 inf])
    hold off
end

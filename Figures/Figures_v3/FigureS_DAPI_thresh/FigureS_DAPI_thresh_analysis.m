

clear all
close all

imstack = readStack('E:\DFB_imaging_experiments\DFB_190426_HMEC_1G_DAPI_2\OneCell.tif');

[Y,X,C] = size(imstack);

im_DAPI = imstack(:,:,1);
im_mCherry = imstack(:,:,2);

%% Analyze DAPI
% DAPI range is 500-1000

gaussian_width = 2;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

volume_power = 1.5;

num_segmentation_tries = 21;
commonly_used_segmentation_num = 11;
possible_DAPI_thresholds = linspace(600,1200,num_segmentation_tries);

gaussian_filtered_DAPI = imgaussfilt(im_DAPI,gaussian_width);
% Otsu threshold is close to 300 but that is too tight in my opinion
otsu = graythresh(double(gaussian_filtered_DAPI) / double(max(gaussian_filtered_DAPI(:)))) * double(max(gaussian_filtered_DAPI(:)));

% f = figure('Name','Segmentation at varying thresholds')

for try_num = 1:num_segmentation_tries
    
    DAPI_threshold = possible_DAPI_thresholds(try_num);
    
    thresholded_DAPI = gaussian_filtered_DAPI > DAPI_threshold;
    im_opened_DAPI = imopen(thresholded_DAPI,se);
    im_closed_DAPI = imclose(im_opened_DAPI,se);
    segmented_DAPI = im_closed_DAPI;
    [DAPI_labels,num_objects_DAPI] = bwlabel(segmented_DAPI,4);
    
    DAPI_rgb = uint16(zeros(Y,X,3));
    DAPI_rgb(:,:,3) = im_DAPI*40;
    DAPI_rgb(:,:,1) = im_mCherry*100;
    
    outlined_DAPI = imoverlay_fast(DAPI_rgb,bwperim(DAPI_labels),'w');
    %     outlined_DAPI_toshow = outlined_DAPI(100:200,100:300,:);
    outlined_DAPI_toshow = outlined_DAPI(:,:,:);
    outlined_DAPI_toshow = insertText(outlined_DAPI_toshow,[1 1],num2str(DAPI_threshold),'TextColor','yellow','BoxOpacity',0);
    
    %     figure(f)
    %     subplot(sqrt(num_segmentation_tries),sqrt(num_segmentation_tries),try_num)
    
    %     imshow(outlined_DAPI_toshow,[])
    %     title(num2str(DAPI_threshold))
    
%     if any(DAPI_threshold == [120 180 240 300])
        figure,imshow(outlined_DAPI_toshow,[])
        %         title(DAPI_threshold)
%     end
    
    raw_DAPI_props = regionprops(DAPI_labels,im_DAPI,'Area','MeanIntensity','Centroid','BoundingBox');
    raw_mCherry_props_from_DAPI_segmentation = regionprops(DAPI_labels,im_mCherry,'MeanIntensity','Centroid','BoundingBox');
    
    for j = 1:num_objects_DAPI
        
        boundingBox_vals = raw_DAPI_props(j).BoundingBox;
        local_expansion = 100;
        x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
        x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
        y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
        y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
        boundingBox = segmented_DAPI(y_min:y_max, x_min:x_max);
        boundingBox_background_mask = boundingBox == 0;
        %                 imshow(boundingBox_background_mask,[])
        fullsize_im_local_background_mask = zeros(Y,X);
        fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
        raw_mean_background_DAPI = regionprops(fullsize_im_local_background_mask, im_DAPI, 'MeanIntensity');
        raw_mean_background_mCherry_from_DAPI_segmentation = regionprops(fullsize_im_local_background_mask, im_mCherry, 'MeanIntensity');
        
        volume_measurements_DAPI(try_num,j) = raw_DAPI_props(j).Area ^ volume_power;
        intensity_measurements_DAPI(try_num,j) = raw_DAPI_props(j).Area * (raw_DAPI_props(j).MeanIntensity - raw_mean_background_DAPI.MeanIntensity);
        intensity_measurements_mCherry_from_DAPI_segmentation(try_num,j) = raw_DAPI_props(j).Area * (raw_mCherry_props_from_DAPI_segmentation(j).MeanIntensity - raw_mean_background_mCherry_from_DAPI_segmentation(j).MeanIntensity);
    end
end

for j = 1:num_objects_DAPI
    scaled_volume_measurements_DAPI(:,j) = volume_measurements_DAPI(:,j) / volume_measurements_DAPI(commonly_used_segmentation_num,j);
    scaled_intensity_measurements_DAPI(:,j) = intensity_measurements_DAPI(:,j) / intensity_measurements_DAPI(commonly_used_segmentation_num,j);
    
    figure
    box on
    hold on
    plot(possible_DAPI_thresholds,scaled_volume_measurements_DAPI(:,j),'k--')
    plot(possible_DAPI_thresholds,scaled_intensity_measurements_DAPI(:,j),'b-')
    %     legend('Nuclear Volume','prEF1a-DAPI-NLS')
    xlabel('Segmentation threshold')
    ylabel('Relative measurement value')
%     xticks([120 180 240 300])
    yticks([0 1 2 3])
    axis([-inf inf 0 3],'square')
    ax = gca();
    ax.FontSize = 16;
    hold off
end

for j = 1:num_objects_DAPI
    scaled_volume_measurements_DAPI(:,j) = volume_measurements_DAPI(:,j) / volume_measurements_DAPI(commonly_used_segmentation_num,j);
    scaled_intensity_measurements_mCherry_from_DAPI_segmentation(:,j) = intensity_measurements_mCherry_from_DAPI_segmentation(:,j) / intensity_measurements_mCherry_from_DAPI_segmentation(commonly_used_segmentation_num,j);
    
    figure
    box on
    hold on
    plot(possible_DAPI_thresholds,scaled_volume_measurements_DAPI(:,j),'k--')
    plot(possible_DAPI_thresholds,scaled_intensity_measurements_mCherry_from_DAPI_segmentation(:,j),'r-')
    %     legend('Nuclear Volume','prEF1a-DAPI-NLS')
    xlabel('Segmentation threshold')
    ylabel('Relative measurement value')
%     xticks([120 180 240 300])
    yticks([0 1 2 3])
    axis([-inf inf 0 3],'square')
    ax = gca();
    ax.FontSize = 16;
    hold off
end


%% Analyze mCherry
% mCherry range is 150-400

gaussian_width = 2;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

volume_power = 1.5;

num_segmentation_tries = 21;
commonly_used_segmentation_num = 11;
possible_mCherry_thresholds = linspace(140,340,num_segmentation_tries);

gaussian_filtered_mCherry = imgaussfilt(im_mCherry,gaussian_width);
% Otsu threshold is close to 300 but that is too tight in my opinion
otsu = graythresh(double(gaussian_filtered_mCherry) / double(max(gaussian_filtered_mCherry(:)))) * double(max(gaussian_filtered_mCherry(:)));

% f = figure('Name','Segmentation at varying thresholds')

for try_num = 1:num_segmentation_tries
    
    mCherry_threshold = possible_mCherry_thresholds(try_num);
    
    thresholded_mCherry = gaussian_filtered_mCherry > mCherry_threshold;
    im_opened_mCherry = imopen(thresholded_mCherry,se);
    im_closed_mCherry = imclose(im_opened_mCherry,se);
    segmented_mCherry = im_closed_mCherry;
    [mCherry_labels,num_objects_mCherry] = bwlabel(segmented_mCherry,4);
    
    mCherry_rgb = uint16(zeros(Y,X,3));
    mCherry_rgb(:,:,1) = im_mCherry*100;
    
    outlined_mCherry = imoverlay_fast(mCherry_rgb,bwperim(mCherry_labels),'w');
    %     outlined_mCherry_toshow = outlined_mCherry(100:200,100:300,:);
    outlined_mCherry_toshow = outlined_mCherry(:,:,:);
    outlined_mCherry_toshow = insertText(outlined_mCherry_toshow,[1 1],num2str(mCherry_threshold),'TextColor','yellow','BoxOpacity',0);
    
    %     figure(f)
    %     subplot(sqrt(num_segmentation_tries),sqrt(num_segmentation_tries),try_num)
    
    %     imshow(outlined_mCherry_toshow,[])
    %     title(num2str(mCherry_threshold))
    
%     if any(mCherry_threshold == [120 180 240 300])
        figure,imshow(outlined_mCherry_toshow,[])
        %         title(mCherry_threshold)
%     end
    
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
        
        volume_measurements_mCherry(try_num,j) = raw_mcherry_props(j).Area ^ volume_power;
        intensity_measurements_mCherry(try_num,j) = raw_mcherry_props(j).Area * (raw_mcherry_props(j).MeanIntensity - raw_mean_background.MeanIntensity);
    end
end

for j = 1:num_objects_mCherry
    scaled_volume_measurements_mCherry(:,j) = volume_measurements_mCherry(:,j) / volume_measurements_mCherry(commonly_used_segmentation_num,j);
    scaled_intensity_measurements_mCherry(:,j) = intensity_measurements_mCherry(:,j) / intensity_measurements_mCherry(commonly_used_segmentation_num,j);
    
    figure
    box on
    hold on
    plot(possible_mCherry_thresholds,scaled_volume_measurements_mCherry(:,j),'k--')
    plot(possible_mCherry_thresholds,scaled_intensity_measurements_mCherry(:,j),'r-')
    %     legend('Nuclear Volume','prEF1a-mCherry-NLS')
    xlabel('Segmentation threshold')
    ylabel('Relative measurement value')
    xticks([120 180 240 300])
    yticks([0 1 2])
    axis([-inf inf 0 inf],'square')
    ax = gca();
    ax.FontSize = 16;
    hold off
end

clear all
close all

plot_data = false;

folder = 'E:\DFB_imaging_experiments';
base_expt_name = 'DFB_190426_HMEC_1G_DAPI_2';

expt_folder = [folder '\' base_expt_name];

position_list = 1:11;
% position_list = 1:2;

num_segmentation_tries = 21;

possible_mCherry_thresholds = linspace(340,140,num_segmentation_tries);
possible_DAPI_thresholds = linspace(1200,600,num_segmentation_tries);

mCherry_data_at_each_thresh = struct;
DAPI_data_at_each_thresh = struct;
mCherry_data_from_DAPI_segmentation_at_each_thresh = struct;

for try_num = 1:num_segmentation_tries
    
    mCherry_threshold = possible_mCherry_thresholds(try_num);
    DAPI_threshold = possible_DAPI_thresholds(try_num);
    
    for pos = position_list
        
        im_DAPI = imread([expt_folder '\Pos' num2str(pos) '\img_channel000_position' sprintf('%03d',pos) '_time000000000_z000.tif']);
        im_mCherry = imread([expt_folder '\Pos' num2str(pos) '\img_channel001_position' sprintf('%03d',pos) '_time000000000_z000.tif']);
        
        [Y,X] = size(im_DAPI);
        
        gaussian_width = 2;
        strel_shape = 'disk';
        strel_size = 1;
        se = strel(strel_shape,strel_size);
        
        volume_power = 1.5;
        
        %     figure()
        gaussian_filtered_mCherry = imgaussfilt(im_mCherry,gaussian_width);
        %     subplot(1,2,1)
        %     imshow(gaussian_filtered_mCherry,[])
        thresholded_mCherry = gaussian_filtered_mCherry > mCherry_threshold;
        % figure,imshow(thresholded_mCherry)
        im_opened_mCherry = imopen(thresholded_mCherry,se);
        % figure,imshow(im_opened_mCherry)
        im_closed_mCherry = imclose(im_opened_mCherry,se);
        segmented_mCherry = im_closed_mCherry;
        %     subplot(1,2,2)
        %     imshow(segmented_mCherry)
        %     figure()
        %     imshow(imoverlay_fast(im_mCherry*100, bwperim(segmented_mCherry), 'm'),[])
        [mCherry_labels,num_objects_mCherry] = bwlabel(segmented_mCherry,4);
%         figure,imshow(mCherry_labels)
        
        % For the first segmentation threshold, choose the true
        % coordinates that will be used
        if try_num == 1
            true_mCherry_labels{pos} = mCherry_labels;
            num_true_objects_mCherry{pos} = num_objects_mCherry;
            true_mCherry_props{pos} = regionprops(true_mCherry_labels{pos},im_mCherry,'Centroid');
        end
        
        gaussian_filtered_DAPI = imgaussfilt(im_DAPI,gaussian_width);
        %     subplot(1,2,1)
        %     imshow(gaussian_filtered_DAPI,[])
        thresholded_DAPI = gaussian_filtered_DAPI > DAPI_threshold;
        % figure,imshow(thresholded_DAPI)
        im_opened_DAPI = imopen(thresholded_DAPI,se);
        % figure,imshow(im_opened_DAPI)
        im_closed_DAPI = imclose(im_opened_DAPI,se);
        segmented_DAPI = im_closed_DAPI;
        %     subplot(1,2,2)
        %     imshow(segmented_DAPI)
        %     figure()
        %     imshow(imoverlay_fast(im_DAPI*100, bwperim(segmented_DAPI), 'm'),[])
        [DAPI_labels,num_objects_DAPI] = bwlabel(segmented_DAPI,4);
%         figure,imshow(DAPI_labels)
        
        % For the first segmentation threshold, choose the true
        % coordinates that will be used
        if try_num == 1
            true_DAPI_labels{pos} = DAPI_labels;
            num_true_objects_DAPI{pos} = num_objects_DAPI;
            true_DAPI_props{pos} = regionprops(true_DAPI_labels{pos},im_DAPI,'Centroid');
        end
        
        im_to_show(:,:,1) = im_mCherry*100;
        im_to_show(:,:,3) = im_DAPI*20;
        im_to_show(:,:,2) = zeros(Y,X);
        %     figure,imshow(im_to_show)
        im_overlaid = imoverlay_fast(im_to_show, bwperim(segmented_mCherry), 'w');
        im_overlaid = imoverlay_fast(im_overlaid, bwperim(segmented_DAPI), 'w');
        %     figure,imshow(im_overlaid)
        
        
        blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
        blank_field_mean = mean(blank_field(:));
        
        raw_DAPI_props = regionprops(DAPI_labels,im_DAPI,'Area','MeanIntensity','Centroid','BoundingBox');
        raw_mCherry_props = regionprops(mCherry_labels,im_mCherry,'Area','MeanIntensity','Centroid','BoundingBox');
        raw_mCherry_props_from_DAPI_segmentation = regionprops(DAPI_labels, im_mCherry,'Area','MeanIntensity','Centroid','BoundingBox');
        
        zeroed_im_DAPI = im_DAPI - mode(im_DAPI(:));
        zeroed_im_mcherry = im_mCherry - mode(im_mCherry(:));
        flatfielded_im_DAPI = double(zeroed_im_DAPI) * blank_field_mean ./ blank_field;
        flatfielded_im_mCherry = double(zeroed_im_mcherry) * blank_field_mean ./ blank_field;
        
        flatfielded_DAPI_props = regionprops(DAPI_labels,flatfielded_im_DAPI,'Area','MeanIntensity','Centroid','BoundingBox');
        flatfielded_mCherry_props = regionprops(mCherry_labels,flatfielded_im_mCherry,'Area','MeanIntensity','Centroid','BoundingBox');
        flatfielded_mCherry_props_from_DAPI_segmentation = regionprops(DAPI_labels,flatfielded_im_mCherry,'Area','MeanIntensity','Centroid','BoundingBox');
        
        flatfielded_DAPI_props_by_true_position = struct('Area',[],'Centroid',[],'BoundingBox',[],'MeanIntensity',[],'MeanBackgroundIntensity',[],'MeanIntensityMinusBackground',[],'IntegratedIntensityMinusBackground',[]);
        flatfielded_mCherry_props_by_true_position = struct('Area',[],'Centroid',[],'BoundingBox',[],'MeanIntensity',[],'MeanBackgroundIntensity',[],'MeanIntensityMinusBackground',[],'IntegratedIntensityMinusBackground',[]);
        flatfielded_mCherry_props_from_DAPI_segmentation_by_true_position = struct('Area',[],'Centroid',[],'BoundingBox',[],'MeanIntensity',[],'MeanBackgroundIntensity',[],'MeanIntensityMinusBackground',[],'IntegratedIntensityMinusBackground',[]);
        
        % For each true object from a single segmentation threshold
        for i = 1:num_true_objects_DAPI{pos}
            disp(['Measuring try ' num2str(try_num) ' pos ' num2str(pos) ' DAPI object ' num2str(i) '/' num2str(num_true_objects_DAPI{pos})])
            this_DAPI_centroid_x = round(true_DAPI_props{pos}(i).Centroid(1));
            this_DAPI_centroid_y = round(true_DAPI_props{pos}(i).Centroid(2));
            
            % Examine all objects segmented at this segmentation
            % threshold
            for k = 1:num_objects_DAPI
                
                % If the centroid of the original object is inside the
                % segmented area at this threshold, we are good to go
                if DAPI_labels(this_DAPI_centroid_y,this_DAPI_centroid_x) == k
                    disp(['Cell found for try ' num2str(try_num) ' pos ' num2str(pos) ' DAPI object ' num2str(i) '/' num2str(num_true_objects_DAPI{pos})])
                    % Get local background values and subtract them
                    boundingBox_vals = raw_DAPI_props(k).BoundingBox;
                    local_expansion = 100;
                    x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
                    x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
                    y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
                    y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
                    boundingBox = segmented_DAPI(y_min:y_max, x_min:x_max);
                    boundingBox_background_mask = boundingBox == 0;
                    %         imshow(boundingBox_background_mask,[])
                    fullsize_im_local_background_mask = zeros(Y,X);
                    fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
                    raw_mean_background = regionprops(fullsize_im_local_background_mask, im_DAPI, 'MeanIntensity');
                    raw_mean_mcherry_background_from_DAPI_segmentation = regionprops(fullsize_im_local_background_mask, im_mCherry, 'MeanIntensity');
                    raw_DAPI_props(k).MeanBackgroundIntensity = raw_mean_background.MeanIntensity;
                    raw_mCherry_props_from_DAPI_segmentation(k).MeanBackgroundIntensity = raw_mean_mcherry_background_from_DAPI_segmentation.MeanIntensity;
                    
                    flat_mean_background = regionprops(fullsize_im_local_background_mask, flatfielded_im_DAPI, 'MeanIntensity');
                    flat_mean_mcherry_background_from_DAPI_segmentation = regionprops(fullsize_im_local_background_mask, flatfielded_im_mCherry, 'MeanIntensity');
                    flatfielded_DAPI_props(k).MeanBackgroundIntensity = flat_mean_background.MeanIntensity;
                    flatfielded_mCherry_props_from_DAPI_segmentation(k).MeanBackgroundIntensity = flat_mean_background.MeanIntensity;
                    
                    raw_DAPI_props(k).MeanIntensityMinusBackground = raw_DAPI_props(k).MeanIntensity - raw_DAPI_props(k).MeanBackgroundIntensity;
                    raw_DAPI_props(k).IntegratedIntensityMinusBackground = raw_DAPI_props(k).Area * raw_DAPI_props(k).MeanIntensityMinusBackground;
                    
                    raw_mCherry_props_from_DAPI_segmentation(k).MeanIntensityMinusBackground = raw_mCherry_props_from_DAPI_segmentation(k).MeanIntensity - raw_mCherry_props_from_DAPI_segmentation(k).MeanBackgroundIntensity;
                    raw_mCherry_props_from_DAPI_segmentation(k).IntegratedIntensityMinusBackground = raw_mCherry_props_from_DAPI_segmentation(k).Area * raw_mCherry_props_from_DAPI_segmentation(k).MeanIntensityMinusBackground;
                    
                    flatfielded_DAPI_props(k).MeanIntensityMinusBackground = flatfielded_DAPI_props(k).MeanIntensity - flatfielded_DAPI_props(k).MeanBackgroundIntensity;
                    flatfielded_DAPI_props(k).IntegratedIntensityMinusBackground = flatfielded_DAPI_props(k).Area * flatfielded_DAPI_props(k).MeanIntensityMinusBackground;
                    
                    flatfielded_mCherry_props_from_DAPI_segmentation(k).MeanIntensityMinusBackground = flatfielded_mCherry_props_from_DAPI_segmentation(k).MeanIntensity - flatfielded_mCherry_props_from_DAPI_segmentation(k).MeanBackgroundIntensity;
                    flatfielded_mCherry_props_from_DAPI_segmentation(k).IntegratedIntensityMinusBackground = flatfielded_mCherry_props_from_DAPI_segmentation(k).Area * flatfielded_mCherry_props_from_DAPI_segmentation(k).MeanIntensityMinusBackground;
                    
                    flatfielded_DAPI_props_by_true_position(i) = flatfielded_DAPI_props(k);
                    flatfielded_mCherry_props_from_DAPI_segmentation_by_true_position(i) = flatfielded_mCherry_props_from_DAPI_segmentation(k);
                end
            end
        end
        
        for i = 1:num_true_objects_DAPI{pos}
            if length(flatfielded_DAPI_props_by_true_position) < i || isempty(flatfielded_DAPI_props_by_true_position(i).Area)
                flatfielded_DAPI_props_by_true_position(i).Area = NaN;
                flatfielded_DAPI_props_by_true_position(i).IntegratedIntensityMinusBackground = NaN;
                flatfielded_mCherry_props_from_DAPI_segmentation_by_true_position(i).Area = NaN;
                flatfielded_mCherry_props_from_DAPI_segmentation_by_true_position(i).IntegratedIntensityMinusBackground = NaN;
            end
        end
        
        % This code uses the true mCherry centroids for the mCherry measurements. By instead using the
        % true DAPI centroids we can compare the two.
%         % For each true object from a single segmentation threshold
%         for j = 1:num_true_objects_mCherry{pos}
%             disp(['Measuring try ' num2str(try_num) ' pos ' num2str(pos) ' mCherry object ' num2str(j) '/' num2str(num_true_objects_mCherry{pos})])
%             this_mCherry_centroid_x = round(true_mCherry_props{pos}(j).Centroid(1));
%             this_mCherry_centroid_y = round(true_mCherry_props{pos}(j).Centroid(2));
%             
%             % Examine all objects segmented at this segmentation
%             % threshold
%             for k = 1:num_objects_mCherry
%                 
%                 % If the centroid of the original object is inside the
%                 % segmented area at this threshold, we are good to go
%                 if mCherry_labels(this_mCherry_centroid_y,this_mCherry_centroid_x) == k
                    
                     % For each true object from a single segmentation threshold
                     
        % This code uses the true DAPI centroids even for the mCherry
        % measurements
        for j = 1:num_true_objects_DAPI{pos}
            disp(['Measuring try ' num2str(try_num) ' pos ' num2str(pos) ' mCherry object ' num2str(j) '/' num2str(num_true_objects_DAPI{pos})])
            this_DAPI_centroid_x = round(true_DAPI_props{pos}(j).Centroid(1));
            this_DAPI_centroid_y = round(true_DAPI_props{pos}(j).Centroid(2));
            disp(['Cell found for try ' num2str(try_num) ' pos ' num2str(pos) ' mCherry object ' num2str(j) '/' num2str(num_true_objects_DAPI{pos})])
            % Examine all objects segmented at this segmentation
            % threshold
            for k = 1:num_objects_mCherry
                
                % If the centroid of the original object is inside the
                % segmented area at this threshold, we are good to go
                if mCherry_labels(this_DAPI_centroid_y,this_DAPI_centroid_x) == k       
                    
                    
                    % Get local background values and subtract them
                    boundingBox_vals = raw_mCherry_props(k).BoundingBox;
                    local_expansion = 100;
                    x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
                    x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
                    y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
                    y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
                    boundingBox = segmented_mCherry(y_min:y_max, x_min:x_max);
                    boundingBox_background_mask = boundingBox == 0;
                    %         imshow(boundingBox_background_mask,[])
                    fullsize_im_local_background_mask = zeros(Y,X);
                    fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
                    raw_mean_background = regionprops(fullsize_im_local_background_mask, im_mCherry, 'MeanIntensity');
                    raw_mCherry_props(k).MeanBackgroundIntensity = raw_mean_background.MeanIntensity;
                    flat_mean_background = regionprops(fullsize_im_local_background_mask, flatfielded_im_mCherry, 'MeanIntensity');
                    flatfielded_mCherry_props(k).MeanBackgroundIntensity = flat_mean_background.MeanIntensity;
                    
                    raw_mCherry_props(k).MeanIntensityMinusBackground = raw_mCherry_props(k).MeanIntensity - raw_mCherry_props(k).MeanBackgroundIntensity;
                    raw_mCherry_props(k).IntegratedIntensityMinusBackground = raw_mCherry_props(k).Area * raw_mCherry_props(k).MeanIntensityMinusBackground;
                    
                    flatfielded_mCherry_props(k).MeanIntensityMinusBackground = flatfielded_mCherry_props(k).MeanIntensity - flatfielded_mCherry_props(k).MeanBackgroundIntensity;
                    flatfielded_mCherry_props(k).IntegratedIntensityMinusBackground = flatfielded_mCherry_props(k).Area * flatfielded_mCherry_props(k).MeanIntensityMinusBackground;
                    
                    flatfielded_mCherry_props_by_true_position(j) = flatfielded_mCherry_props(k);
                end
            end
        end
        
        for j = 1:num_true_objects_DAPI{pos}
            if  length(flatfielded_mCherry_props_by_true_position) < j || isempty(flatfielded_mCherry_props_by_true_position(j).Area)
                flatfielded_mCherry_props_by_true_position(j).Area = NaN;
                flatfielded_mCherry_props_by_true_position(j).IntegratedIntensityMinusBackground = NaN;
            end
        end
        
        
        complete_data(pos).DAPI_data = flatfielded_DAPI_props_by_true_position;
        complete_data(pos).mCherry_data = flatfielded_mCherry_props_by_true_position;
        complete_data(pos).mCherry_data_from_DAPI_segmentation = flatfielded_mCherry_props_from_DAPI_segmentation_by_true_position;
        
    end
    
    all_DAPI_areas = [];
    all_DAPI_flat_integratedintensities_minusbackground = [];
    all_mcherry_areas = [];
    all_mcherry_flat_integratedintensities_minusbackground = [];
    all_mcherry_areas_from_DAPI_segmentation = [];
    all_mcherry_flat_integrated_intensities_minusbackground_from_DAPI_segmentation = [];
    
    for pos = position_list
        for c = 1:length(complete_data(pos).DAPI_data)
            all_DAPI_areas = [all_DAPI_areas; complete_data(pos).DAPI_data(c).Area];
            all_DAPI_flat_integratedintensities_minusbackground = [all_DAPI_flat_integratedintensities_minusbackground;...
                complete_data(pos).DAPI_data(c).IntegratedIntensityMinusBackground];
            all_mcherry_areas_from_DAPI_segmentation = [all_mcherry_areas_from_DAPI_segmentation; complete_data(pos).mCherry_data_from_DAPI_segmentation(c).Area];
            all_mcherry_flat_integrated_intensities_minusbackground_from_DAPI_segmentation = [all_mcherry_flat_integrated_intensities_minusbackground_from_DAPI_segmentation;
                complete_data(pos).mCherry_data_from_DAPI_segmentation(c).IntegratedIntensityMinusBackground];
        end
        for c = 1:length(complete_data(pos).mCherry_data)
            all_mcherry_areas = [all_mcherry_areas; complete_data(pos).mCherry_data(c).Area];
            all_mcherry_flat_integratedintensities_minusbackground = [all_mcherry_flat_integratedintensities_minusbackground;...
                complete_data(pos).mCherry_data(c).IntegratedIntensityMinusBackground];
        end
    end
    
    mCherry_data_at_each_thresh(try_num).all_mcherry_areas = all_mcherry_areas;
    mCherry_data_at_each_thresh(try_num).all_mcherry_flat_integrated_intensities_minusbackground = all_mcherry_flat_integratedintensities_minusbackground;
    DAPI_data_at_each_thresh(try_num).all_DAPI_areas = all_DAPI_areas;
    DAPI_data_at_each_thresh(try_num).all_DAPI_flat_integratedintensities_minusbackground = all_DAPI_flat_integratedintensities_minusbackground;
    mCherry_data_from_DAPI_segmentation_at_each_thresh(try_num).all_mcherry_areas_from_DAPI_segmentation = all_mcherry_areas_from_DAPI_segmentation;
    mCherry_data_from_DAPI_segmentation_at_each_thresh(try_num).all_mcherry_flat_integrated_intensities_from_DAPI_segmentation = all_mcherry_flat_integrated_intensities_minusbackground_from_DAPI_segmentation;
    
end

save(['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\' base_expt_name '_ChangingThresh.mat'], 'mCherry_data_at_each_thresh', 'possible_mCherry_thresholds','DAPI_data_at_each_thresh','possible_DAPI_thresholds','mCherry_data_from_DAPI_segmentation_at_each_thresh')
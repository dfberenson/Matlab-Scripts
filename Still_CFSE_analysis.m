clear all
close all

folder = 'E:\DFB_imaging_experiments';
% base_expt_name = 'DFB_180903_HMEC_1G_CFSE_2';
% base_expt_name = 'DFB_180905_HMEC_1G_CFSE_1';
% base_expt_name = 'DFB_181028_HMEC_1E_CFSE_1';
% base_expt_name = 'DFB_181028_HMEC_1E_CFSE_2';
% base_expt_name = 'DFB_181213_HMEC_D5_CFSE_2';
% base_expt_name = 'DFB_181225_HMEC_D5_CFSE_4';
base_expt_name = 'DFB_190117_HMEC_D5_CFSE_2';

expt_folder = [folder '\' base_expt_name];

% for position_class = 1:3
% switch position_class
%     case 1
%         position_list = 1:8;
%     case 2
%         position_list = 9:16;
%     case 3
%         position_list = 17:24;
% end

if strcmp(base_expt_name,'DFB_180905_HMEC_1G_CFSE_1')
    % Positions 1:8 were for 1 uL CFSE which was the standard dose before
    position_list = [1:8]
    % ef1a_threshold = 150;
    ef1a_threshold = 180;
    CFSE_threshold = 200;
    phase_channel = 1;
    cfse_channel = 2;
    ef1a_channel = 3;
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 1500;
elseif strcmp(base_expt_name,'DFB_181028_HMEC_1E_CFSE_1') || strcmp(base_expt_name,'DFB_181028_HMEC_1E_CFSE_2')
    % Rename Pos0 to Pos14 so indexing works
    position_list = [1:14]
    % ef1a_threshold = 150;
    ef1a_threshold = 180;
    CFSE_threshold = 200;
    phase_channel = 1;
    cfse_channel = 2;
    ef1a_channel = 3;
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 1500;
elseif strcmp(base_expt_name,'DFB_181213_HMEC_D5_CFSE_2')
%     position_list = [1:10];
    position_list = [11:20];
%     ef1a_threshold = 140;
    ef1a_threshold = 350;
    CFSE_threshold = 350;
    phase_channel = 1;
    cfse_channel = 2;
%     ef1a_channel = 3;
    ef1a_channel = 4;
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 2000;
elseif strcmp(base_expt_name,'DFB_181225_HMEC_D5_CFSE_4')
    position_list = [1:10];
    %     position_list = [11:20];
    %     ef1a_threshold = 140;
    ef1a_threshold = 550;
    CFSE_threshold = 500;
    phase_channel = 1;
    cfse_channel = 2;
%     ef1a_channel = 3;
    ef1a_channel = 4;
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 2000;
elseif strcmp(base_expt_name,'DFB_190117_HMEC_D5_CFSE_2')
    position_list = [1:10];
    %     position_list = [11:20];
    %     ef1a_threshold = 140;
    ef1a_threshold = 350;
    CFSE_threshold = 500;
    phase_channel = 1;
    cfse_channel = 2;
    ef1a_channel = 3;
    min_CFSE_obj_area = 500;
    max_CFSE_obj_area = 2000;    
end


for pos = position_list
    
    %% Load and segment the images
    
    imstack = readStack([expt_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '.ome.tif']);
    
    [Y,X,C] = size(imstack);
    
    im_phase = imstack(:,:,phase_channel);
    im_CFSE = imstack(:,:,cfse_channel);
    im_ef1a = imstack(:,:,ef1a_channel);
    
    gaussian_width = 2;
    strel_shape = 'disk';
    strel_size = 1;
    se = strel(strel_shape,strel_size);
    
    fileID = fopen([expt_folder '\Segmentation_Parameters.txt'],'w');
    fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
    fprintf(fileID,['ef1a Threshold > ' num2str(ef1a_threshold) '\r\n']);
    fprintf(fileID,['CFSE Threshold > ' num2str(CFSE_threshold) '\r\n']);
    fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
    fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
    fclose(fileID);
    
    %     figure()
    gaussian_filtered_ef1a = imgaussfilt(im_ef1a,gaussian_width);
    %     subplot(1,2,1)
    %     imshow(gaussian_filtered_ef1a,[])
    thresholded_ef1a = gaussian_filtered_ef1a > ef1a_threshold;
    % figure,imshow(thresholded_ef1a)
    im_opened_ef1a = imopen(thresholded_ef1a,se);
    % figure,imshow(im_opened_ef1a)
    im_closed_ef1a = imclose(im_opened_ef1a,se);
    segmented_ef1a = im_closed_ef1a;
    %     subplot(1,2,2)
    %     imshow(segmented_ef1a)
    %     figure()
    %     imshow(imoverlay_fast(im_ef1a*100, bwperim(segmented_ef1a), 'm'),[])
    [ef1a_labels,num_objects_ef1a] = bwlabel(segmented_ef1a,4);
    % An attempt to watershed the cells that was not very successful:
    % props = regionprops(ef1a_labels,'Image','BoundingBox');
    % for thislabel = 1:num_objects_ef1a
    %     boundingBox_vals = props(thislabel).BoundingBox;
    %     x_min = max(uint16(boundingBox_vals(1)),1);
    %     x_max = min(uint16(x_min + boundingBox_vals(3)),X);
    %     y_min = max(uint16(boundingBox_vals(2)),1);
    %     y_max = min(uint16(y_min + boundingBox_vals(4)),Y);
    %     segmented_ef1a_bounding_box = segmented_ef1a(y_min:y_max, x_min:x_max);
    %     raw_ef1a_bounding_box = im_ef1a(y_min:y_max, x_min:x_max);
    %     touching_cells = props(thislabel).Image;
    %
    %     just_raw_cells = imimposemin(raw_ef1a_bounding_box, ~segmented_ef1a_bounding_box);
    %     basins = single(just_raw_cells);
    %     watershed_se = strel('disk',2);
    %     basins_opened = imopen(basins,watershed_se);
    %     shed = watershed(-basins_opened);
    %
    %     separated_cells = segmented_ef1a_bounding_box;
    %     separated_cells(shed == 0) = 0;
    %     separated_cells(separated_cells ~= 0) = 1;
    %
    %     segmented_ef1a_bounding_box(touching_cells) = separated_cells(touching_cells);
    %     segmented_ef1a(y_min:y_max, x_min:x_max) = segmented_ef1a_bounding_box;
    % end
    % figure()
    % imshow(imoverlay_fast(im_ef1a*100, bwperim(segmented_ef1a), 'm'),[])
    
    
    %     figure()
    gaussian_filtered_CFSE = imgaussfilt(im_CFSE,gaussian_width);
    %     subplot(1,2,1)
    %     imshow(gaussian_filtered_CFSE,[])
    thresholded_CFSE = gaussian_filtered_CFSE > CFSE_threshold;
    % figure,imshow(thresholded_CFSE)
    im_opened_CFSE = imopen(thresholded_CFSE,se);
    % figure,imshow(im_opened_CFSE)
    im_closed_CFSE = imclose(im_opened_CFSE,se);
    segmented_CFSE = im_closed_CFSE;
    %     subplot(1,2,2)
    %     imshow(segmented_CFSE)
    %     figure()
    %     imshow(imoverlay_fast(im_CFSE*100, bwperim(segmented_CFSE), 'm'),[])
    [CFSE_labels,num_objects_CFSE] = bwlabel(segmented_CFSE,4);
    
    % An attempt to watershed the cells that was not very successful:
    % props = regionprops(CFSE_labels,'Image','BoundingBox');
    % for thislabel = 1:num_objects_CFSE
    %     boundingBox_vals = props(thislabel).BoundingBox;
    %     x_min = max(uint16(boundingBox_vals(1)),1);
    %     x_max = min(uint16(x_min + boundingBox_vals(3)),X);
    %     y_min = max(uint16(boundingBox_vals(2)),1);
    %     y_max = min(uint16(y_min + boundingBox_vals(4)),Y);
    %     segmented_CFSE_bounding_box = segmented_CFSE(y_min:y_max, x_min:x_max);
    %     raw_CFSE_bounding_box = im_CFSE(y_min:y_max, x_min:x_max);
    %     figure,imshow(raw_CFSE_bounding_box,[])
    %     touching_cells = props(thislabel).Image;
    %
    %     just_raw_cells = imimposemin(raw_CFSE_bounding_box, ~segmented_CFSE_bounding_box);
    %     basins = single(just_raw_cells);
    %     watershed_se = strel('disk',3);
    %     basins_opened = imopen(basins,watershed_se);
    %     suppressed = imhmin(basins_opened,500);
    %     imshow(suppressed,[])
    %     shed = watershed(-suppressed);
    %
    %     separated_cells = segmented_CFSE_bounding_box;
    %     separated_cells(shed == 0) = 0;
    %     separated_cells(separated_cells ~= 0) = 1;
    %
    %     segmented_CFSE_bounding_box(touching_cells) = separated_cells(touching_cells);
    %     figure,imshow(segmented_CFSE_bounding_box,[])
    %     segmented_CFSE(y_min:y_max, x_min:x_max) = segmented_CFSE_bounding_box;
    % end
    % figure()
    % imshow(imoverlay_fast(im_CFSE*100, bwperim(segmented_CFSE), 'm'),[])
    
    im_to_show(:,:,1) = im_ef1a*100;
    im_to_show(:,:,2) = im_CFSE*30;
    im_to_show(:,:,3) = zeros(Y,X);
    %     figure,imshow(im_to_show)
    im_overlaid = imoverlay_fast(im_to_show, bwperim(segmented_ef1a), 'w');
    im_overlaid = imoverlay_fast(im_overlaid, bwperim(segmented_CFSE), 'w');
    figure,imshow(im_overlaid)
    
    
    
    %% Match segmented ef1a objects with segmented CFSE objects
    
    
    blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
    blank_field_mean = mean(blank_field(:));
    
    raw_cfse_props = regionprops(CFSE_labels,im_CFSE,'Area','MeanIntensity','BoundingBox');
    raw_ef1a_props = regionprops(ef1a_labels,im_ef1a,'Area','MeanIntensity','Centroid','BoundingBox');
    
    zeroed_im_cfse = im_CFSE - mode(im_CFSE(:));
    zeroed_im_ef1a = im_ef1a - mode(im_ef1a(:));
    flatfielded_im_cfse = double(zeroed_im_cfse) * blank_field_mean ./ blank_field;
    flatfielded_im_ef1a = double(zeroed_im_ef1a) * blank_field_mean ./ blank_field;
    
    flatfielded_cfse_props = regionprops(CFSE_labels,flatfielded_im_cfse,'Area','MeanIntensity','BoundingBox');
    flatfielded_ef1a_props = regionprops(ef1a_labels,flatfielded_im_ef1a,'Area','MeanIntensity','Centroid','BoundingBox');
    
    for i = 1:num_objects_CFSE
        disp(['Measuring CFSE object ' num2str(i) '/' num2str(num_objects_CFSE)])
        
        % Get raw values
        raw_cfse_props(i).IntegratedIntensity = raw_cfse_props(i).Area * raw_cfse_props(i).MeanIntensity;
        raw_cfse_props(i).corresponding_ef1a_labels = [];
        raw_cfse_props(i).corresponding_ef1a_areas = [];
        raw_cfse_props(i).corresponding_ef1a_means = [];
        raw_cfse_props(i).corresponding_ef1a_meansMinusBackground = [];
        raw_cfse_props(i).corresponding_ef1a_IntegratedIntensity = [];
        raw_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground = [];
        
        % Get flatfielded values
        flatfielded_cfse_props(i).IntegratedIntensity = flatfielded_cfse_props(i).Area * flatfielded_cfse_props(i).MeanIntensity;
        flatfielded_cfse_props(i).corresponding_ef1a_labels = [];
        flatfielded_cfse_props(i).corresponding_ef1a_areas = [];
        flatfielded_cfse_props(i).corresponding_ef1a_means = [];
        flatfielded_cfse_props(i).corresponding_ef1a_meansMinusBackground = [];
        flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensity = [];
        flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground = [];
        
        % Get local background values and subtract them
        boundingBox_vals = raw_cfse_props(i).BoundingBox;
        local_expansion = 100;
        x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
        x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
        y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
        y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
        boundingBox = segmented_CFSE(y_min:y_max, x_min:x_max);
        boundingBox_background_mask = boundingBox == 0;
        %         imshow(boundingBox_background_mask,[])
        fullsize_im_local_background_mask = zeros(Y,X);
        fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
        raw_mean_background = regionprops(fullsize_im_local_background_mask, im_CFSE, 'MeanIntensity');
        raw_cfse_props(i).MeanBackgroundIntensity = raw_mean_background.MeanIntensity;
        flat_mean_background = regionprops(fullsize_im_local_background_mask, flatfielded_im_cfse, 'MeanIntensity');
        flatfielded_cfse_props(i).MeanBackgroundIntensity = flat_mean_background.MeanIntensity;
        
        raw_cfse_props(i).MeanIntensityMinusBackground = raw_cfse_props(i).MeanIntensity - raw_cfse_props(i).MeanBackgroundIntensity;
        raw_cfse_props(i).IntegratedIntensityMinusBackground = raw_cfse_props(i).Area * raw_cfse_props(i).MeanIntensityMinusBackground;
        
        flatfielded_cfse_props(i).MeanIntensityMinusBackground = flatfielded_cfse_props(i).MeanIntensity - flatfielded_cfse_props(i).MeanBackgroundIntensity;
        flatfielded_cfse_props(i).IntegratedIntensityMinusBackground = flatfielded_cfse_props(i).Area * flatfielded_cfse_props(i).MeanIntensityMinusBackground;
        
        
        for j = 1:num_objects_ef1a
            this_ef1a_centroid_x = round(raw_ef1a_props(j).Centroid(1));
            this_ef1a_centroid_y = round(raw_ef1a_props(j).Centroid(2));
            if CFSE_labels(this_ef1a_centroid_y,this_ef1a_centroid_x) == i
                % Get raw values
                raw_cfse_props(i).corresponding_ef1a_labels = [raw_cfse_props(i).corresponding_ef1a_labels, j];
                raw_cfse_props(i).corresponding_ef1a_areas = [raw_cfse_props(i).corresponding_ef1a_areas,...
                    raw_ef1a_props(j).Area];
                raw_cfse_props(i).corresponding_ef1a_means = [raw_cfse_props(i).corresponding_ef1a_means,...
                    raw_ef1a_props(j).MeanIntensity];
                raw_cfse_props(i).corresponding_ef1a_IntegratedIntensity = [raw_cfse_props(i).corresponding_ef1a_IntegratedIntensity...
                    raw_ef1a_props(j).Area * raw_ef1a_props(j).MeanIntensity];
                
                % Get flatfielded values
                flatfielded_cfse_props(i).corresponding_ef1a_labels = [flatfielded_cfse_props(i).corresponding_ef1a_labels, j];
                flatfielded_cfse_props(i).corresponding_ef1a_areas = [flatfielded_cfse_props(i).corresponding_ef1a_areas,...
                    flatfielded_ef1a_props(j).Area];
                flatfielded_cfse_props(i).corresponding_ef1a_means = [flatfielded_cfse_props(i).corresponding_ef1a_means,...
                    flatfielded_ef1a_props(j).MeanIntensity];
                flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensity = [flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensity,...
                    flatfielded_ef1a_props(j).Area * flatfielded_ef1a_props(j).MeanIntensity];
                
                % Get local background values and subtract them
                boundingBox_vals = raw_ef1a_props(j).BoundingBox;
                local_expansion = 100;
                x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
                x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
                y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
                y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
                boundingBox = segmented_ef1a(y_min:y_max, x_min:x_max);
                boundingBox_background_mask = boundingBox == 0;
                %                 imshow(boundingBox_background_mask,[])
                fullsize_im_local_background_mask = zeros(Y,X);
                fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
                raw_mean_background = regionprops(fullsize_im_local_background_mask, im_ef1a, 'MeanIntensity');
                flat_mean_background = regionprops(fullsize_im_local_background_mask, flatfielded_im_ef1a, 'MeanIntensity');
                
                raw_cfse_props(i).corresponding_ef1a_meansMinusBackground = [raw_cfse_props(i).corresponding_ef1a_meansMinusBackground,...
                    raw_ef1a_props(j).MeanIntensity - raw_mean_background.MeanIntensity];
                raw_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground = [raw_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground,...
                    raw_ef1a_props(j).Area * (raw_ef1a_props(j).MeanIntensity - raw_mean_background.MeanIntensity)];
                flatfielded_cfse_props(i).corresponding_ef1a_meansMinusBackground = [flatfielded_cfse_props(i).corresponding_ef1a_meansMinusBackground,...
                    flatfielded_ef1a_props(j).MeanIntensity - flat_mean_background.MeanIntensity];
                flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground = [flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground,...
                    flatfielded_ef1a_props(j).Area * (flatfielded_ef1a_props(j).MeanIntensity - flat_mean_background.MeanIntensity)];
            end
        end
        
        raw_cfse_props(i).sum_corresponding_ef1a_areas = sum(raw_cfse_props(i).corresponding_ef1a_areas);
        raw_cfse_props(i).sum_corresponding_ef1a_IntegratedIntensities = sum(raw_cfse_props(i).corresponding_ef1a_IntegratedIntensity);
        raw_cfse_props(i).sum_corresponding_ef1a_IntegratedIntensitiesMinusBackground = sum(raw_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground);
        
        flatfielded_cfse_props(i).sum_corresponding_ef1a_areas = sum(flatfielded_cfse_props(i).corresponding_ef1a_areas);
        flatfielded_cfse_props(i).sum_corresponding_ef1a_IntegratedIntensities = sum(flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensity);
        flatfielded_cfse_props(i).sum_corresponding_ef1a_IntegratedIntensitiesMinusBackground = sum(flatfielded_cfse_props(i).corresponding_ef1a_IntegratedIntensityMinusBackground);
        flatfielded_cfse_props(i).mean_corresponding_ef1a_MeanIntensityMinusBackground = mean(flatfielded_cfse_props(i).corresponding_ef1a_meansMinusBackground);
        
        %         if flatfielded_cfse_props(i).sum_corresponding_ef1a_areas > 500 && flatfielded_cfse_props(i).sum_corresponding_ef1a_areas < 1500
        %             if flatfielded_cfse_props(i).IntegratedIntensityMinusBackground < 250000
        %                 figure,imshow(CFSE_labels == i)
        %             end
        %         end
        
    end
    
    complete_data(pos).data_by_cfse_obj_raw = raw_cfse_props;
    complete_data(pos).data_by_cfse_obj_flat = flatfielded_cfse_props;
end

%% Gather data

all_cfse_areas = [];
all_cfse_raw_integratedintensities = [];
all_cfse_raw_integratedintensities_minusbackground = [];
all_cfse_flat_integratedintensities = [];
all_cfse_flat_integratedintensities_minusbackground = [];
all_ef1a_areas = [];
all_ef1a_raw_integratedintensities = [];
all_ef1a_raw_integratedintensities_minusbackground = [];
all_ef1a_flat_integratedintensities = [];
all_ef1a_flat_integratedintensities_minusbackground = [];
all_ef1a_flat_mean_minusbackground = [];

for pos = position_list
    for i = 1:length(complete_data(pos).data_by_cfse_obj_raw)
        all_cfse_areas = [all_cfse_areas;...
            complete_data(pos).data_by_cfse_obj_raw(i).Area];
        all_cfse_raw_integratedintensities = [all_cfse_raw_integratedintensities;...
            complete_data(pos).data_by_cfse_obj_raw(i).IntegratedIntensity];
        all_cfse_raw_integratedintensities_minusbackground = [all_cfse_raw_integratedintensities_minusbackground;...
            complete_data(pos).data_by_cfse_obj_raw(i).IntegratedIntensityMinusBackground];
        all_cfse_flat_integratedintensities = [all_cfse_flat_integratedintensities;...
            complete_data(pos).data_by_cfse_obj_flat(i).IntegratedIntensity];
        all_cfse_flat_integratedintensities_minusbackground = [all_cfse_flat_integratedintensities_minusbackground;...
            complete_data(pos).data_by_cfse_obj_flat(i).IntegratedIntensityMinusBackground];
        
        all_ef1a_areas = [all_ef1a_areas;...
            complete_data(pos).data_by_cfse_obj_raw(i).sum_corresponding_ef1a_areas];
        all_ef1a_raw_integratedintensities = [all_ef1a_raw_integratedintensities;...
            complete_data(pos).data_by_cfse_obj_raw(i).sum_corresponding_ef1a_IntegratedIntensities];
        all_ef1a_raw_integratedintensities_minusbackground = [all_ef1a_raw_integratedintensities_minusbackground;...
            complete_data(pos).data_by_cfse_obj_raw(i).sum_corresponding_ef1a_IntegratedIntensitiesMinusBackground];
        all_ef1a_flat_integratedintensities = [all_ef1a_flat_integratedintensities;...
            complete_data(pos).data_by_cfse_obj_flat(i).sum_corresponding_ef1a_IntegratedIntensities];
        all_ef1a_flat_integratedintensities_minusbackground = [all_ef1a_flat_integratedintensities_minusbackground;...
            complete_data(pos).data_by_cfse_obj_flat(i).sum_corresponding_ef1a_IntegratedIntensitiesMinusBackground];
        
        all_ef1a_flat_mean_minusbackground = [all_ef1a_flat_mean_minusbackground;...
            complete_data(pos).data_by_cfse_obj_flat(i).mean_corresponding_ef1a_MeanIntensityMinusBackground];
        
    end
end

save(['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data\' base_expt_name '.mat'])

%% Plot data

table_folder = 'C:\Users\Skotheim Lab\Desktop\Tables';
T = table;
T.CFSE_areas = all_cfse_areas;
T.nuclear_areas = all_ef1a_areas;
T.nuclear_volumes = all_ef1a_areas .^ 1.5;
T.ef1a_int_intens = all_ef1a_flat_integratedintensities_minusbackground;
T.CFSE_int_intens = all_cfse_flat_integratedintensities_minusbackground;
writetable(T,[table_folder '\' base_expt_name '_all_measurements.xlsx']);

figure_folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots';
figure_subfolder = [figure_folder '\' base_expt_name];
if ~exist(figure_subfolder,'dir')
    mkdir(figure_subfolder)
end

x_vars = {'CFSE_Areas','ef1a_Areas','ef1a_Volumes','ef1a_RawIntegratedIntensity','ef1a_RawIntegratedIntensityMinusBackground',...
    'ef1a_FlatfieldedIntegratedIntensity','ef1a_FlatfieldedIntegratedIntensityMinusBackground','ef1a_FlatMeanIntensityMinusBackground'};
y_vars = {'ef1a_Areas','CFSE_RawIntegratedIntensity','CFSE_RawIntegratedIntensityMinusBackground',...
    'CFSE_FlatfieldedIntegratedIntensity','CFSE_FlatfieldedIntegratedIntensityMinusBackground'};

x_vars = {'ef1a_Areas','ef1a_FlatfieldedIntegratedIntensityMinusBackground','ef1a_Volumes'};
y_vars = {'CFSE_FlatfieldedIntegratedIntensityMinusBackground'};

% x_vars = {'ef1a_FlatfieldedIntegratedIntensityMinusBackground'};
% y_vars = {'CFSE_FlatfieldedIntegratedIntensityMinusBackground'};

for x_var = x_vars
    for y_var = y_vars
        switch x_var{1}
            case 'CFSE_Areas'
                complete_data_to_scatter.x = all_cfse_areas;
                x_axis_label = 'CFSE object area';
            case 'ef1a_Areas'
                complete_data_to_scatter.x = all_ef1a_areas;
                x_axis_label = 'Nuclear ef1a object area (px2)';
            case 'ef1a_Volumes'
                complete_data_to_scatter.x = all_ef1a_areas .^ 1.5;
                x_axis_label = 'Nuclear ef1a object volume (px3)'
            case 'ef1a_RawIntegratedIntensity'
                complete_data_to_scatter.x = all_ef1a_raw_integratedintensities;
                x_axis_label = 'Raw ef1a integrated intensity';
            case 'ef1a_RawIntegratedIntensityMinusBackground'
                complete_data_to_scatter.x = all_ef1a_raw_integratedintensities_minusbackground;
                x_axis_label = 'Raw ef1a integrated intensity, minus background';
            case 'ef1a_FlatfieldedIntegratedIntensity'
                complete_data_to_scatter.x = all_ef1a_flat_integratedintensities;
                x_axis_label = 'Flatfielded ef1a integrated intensity';
            case 'ef1a_FlatfieldedIntegratedIntensityMinusBackground'
                complete_data_to_scatter.x = all_ef1a_flat_integratedintensities_minusbackground;
                x_axis_label = 'Flatfielded ef1a integrated intensity, minus background';
            case 'ef1a_FlatMeanIntensityMinusBackground'
                complete_data_to_scatter.x = all_ef1a_flat_mean_minusbackground;
                x_axis_label = 'Flatfielded ef1a mean intensity, minus background (AU)';
        end
        
        switch y_var{1}
            case 'ef1a_Areas'
                complete_data_to_scatter.y = all_ef1a_areas;
                y_axis_label = 'ef1a object area';
            case 'CFSE_RawIntegratedIntensity'
                complete_data_to_scatter.y = all_cfse_raw_integratedintensities;
                y_axis_label = 'Raw CFSE integrated intensity';
            case 'CFSE_RawIntegratedIntensityMinusBackground'
                complete_data_to_scatter.y = all_cfse_raw_integratedintensities_minusbackground;
                y_axis_label = 'Raw CFSE integrated intensity, minus background';
            case 'CFSE_FlatfieldedIntegratedIntensity'
                complete_data_to_scatter.y = all_cfse_flat_integratedintensities;
                y_axis_label = 'Flatfielded CFSE integrated intensity';
            case 'CFSE_FlatfieldedIntegratedIntensityMinusBackground'
                complete_data_to_scatter.y = all_cfse_flat_integratedintensities_minusbackground;
                y_axis_label = 'Flatfielded CFSE integrated intensity, minus background (AU)';
        end
        
        plot_scatter_with_line(complete_data_to_scatter.x, complete_data_to_scatter.y,'no_intercept');
        xlabel(x_axis_label)
        ylabel(y_axis_label)
        title([{['Positions ' num2str(position_list) ', All measured objects']};...
            {'Enforced 0-intercept'}])
        
        % Try to isolate only single cells
        
        objs_with_CFSE_area_within_range = all_cfse_areas < max_CFSE_obj_area & all_cfse_areas > min_CFSE_obj_area;
        
        clean_data_to_scatter.x = complete_data_to_scatter.x(objs_with_CFSE_area_within_range);
        clean_data_to_scatter.y = complete_data_to_scatter.y(objs_with_CFSE_area_within_range);
        
        plot_scatter_with_line(clean_data_to_scatter.x, clean_data_to_scatter.y,'no_intercept');
        xlabel(x_axis_label)
        ylabel(y_axis_label)
        title([{['Positions ' num2str(position_list) ', Objects with CFSE area between ' num2str(min_CFSE_obj_area) ' and ' num2str(max_CFSE_obj_area)]};...
            {'Enforced 0-intercept'}])
        
        saveas(gcf,[figure_subfolder '\' y_var{1} '_vs_' x_var{1} '.png'])
        
        
        % Try to isolate eliminate dead cells
        min_ef1a_area_to_examine_CFSE_intensity = 400;
        min_CFSE_intensity_live_cells = 250000;
        % If the ef1a area is below the minimum, it is expected to have
        % low CFSE intensity so we don't need to check and can use this cell.
        % If the ef1a area is above this minimum, then we check whether
        % the CFSE intensity is above this threshold.
        objs_with_CFSE_intensity_within_range = all_ef1a_areas < min_ef1a_area_to_examine_CFSE_intensity | all_cfse_flat_integratedintensities_minusbackground > min_CFSE_intensity_live_cells;
        cleanest_data_to_scatter.x = complete_data_to_scatter.x(objs_with_CFSE_area_within_range & objs_with_CFSE_intensity_within_range);
        cleanest_data_to_scatter.y = complete_data_to_scatter.y(objs_with_CFSE_area_within_range & objs_with_CFSE_intensity_within_range);
        
        plot_scatter_with_line(cleanest_data_to_scatter.x, cleanest_data_to_scatter.y,'no_intercept');
        xlabel(x_axis_label)
        ylabel(y_axis_label)
        title([{['Positions ' num2str(position_list) ', Objects with CFSE area between ' num2str(min_CFSE_obj_area) ' and ' num2str(max_CFSE_obj_area)]};...
            {['and CFSE intensity > ' num2str(min_CFSE_intensity_live_cells) ' for cells with nuclear area > ' num2str(min_ef1a_area_to_examine_CFSE_intensity) ', Enforced 0-intercept']}])
        
        saveas(gcf,[figure_subfolder '\' y_var{1} '_vs_' x_var{1} '.png'])
        
        fileID = fopen([table_folder '\' base_expt_name '_Cleaning_Parameters.txt'],'w');
        fprintf(fileID,['Look at only single cells: CFSE area between ' num2str(min_CFSE_obj_area) ' and ' num2str(max_CFSE_obj_area) '\r\n']);
        fprintf(fileID,['Attempt to eliminate dead cells by examining CFSE intensity. \r\n']);
        fprintf(fileID,['If these cells have nuclear area less than ' num2str(min_ef1a_area_to_examine_CFSE_intensity)...
            ', it is expected to have low CFSE intensity so we can''t check further. \r\n']);
        fprintf(fileID,['If the nuclear area is larger than that number, then we can look for dead cells'...
            ' which are defined as cells with CFSE intensity less than ' num2str(min_CFSE_intensity_live_cells) '\r\n']);
        fclose(fileID);
        
        %         cleaner_data_to_scatter.x = complete_data_to_scatter.x(objs_with_CFSE_area_within_range & objs_with_CFSE_intensity_within_range);
        %         cleaner_data_to_scatter.y = complete_data_to_scatter.y(objs_with_CFSE_area_within_range & objs_with_CFSE_intensity_within_range);
        %
        %         plot_scatter_with_line(cleaner_data_to_scatter.x, cleaner_data_to_scatter.y,'no_intercept');
        %         xlabel(x_axis_label)
        %         ylabel(y_axis_label)
        %         title(['Positions ' num2str(position_list) ', Objects with CFSE area between ' num2str(min_CFSE_obj_area) ' and ' num2str(max_CFSE_obj_area) ' and also with CFSE intensity within range'])
        
        
    end
end
% end
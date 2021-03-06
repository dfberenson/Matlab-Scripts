
folder = 'F:\DFB_imaging_experiments_2';
expt_name = 'DFB_181021_HMEC_1GFiii';

measurements_folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Still_Imaging_Data';


if exist([measurements_folder '\' expt_name '_Measurements.mat'])
    response = questdlg('Data have already been measured. Use previously recorded measurements?');
end
if strcmp(response,'Yes')
    load([measurements_folder '\' expt_name '_Measurements.mat'])
else
    
    
    all_mcherry_constantexposure_before = [];
    all_mcherry_intermittentexposure_before = [];
    all_mcherry_noexposure_before = [];
    all_mcherry_constantexposure_after = [];
    all_mcherry_intermittentexposure_after = [];
    all_mcherry_noexposure_after = [];
    
    for pos = [0:11]
        disp(['Measuring position ' num2str(pos)])
        for status = [{'before'},{'after'}]
            
            fpath = [folder '\' expt_name '_' status{1} '_1\' expt_name '_' status{1} '_1_MMStack_Pos' num2str(pos) '.ome.tif'];
            im = readStack(fpath);
            [Y,X,num_channels] = size(im);
            assert(num_channels == 3)
            im_mCherry = im(:,:,1);
            
            gaussian_width = 2;
            threshold = 225;
            strel_shape = 'disk';
            strel_size = 3;
            se = strel(strel_shape,strel_size);
            
            
            
            gaussian_filtered = imgaussfilt(im_mCherry,gaussian_width);
            % figure,imshow(gaussian_filtered,[])
            thresholded = gaussian_filtered > threshold;
            % figure,imshow(thresholded)
            im_opened = imopen(thresholded,se);
            % figure,imshow(im_opened)
            im_closed = imclose(im_opened,se);
            % figure,imshow(im_closed)
            segmented_im = im_closed;
            
            mcherry_mode = mode(im_mCherry(:));
            zeroed_im_mcherry = im_mCherry - mcherry_mode;
            blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
            blank_field_mean = mean(blank_field(:));
            flatfielded_im_mcherry = double(zeroed_im_mcherry)  * blank_field_mean ./ blank_field;
            
            [L,num_cells] = bwlabel(segmented_im,4);
            
            thispos_mcherry_intintens = zeros(num_cells,1);
            
            for cellnum = 1:num_cells
                thiscellmask = L == cellnum;
                label_props = regionprops(thiscellmask,'Area','BoundingBox');
                
                % Expand bounding box in each direction to examine
                % local background.
                local_expansion = 100;
                
                boundingBox_vals = label_props.BoundingBox;
                x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
                x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
                y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
                y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
                
                boundingBox = segmented_im(y_min:y_max, x_min:x_max);
                boundingBox_background_mask = boundingBox == 0;
                fullsize_im_local_background_mask = zeros(Y,X);
                fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
                
                mcherry_flat_props = regionprops(thiscellmask,flatfielded_im_mcherry,'MeanIntensity');
                mcherry_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_mcherry,'MeanIntensity');
                mcherry_net_mean = mcherry_flat_props.MeanIntensity - mcherry_flat_background_props.MeanIntensity;
                
                thispos_mcherry_intintens(cellnum) = mcherry_net_mean * label_props.Area;
            end
            
            switch status{1}
                case 'before'
                    switch pos
                        case {0,1,2,3}
                            all_mcherry_constantexposure_before = [all_mcherry_constantexposure_before; thispos_mcherry_intintens];
                        case {4,5,6,7}
                            all_mcherry_intermittentexposure_before = [all_mcherry_intermittentexposure_before; thispos_mcherry_intintens];
                        case {8,9,10,11}
                            all_mcherry_noexposure_before = [all_mcherry_noexposure_before; thispos_mcherry_intintens];
                    end
                case 'after'
                    switch pos
                        case {0,1,2,3}
                            all_mcherry_constantexposure_after = [all_mcherry_constantexposure_after; thispos_mcherry_intintens];
                        case {4,5,6,7}
                            all_mcherry_intermittentexposure_after = [all_mcherry_intermittentexposure_after; thispos_mcherry_intintens];
                        case {8,9,10,11}
                            all_mcherry_noexposure_after = [all_mcherry_noexposure_after; thispos_mcherry_intintens];
                    end
            end
        end
        clear im
        clear im_mCherry
        clear flatfielded_im_mcherry
        clear fullsize_im_local_background_mask
        clear gaussian_filtered
        clear thresholded
        clear im_opened
        clear im_closed
        clear segmented_im
        clear L
        clear thiscellmask
    end
    
    mean_mcherry_constantexposure_before = mean(all_mcherry_constantexposure_before);
    median_mcherry_constantexposure_before = median(all_mcherry_constantexposure_before);
    firstquartile_mcherry_constantexposure_before = quantile(all_mcherry_constantexposure_before,0.25);
    thirdquartile_mcherry_constantexposure_before = quantile(all_mcherry_constantexposure_before,0.75);
    stdevs_mcherry_constantexposure_before = std(all_mcherry_constantexposure_before);
    stderrs_mcherry_constantexposure_before = stdevs_mcherry_constantexposure_before / sqrt(length(all_mcherry_constantexposure_before));
    
    mean_mcherry_intermittentexposure_before = mean(all_mcherry_intermittentexposure_before);
    median_mcherry_intermittentexposure_before = median(all_mcherry_intermittentexposure_before);
    firstquartile_mcherry_intermittentexposure_before = quantile(all_mcherry_intermittentexposure_before,0.25);
    thirdquartile_mcherry_intermittentexposure_before = quantile(all_mcherry_intermittentexposure_before,0.75);
    stdevs_mcherry_intermittentexposure_before = std(all_mcherry_intermittentexposure_before);
    stderrs_mcherry_intermittentexposure_before = stdevs_mcherry_intermittentexposure_before / sqrt(length(all_mcherry_intermittentexposure_before));
    
    mean_mcherry_noexposure_before = mean(all_mcherry_noexposure_before);
    median_mcherry_noexposure_before = median(all_mcherry_noexposure_before);
    firstquartile_mcherry_noexposure_before = quantile(all_mcherry_noexposure_before,0.25);
    thirdquartile_mcherry_noexposure_before = quantile(all_mcherry_noexposure_before,0.75);
    stdevs_mcherry_noexposure_before = std(all_mcherry_noexposure_before);
    stderrs_mcherry_noexposure_before = stdevs_mcherry_noexposure_before / sqrt(length(all_mcherry_noexposure_before));
    
    mean_mcherry_constantexposure_after = mean(all_mcherry_constantexposure_after);
    median_mcherry_constantexposure_after = median(all_mcherry_constantexposure_after);
    firstquartile_mcherry_constantexposure_after = quantile(all_mcherry_constantexposure_after,0.25);
    thirdquartile_mcherry_constantexposure_after = quantile(all_mcherry_constantexposure_after,0.75);
    stdevs_mcherry_constantexposure_after = std(all_mcherry_constantexposure_after);
    stderrs_mcherry_constantexposure_after = stdevs_mcherry_constantexposure_after / sqrt(length(all_mcherry_constantexposure_after));
    
    mean_mcherry_intermittentexposure_after = mean(all_mcherry_intermittentexposure_after);
    median_mcherry_intermittentexposure_after = median(all_mcherry_intermittentexposure_after);
    firstquartile_mcherry_intermittentexposure_after = quantile(all_mcherry_intermittentexposure_after,0.25);
    thirdquartile_mcherry_intermittentexposure_after = quantile(all_mcherry_intermittentexposure_after,0.75);
    stdevs_mcherry_intermittentexposure_after = std(all_mcherry_intermittentexposure_after);
    stderrs_mcherry_intermittentexposure_after = stdevs_mcherry_intermittentexposure_after / sqrt(length(all_mcherry_intermittentexposure_after));
    
    mean_mcherry_noexposure_after = mean(all_mcherry_noexposure_after);
    median_mcherry_noexposure_after = median(all_mcherry_noexposure_after);
    firstquartile_mcherry_noexposure_after = quantile(all_mcherry_noexposure_after,0.25);
    thirdquartile_mcherry_noexposure_after = quantile(all_mcherry_noexposure_after,0.75);
    stdevs_mcherry_noexposure_after = std(all_mcherry_noexposure_after);
    stderrs_mcherry_noexposure_after = stdevs_mcherry_noexposure_after / sqrt(length(all_mcherry_noexposure_after));
    
    save([measurements_folder '\' expt_name '_Measurements.mat']) 
end

disp(['Percent decrease in median mcherry integrated intensity after constant exposure: ' num2str(1 - median_mcherry_constantexposure_after / median_mcherry_constantexposure_before)])
disp(['Percent decrease in median mcherry integrated intensity after intermittent exposure: ' num2str(1 - median_mcherry_intermittentexposure_after / median_mcherry_intermittentexposure_before)])
disp(['Percent decrease in median mcherry integrated intensity after no exposure: ' num2str(1 - median_mcherry_noexposure_after / median_mcherry_intermittentexposure_before)])


figure
hold on
cdfplot(all_mcherry_constantexposure_before)
cdfplot(all_mcherry_intermittentexposure_before)
cdfplot(all_mcherry_noexposure_before)
cdfplot(all_mcherry_constantexposure_after)
cdfplot(all_mcherry_intermittentexposure_after)
cdfplot(all_mcherry_noexposure_after)
legend({'Constant, before','Intermittent, before', 'Dark, before', 'Constant, after', 'Intermittent, after', 'Dark, after'})
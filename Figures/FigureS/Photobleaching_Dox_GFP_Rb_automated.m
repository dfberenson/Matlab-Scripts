
clear all
close all

folder = 'I:';
expt_name = 'DFB_181114_HMEC_BT45_slowframes_2';

%% Segment

gaussian_width = 2;
threshold = 1200;
strel_shape = 'disk';
strel_size = 3;
se = strel(strel_shape,strel_size);

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));
max_area = 1200;
min_area = 100;

for timepoint = 1:5
    areas{timepoint} = [];
    mean_intens{timepoint} = [];
    int_intens{timepoint} = [];
    for pos = [1 2 3 5 6 7 8 9 10 11 12 13 14 15 16]
        disp(['Measuring timepoint ' num2str(timepoint) ' position ' num2str(pos)])
        t = (timepoint-1)*36;
        gfp_im = imread([folder '\' expt_name '\Pos' num2str(pos) '\img_channel001_position' sprintf('%03d',pos) '_time' sprintf('%09d',t) '_z000.tif']);
        %         figure,imshow(gfp_im,[500 3500])
        
        [Y,X] = size(gfp_im);
        
        gaussian_filtered = imgaussfilt(gfp_im,gaussian_width);
        %             imtool(gaussian_filtered)
        %     figure,imshow(gaussian_filtered,[])
        thresholded = gaussian_filtered > threshold;
        % figure,imshow(thresholded)
        im_opened = imopen(thresholded,se);
        % figure,imshow(im_opened)
        im_closed = imclose(im_opened,se);
        segmented_im = im_closed;
        %         figure,imshow(segmented_im)
        
        zeroed_gfp_im = gfp_im - mode(gfp_im(:));
        flatfielded_gfp_im = double(zeroed_gfp_im) * blank_field_mean ./ blank_field;
        
        [L,n] = bwlabel(segmented_im,4);
        
        for i = 1:n
            thiscellmask = L == i;
            
            label_props = regionprops(thiscellmask,'Area','BoundingBox');
            area = label_props.Area;
            
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
            
            green_raw_props = regionprops(thiscellmask,gfp_im,'MeanIntensity');
            green_flat_props = regionprops(thiscellmask,flatfielded_gfp_im,'MeanIntensity');
            
            green_raw_background_props = regionprops(fullsize_im_local_background_mask, gfp_im, 'MeanIntensity');
            green_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_gfp_im, 'MeanIntensity');
            
            if area < max_area && area > min_area
                areas{timepoint} = [areas{timepoint}; area];
                mean_intens{timepoint} = [mean_intens{timepoint}; green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity];
                int_intens{timepoint} = [int_intens{timepoint}; area * (green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity)];
            end
        end
    end
end

%% Plot

for timepoint = 1:5
    mean_areas(timepoint) = mean(areas{timepoint});
    mean_mean_intens(timepoint) = mean(mean_intens{timepoint});
    mean_int_intens(timepoint) = mean(int_intens{timepoint});
    
    stdev_areas(timepoint) = std(areas{timepoint});
    stdev_mean_intens(timepoint) = std(mean_intens{timepoint});
    stdev_int_intens(timepoint) = std(int_intens{timepoint});
    
    stderr_areas(timepoint) = std(areas{timepoint}) / sqrt(length(areas{timepoint}));
    stderr_mean_intens(timepoint) = std(mean_intens{timepoint}) / sqrt(length(mean_intens{timepoint}));
    stderr_int_intens(timepoint) = std(int_intens{timepoint}) / sqrt(length(int_intens{timepoint}));
end

figure
shadedErrorBar([0,12,24,36,48],mean_areas,stdev_areas)
xlabel('Time (h)')
ylabel('Area (px^2)')

figure
shadedErrorBar([0,12,24,36,48],mean_mean_intens,stdev_mean_intens)
xlabel('Time (h)')
ylabel('Mean intensity')

figure
shadedErrorBar([0,12,24,36,48],mean_int_intens,stdev_int_intens)
xlabel('Time (h)')
ylabel('Integrated intensty')
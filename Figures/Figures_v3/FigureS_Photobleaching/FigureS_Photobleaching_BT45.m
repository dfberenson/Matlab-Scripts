

clear all
close all

folder = 'I:';

for cond = 1:2
    if cond ==  1
        expt_name = 'DFB_181114_HMEC_BT45_slowframes_2';
    elseif cond == 2
        expt_name = 'DFB_181214_BT45_slowframes_1';
    end
    
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
        if strcmp(expt_name,'DFB_181114_HMEC_BT45_slowframes_2')
            positions = 1:16;
        elseif strcmp(expt_name,'DFB_181214_BT45_slowframes_1')
            positions = 1:24;
        end
        for pos = positions
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
    
    %% Measure distributions
    
    for timepoint = 1:5
        mean_areas(timepoint,cond) = mean(areas{timepoint});
        mean_mean_intens(timepoint,cond) = mean(mean_intens{timepoint});
        mean_int_intens(timepoint,cond) = mean(int_intens{timepoint});
        
        stdev_areas(timepoint,cond) = std(areas{timepoint});
        stdev_mean_intens(timepoint,cond) = std(mean_intens{timepoint});
        stdev_int_intens(timepoint,cond) = std(int_intens{timepoint});
        
        stderr_areas(timepoint,cond) = std(areas{timepoint}) / sqrt(length(areas{timepoint}));
        stderr_mean_intens(timepoint,cond) = std(mean_intens{timepoint}) / sqrt(length(mean_intens{timepoint}));
        stderr_int_intens(timepoint,cond) = std(int_intens{timepoint}) / sqrt(length(int_intens{timepoint}));
    end
end

save('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Photobleaching.mat')

%% Plot

% Black is GFP q12h
% Blue is GFP q20min

normalized_mean_areas = mean_areas ./ mean_areas(1,:);
normalized_mean_mean_intens = mean_mean_intens ./ mean_mean_intens(1,:);
normalized_mean_int_intens = mean_int_intens ./ mean_int_intens(1,:);

normalized_stdev_areas = stdev_areas ./ mean_areas(1,:);
normalized_stdev_mean_intens = stdev_mean_intens ./ mean_mean_intens(1,:);
normalized_stdev_int_intens = stdev_int_intens  ./ mean_int_intens(1,:);

normalized_stderr_areas = stderr_areas ./ mean_areas(1,:);
normalized_stderr_mean_intens = stderr_mean_intens ./ mean_mean_intens(1,:);
normalized_stderr_int_intens = stderr_int_intens  ./ mean_int_intens(1,:);

figure
hold on
shadedErrorBar([0,12,24,36,48],normalized_mean_areas(:,1),normalized_stdev_areas(:,1),'k',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_areas(:,2),normalized_stdev_areas(:,2),'b',0.5)
xlabel('Time (h)')
ylabel('Area (px^2)')

figure
hold on
shadedErrorBar([0,12,24,36,48],normalized_mean_mean_intens(:,1),normalized_stdev_mean_intens(:,1),'k',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_mean_intens(:,2),normalized_stdev_mean_intens(:,2),'b',0.5)
xlabel('Time (h)')
ylabel('Mean intensity')

figure
hold on
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,1),normalized_stdev_int_intens(:,1),'k',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,2),normalized_stdev_int_intens(:,2),'b',0.5)
xlabel('Time (h)')
ylabel('Integrated intensty')

figure
hold on
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,1),normalized_stderr_int_intens(:,1),'k',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,2),normalized_stderr_int_intens(:,2),'b',0.5)
xlabel('Time (h)')
ylabel('Integrated intensty')

figure
hold on
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,1),normalized_stdev_int_intens(:,1),'b',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,2),normalized_stdev_int_intens(:,2),'m',0.5)
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,1),normalized_stderr_int_intens(:,1),'k',0)
shadedErrorBar([0,12,24,36,48],normalized_mean_int_intens(:,2),normalized_stderr_int_intens(:,2),'r',0.5)
xlabel('Time (h)')
ylabel('Integrated intensty')
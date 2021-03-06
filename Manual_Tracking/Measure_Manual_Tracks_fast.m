%% Initialize variables

close all
clear all

% expt_folder = 'C:\Users\Skotheim Lab\Desktop\Manual_Tracking';
% expt_name = 'DFB_180822_HMEC_1GFiii_1_Pos1';
expt_folder = 'H:\Manually tracked imaging experiments';
expt_name = 'DFB_181031_HMEC_1E+gem_palbo_1_Pos1';

segmentation_prefix = [expt_folder '\' expt_name '\'...
    'Segmentation\Segmented'];
resegmentation_prefix = [expt_folder '\' expt_name '\'...
    'Resegmentation\Resegmented'];
raw_red_prefix = [expt_folder '\' expt_name '\'...
    expt_name '_RawRed\' expt_name '_RawRed'];
raw_green_prefix = [expt_folder '\' expt_name '\'...
    expt_name '_RawGreen\' expt_name '_RawGreen'];

load([expt_folder '\' expt_name '\TrackingData.mat']);
s = saved_data;

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));


% cellnum = input('Choose a cell number to plot: ');
cells_to_track = s.all_tracknums;
% cells_to_track = [2];

%% At each timepoint, measure each cell

for t = s.startframe:s.endframe
    disp(['Measuring time ' num2str(t)]);
    raw_im_red = double(imread([raw_red_prefix '_' sprintf('%03d',t) '.tif']));
    raw_im_green = double(imread([raw_green_prefix '_' sprintf('%03d',t) '.tif']));
    if exist([resegmentation_prefix '_' sprintf('%03d',t) '.tif']);
        segmented_im = imread([resegmentation_prefix '_' sprintf('%03d',t) '.tif']);
    else
        segmented_im = imread([segmentation_prefix '_' sprintf('%03d',t) '.tif']);
    end
    
    img_size = size(segmented_im);
    Y = img_size(1);
    X = img_size(2);
    
    raw_im_red_mode = mode(raw_im_red(:));
    raw_im_green_mode = mode(raw_im_green(:));
    
    zeroed_im_red = raw_im_red - raw_im_red_mode;
    zeroed_im_green = raw_im_green - raw_im_green_mode;
    flatfielded_im_red = zeroed_im_red * blank_field_mean ./ blank_field;
    flatfielded_im_green = zeroed_im_green * blank_field_mean ./ blank_field;
    
    [L,~] = bwlabel(segmented_im,4);
    
    for cellnum = cells_to_track
        disp(['Measuring cell ' num2str(cellnum)]);
        click_table_size = size(s.clicks);
        if cellnum <= click_table_size(2)
            area_trace = [];
            red_raw_integrated_intensity_trace = [];
            green_raw_integrated_intensity_trace = [];
            red_flat_integrated_intensity_trace = [];
            green_flat_integrated_intensity_trace= [];
            
            click = s.clicks{t,cellnum};
            if ~isempty(click)
                x = click(1);
                y = click(2);
                thislabelnum = L(y,x);
                thiscellmask = L == thislabelnum;
                
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

                red_raw_props = regionprops(thiscellmask,raw_im_red,'MeanIntensity');
                green_raw_props = regionprops(thiscellmask,raw_im_green,'MeanIntensity');
                red_flat_props = regionprops(thiscellmask,flatfielded_im_red,'MeanIntensity');
                green_flat_props = regionprops(thiscellmask,flatfielded_im_green,'MeanIntensity');
                
                red_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
                green_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
                red_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_red, 'MeanIntensity');
                green_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_green, 'MeanIntensity');
                
                area_trace(t) = label_props.Area;
                red_raw_integrated_intensity_trace(t) = area_trace(t) * (red_raw_props.MeanIntensity - red_raw_background_props.MeanIntensity);
                green_raw_integrated_intensity_trace(t) = area_trace(t) * (green_raw_props.MeanIntensity - green_raw_background_props.MeanIntensity);
                red_flat_integrated_intensity_trace(t) = area_trace(t) * (red_flat_props.MeanIntensity - red_flat_background_props.MeanIntensity);
                green_flat_integrated_intensity_trace(t) = area_trace(t) * (green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity);
                
                all_area_traces(t,cellnum) = area_trace(t);
                all_red_raw_integrated_intensity_traces(t,cellnum) = red_raw_integrated_intensity_trace(t);
                all_green_raw_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
                all_red_flat_integrated_intensity_traces(t,cellnum) = red_flat_integrated_intensity_trace(t);
                all_green_flat_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
            end
        end
    end
end

measurements_struct.all_area_traces = all_area_traces;
measurements_struct.all_red_raw_integrated_intensity_traces = all_red_raw_integrated_intensity_traces;
measurements_struct.all_green_raw_integrated_intensity_traces = all_green_raw_integrated_intensity_traces;
measurements_struct.all_red_flat_integrated_intensity_traces = all_red_flat_integrated_intensity_traces;
measurements_struct.all_green_flat_integrated_intensity_traces = all_green_flat_integrated_intensity_traces;
save([expt_folder '\' expt_name '\Measurements.mat'], 'measurements_struct');

%% Plot data


response = questdlg('Plot cells?');
if strcmp(response,'Yes')
    
else
    return
end

% for cellnum = cells_to_track
for cellnum = [1 2 3 4 5]
    area_trace = measurements_struct.all_area_traces(:,cellnum);
    red_raw_integrated_intensity_trace = measurements_struct.all_red_raw_integrated_intensity_traces(:,cellnum);
    green_raw_integrated_intensity_trace = measurements_struct.all_green_raw_integrated_intensity_traces(:,cellnum);
    red_flat_integrated_intensity_trace = measurements_struct.all_red_flat_integrated_intensity_traces(:,cellnum);
    green_flat_integrated_intensity_trace = measurements_struct.all_green_flat_integrated_intensity_traces(:,cellnum);
    
    
    figure,title(['Red raw integrated intensity for cell ' num2str(cellnum)]);
    hold on
    plot(red_raw_integrated_intensity_trace,'r')
    drawnow
    hold off
    
    figure,title(['Green raw integrated intensity for cell ' num2str(cellnum)]);
    hold on
    plot(green_raw_integrated_intensity_trace,'g')
    drawnow
    hold off
    
    figure,title(['Red flatfielded integrated intensity for cell ' num2str(cellnum)]);
    hold on
    plot(red_flat_integrated_intensity_trace,'r')
    drawnow
    hold off
    
    figure,title(['Green flatfielded integrated intensity for cell ' num2str(cellnum)]);
    hold on
    plot(green_flat_integrated_intensity_trace,'g')
    drawnow
    hold off
    
    figure,title(['Areas for cell ' num2str(cellnum)]);
    hold on
    plot(area_trace,'k')
    drawnow
    hold off
end
%% Initialize variables

close all
clear all

expt_folder = 'C:\Users\Skotheim Lab\Desktop\Manual_Tracking';
expt_name = 'DFB_180803_HMEC_D5_1_Pos13';

segmentation_prefix = [expt_folder '\' expt_name '\'...
    'Segmentation\Segmented'];
resegmentation_prefix = [expt_folder '\' expt_name '\'...
    'Resegmentation\Resegmented'];
raw_farred_prefix = [expt_folder '\' expt_name '\'...
    expt_name '_RawFarRed\' expt_name '_RawFarRed'];
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
    raw_im_farred = double(imread([raw_farred_prefix '_' sprintf('%03d',t) '.tif']));
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
    
    raw_im_farred_mode = mode(raw_im_farred(:));
    raw_im_red_mode = mode(raw_im_red(:));
    raw_im_green_mode = mode(raw_im_green(:));
    
    zeroed_im_farred = raw_im_farred - raw_im_farred_mode;
    zeroed_im_red = raw_im_red - raw_im_red_mode;
    zeroed_im_green = raw_im_green - raw_im_green_mode;
    flatfielded_im_farred = zeroed_im_farred * blank_field_mean ./ blank_field;
    flatfielded_im_red = zeroed_im_red * blank_field_mean ./ blank_field;
    flatfielded_im_green = zeroed_im_green * blank_field_mean ./ blank_field;
    
    [L,~] = bwlabel(segmented_im,4);
    
    for cellnum = cells_to_track
        disp(['Measuring cell ' num2str(cellnum)]);
        click_table_size = size(s.clicks);
        if cellnum <= click_table_size(2)
            area_trace = [];
            farred_raw_integrated_intensity_trace = [];
            red_raw_integrated_intensity_trace = [];
            green_raw_integrated_intensity_trace = [];
            farred_flat_integrated_intensity_trace = [];
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
                
                farred_raw_props = regionprops(thiscellmask,raw_im_farred,'MeanIntensity');
                red_raw_props = regionprops(thiscellmask,raw_im_red,'MeanIntensity');
                green_raw_props = regionprops(thiscellmask,raw_im_green,'MeanIntensity');
                farred_flat_props = regionprops(thiscellmask,flatfielded_im_farred,'MeanIntensity');
                red_flat_props = regionprops(thiscellmask,flatfielded_im_red,'MeanIntensity');
                green_flat_props = regionprops(thiscellmask,flatfielded_im_green,'MeanIntensity');
                
                farred_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_farred, 'MeanIntensity');
                red_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
                green_raw_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
                farred_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_farred, 'MeanIntensity');
                red_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_red, 'MeanIntensity');
                green_flat_background_props = regionprops(fullsize_im_local_background_mask, flatfielded_im_green, 'MeanIntensity');
                
                area_trace(t) = label_props.Area;
                farred_raw_integrated_intensity_trace(t) = area_trace(t) * (farred_raw_props.MeanIntensity - farred_raw_background_props.MeanIntensity);
                red_raw_integrated_intensity_trace(t) = area_trace(t) * (red_raw_props.MeanIntensity - red_raw_background_props.MeanIntensity);
                green_raw_integrated_intensity_trace(t) = area_trace(t) * (green_raw_props.MeanIntensity - green_raw_background_props.MeanIntensity);
                farred_flat_integrated_intensity_trace(t) = area_trace(t) * (farred_flat_props.MeanIntensity - farred_flat_background_props.MeanIntensity);
                red_flat_integrated_intensity_trace(t) = area_trace(t) * (red_flat_props.MeanIntensity - red_flat_background_props.MeanIntensity);
                green_flat_integrated_intensity_trace(t) = area_trace(t) * (green_flat_props.MeanIntensity - green_flat_background_props.MeanIntensity);
                
                % Take the measurements for this cell and put them into the
                % overall matrix.
                all_area_traces(t,cellnum) = area_trace(t);
                all_farred_raw_integrated_intensity_traces(t,cellnum) = farred_raw_integrated_intensity_trace(t);
                all_red_raw_integrated_intensity_traces(t,cellnum) = red_raw_integrated_intensity_trace(t);
                all_green_raw_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
                all_farred_flat_integrated_intensity_traces(t,cellnum) = farred_flat_integrated_intensity_trace(t);
                all_red_flat_integrated_intensity_traces(t,cellnum) = red_flat_integrated_intensity_trace(t);
                all_green_flat_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
                
            else
                % It might be that the click is empty even though the cell
                % exists. If so, set all measurements at that
                % timepoint to zero.
                if s.track_metadata(cellnum).firstframe <= t && s.track_metadata(cellnum).lastframe >= t
                    area_trace(t) = label_props.Area;
                    farred_raw_integrated_intensity_trace(t) = 0;
                    red_raw_integrated_intensity_trace(t) = 0;
                    green_raw_integrated_intensity_trace(t) = 0;
                    farred_flat_integrated_intensity_trace(t) = 0;
                    red_flat_integrated_intensity_trace(t) = 0;
                    green_flat_integrated_intensity_trace(t) = 0;
                    
                    % Take the measurements for this cell and put them into the
                    % overall matrix.
                    all_area_traces(t,cellnum) = area_trace(t);
                    all_farred_raw_integrated_intensity_traces(t,cellnum) = farred_raw_integrated_intensity_trace(t);
                    all_red_raw_integrated_intensity_traces(t,cellnum) = red_raw_integrated_intensity_trace(t);
                    all_green_raw_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
                    all_farred_flat_integrated_intensity_traces(t,cellnum) = farred_flat_integrated_intensity_trace(t);
                    all_red_flat_integrated_intensity_traces(t,cellnum) = red_flat_integrated_intensity_trace(t);
                    all_green_flat_integrated_intensity_traces(t,cellnum) = green_raw_integrated_intensity_trace(t);
                end
            end
        end
    end
end

measurements_struct.all_area_traces = all_area_traces;
measurements_struct.all_farred_raw_integrated_intensity_traces = all_farred_raw_integrated_intensity_traces;
measurements_struct.all_red_raw_integrated_intensity_traces = all_red_raw_integrated_intensity_traces;
measurements_struct.all_green_raw_integrated_intensity_traces = all_green_raw_integrated_intensity_traces;
measurements_struct.all_farred_flat_integrated_intensity_traces = all_farred_flat_integrated_intensity_traces;
measurements_struct.all_red_flat_integrated_intensity_traces = all_red_flat_integrated_intensity_traces;
measurements_struct.all_green_flat_integrated_intensity_traces = all_green_flat_integrated_intensity_traces;
save([expt_folder '\' expt_name '\Measurements.mat'], 'measurements_struct');

%% Plot data

load([expt_folder '\' expt_name '\Measurements.mat']);

% response = questdlg('Plot cells?');
response = 'Yes';
if strcmp(response,'Yes')
    
else
    return
end

for cellnum = cells_to_track
    firstframe = s.track_metadata(cellnum).firstframe;
    lastframe = s.track_metadata(cellnum).lastframe;
    if ~isempty(s.track_metadata(cellnum).mitosis) && lastframe - firstframe > 60
        area_trace = measurements_struct.all_area_traces(:,cellnum);
        farred_raw_integrated_intensity_trace = measurements_struct.all_farred_raw_integrated_intensity_traces(:,cellnum);
        red_raw_integrated_intensity_trace = measurements_struct.all_red_raw_integrated_intensity_traces(:,cellnum);
        green_raw_integrated_intensity_trace = measurements_struct.all_green_raw_integrated_intensity_traces(:,cellnum);
        farred_flat_integrated_intensity_trace = measurements_struct.all_farred_flat_integrated_intensity_traces(:,cellnum);
        red_flat_integrated_intensity_trace = measurements_struct.all_red_flat_integrated_intensity_traces(:,cellnum);
        green_flat_integrated_intensity_trace = measurements_struct.all_green_flat_integrated_intensity_traces(:,cellnum);
        
        local_area_trace = measurements_struct.all_area_traces(firstframe:lastframe,cellnum);
        local_farred_flat_trace = measurements_struct.all_farred_flat_integrated_intensity_traces(firstframe:lastframe,cellnum);
        local_red_flat_trace = measurements_struct.all_red_flat_integrated_intensity_traces(firstframe:lastframe,cellnum);
        local_green_flat_trace = measurements_struct.all_green_flat_integrated_intensity_traces(firstframe:lastframe,cellnum);
        
        %                 figure()
        %                 hold on
        %                 xlabel('Frame q10min')
        %                 yyaxis left
        %                 plot(farred_flat_integrated_intensity_trace, 'r')
        %                 ax = gca;
        %                 ax.YColor = 'r';
        %                 ylabel('EF1a-Crimson size measurement')
        %                 yyaxis right
        %                 plot(red_flat_integrated_intensity_trace, 'm')
        %                 ax = gca;
        %                 ax.YColor = 'm';
        %                 ylabel('Geminin-mCherry')
        %                 hold off
        %
        %         smooth_farred_flat_integrated_intensity_trace = movmedian(farred_flat_integrated_intensity_trace, 5);
        %         figure()
        %         hold on
        %         xlabel('Frame q10min')
        %         yyaxis left
        %         plot(smooth_farred_flat_integrated_intensity_trace, 'r')
        %         ax = gca;
        %         ax.YColor = 'r'
        %         ylabel('EF1a-Crimson size measurement, smoothened')
        %         yyaxis right
        %         plot(red_flat_integrated_intensity_trace ./ smooth_farred_flat_integrated_intensity_trace, 'm')
        %         % A threshold value here of 0.15 is looking pretty good
        %         ax = gca;
        %         ax.YColor = 'm';
        %         ylabel('Geminin-mCherry, normalized to smoothened Crimson')
        %         hold off
        
        analysis_parameters.strategy = 'all';
        analysis_parameters.min_total_trace_frames = 30;
        analysis_parameters.num_first_frames_to_avoid = 0;
        analysis_parameters.num_last_frames_to_avoid = 10;
        analysis_parameters.threshold = 0.15;
        analysis_parameters.frames_to_check_nearby = 20;
        analysis_parameters.min_frames_above = 15;
        analysis_parameters.second_line_min_slope = 0.05/20;
        analysis_parameters.require_tight_clustering_of_strategies = true;
        analysis_parameters.max_g1s_noise_frames = 10;
        analysis_parameters.plot = true;
        
        normalized_geminin_trace = local_red_flat_trace ./ movmedian(local_farred_flat_trace,5);
        get_g1s_frame(normalized_geminin_trace, analysis_parameters)
        
        
        
        
        %
        %         figure,title(['FarRed raw integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(farred_raw_integrated_intensity_trace,'r')
        %         drawnow
        %         hold off
        %
        %         figure,title(['Red raw integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(red_raw_integrated_intensity_trace,'m')
        %         drawnow
        %         hold off
        %
        %         figure,title(['Green raw integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(green_raw_integrated_intensity_trace,'g')
        %         drawnow
        %         hold off
        %
        %         figure,title(['FarRed flatfielded integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(farred_flat_integrated_intensity_trace,'r')
        %         drawnow
        %         hold off
        %
        %         figure,title(['Red flatfielded integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(red_flat_integrated_intensity_trace,'m')
        %         drawnow
        %         hold off
        %
        %         figure,title(['Green flatfielded integrated intensity for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(green_flat_integrated_intensity_trace,'g')
        %         drawnow
        %         hold off
        %
        %         figure,title(['Areas for cell ' num2str(cellnum)]);
        %         hold on
        %         plot(area_trace,'k')
        %         drawnow
        %         hold off
    end
end
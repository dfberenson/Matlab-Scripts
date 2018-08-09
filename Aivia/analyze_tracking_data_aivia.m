
% Desperately need to fix how G1S is detected with these traces

function [analyzed_values,tree] = analyze_tracking_data_aivia(expt_folder, expt_name, pos, analysis_parameters)

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));
[Y,X] = size(blank_field);

xlsx_fpath = [expt_folder '\' expt_name '_Pos' num2str(pos) '_Tracks.xlsx'];
[status,sheets] = xlsfinfo(xlsx_fpath);

disp('Reading tables')

lineage_table = readtable(xlsx_fpath,'Sheet','Track Lineages');
num_tracks = height(lineage_table);
tree = make_lineage_tree(lineage_table);

areas_table = readtable(xlsx_fpath, 'Sheet', 'Area (px�)');
x_coord_table = readtable(xlsx_fpath, 'Sheet', 'X (px)');
y_coord_table = readtable(xlsx_fpath, 'Sheet', 'Y (px)');
red_mean_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - Red');
green_mean_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - Green');
red_total_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - Red');
green_total_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - Green');

assert(num_tracks == width(areas_table) - 1);

analyzed_values = struct;

% Pre-segment images
for t = analysis_parameters.movie_start_frame : analysis_parameters.movie_end_frame
    disp(['Segmenting time ' num2str(t)])
    % Load image (e.g., C2_T1.tif)
    if strcmp(analysis_parameters.order_of_channels, 'prg');
        raw_im_red = imread([expt_folder '\Image_Sequences\Pos' num2str(pos) '\C2_T' num2str(t) '.tif']);
        raw_im_green = imread([expt_folder '\Image_Sequences\Pos' num2str(pos) '\C3_T' num2str(t) '.tif']);
        red_global_mode(t) = double(mode(raw_im_red(:)));
        green_global_mode(t) = double(mode(raw_im_green(:)));
    end
    
    % Segment and label image
    assert(strcmp(analysis_parameters.size_channel,'r'));
    gaussian_filtered = imgaussfilt(raw_im_red,analysis_parameters.segmentation_parameters.gaussian_width);
    % figure,imshow(gaussian_filtered,[])
    thresholded = gaussian_filtered > analysis_parameters.segmentation_parameters.threshold;
    % figure,imshow(thresholded)
    se = strel(analysis_parameters.segmentation_parameters.strel_shape,analysis_parameters.segmentation_parameters.strel_size);
    im_opened = imopen(thresholded,se);
    % figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    % figure,imshow(im_closed)
    segmented_im = im_closed;
    
    [L,~] = bwlabel(segmented_im,4);
    
    raw_im_red_stack(:,:,t) = raw_im_red;
    raw_im_green_stack(:,:,t) = raw_im_green;
    label_stack(:,:,t) = L;
end

for c = 1:num_tracks
    disp(['Measuring position ' num2str(pos) ' cell ' num2str(c)])
    thiscell_complete_x_coords = x_coord_table{:,['Track' num2str(c)]};
    thiscell_complete_y_coords = y_coord_table{:,['Track' num2str(c)]};
    thiscell_complete_area_measurements = areas_table{:,['Track' num2str(c)]};
    
    assert(strcmp(analysis_parameters.size_channel,'r') && strcmp(analysis_parameters.geminin_channel,'g'));
    
    thiscell_complete_raw_red_mean_measurements = red_mean_intensity_table{:,['Track' num2str(c)]};
    thiscell_complete_raw_green_mean_measurements = green_mean_intensity_table{:,['Track' num2str(c)]};
    %     thiscell_complete_raw_size_measurements = red_total_intensity_table{:,['Track' num2str(c)]};
    %     thiscell_complete_raw_geminin_measurements = green_total_intensity_table{:,['Track' num2str(c)]};
    
    %     scatter(thiscell_complete_area_measurements .* thiscell_complete_ef1a_mean_measurements,...
    %         thiscell_complete_size_measurements)
    %     axis([0 inf 0 inf])
    %     scatter(thiscell_complete_area_measurements .* thiscell_complete_geminin_mean_measurements,...
    %         thiscell_complete_geminin_measurements)
    %     axis([0 inf 0 inf])
    
    % Add 1 to frame measurements to change from Aivia's zero-indexing to
    % Matlab's one-indexing
    analyzed_values(c).firstframe = lineage_table{c,'FirstFrame'} + 1;
    analyzed_values(c).lastframe = lineage_table{c,'LastFrame'} + 1;
    
    if isnan(thiscell_complete_area_measurements(analyzed_values(c).firstframe)) ||...
            isnan(thiscell_complete_area_measurements(analyzed_values(c).lastframe))
        analyzed_values(c).has_properly_annotated_firstlast = false;
        analyzed_values(c).has_something_horribly_wrong = true;
        continue
    else
        analyzed_values(c).has_properly_annotated_firstlast = true;
    end
    
    % FLATFIELDING PROCEDURE
    for t = analyzed_values(c).firstframe : analyzed_values(c).lastframe
        disp(['Measuring position ' num2str(pos) ' cell ' num2str(c) ' time ' num2str(t)])
        % (1) Get xy coordinates and mean intensity of cell
        x = max(1,min(round(thiscell_complete_x_coords(t)),X));
        y = max(1,min(round(thiscell_complete_y_coords(t)),Y));
        area = thiscell_complete_area_measurements(t);
        raw_red_mean = thiscell_complete_raw_red_mean_measurements(t);
        raw_green_mean = thiscell_complete_raw_green_mean_measurements(t);
        
        % (2) Get local flatfield divisor
        local_flatfield_factor = blank_field_mean ./ blank_field(y,x);
        
        % (3) Get mean intensity of local background:
        raw_im_red = raw_im_red_stack(:,:,t);
        raw_im_green = raw_im_green_stack(:,:,t);
        
        thislabelnum = label_stack(y,x,t);
        if thislabelnum == 0
            continue
        end
        thiscellmask = label_stack(:,:,t) == thislabelnum;
        label_props = regionprops(thiscellmask,'Area','BoundingBox');
        
        % Expand bounding box in each direction to examine
        % local background.
        local_expansion = 100;
        boundingBox_vals = label_props.BoundingBox;
        x_min = max(uint16(boundingBox_vals(1)) - local_expansion, 1);
        x_max = min(uint16(boundingBox_vals(1) + boundingBox_vals(3)) + local_expansion, X);
        y_min = max(uint16(boundingBox_vals(2)) - local_expansion, 1);
        y_max = min(uint16(boundingBox_vals(2) + boundingBox_vals(4)) + local_expansion, Y);
        
        boundingBox = label_stack(y_min:y_max, x_min:x_max, t);
        boundingBox_background_mask = boundingBox == 0;
        fullsize_im_local_background_mask = zeros(Y,X);
        fullsize_im_local_background_mask(y_min:y_max, x_min:x_max) = boundingBox_background_mask;
        %         imshow(fullsize_im_local_background_mask)
        
        % (3d) Get local background intensity by looking in bounding box
        raw_red_local_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
        raw_green_local_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
        raw_red_local_background_mean_intensity = raw_red_local_background_props.MeanIntensity;
        raw_green_local_background_mean_intensity = raw_green_local_background_props.MeanIntensity;
        
        % (4) Flatfield cell and background intensities
        zeroed_red_mean = raw_red_mean - red_global_mode(t);
        zeroed_green_mean = raw_green_mean - green_global_mode(t);
        flat_red_mean = zeroed_red_mean * local_flatfield_factor;
        flat_green_mean = zeroed_green_mean * local_flatfield_factor;
        
        zeroed_red_local_background_mean = raw_red_local_background_mean_intensity - red_global_mode(t);
        zeroed_green_local_background_mean = raw_green_local_background_mean_intensity - green_global_mode(t);
        flat_red_background_mean = zeroed_red_local_background_mean * local_flatfield_factor;
        flat_green_background_mean = zeroed_green_local_background_mean * local_flatfield_factor;
        
        net_flat_red_mean(t) = flat_red_mean - flat_red_background_mean;
        net_flat_green_mean(t) = flat_green_mean - flat_green_background_mean;
        net_red_integrated_intensity(t) = area *  net_flat_red_mean(t);
        net_green_integrated_intensity(t) = area * net_flat_green_mean(t);
    end
    
    if strcmp(analysis_parameters.size_channel,'r')
        thiscell_complete_size_measurements = net_red_integrated_intensity';
    end
    if strcmp(analysis_parameters.geminin_channel,'g')
        thiscell_complete_geminin_measurements = net_green_integrated_intensity';
    end
    
    % Check birth
    analyzed_values(c).is_born = ~isempty(tree(c).mother_id);
    
    % Check generation
    analyzed_values(c).generation = 0;
    thiscell = c;
    mother = tree(thiscell).mother_id;
    while ~isempty(mother)
        analyzed_values(c).generation = analyzed_values(c).generation + 1;
        % Check for infinite loops resulting from impossible parentage
        if thiscell == mother
            disp(['Cell ' num2str(c) ' is its own mother.'])
            analyzed_values(c).has_something_horribly_wrong = true;
            break
        end
        thiscell = mother;
        mother = tree(thiscell).mother_id;
    end
    
    % Check whether born early or late in movie
    analyzed_values(c).is_born_early_in_movie = analyzed_values(c).firstframe < analysis_parameters.birth_frame_threshold;
    
    % Check mitosis
    analyzed_values(c).has_mitosis = lineage_table{c,'Divides'};
    
    % Check duration
    analyzed_values(c).trace_duration_frames =...
        analyzed_values(c).lastframe - analyzed_values(c).firstframe + 1;
    analyzed_values(c).trace_duration_hours =...
        analyzed_values(c).trace_duration_frames * analysis_parameters.framerate;
    if analyzed_values(c).trace_duration_hours >= analysis_parameters.min_cycle_duration_hours
        analyzed_values(c).trace_is_long_enough = true;
    else
        analyzed_values(c).trace_is_long_enough = false;
        continue
    end
    
    % Check if it's a complete cycle
    analyzed_values(c).has_complete_cycle = analyzed_values(c).is_born &&...
        analyzed_values(c).has_mitosis && analyzed_values(c).trace_is_long_enough;
    if analyzed_values(c).has_complete_cycle
        disp(['Cell ' num2str(c) ' has complete cycle.'])
    end
    
    % Gather the measurements
    analyzed_values(c).birth_aligned_frames = [analyzed_values(c).firstframe : analyzed_values(c).lastframe]';
    analyzed_values(c).birth_aligned_hours = linspace(0, (analyzed_values(c).trace_duration_frames - 1)*analysis_parameters.framerate,...
        analyzed_values(c).trace_duration_frames);
    analyzed_values(c).area_measurements = thiscell_complete_area_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    analyzed_values(c).size_measurements = thiscell_complete_size_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    analyzed_values(c).geminin_measurements = thiscell_complete_geminin_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    
    % Smoothen measurements
    analyzed_values(c).area_measurements_smooth = movmedian(analyzed_values(c).area_measurements, analysis_parameters.smoothing_param);
    analyzed_values(c).size_measurements_smooth = movmedian(analyzed_values(c).size_measurements, analysis_parameters.smoothing_param);
    analyzed_values(c).geminin_measurements_smooth = movmedian(analyzed_values(c).geminin_measurements, analysis_parameters.smoothing_param);
    
    % Gather measurements avoiding frames at start and end of cycle
    frames_to_avoid_at_start = 0;
    frames_to_avoid_at_end = 0;
    if analyzed_values(c).is_born
        frames_to_avoid_at_start = analysis_parameters.num_first_frames_to_avoid;
    end
    if analyzed_values(c).has_mitosis
        frames_to_avoid_at_end = analysis_parameters.num_last_frames_to_avoid;
    end
    analyzed_values(c).area_measurements_avoiding_ends = analyzed_values(c).area_measurements...
        (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
    analyzed_values(c).size_measurements_avoiding_ends = analyzed_values(c).size_measurements...
        (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
    analyzed_values(c).geminin_measurements_avoiding_ends = analyzed_values(c).geminin_measurements...
        (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
    
    % Measure birth size
    if analyzed_values(c).is_born
        areas_near_birth = analyzed_values(c).area_measurements(analysis_parameters.birthsize_measuring_frames);
        analyzed_values(c).birth_area = median(areas_near_birth);
        sizes_near_birth = analyzed_values(c).size_measurements(analysis_parameters.birthsize_measuring_frames);
        analyzed_values(c).birth_size = median(sizes_near_birth);
    end
    
    % Measure G1S transition time and cell cycle phase lengths
    if analyzed_values(c).has_complete_cycle
        analyzed_values(c).g1s_frame_notsmooth = get_g1s_frame(analyzed_values(c).geminin_measurements,analysis_parameters);
        analyzed_values(c).g1s_frame_smooth = get_g1s_frame(analyzed_values(c).geminin_measurements_smooth,analysis_parameters);
        analyzed_values(c).g1_length_hours_v1 = analyzed_values(c).g1s_frame_notsmooth * analysis_parameters.framerate;
        analyzed_values(c).g1_length_hours_v2 = analyzed_values(c).g1s_frame_smooth * analysis_parameters.framerate;
        
        analyzed_values(c).g1s_frame = analyzed_values(c).g1s_frame_notsmooth;
        analyzed_values(c).g1_length_hours = analyzed_values(c).g1_length_hours_v1;
        
        % If no G1S frame was found, count it no longer as a complete
        % cycle.
        if isempty(analyzed_values(c).g1s_frame)
            analyzed_values(c).has_complete_cycle = false;
        end
        
        analyzed_values(c).sg2_length_hours = analyzed_values(c).trace_duration_hours - analyzed_values(c).g1_length_hours;
    end
    
    % Measure sizes at G1S and G2M
    if analyzed_values(c).has_complete_cycle
        analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(round(analyzed_values(c).g1s_frame));
        analyzed_values(c).g2m_size = analyzed_values(c).size_measurements_smooth(end - frames_to_avoid_at_end);
        
        analyzed_values(c).g1_growth = analyzed_values(c).g1s_size - analyzed_values(c).birth_size;
        analyzed_values(c).sg2_growth = analyzed_values(c).g2m_size - analyzed_values(c).g1s_size;
        analyzed_values(c).complete_cycle_growth = analyzed_values(c).g2m_size - analyzed_values(c).birth_size;
    end
    
    
%     % Plot some cells
%     if analyzed_values(c).has_complete_cycle
%         figure()
%         hold on
%         xlabel('Cell age (h)')
%         yyaxis left
%         plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).size_measurements,'r');
%         plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).size_measurements_smooth,'m');
%         ax = gca;
%         ax.YColor = 'r';
%         ylabel('EF1a-mCherry size measurement')
%         axis([0 inf 0 500000]);
%         yyaxis right
%         plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).geminin_measurements,'g');
%         plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).geminin_measurements_smooth,'c')
%         ax = gca;
%         ax.YColor = 'g';
%         ylabel('Geminin-GFP')
%         axis([0 inf 0 2000000]);
%         hold off
%     end
    
end
end
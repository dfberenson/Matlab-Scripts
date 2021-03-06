
% Desperately need to fix how G1S is detected with these traces

function [analyzed_values,tree] = analyze_tracking_data_aivia(table_expt_folder, image_expt_folder, expt_name, pos, analysis_parameters)

analyzed_values = struct;

is_four_channels = length(analysis_parameters.order_of_channels) == 4;

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));
[Y,X] = size(blank_field);

% xlsx_fpath = [table_expt_folder '\' expt_name '_Pos' num2str(pos) '_Tracks.xlsx'];
xlsx_fpath = [table_expt_folder '\Pos' num2str(pos) '_tracks.xlsx'];
[status,sheets] = xlsfinfo(xlsx_fpath);

disp('Reading tables')

lineage_table = readtable(xlsx_fpath,'Sheet','Track Lineages');

areas_table = readtable(xlsx_fpath, 'Sheet', 'Area (px�)');
x_coord_table = readtable(xlsx_fpath, 'Sheet', 'X (px)');
y_coord_table = readtable(xlsx_fpath, 'Sheet', 'Y (px)');
red_mean_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - Red');
green_mean_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - Green');
red_total_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - Red');
green_total_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - Green');

if is_four_channels
    farred_mean_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - FarRed');
    farred_total_intensity_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - FarRed');
end

num_tracks = height(lineage_table);
tree = make_lineage_tree(lineage_table);

assert(num_tracks == width(areas_table) - 1);

% Pre-segment images
for t = analysis_parameters.movie_start_frame : analysis_parameters.movie_end_frame
    disp(['Segmenting time ' num2str(t)])
    % Load image (e.g., C2_T1.tif)
    if strcmp(analysis_parameters.order_of_channels, 'prg')
        raw_im_red = imread([image_expt_folder '\Image_Sequences\Pos' num2str(pos) '\C2_T' num2str(t) '.tif']);
        raw_im_green = imread([image_expt_folder '\Image_Sequences\Pos' num2str(pos) '\C3_T' num2str(t) '.tif']);
        red_global_mode(t) = double(mode(raw_im_red(:)));
        green_global_mode(t) = double(mode(raw_im_green(:)));
    elseif strcmp(analysis_parameters.order_of_channels, 'pgrf')
        raw_im_farred = imread([image_expt_folder '_Pos' num2str(pos) '\' expt_name '_Pos' num2str(pos) '_RawFarRed\' expt_name '_Pos' num2str(pos) '_RawFarRed_' sprintf('%03d',t) '.tif']);
        raw_im_red = imread([image_expt_folder '_Pos' num2str(pos) '\' expt_name '_Pos' num2str(pos) '_RawRed\' expt_name '_Pos' num2str(pos) '_RawRed_' sprintf('%03d',t) '.tif']);
        raw_im_green = imread([image_expt_folder '_Pos' num2str(pos) '\' expt_name '_Pos' num2str(pos) '_RawGreen\' expt_name '_Pos' num2str(pos) '_RawGreen_' sprintf('%03d',t) '.tif']);
        farred_global_mode(t) = double(mode(raw_im_farred(:)));
        red_global_mode(t) = double(mode(raw_im_red(:)));
        %         green_global_mode(t) = double(mode(raw_im_green(:)));
        % Can't just use the mode for green in a four-channel movie with
        % Rb-Clover because the uneven background is overpowering. Instead use
        % the darkfield value from the corners of the image.
        green_global_mode(t) = 110;
    end
    
    switch analysis_parameters.size_channel
        case 'r'
            raw_im_size = raw_im_red;
        case 'f'
            raw_im_size = raw_im_farred;
    end
    
    % Segment and label image
    gaussian_filtered = imgaussfilt(raw_im_size,analysis_parameters.segmentation_parameters.gaussian_width);
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
    if is_four_channels
        raw_im_farred_stack(:,:,t) = raw_im_farred;
    end
    raw_im_red_stack(:,:,t) = raw_im_red;
    raw_im_green_stack(:,:,t) = raw_im_green;
    label_stack(:,:,t) = L;
end

for c = 1:num_tracks
    disp(['Measuring position ' num2str(pos) ' cell ' num2str(c)])
    thiscell_complete_x_coords = x_coord_table{:,['Track' num2str(c)]};
    thiscell_complete_y_coords = y_coord_table{:,['Track' num2str(c)]};
    analyzed_values(c).thiscell_complete_area_measurements = areas_table{:,['Track' num2str(c)]};
    
    if is_four_channels
        analyzed_values(c).thiscell_complete_raw_farred_mean_measurements = farred_mean_intensity_table{:,['Track' num2str(c)]};
    end
    analyzed_values(c).thiscell_complete_raw_red_mean_measurements = red_mean_intensity_table{:,['Track' num2str(c)]};
    analyzed_values(c).thiscell_complete_raw_green_mean_measurements = green_mean_intensity_table{:,['Track' num2str(c)]};
    %     analyzed_values(c).thiscell_complete_raw_size_measurements = red_total_intensity_table{:,['Track' num2str(c)]};
    %     analyzed_values(c).thiscell_complete_raw_geminin_measurements = green_total_intensity_table{:,['Track' num2str(c)]};
    
    %     scatter(analyzed_values(c).thiscell_complete_area_measurements .* analyzed_values(c).thiscell_complete_ef1a_mean_measurements,...
    %         analyzed_values(c).thiscell_complete_size_measurements)
    %     axis([0 inf 0 inf])
    %     scatter(analyzed_values(c).thiscell_complete_area_measurements .* analyzed_values(c).thiscell_complete_geminin_mean_measurements,...
    %         analyzed_values(c).thiscell_complete_geminin_measurements)
    %     axis([0 inf 0 inf])
    
    % Add 1 to frame measurements to change from Aivia's zero-indexing to
    % Matlab's one-indexing
    analyzed_values(c).firstframe = lineage_table{c,'FirstFrame'} + 1;
    analyzed_values(c).lastframe = lineage_table{c,'LastFrame'} + 1;
    
    analyzed_values(c).has_something_gone_horribly_wrong = false;
    
    if isnan(analyzed_values(c).thiscell_complete_area_measurements(analyzed_values(c).firstframe)) ||...
            isnan(analyzed_values(c).thiscell_complete_area_measurements(analyzed_values(c).lastframe))
        analyzed_values(c).has_properly_annotated_firstlast = false;
        analyzed_values(c).has_something_gone_horribly_wrong = true;
        continue
    else
        analyzed_values(c).has_properly_annotated_firstlast = true;
        analyzed_values(c).relative_lastframe = analyzed_values(c).lastframe - analyzed_values(c).firstframe + 1;
    end
    
    if is_four_channels
        net_flat_farred_mean = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
        net_farred_integrated_intensity = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
    end
    net_flat_red_mean = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
    net_flat_green_mean = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
    net_red_integrated_intensity = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
    net_green_integrated_intensity = zeros(analysis_parameters.movie_end_frame - analysis_parameters.movie_start_frame + 1, 1);
    
    % FLATFIELDING PROCEDURE
    for t = analyzed_values(c).firstframe : analyzed_values(c).lastframe
        disp(['Measuring position ' num2str(pos) ' cell ' num2str(c) ' time ' num2str(t)])
        % (1) Get xy coordinates and mean intensity of cell
        x = max(1,min(round(thiscell_complete_x_coords(t)),X));
        y = max(1,min(round(thiscell_complete_y_coords(t)),Y));
        area = analyzed_values(c).thiscell_complete_area_measurements(t);
        if is_four_channels
            raw_farred_mean = analyzed_values(c).thiscell_complete_raw_farred_mean_measurements(t);
        end
        raw_red_mean = analyzed_values(c).thiscell_complete_raw_red_mean_measurements(t);
        raw_green_mean = analyzed_values(c).thiscell_complete_raw_green_mean_measurements(t);
        
        % (2) Get local flatfield divisor
        local_flatfield_factor = blank_field_mean ./ blank_field(y,x);
        
        % (3) Get mean intensity of local background:
        if is_four_channels
            raw_im_farred = raw_im_farred_stack(:,:,t);
        end
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
        if is_four_channels
            raw_farred_local_background_props = regionprops(fullsize_im_local_background_mask, raw_im_farred, 'MeanIntensity');
            raw_farred_local_background_mean_intensity = raw_farred_local_background_props.MeanIntensity;
        end
        raw_red_local_background_props = regionprops(fullsize_im_local_background_mask, raw_im_red, 'MeanIntensity');
        raw_red_local_background_mean_intensity = raw_red_local_background_props.MeanIntensity;
        raw_green_local_background_props = regionprops(fullsize_im_local_background_mask, raw_im_green, 'MeanIntensity');
        raw_green_local_background_mean_intensity = raw_green_local_background_props.MeanIntensity;
        
        % (4) Flatfield cell and background intensities
        if is_four_channels
            zeroed_farred_mean = raw_farred_mean - farred_global_mode(t);
            flat_farred_mean = zeroed_farred_mean * local_flatfield_factor;
        end
        zeroed_red_mean = raw_red_mean - red_global_mode(t);
        flat_red_mean = zeroed_red_mean * local_flatfield_factor;
        zeroed_green_mean = raw_green_mean - green_global_mode(t);
        flat_green_mean = zeroed_green_mean * local_flatfield_factor;
        
        if is_four_channels
            zeroed_farred_local_background_mean = raw_farred_local_background_mean_intensity - farred_global_mode(t);
            flat_farred_background_mean = zeroed_farred_local_background_mean * local_flatfield_factor;
        end
        zeroed_red_local_background_mean = raw_red_local_background_mean_intensity - red_global_mode(t);
        flat_red_background_mean = zeroed_red_local_background_mean * local_flatfield_factor;
        zeroed_green_local_background_mean = raw_green_local_background_mean_intensity - green_global_mode(t);
        flat_green_background_mean = zeroed_green_local_background_mean * local_flatfield_factor;
        
        if is_four_channels
            net_flat_farred_mean(t) = flat_farred_mean - flat_farred_background_mean;
            net_farred_integrated_intensity(t) = area *  net_flat_farred_mean(t);
        end
        net_flat_red_mean(t) = flat_red_mean - flat_red_background_mean;
        net_red_integrated_intensity(t) = area *  net_flat_red_mean(t);
        net_flat_green_mean(t) = flat_green_mean - flat_green_background_mean;
        net_green_integrated_intensity(t) = area * net_flat_green_mean(t);
    end
    
    switch analysis_parameters.size_channel
        case 'r'
            analyzed_values(c).thiscell_complete_size_measurements = net_red_integrated_intensity;
        case 'f'
            analyzed_values(c).thiscell_complete_size_measurements = net_farred_integrated_intensity;
    end
    switch analysis_parameters.geminin_channel
        case 'g'
            analyzed_values(c).thiscell_complete_geminin_measurements = net_green_integrated_intensity;
        case 'r'
            analyzed_values(c).thiscell_complete_geminin_measurements = net_red_integrated_intensity;
    end
    if is_four_channels
        switch analysis_parameters.protein_channel
            case 'g'
                analyzed_values(c).thiscell_complete_protein_measurements = net_green_integrated_intensity;
        end
    end
    
    % Check mitosis
    analyzed_values(c).has_mitosis = lineage_table{c,'Divides'};
    
    advanced_values = advanced_tracking_analysis(analyzed_values(c), c, tree, analysis_parameters, is_four_channels);
    for fn = fieldnames(advanced_values)'
        analyzed_values(c).(fn{1}) = advanced_values.(fn{1});
    end
    
%     % Check birth
%     analyzed_values(c).is_born = ~isempty(tree(c).mother_id);
%     
%     % Check generation
%     analyzed_values(c).generation = 0;
%     thiscell = c;
%     mother = tree(thiscell).mother_id;
%     while ~isempty(mother)
%         analyzed_values(c).generation = analyzed_values(c).generation + 1;
%         % Check for infinite loops resulting from impossible parentage
%         if thiscell == mother
%             disp(['Cell ' num2str(c) ' is its own mother.'])
%             analyzed_values(c).has_something_gone_horribly_wrong = true;
%             break
%         end
%         thiscell = mother;
%         mother = tree(thiscell).mother_id;
%     end
%     
%     % Check whether born early or late in movie
%     analyzed_values(c).is_born_early_in_movie = analyzed_values(c).firstframe < analysis_parameters.birth_frame_threshold;
%     
%     % Check mitosis
%     analyzed_values(c).has_mitosis = lineage_table{c,'Divides'};
%     
%     % Check duration
%     analyzed_values(c).trace_duration_frames =...
%         analyzed_values(c).lastframe - analyzed_values(c).firstframe + 1;
%     analyzed_values(c).trace_duration_hours =...
%         analyzed_values(c).trace_duration_frames * analysis_parameters.framerate;
%     if analyzed_values(c).trace_duration_hours >= analysis_parameters.min_total_trace_frames * analysis_parameters.framerate
%         analyzed_values(c).trace_is_long_enough = true;
%     else
%         analyzed_values(c).trace_is_long_enough = false;
%         continue
%     end
%     
%     % Check if it's a complete cycle
%     analyzed_values(c).has_complete_cycle = analyzed_values(c).is_born && analyzed_values(c).has_mitosis
%     if analyzed_values(c).has_complete_cycle
%         disp(['Cell ' num2str(c) ' has complete cycle.'])
%     end
%     
%     % Gather the measurements
%     analyzed_values(c).birth_aligned_frames = [analyzed_values(c).firstframe : analyzed_values(c).lastframe]';
%     analyzed_values(c).birth_aligned_hours = linspace(0, (analyzed_values(c).trace_duration_frames - 1)*analysis_parameters.framerate,...
%         analyzed_values(c).trace_duration_frames)';
%     analyzed_values(c).area_measurements = thiscell_complete_area_measurements...
%         (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
%     analyzed_values(c).size_measurements = thiscell_complete_size_measurements...
%         (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
%     analyzed_values(c).geminin_measurements = thiscell_complete_geminin_measurements...
%         (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
%     if is_four_channels
%         analyzed_values(c).protein_measurements = thiscell_complete_protein_measurements...
%             (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
%     end
%     
%     % Smoothen measurements
%     analyzed_values(c).area_measurements_smooth = movmedian(analyzed_values(c).area_measurements, analysis_parameters.smoothing_param);
%     analyzed_values(c).size_measurements_smooth = movmedian(analyzed_values(c).size_measurements, analysis_parameters.smoothing_param);
%     analyzed_values(c).geminin_measurements_smooth = movmedian(analyzed_values(c).geminin_measurements, analysis_parameters.smoothing_param);
%     if is_four_channels
%         analyzed_values(c).protein_measurements_smooth = movmedian(analyzed_values(c).protein_measurements, analysis_parameters.smoothing_param);
%     end
%     
%     % Gather measurements avoiding frames at start and end of cycle
%     frames_to_avoid_at_start = 0;
%     frames_to_avoid_at_end = 0;
%     if analyzed_values(c).is_born
%         frames_to_avoid_at_start = analysis_parameters.num_first_frames_to_avoid;
%     end
%     if analyzed_values(c).has_mitosis
%         frames_to_avoid_at_end = analysis_parameters.num_last_frames_to_avoid;
%     end
%     analyzed_values(c).area_measurements_avoiding_ends = analyzed_values(c).area_measurements...
%         (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
%     analyzed_values(c).size_measurements_avoiding_ends = analyzed_values(c).size_measurements...
%         (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
%     analyzed_values(c).geminin_measurements_avoiding_ends = analyzed_values(c).geminin_measurements...
%         (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
%     if is_four_channels
%         analyzed_values(c).protein_measurements_avoiding_ends = analyzed_values(c).protein_measurements...
%             (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
%     end
%     
%     % Measure birth size
%     if analyzed_values(c).is_born
%         areas_near_birth = analyzed_values(c).area_measurements(analysis_parameters.birthsize_measuring_frames);
%         analyzed_values(c).birth_area = median(areas_near_birth);
%         sizes_near_birth = analyzed_values(c).size_measurements(analysis_parameters.birthsize_measuring_frames);
%         analyzed_values(c).birth_size = median(sizes_near_birth);
%     end
%     
%     analyzed_values(c).passes_g1s = [];
%     
%     % Measure G1S transition time and cell cycle phase lengths
%     if ~is_four_channels
%         % If not a four-channel movie, can look only at complete cell
%         % cycles.
%         if analyzed_values(c).has_complete_cycle
%             analyzed_values(c).g1s_frame_notsmooth = get_g1s_frame(analyzed_values(c).geminin_measurements,analysis_parameters);
%             analyzed_values(c).g1s_frame_smooth = get_g1s_frame(analyzed_values(c).geminin_measurements_smooth,analysis_parameters);
%             analyzed_values(c).g1_length_hours_notsmooth = analyzed_values(c).g1s_frame_notsmooth * analysis_parameters.framerate;
%             analyzed_values(c).g1_length_hours_smooth = analyzed_values(c).g1s_frame_smooth * analysis_parameters.framerate;
%             
%             analyzed_values(c).g1s_frame = analyzed_values(c).g1s_frame_notsmooth;
%             analyzed_values(c).g1_length_hours = analyzed_values(c).g1_length_hours_notsmooth;
%             
%             % If no G1S frame was found, count it no longer as a complete
%             % cycle.
%             if isempty(analyzed_values(c).g1s_frame)
%                 analyzed_values(c).passes_g1s = false;
%                 analyzed_values(c).has_complete_cycle = false;
%                 
%                 % Else record some measurements around G1/S
%             else
%                 analyzed_values(c).passes_g1s = true;
%                 analyzed_values(c).sg2_length_hours = analyzed_values(c).trace_duration_hours - analyzed_values(c).g1_length_hours;
%                 analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
%                 analyzed_values(c).frame_to_start_measuring = max(1, analyzed_values(c).g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
%                 
%                 analyzed_values(c).instantaneous_sizes_during_g1 = analyzed_values(c).size_measurements(1:analyzed_values(c).g1s_frame);
%                 analyzed_values(c).instantaneous_sizes_during_sg2 = analyzed_values(c).size_measurements(analyzed_values(c).g1s_frame + 1 : end);
%                 
%                 % Give frames indices running from say -32 to +26,
%                 % with G1/S at index 0
%                 analyzed_values(c).all_frame_indices_wrt_g1s = (analyzed_values(c).firstframe : analyzed_values(c).lastframe) - analyzed_values(c).g1s_frame;
%                 
%                 analyzed_values(c).frame_indices_wrt_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : -1)';
%                 analyzed_values(c).g1s_happens_here_nextframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_nextframe),1));
%                 analyzed_values(c).g1s_happens_here_nextframe(end) = 1;
%                 analyzed_values(c).areas_up_to_g1s_nextframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%                 analyzed_values(c).sizes_up_to_g1s_nextframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%                 analyzed_values(c).geminin_up_to_g1s_nextframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%                 
%                 if analyzed_values(c).is_born
%                     analyzed_values(c).age_in_frames_up_to_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1)';
%                     analyzed_values(c).age_in_hours_up_to_g1s_nextframe = analyzed_values(c).age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
%                 end
%                 
%                 analyzed_values(c).frame_indices_wrt_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : 0)';
%                 analyzed_values(c).g1s_happens_here_thisframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_thisframe),1));
%                 analyzed_values(c).g1s_happens_here_thisframe(end) = 1;
%                 analyzed_values(c).areas_up_to_g1s_thisframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%                 analyzed_values(c).sizes_up_to_g1s_thisframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%                 analyzed_values(c).geminin_up_to_g1s_thisframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%                 
%                 if analyzed_values(c).is_born
%                     analyzed_values(c).age_in_frames_up_to_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0)';
%                     analyzed_values(c).age_in_hours_up_to_g1s_thisframe = analyzed_values(c).age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
%                 end
%             end
%         end
%         
%         % Measure sizes at G1S and G2M
%         if analyzed_values(c).has_complete_cycle
%             analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
%             analyzed_values(c).g2m_size = analyzed_values(c).size_measurements_smooth(end - frames_to_avoid_at_end);
%             
%             analyzed_values(c).g1_growth = analyzed_values(c).g1s_size - analyzed_values(c).birth_size;
%             analyzed_values(c).sg2_growth = analyzed_values(c).g2m_size - analyzed_values(c).g1s_size;
%             analyzed_values(c).complete_cycle_growth = analyzed_values(c).g2m_size - analyzed_values(c).birth_size;
%         end
%         
%     elseif is_four_channels
%         % Get G1S frame by first normalizing each Geminin-mCherry signal to
%         % the size-Crimson signal so that the Geminin curve is flat and
%         % then slopes up.
%         disp(['Finding G1S for cell ' num2str(c)])
%         %         if c == 47
%         %             disp('Stop here')
%         %         end
%         
%         %         figure,plot(analyzed_values(c).geminin_measurements)
%         %         figure,plot(analyzed_values(c).size_measurements_smooth)
%         
%         analyzed_values(c).g1s_frame = get_g1s_frame(...
%             analyzed_values(c).geminin_measurements ./ analyzed_values(c).size_measurements_smooth,...
%             analysis_parameters);
%         analyzed_values(c).passes_g1s = ~isempty(analyzed_values(c).g1s_frame);
%         
%         %Examine all cell that pass G1/S, even if they don't have complete
%         %cycles.
%         if analyzed_values(c).passes_g1s
%             analyzed_values(c).hours_before_g1s = analyzed_values(c).g1s_frame * analysis_parameters.framerate;
%             analyzed_values(c).hours_after_g1s = analyzed_values(c).trace_duration_hours - analyzed_values(c).hours_before_g1s;
%             analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
%             analyzed_values(c).frame_to_start_measuring = max(1, analyzed_values(c).g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
%             analyzed_values(c).g1s_protein_amt = analyzed_values(c).protein_measurements(analyzed_values(c).g1s_frame);
%             
%             if analyzed_values(c).is_born
%                 analyzed_values(c).g1_length_hours = analyzed_values(c).g1s_frame * analysis_parameters.framerate;
%                 analyzed_values(c).g1_growth = analyzed_values(c).g1s_size - analyzed_values(c).birth_size;
%             end
%             
%             if analyzed_values(c).has_mitosis
%                 analyzed_values(c).sg2_length_frames = analyzed_values(c).relative_lastframe - analyzed_values(c).g1s_frame;
%                 analyzed_values(c).sg2_length_hours = analyzed_values(c).sg2_length_frames * analysis_parameters.framerate;
%                 analyzed_values(c).g2m_size = analyzed_values(c).size_measurements_smooth(end - frames_to_avoid_at_end);
%                 analyzed_values(c).sg2_growth = analyzed_values(c).g2m_size - analyzed_values(c).g1s_size;
%                 analyzed_values(c).g2m_protein_amt = analyzed_values(c).protein_measurements(end - frames_to_avoid_at_end);
%                 analyzed_values(c).sg2_protein_increase = analyzed_values(c).g2m_protein_amt - analyzed_values(c).g1s_protein_amt;
%                 analyzed_values(c).protein_amts_during_sg2 = analyzed_values(c).protein_measurements(analyzed_values(c).g1s_frame : end - frames_to_avoid_at_end);
%                 analyzed_values(c).sg2_frames = 1 : length(analyzed_values(c).protein_amts_during_sg2);
%                 lm = fitlm(analyzed_values(c).sg2_frames, analyzed_values(c).protein_amts_during_sg2);
%                 analyzed_values(c).sg2_protein_accumulation_slope_perframe = lm.Coefficients.Estimate(2);
%             end
%             
%             if analyzed_values(c).has_complete_cycle
%                 analyzed_values(c).complete_cycle_growth = analyzed_values(c).g2m_size - analyzed_values(c).birth_size;
%             end
%             
%             analyzed_values(c).instantaneous_sizes_during_g1 = analyzed_values(c).size_measurements(1:analyzed_values(c).g1s_frame);
%             analyzed_values(c).instantaneous_sizes_during_sg2 = analyzed_values(c).size_measurements(analyzed_values(c).g1s_frame + 1 : end);
%             
%             % Give frames indices running from say -32 to +26,
%             % with G1/S at index 0
%             analyzed_values(c).all_frame_indices_wrt_g1s = (analyzed_values(c).firstframe : analyzed_values(c).lastframe) - analyzed_values(c).g1s_frame;
%             
%             analyzed_values(c).frame_indices_wrt_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : -1)';
%             analyzed_values(c).g1s_happens_here_nextframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_nextframe),1));
%             analyzed_values(c).g1s_happens_here_nextframe(end) = 1;
%             analyzed_values(c).areas_up_to_g1s_nextframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%             analyzed_values(c).sizes_up_to_g1s_nextframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%             analyzed_values(c).geminin_up_to_g1s_nextframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%             analyzed_values(c).protein_amt_up_to_g1s_nextframe = analyzed_values(c).protein_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
%             analyzed_values(c).protein_per_area_up_to_g1s_nextframe = analyzed_values(c).protein_amt_up_to_g1s_nextframe ./ analyzed_values(c).areas_up_to_g1s_nextframe;
%             analyzed_values(c).protein_per_size_up_to_g1s_nextframe = analyzed_values(c).protein_amt_up_to_g1s_nextframe ./ analyzed_values(c).sizes_up_to_g1s_nextframe;
%             
%             if analyzed_values(c).is_born
%                 analyzed_values(c).age_in_frames_up_to_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1)';
%                 analyzed_values(c).age_in_hours_up_to_g1s_nextframe = analyzed_values(c).age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
%             end
%             
%             analyzed_values(c).frame_indices_wrt_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : 0)';
%             analyzed_values(c).g1s_happens_here_thisframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_thisframe),1));
%             analyzed_values(c).g1s_happens_here_thisframe(end) = 1;
%             analyzed_values(c).areas_up_to_g1s_thisframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%             analyzed_values(c).sizes_up_to_g1s_thisframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%             analyzed_values(c).geminin_up_to_g1s_thisframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%             analyzed_values(c).protein_amt_up_to_g1s_thisframe = analyzed_values(c).protein_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
%             analyzed_values(c).protein_per_area_up_to_g1s_thisframe = analyzed_values(c).protein_amt_up_to_g1s_thisframe ./ analyzed_values(c).areas_up_to_g1s_thisframe;
%             analyzed_values(c).protein_per_size_up_to_g1s_thisframe = analyzed_values(c).protein_amt_up_to_g1s_thisframe ./ analyzed_values(c).sizes_up_to_g1s_thisframe;
%             
%             if analyzed_values(c).is_born
%                 analyzed_values(c).age_in_frames_up_to_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0)';
%                 analyzed_values(c).age_in_hours_up_to_g1s_thisframe = analyzed_values(c).age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
%             end
%         end
%     end
    
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
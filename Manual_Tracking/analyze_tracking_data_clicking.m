
function analyzed_values = analyze_tracking_data_clicking(tracking_measurements, tree, analysis_parameters);

% Call this function once per position.
% Take as input the tracking measurements from the manually clicked cells,
% the lineage tree, and the analysis parameters struct

% Return a cellwise structure with all the relevant data for each cell

analyzed_values = struct;

for c = tracking_measurements.all_tracknums
    
    analyzed_values(c).has_something_horribly_wrong = false;
    
    thiscell_complete_area_measurements = tracking_measurements.all_area_traces(:,c);
    thiscell_complete_size_measurements = tracking_measurements.all_red_flat_integrated_intensity_traces(:,c);
    thiscell_complete_geminin_measurements = tracking_measurements.all_green_flat_integrated_intensity_traces(:,c);
    
    analyzed_values(c).firstframe = tracking_measurements.track_metadata(c).firstframe;
    analyzed_values(c).lastframe = tracking_measurements.track_metadata(c).lastframe;
    
    % Check if firstframe and lastframe are properly annotated
    if analyzed_values(c).firstframe == -1 || analyzed_values(c).lastframe == -1
        analyzed_values(c).has_properly_annotated_firstlast = false;
        analyzed_values(c).has_something_horribly_wrong = true;
        continue
    else
        analyzed_values(c).has_properly_annotated_firstlast = true;
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
    analyzed_values(c).has_mitosis = ~isempty(tracking_measurements.track_metadata(c).mitosis);
    
    if tracking_measurements.track_metadata(c).mitosis ~= analyzed_values(c).lastframe
        analyzed_values(c).mitosis_is_lastframe = false;
        disp('Mitosis and lastframe do not match')
        continue
    else
        analyzed_values(c).mitosis_is_lastframe = true;
    end
    
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
        analyzed_values(c).g1s_frame_bilinear_notsmooth = get_g1s_frame(analyzed_values(c).geminin_measurements,analysis_parameters);
        analyzed_values(c).g1s_frame_bilinear_smooth = get_g1s_frame(analyzed_values(c).geminin_measurements_smooth,analysis_parameters);
        analyzed_values(c).g1_length_hours_v1 = analyzed_values(c).g1s_frame_bilinear_notsmooth * analysis_parameters.framerate;
        analyzed_values(c).g1_length_hours_v2 = analyzed_values(c).g1s_frame_bilinear_smooth * analysis_parameters.framerate;
        
        analyzed_values(c).g1s_frame = analyzed_values(c).g1s_frame_bilinear_notsmooth;
        analyzed_values(c).g1_length_hours = analyzed_values(c).g1_length_hours_v1;
        
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
    
    
    %
    %     % Plot some cells
    %         if analyzed_values(c).has_complete_cycle && ismember(c,[38 42])
    %             figure()
    %             hold on
    %             xlabel('Cell age (h)')
    %             yyaxis left
    %             plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).size_measurements,'r');
    %             plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).size_measurements_smooth,'m');
    %             ax = gca;
    %             ax.YColor = 'r';
    %             ylabel('EF1a-mCherry size measurement')
    %             axis([0 inf 0 200000]);
    %             yyaxis right
    %             plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).geminin_measurements,'g');
    %             plot(analyzed_values(c).birth_aligned_hours, analyzed_values(c).geminin_measurements_smooth,'c')
    %             ax = gca;
    %             ax.YColor = 'g';
    %             ylabel('Geminin-GFP')
    %             axis([0 inf 0 1000000]);
    %             hold off
    %         end
    %
end
end
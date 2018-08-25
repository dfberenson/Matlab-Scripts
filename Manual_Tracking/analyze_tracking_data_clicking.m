
function analyzed_values = analyze_tracking_data_clicking(tracking_measurements, tree, analysis_parameters)

% Call this function once per position.
% Take as input the tracking measurements from the manually clicked cells,
% the lineage tree, and the analysis parameters struct

% Return a cellwise structure with all the relevant data for each cell

analyzed_values = struct;

is_four_channels = length(analysis_parameters.order_of_channels) == 4;

for c = tracking_measurements.all_tracknums
    
    analyzed_values(c).has_something_horribly_wrong = false;
    
    thiscell_complete_area_measurements = tracking_measurements.all_area_traces(:,c);
    
    if analysis_parameters.size_channel == 'r'
        thiscell_complete_size_measurements = tracking_measurements.all_red_flat_integrated_intensity_traces(:,c);
    elseif analysis_parameters.size_channel == 'f'
        thiscell_complete_size_measurements = tracking_measurements.all_farred_flat_integrated_intensity_traces(:,c);
    end
    
    if analysis_parameters.geminin_channel == 'g'
        thiscell_complete_geminin_measurements = tracking_measurements.all_green_flat_integrated_intensity_traces(:,c);
    elseif analysis_parameters.geminin_channel == 'r'
        thiscell_complete_geminin_measurements = tracking_measurements.all_red_flat_integrated_intensity_traces(:,c);
    end
    
    if is_four_channels
        if analysis_parameters.protein_channel == 'g'
            thiscell_complete_protein_measurements = tracking_measurements.all_green_flat_integrated_intensity_traces(:,c);
        end
    end
    
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
    
    if analyzed_values(c).has_mitosis
        if tracking_measurements.track_metadata(c).mitosis ~= analyzed_values(c).lastframe
            analyzed_values(c).mitosis_is_lastframe = false;
            disp('Mitosis and lastframe do not match')
            continue
        else
            analyzed_values(c).mitosis_is_lastframe = true;
        end
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
    if analyzed_values(c).has_complete_cycle
        disp(['Cell ' num2str(c) ' has complete cycle.'])
    end
    
    % Gather the measurements
    analyzed_values(c).birth_aligned_frames = [analyzed_values(c).firstframe : analyzed_values(c).lastframe]';
    analyzed_values(c).birth_aligned_hours = linspace(0, (analyzed_values(c).trace_duration_frames - 1)*analysis_parameters.framerate,...
        analyzed_values(c).trace_duration_frames)';
    analyzed_values(c).area_measurements = thiscell_complete_area_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    analyzed_values(c).size_measurements = thiscell_complete_size_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    analyzed_values(c).geminin_measurements = thiscell_complete_geminin_measurements...
        (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    if is_four_channels
        analyzed_values(c).protein_measurements = thiscell_complete_protein_measurements...
            (analyzed_values(c).firstframe : analyzed_values(c).lastframe);
    end
    
    % Smoothen measurements
    analyzed_values(c).area_measurements_smooth = movmedian(analyzed_values(c).area_measurements, analysis_parameters.smoothing_param);
    analyzed_values(c).size_measurements_smooth = movmedian(analyzed_values(c).size_measurements, analysis_parameters.smoothing_param);
    analyzed_values(c).geminin_measurements_smooth = movmedian(analyzed_values(c).geminin_measurements, analysis_parameters.smoothing_param);
    if is_four_channels
        analyzed_values(c).protein_measurements_smooth = movmedian(analyzed_values(c).protein_measurements, analysis_parameters.smoothing_param);
    end
    
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
    if is_four_channels
        analyzed_values(c).protein_measurements_avoiding_ends = analyzed_values(c).protein_measurements...
            (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
    end
    
    % Measure birth size
    if analyzed_values(c).is_born
        areas_near_birth = analyzed_values(c).area_measurements(analysis_parameters.birthsize_measuring_frames);
        analyzed_values(c).birth_area = median(areas_near_birth);
        sizes_near_birth = analyzed_values(c).size_measurements(analysis_parameters.birthsize_measuring_frames);
        analyzed_values(c).birth_size = median(sizes_near_birth);
    end
    
    analyzed_values(c).passes_g1s = [];
    
    % Measure G1S transition time and cell cycle phase lengths
    if ~is_four_channels
        % If not a four-channel movie, can look only at complete cell
        % cycles.
        if analyzed_values(c).has_complete_cycle
            analyzed_values(c).g1s_frame_bilinear_notsmooth = get_g1s_frame(analyzed_values(c).geminin_measurements,analysis_parameters);
            analyzed_values(c).g1s_frame_bilinear_smooth = get_g1s_frame(analyzed_values(c).geminin_measurements_smooth,analysis_parameters);
            analyzed_values(c).g1_length_hours_v1 = analyzed_values(c).g1s_frame_bilinear_notsmooth * analysis_parameters.framerate;
            analyzed_values(c).g1_length_hours_v2 = analyzed_values(c).g1s_frame_bilinear_smooth * analysis_parameters.framerate;
            
            analyzed_values(c).g1s_frame = analyzed_values(c).g1s_frame_bilinear_notsmooth;
            analyzed_values(c).g1_length_hours = analyzed_values(c).g1_length_hours_v1;
            
            % If no G1S frame was found, count it no longer as a complete
            % cycle.
            if isempty(analyzed_values(c).g1s_frame)
                analyzed_values(c).passes_g1s = false;
                analyzed_values(c).has_complete_cycle = false;
                
                % Else record some measurements around G1/S
            else
                analyzed_values(c).passes_g1s = true;
                analyzed_values(c).sg2_length_hours = analyzed_values(c).trace_duration_hours - analyzed_values(c).g1_length_hours;
                analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
                analyzed_values(c).frame_to_start_measuring = max(1, analyzed_values(c).g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
                
                analyzed_values(c).instantaneous_sizes_during_g1 = analyzed_values(c).size_measurements(1:analyzed_values(c).g1s_frame);
                analyzed_values(c).instantaneous_sizes_during_sg2 = analyzed_values(c).size_measurements(analyzed_values(c).g1s_frame + 1 : end);
                
                analyzed_values(c).frame_indices_wrt_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : -1)';
                analyzed_values(c).g1s_happens_here_nextframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_nextframe),1));
                analyzed_values(c).g1s_happens_here_nextframe(end) = 1;
                analyzed_values(c).areas_up_to_g1s_nextframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
                analyzed_values(c).sizes_up_to_g1s_nextframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
                analyzed_values(c).geminin_up_to_g1s_nextframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
                
                if analyzed_values(c).is_born
                    analyzed_values(c).age_in_frames_up_to_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1)';
                    analyzed_values(c).age_in_hours_up_to_g1s_nextframe = analyzed_values(c).age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
                end
                
                analyzed_values(c).frame_indices_wrt_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : 0)';
                analyzed_values(c).g1s_happens_here_thisframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_thisframe),1));
                analyzed_values(c).g1s_happens_here_thisframe(end) = 1;
                analyzed_values(c).areas_up_to_g1s_thisframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
                analyzed_values(c).sizes_up_to_g1s_thisframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
                analyzed_values(c).geminin_up_to_g1s_thisframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
                
                if analyzed_values(c).is_born
                    analyzed_values(c).age_in_frames_up_to_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0)';
                    analyzed_values(c).age_in_hours_up_to_g1s_thisframe = analyzed_values(c).age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
                end
            end
        end
        
        % Measure sizes at G1S and G2M
        if analyzed_values(c).has_complete_cycle
            analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
            analyzed_values(c).g2m_size = analyzed_values(c).size_measurements_smooth(end - frames_to_avoid_at_end);
            
            analyzed_values(c).g1_growth = analyzed_values(c).g1s_size - analyzed_values(c).birth_size;
            analyzed_values(c).sg2_growth = analyzed_values(c).g2m_size - analyzed_values(c).g1s_size;
            analyzed_values(c).complete_cycle_growth = analyzed_values(c).g2m_size - analyzed_values(c).birth_size;
        end
        
    elseif is_four_channels
        % Get G1S frame by first normalizing each Geminin-mCherry signal to
        % the size-Crimson signal so that the Geminin curve is flat and
        % then slopes up.
        disp(['Finding G1S for cell ' num2str(c)])
        %         if c == 47
        %             disp('Stop here')
        %         end
        analyzed_values(c).g1s_frame = get_g1s_frame(...
            analyzed_values(c).geminin_measurements ./ analyzed_values(c).size_measurements_smooth,...
            analysis_parameters);
        analyzed_values(c).passes_g1s = ~isempty(analyzed_values(c).g1s_frame);
        
        %Examine all cell that pass G1/S, even if they don't have complete
        %cycles.
        if analyzed_values(c).passes_g1s
            analyzed_values(c).hours_before_g1s = analyzed_values(c).g1s_frame * analysis_parameters.framerate;
            analyzed_values(c).hours_after_g1s = analyzed_values(c).trace_duration_hours - analyzed_values(c).hours_before_g1s;
            analyzed_values(c).g1s_size = analyzed_values(c).size_measurements_smooth(analyzed_values(c).g1s_frame);
            analyzed_values(c).frame_to_start_measuring = max(1, analyzed_values(c).g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
            
            analyzed_values(c).instantaneous_sizes_during_g1 = analyzed_values(c).size_measurements(1:analyzed_values(c).g1s_frame);
            analyzed_values(c).instantaneous_sizes_during_sg2 = analyzed_values(c).size_measurements(analyzed_values(c).g1s_frame + 1 : end);
            
            analyzed_values(c).frame_indices_wrt_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : -1)';
            analyzed_values(c).g1s_happens_here_nextframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_nextframe),1));
            analyzed_values(c).g1s_happens_here_nextframe(end) = 1;
            analyzed_values(c).areas_up_to_g1s_nextframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
            analyzed_values(c).sizes_up_to_g1s_nextframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
            analyzed_values(c).geminin_up_to_g1s_nextframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
            analyzed_values(c).protein_amt_up_to_g1s_nextframe = analyzed_values(c).protein_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1);
            analyzed_values(c).protein_per_area_up_to_g1s_nextframe = analyzed_values(c).protein_amt_up_to_g1s_nextframe ./ analyzed_values(c).areas_up_to_g1s_nextframe;
            analyzed_values(c).protein_per_size_up_to_g1s_nextframe = analyzed_values(c).protein_amt_up_to_g1s_nextframe ./ analyzed_values(c).sizes_up_to_g1s_nextframe;
            
            if analyzed_values(c).is_born
                analyzed_values(c).age_in_frames_up_to_g1s_nextframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 1)';
                analyzed_values(c).age_in_hours_up_to_g1s_nextframe = analyzed_values(c).age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
            end
            
            analyzed_values(c).frame_indices_wrt_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring - analyzed_values(c).g1s_frame : 0)';
            analyzed_values(c).g1s_happens_here_thisframe = logical(zeros(length(analyzed_values(c).frame_indices_wrt_g1s_thisframe),1));
            analyzed_values(c).g1s_happens_here_thisframe(end) = 1;
            analyzed_values(c).areas_up_to_g1s_thisframe = analyzed_values(c).area_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
            analyzed_values(c).sizes_up_to_g1s_thisframe = analyzed_values(c).size_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
            analyzed_values(c).geminin_up_to_g1s_thisframe = analyzed_values(c).geminin_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
            analyzed_values(c).protein_amt_up_to_g1s_thisframe = analyzed_values(c).protein_measurements(analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0);
            analyzed_values(c).protein_per_area_up_to_g1s_thisframe = analyzed_values(c).protein_amt_up_to_g1s_thisframe ./ analyzed_values(c).areas_up_to_g1s_thisframe;
            analyzed_values(c).protein_per_size_up_to_g1s_thisframe = analyzed_values(c).protein_amt_up_to_g1s_thisframe ./ analyzed_values(c).sizes_up_to_g1s_thisframe;
            
            if analyzed_values(c).is_born
                analyzed_values(c).age_in_frames_up_to_g1s_thisframe = (analyzed_values(c).frame_to_start_measuring : analyzed_values(c).g1s_frame - 0)';
                analyzed_values(c).age_in_hours_up_to_g1s_thisframe = analyzed_values(c).age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
            end
        end
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
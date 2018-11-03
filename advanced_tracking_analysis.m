
function thiscell_analysis = advanced_tracking_analysis(thiscell_analysis, c, tree, analysis_parameters, is_four_channels)


% Check birth
thiscell_analysis.is_born = ~isempty(tree(c).mother_id);

% Check generation
thiscell_analysis.generation = 0;
thiscell = c;
mother = tree.mother_id;
while ~isempty(mother)
    thiscell_analysis.generation = thiscell_analysis.generation + 1;
    % Check for infinite loops resulting from impossible parentage
    if thiscell == mother
        disp(['Cell ' num2str(c) ' is its own mother.'])
        thiscell_analysis.has_something_gone_horribly_wrong = true;
        break
    end
    thiscell = mother;
    mother = tree(thiscell).mother_id;
end

% Check whether born early or late in movie
thiscell_analysis.is_born_early_in_movie = thiscell_analysis.firstframe < analysis_parameters.birth_frame_threshold;

% if thiscell_analysis.has_mitosis
%     if tracking_measurements.track_metadata(c).mitosis ~= thiscell_analysis.lastframe
%         thiscell_analysis.mitosis_is_lastframe = false;
%         disp('Mitosis and lastframe do not match')
%     else
%         thiscell_analysis.mitosis_is_lastframe = true;
%     end
% end

% Check duration
thiscell_analysis.trace_duration_frames =...
    thiscell_analysis.lastframe - thiscell_analysis.firstframe + 1;
thiscell_analysis.trace_duration_hours =...
    thiscell_analysis.trace_duration_frames * analysis_parameters.framerate;
if thiscell_analysis.trace_duration_hours >= analysis_parameters.min_total_trace_frames * analysis_parameters.framerate
    thiscell_analysis.trace_is_long_enough = true;
else
    thiscell_analysis.trace_is_long_enough = false;
    return
end

% Check if it's a complete cycle
thiscell_analysis.has_complete_cycle = thiscell_analysis.is_born && thiscell_analysis.has_mitosis;
if thiscell_analysis.has_complete_cycle
    disp(['Cell ' num2str(c) ' has complete cycle.'])
end

% Gather the measurements
thiscell_analysis.birth_aligned_frames = [thiscell_analysis.firstframe : thiscell_analysis.lastframe]';
thiscell_analysis.birth_aligned_hours = linspace(0, (thiscell_analysis.trace_duration_frames - 1)*analysis_parameters.framerate,...
    thiscell_analysis.trace_duration_frames)';
thiscell_analysis.area_measurements = thiscell_analysis.thiscell_complete_area_measurements...
    (thiscell_analysis.firstframe : thiscell_analysis.lastframe);
thiscell_analysis.size_measurements = thiscell_analysis.thiscell_complete_size_measurements...
    (thiscell_analysis.firstframe : thiscell_analysis.lastframe);
thiscell_analysis.geminin_measurements = thiscell_analysis.thiscell_complete_geminin_measurements...
    (thiscell_analysis.firstframe : thiscell_analysis.lastframe);
if is_four_channels
    thiscell_analysis.protein_measurements = thiscell_analysis.thiscell_complete_protein_measurements...
        (thiscell_analysis.firstframe : thiscell_analysis.lastframe);
end

% Smoothen measurements
thiscell_analysis.area_measurements_smooth = movmedian(thiscell_analysis.area_measurements, analysis_parameters.smoothing_param);
thiscell_analysis.size_measurements_smooth = movmedian(thiscell_analysis.size_measurements, analysis_parameters.smoothing_param);
thiscell_analysis.geminin_measurements_smooth = movmedian(thiscell_analysis.geminin_measurements, analysis_parameters.smoothing_param);
if is_four_channels
    thiscell_analysis.protein_measurements_smooth = movmedian(thiscell_analysis.protein_measurements, analysis_parameters.smoothing_param);
end

% Gather measurements avoiding frames at start and end of cycle
frames_to_avoid_at_start = 0;
frames_to_avoid_at_end = 0;
if thiscell_analysis.is_born
    frames_to_avoid_at_start = analysis_parameters.num_first_frames_to_avoid;
end
if thiscell_analysis.has_mitosis
    frames_to_avoid_at_end = analysis_parameters.num_last_frames_to_avoid;
end
thiscell_analysis.area_measurements_avoiding_ends = thiscell_analysis.area_measurements...
    (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
thiscell_analysis.size_measurements_avoiding_ends = thiscell_analysis.size_measurements...
    (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
thiscell_analysis.geminin_measurements_avoiding_ends = thiscell_analysis.geminin_measurements...
    (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
if is_four_channels
    thiscell_analysis.protein_measurements_avoiding_ends = thiscell_analysis.protein_measurements...
        (frames_to_avoid_at_start + 1 : end - frames_to_avoid_at_end);
end

% Measure birth size
if thiscell_analysis.is_born
    areas_near_birth = thiscell_analysis.area_measurements(analysis_parameters.birthsize_measuring_frames);
    thiscell_analysis.birth_area = median(areas_near_birth);
    sizes_near_birth = thiscell_analysis.size_measurements(analysis_parameters.birthsize_measuring_frames);
    thiscell_analysis.birth_size = median(sizes_near_birth);
end

thiscell_analysis.passes_g1s = [];

% Measure G1S transition time and cell cycle phase lengths
if ~is_four_channels
    % If not a four-channel movie, can look only at complete cell
    % cycles.
    if thiscell_analysis.has_complete_cycle
        thiscell_analysis.g1s_frame_notsmooth = get_g1s_frame(thiscell_analysis.geminin_measurements,analysis_parameters);
        thiscell_analysis.g1s_frame_smooth = get_g1s_frame(thiscell_analysis.geminin_measurements_smooth,analysis_parameters);
        thiscell_analysis.g1_length_hours_notsmooth = thiscell_analysis.g1s_frame_notsmooth * analysis_parameters.framerate;
        thiscell_analysis.g1_length_hours_smooth = thiscell_analysis.g1s_frame_smooth * analysis_parameters.framerate;
        
        thiscell_analysis.g1s_frame = thiscell_analysis.g1s_frame_notsmooth;
        thiscell_analysis.g1_length_hours = thiscell_analysis.g1_length_hours_notsmooth;
        
        % If no G1S frame was found, count it no longer as a complete
        % cycle.
        if isempty(thiscell_analysis.g1s_frame)
            thiscell_analysis.passes_g1s = false;
            thiscell_analysis.has_complete_cycle = false;
            
            % Else record some measurements around G1/S
        else
            thiscell_analysis.passes_g1s = true;
            thiscell_analysis.sg2_length_hours = thiscell_analysis.trace_duration_hours - thiscell_analysis.g1_length_hours;
            thiscell_analysis.g1s_size = thiscell_analysis.size_measurements_smooth(thiscell_analysis.g1s_frame);
            thiscell_analysis.g1s_area = thiscell_analysis.area_measurements_smooth(thiscell_analysis.g1s_frame);
            thiscell_analysis.frame_to_start_measuring = max(1, thiscell_analysis.g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
            
            thiscell_analysis.instantaneous_sizes_during_g1 = thiscell_analysis.size_measurements(1:thiscell_analysis.g1s_frame);
            thiscell_analysis.instantaneous_sizes_during_sg2 = thiscell_analysis.size_measurements(thiscell_analysis.g1s_frame + 1 : end);
            
            % Give frames indices running from say -32 to +26,
            % with G1/S at index 0
            thiscell_analysis.all_frame_indices_wrt_g1s = (1 : thiscell_analysis.trace_duration_frames) - thiscell_analysis.g1s_frame;
            
            % Examine values up to but not including G1/S frame
            thiscell_analysis.frame_indices_wrt_g1s_nextframe = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -1)';
            thiscell_analysis.g1s_happens_here_nextframe = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_nextframe),1));
            thiscell_analysis.g1s_happens_here_nextframe(end) = 1;
            thiscell_analysis.areas_up_to_g1s_nextframe = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
            thiscell_analysis.sizes_up_to_g1s_nextframe = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
            thiscell_analysis.volumes_up_to_g1s_nextframe = thiscell_analysis.areas_up_to_g1s_nextframe .^ 1.5;
            thiscell_analysis.geminin_up_to_g1s_nextframe = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
            
            if thiscell_analysis.is_born
                thiscell_analysis.age_in_frames_up_to_g1s_nextframe = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1)';
                thiscell_analysis.age_in_hours_up_to_g1s_nextframe = thiscell_analysis.age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
            end
            
            % Examine values up to and including G1/S frame
            thiscell_analysis.frame_indices_wrt_g1s_thisframe = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : 0)';
            thiscell_analysis.g1s_happens_here_thisframe = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_thisframe),1));
            thiscell_analysis.g1s_happens_here_thisframe(end) = 1;
            thiscell_analysis.areas_up_to_g1s_thisframe = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
            thiscell_analysis.sizes_up_to_g1s_thisframe = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
            thiscell_analysis.volumes_up_to_g1s_thisframe = thiscell_analysis.areas_up_to_g1s_thisframe .^ 1.5;
            thiscell_analysis.geminin_up_to_g1s_thisframe = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
            
            if thiscell_analysis.is_born
                thiscell_analysis.age_in_frames_up_to_g1s_thisframe = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0)';
                thiscell_analysis.age_in_hours_up_to_g1s_thisframe = thiscell_analysis.age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
            end
            
            % Examine values before 1 hours prior to G1/S frame
            f1 = 1 / analysis_parameters.framerate;
            thiscell_analysis.frame_indices_wrt_g1s_1hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f1)';
            thiscell_analysis.g1s_happens_here_1hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_1hrs_ahead),1));
            thiscell_analysis.g1s_happens_here_1hrs_ahead(end) = 1;
            thiscell_analysis.areas_up_to_g1s_1hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
            thiscell_analysis.sizes_up_to_g1s_1hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
            thiscell_analysis.volumes_up_to_g1s_1hrs_ahead = thiscell_analysis.areas_up_to_g1s_1hrs_ahead .^ 1.5;
            thiscell_analysis.geminin_up_to_g1s_1hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
            
            if thiscell_analysis.is_born
                thiscell_analysis.age_in_frames_up_to_g1s_1hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1)';
                thiscell_analysis.age_in_hours_up_to_g1s_1hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_1hrs_ahead * analysis_parameters.framerate;
            end
            
            % Examine values before 2 hours prior to G1/S frame
            f2 = 2 / analysis_parameters.framerate;
            thiscell_analysis.frame_indices_wrt_g1s_2hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f2)';
            thiscell_analysis.g1s_happens_here_2hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_2hrs_ahead),1));
            thiscell_analysis.g1s_happens_here_2hrs_ahead(end) = 1;
            thiscell_analysis.areas_up_to_g1s_2hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
            thiscell_analysis.sizes_up_to_g1s_2hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
            thiscell_analysis.volumes_up_to_g1s_2hrs_ahead = thiscell_analysis.areas_up_to_g1s_2hrs_ahead .^ 1.5;
            thiscell_analysis.geminin_up_to_g1s_2hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
            
            if thiscell_analysis.is_born
                thiscell_analysis.age_in_frames_up_to_g1s_2hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2)';
                thiscell_analysis.age_in_hours_up_to_g1s_2hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_2hrs_ahead * analysis_parameters.framerate;
            end
            
            % Examine values before 3 hours prior to G1/S frame
            f3 = 3 / analysis_parameters.framerate;
            thiscell_analysis.frame_indices_wrt_g1s_3hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f3)';
            thiscell_analysis.g1s_happens_here_3hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_3hrs_ahead),1));
            thiscell_analysis.g1s_happens_here_3hrs_ahead(end) = 1;
            thiscell_analysis.areas_up_to_g1s_3hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
            thiscell_analysis.sizes_up_to_g1s_3hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
            thiscell_analysis.volumes_up_to_g1s_3hrs_ahead = thiscell_analysis.areas_up_to_g1s_3hrs_ahead .^ 1.5;
            thiscell_analysis.geminin_up_to_g1s_3hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
            
            if thiscell_analysis.is_born
                thiscell_analysis.age_in_frames_up_to_g1s_3hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3)';
                thiscell_analysis.age_in_hours_up_to_g1s_3hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_3hrs_ahead * analysis_parameters.framerate;
            end
            
        end
    end
    
    % Measure sizes at G1S and G2M
    if thiscell_analysis.has_complete_cycle
        thiscell_analysis.g1s_size = thiscell_analysis.size_measurements_smooth(thiscell_analysis.g1s_frame);
        thiscell_analysis.g1s_area = thiscell_analysis.area_measurements_smooth(thiscell_analysis.g1s_frame);
        thiscell_analysis.g2m_size = thiscell_analysis.size_measurements_smooth(end - frames_to_avoid_at_end);
        
        thiscell_analysis.g1_growth = thiscell_analysis.g1s_size - thiscell_analysis.birth_size;
        thiscell_analysis.sg2_growth = thiscell_analysis.g2m_size - thiscell_analysis.g1s_size;
        thiscell_analysis.complete_cycle_growth = thiscell_analysis.g2m_size - thiscell_analysis.birth_size;
    end
    
elseif is_four_channels
    % Get G1S frame by first normalizing each Geminin-mCherry signal to
    % the size-Crimson signal so that the Geminin curve is flat and
    % then slopes up.
    disp(['Finding G1S for cell ' num2str(c)])
    %         if c == 47
    %             disp('Stop here')
    %         end
    thiscell_analysis.g1s_frame = get_g1s_frame(...
        thiscell_analysis.geminin_measurements ./ thiscell_analysis.size_measurements_smooth,...
        analysis_parameters);
    thiscell_analysis.passes_g1s = ~isempty(thiscell_analysis.g1s_frame);
    
    %Examine all cell that pass G1/S, even if they don't have complete
    %cycles.
    if thiscell_analysis.passes_g1s
        thiscell_analysis.hours_before_g1s = thiscell_analysis.g1s_frame * analysis_parameters.framerate;
        thiscell_analysis.hours_after_g1s = thiscell_analysis.trace_duration_hours - thiscell_analysis.hours_before_g1s;
        thiscell_analysis.g1s_size = thiscell_analysis.size_measurements_smooth(thiscell_analysis.g1s_frame);
        thiscell_analysis.g1s_area = thiscell_analysis.area_measurements_smooth(thiscell_analysis.g1s_frame);
        thiscell_analysis.frame_to_start_measuring = max(1, thiscell_analysis.g1s_frame - analysis_parameters.frames_before_g1s_to_examine);
        thiscell_analysis.g1s_protein_amt = thiscell_analysis.protein_measurements(thiscell_analysis.g1s_frame);
        
        if thiscell_analysis.is_born
            thiscell_analysis.g1_length_hours = thiscell_analysis.g1s_frame * analysis_parameters.framerate;
            thiscell_analysis.g1_growth = thiscell_analysis.g1s_size - thiscell_analysis.birth_size;
        end
        
        if thiscell_analysis.has_mitosis
            thiscell_analysis.sg2_length_frames = thiscell_analysis.relative_lastframe - thiscell_analysis.g1s_frame;
            thiscell_analysis.sg2_length_hours = thiscell_analysis.sg2_length_frames * analysis_parameters.framerate;
            thiscell_analysis.g2m_size = thiscell_analysis.size_measurements_smooth(end - frames_to_avoid_at_end);
            thiscell_analysis.g2m_area = thiscell_analysis.area_measurements_smooth(end - frames_to_avoid_at_end);
            thiscell_analysis.sg2_growth = thiscell_analysis.g2m_size - thiscell_analysis.g1s_size;
            thiscell_analysis.g2m_protein_amt = thiscell_analysis.protein_measurements(end - frames_to_avoid_at_end);
            thiscell_analysis.sg2_protein_increase = thiscell_analysis.g2m_protein_amt - thiscell_analysis.g1s_protein_amt;
            thiscell_analysis.protein_amts_during_sg2 = thiscell_analysis.protein_measurements(thiscell_analysis.g1s_frame : end - frames_to_avoid_at_end);
            thiscell_analysis.sg2_frames = 1 : length(thiscell_analysis.protein_amts_during_sg2);
            lm = fitlm(thiscell_analysis.sg2_frames, thiscell_analysis.protein_amts_during_sg2);
            thiscell_analysis.sg2_protein_accumulation_slope_perframe = lm.Coefficients.Estimate(2);
        end
        
        if thiscell_analysis.has_complete_cycle
            thiscell_analysis.complete_cycle_growth = thiscell_analysis.g2m_size - thiscell_analysis.birth_size;
        end
        
        thiscell_analysis.instantaneous_sizes_during_g1 = thiscell_analysis.size_measurements(1:thiscell_analysis.g1s_frame);
        thiscell_analysis.instantaneous_sizes_during_sg2 = thiscell_analysis.size_measurements(thiscell_analysis.g1s_frame + 1 : end);
        
        % Give frames indices running from say -32 to +26,
        % with G1/S at index 0
        thiscell_analysis.all_frame_indices_wrt_g1s = (1 : thiscell_analysis.trace_duration_frames) - thiscell_analysis.g1s_frame;
        
        % Examine values up to but not including G1/S frame        
        thiscell_analysis.frame_indices_wrt_g1s_nextframe = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -1)';
        thiscell_analysis.g1s_happens_here_nextframe = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_nextframe),1));
        thiscell_analysis.g1s_happens_here_nextframe(end) = 1;
        thiscell_analysis.areas_up_to_g1s_nextframe = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
        thiscell_analysis.sizes_up_to_g1s_nextframe = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
        thiscell_analysis.volumes_up_to_g1s_nextframe = thiscell_analysis.areas_up_to_g1s_nextframe .^ 1.5;
        thiscell_analysis.geminin_up_to_g1s_nextframe = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
        thiscell_analysis.protein_amt_up_to_g1s_nextframe = thiscell_analysis.protein_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1);
        thiscell_analysis.protein_per_area_up_to_g1s_nextframe = thiscell_analysis.protein_amt_up_to_g1s_nextframe ./ thiscell_analysis.areas_up_to_g1s_nextframe;
        thiscell_analysis.protein_per_size_up_to_g1s_nextframe = thiscell_analysis.protein_amt_up_to_g1s_nextframe ./ thiscell_analysis.sizes_up_to_g1s_nextframe;
        thiscell_analysis.protein_per_volume_up_to_g1s_nextframe = thiscell_analysis.protein_amt_up_to_g1s_nextframe ./ thiscell_analysis.volumes_up_to_g1s_nextframe;
        
        if thiscell_analysis.is_born
            thiscell_analysis.age_in_frames_up_to_g1s_nextframe = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 1)';
            thiscell_analysis.age_in_hours_up_to_g1s_nextframe = thiscell_analysis.age_in_frames_up_to_g1s_nextframe * analysis_parameters.framerate;
        end
        
        % Examine values up to and including G1/S frame
        thiscell_analysis.frame_indices_wrt_g1s_thisframe = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : 0)';
        thiscell_analysis.g1s_happens_here_thisframe = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_thisframe),1));
        thiscell_analysis.g1s_happens_here_thisframe(end) = 1;
        thiscell_analysis.areas_up_to_g1s_thisframe = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
        thiscell_analysis.sizes_up_to_g1s_thisframe = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
        thiscell_analysis.volumes_up_to_g1s_thisframe = thiscell_analysis.areas_up_to_g1s_thisframe .^ 1.5;
        thiscell_analysis.geminin_up_to_g1s_thisframe = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
        thiscell_analysis.protein_amt_up_to_g1s_thisframe = thiscell_analysis.protein_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0);
        thiscell_analysis.protein_per_area_up_to_g1s_thisframe = thiscell_analysis.protein_amt_up_to_g1s_thisframe ./ thiscell_analysis.areas_up_to_g1s_thisframe;
        thiscell_analysis.protein_per_size_up_to_g1s_thisframe = thiscell_analysis.protein_amt_up_to_g1s_thisframe ./ thiscell_analysis.sizes_up_to_g1s_thisframe;
        thiscell_analysis.protein_per_volume_up_to_g1s_thisframe = thiscell_analysis.protein_amt_up_to_g1s_thisframe ./ thiscell_analysis.volumes_up_to_g1s_thisframe;
        
        if thiscell_analysis.is_born
            thiscell_analysis.age_in_frames_up_to_g1s_thisframe = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - 0)';
            thiscell_analysis.age_in_hours_up_to_g1s_thisframe = thiscell_analysis.age_in_frames_up_to_g1s_thisframe * analysis_parameters.framerate;
        end
        
        % Examine values before 1 hours prior to G1/S frame
        f1 = 1 / analysis_parameters.framerate;
        thiscell_analysis.frame_indices_wrt_g1s_1hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f1)';
        thiscell_analysis.g1s_happens_here_1hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_1hrs_ahead),1));
        thiscell_analysis.g1s_happens_here_1hrs_ahead(end) = 1;
        thiscell_analysis.areas_up_to_g1s_1hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
        thiscell_analysis.sizes_up_to_g1s_1hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
        thiscell_analysis.volumes_up_to_g1s_1hrs_ahead = thiscell_analysis.areas_up_to_g1s_1hrs_ahead .^ 1.5;
        thiscell_analysis.geminin_up_to_g1s_1hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
        thiscell_analysis.protein_amt_up_to_g1s_1hrs_ahead = thiscell_analysis.protein_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1);
        thiscell_analysis.protein_per_area_up_to_g1s_1hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_1hrs_ahead ./ thiscell_analysis.areas_up_to_g1s_1hrs_ahead;
        thiscell_analysis.protein_per_size_up_to_g1s_1hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_1hrs_ahead ./ thiscell_analysis.sizes_up_to_g1s_1hrs_ahead;
        thiscell_analysis.protein_per_volume_up_to_g1s_1hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_1hrs_ahead ./ thiscell_analysis.volumes_up_to_g1s_1hrs_ahead;
        
        if thiscell_analysis.is_born
            thiscell_analysis.age_in_frames_up_to_g1s_1hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f1)';
            thiscell_analysis.age_in_hours_up_to_g1s_1hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_1hrs_ahead * analysis_parameters.framerate;
        end
        
        % Examine values before 2 hours prior to G1/S frame
        f2 = 2 / analysis_parameters.framerate;
        thiscell_analysis.frame_indices_wrt_g1s_2hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f2)';
        thiscell_analysis.g1s_happens_here_2hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_2hrs_ahead),1));
        thiscell_analysis.g1s_happens_here_2hrs_ahead(end) = 1;
        thiscell_analysis.areas_up_to_g1s_2hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
        thiscell_analysis.sizes_up_to_g1s_2hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
        thiscell_analysis.volumes_up_to_g1s_2hrs_ahead = thiscell_analysis.areas_up_to_g1s_2hrs_ahead .^ 1.5;
        thiscell_analysis.geminin_up_to_g1s_2hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
        thiscell_analysis.protein_amt_up_to_g1s_2hrs_ahead = thiscell_analysis.protein_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2);
        thiscell_analysis.protein_per_area_up_to_g1s_2hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_2hrs_ahead ./ thiscell_analysis.areas_up_to_g1s_2hrs_ahead;
        thiscell_analysis.protein_per_size_up_to_g1s_2hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_2hrs_ahead ./ thiscell_analysis.sizes_up_to_g1s_2hrs_ahead;
        thiscell_analysis.protein_per_volume_up_to_g1s_2hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_2hrs_ahead ./ thiscell_analysis.volumes_up_to_g1s_2hrs_ahead;
        
        if thiscell_analysis.is_born
            thiscell_analysis.age_in_frames_up_to_g1s_2hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f2)';
            thiscell_analysis.age_in_hours_up_to_g1s_2hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_2hrs_ahead * analysis_parameters.framerate;
        end
        
        % Examine values before 3 hours prior to G1/S frame
        f3 = 3 / analysis_parameters.framerate;
        thiscell_analysis.frame_indices_wrt_g1s_3hrs_ahead = (thiscell_analysis.frame_to_start_measuring - thiscell_analysis.g1s_frame : -f3)';
        thiscell_analysis.g1s_happens_here_3hrs_ahead = logical(zeros(length(thiscell_analysis.frame_indices_wrt_g1s_3hrs_ahead),1));
        thiscell_analysis.g1s_happens_here_3hrs_ahead(end) = 1;
        thiscell_analysis.areas_up_to_g1s_3hrs_ahead = thiscell_analysis.area_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
        thiscell_analysis.sizes_up_to_g1s_3hrs_ahead = thiscell_analysis.size_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
        thiscell_analysis.volumes_up_to_g1s_3hrs_ahead = thiscell_analysis.areas_up_to_g1s_3hrs_ahead .^ 1.5;
        thiscell_analysis.geminin_up_to_g1s_3hrs_ahead = thiscell_analysis.geminin_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
        thiscell_analysis.protein_amt_up_to_g1s_3hrs_ahead = thiscell_analysis.protein_measurements(thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3);
        thiscell_analysis.protein_per_area_up_to_g1s_3hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_3hrs_ahead ./ thiscell_analysis.areas_up_to_g1s_3hrs_ahead;
        thiscell_analysis.protein_per_size_up_to_g1s_3hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_3hrs_ahead ./ thiscell_analysis.sizes_up_to_g1s_3hrs_ahead;
        thiscell_analysis.protein_per_volume_up_to_g1s_3hrs_ahead = thiscell_analysis.protein_amt_up_to_g1s_3hrs_ahead ./ thiscell_analysis.volumes_up_to_g1s_3hrs_ahead;

        
        if thiscell_analysis.is_born
            thiscell_analysis.age_in_frames_up_to_g1s_3hrs_ahead = (thiscell_analysis.frame_to_start_measuring : thiscell_analysis.g1s_frame - f3)';
            thiscell_analysis.age_in_hours_up_to_g1s_3hrs_ahead = thiscell_analysis.age_in_frames_up_to_g1s_3hrs_ahead * analysis_parameters.framerate;
        end
    end
end


%
%     % Plot some cells
%         if thiscell_analysis.has_complete_cycle && ismember(c,[38 42])
%             figure()
%             hold on
%             xlabel('Cell age (h)')
%             yyaxis left
%             plot(thiscell_analysis.birth_aligned_hours, thiscell_analysis.size_measurements,'r');
%             plot(thiscell_analysis.birth_aligned_hours, thiscell_analysis.size_measurements_smooth,'m');
%             ax = gca;
%             ax.YColor = 'r';
%             ylabel('EF1a-mCherry size measurement')
%             axis([0 inf 0 200000]);
%             yyaxis right
%             plot(thiscell_analysis.birth_aligned_hours, thiscell_analysis.geminin_measurements,'g');
%             plot(thiscell_analysis.birth_aligned_hours, thiscell_analysis.geminin_measurements_smooth,'c')
%             ax = gca;
%             ax.YColor = 'g';
%             ylabel('Geminin-GFP')
%             axis([0 inf 0 1000000]);
%             hold off
%         end
%
end
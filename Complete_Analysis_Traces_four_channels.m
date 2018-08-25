clear all
close all

%% Set parameters

tracking_strategy = 'clicking';
% tracking_strategy = 'aivia';

source_folder = 'E:\Manually tracked measurements';
expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
measure_protein_concentrations = false;

% source_folder = 'F:\Manually tracked imaging experiments';
% expt_name = 'DFB_180803_HMEC_D5_1';
% measure_protein_concentrations = true;

expt_folder = [source_folder '\' expt_name];

num_conditions = 2;

% Choose types of measurements
measure_area_vs_fluorescence = true;
measure_sizes_at_birth_and_other_times = true;
measure_lengths_of_phases = true;
measure_g1s_probabilities = true;

% Set analysis parameters
analysis_parameters = struct;

switch expt_name
    case 'DFB_180627_HMEC_1GFiii_palbo_2'
        analysis_parameters.order_of_channels = 'prg';
        analysis_parameters.size_channel = 'r';
        analysis_parameters.geminin_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 421;
        analysis_parameters.segmentation_parameters.threshold = 200;
        analysis_parameters.segmentation_parameters.strel_size = 1;
        analysis_parameters.threshold = 20000;
        analysis_parameters.second_line_min_slope = 50000/20;
        
    case 'DFB_180803_HMEC_D5_1'
        analysis_parameters.segmentation_parameters.threshold = 272;
        analysis_parameters.segmentation_parameters.strel_size = 3;
        analysis_parameters.threshold = 0.15;
        analysis_parameters.second_line_min_slope = 0.05/20;
        analysis_parameters.order_of_channels = 'pgrf';
        analysis_parameters.size_channel = 'f';
        analysis_parameters.geminin_channel = 'r';
        analysis_parameters.protein_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 432;
end

analysis_parameters.segmentation_parameters.gaussian_width = 2;
analysis_parameters.segmentation_parameters.strel_shape = 'disk';

analysis_parameters.framerate = 1/6;
analysis_parameters.num_first_frames_to_avoid = 5;
analysis_parameters.num_last_frames_to_avoid = 10;
analysis_parameters.frames_to_check_nearby = 20;
analysis_parameters.min_frames_above = 15;

analysis_parameters.plot = false;
analysis_parameters.strategy = 'all';
analysis_parameters.min_total_trace_frames = 30;

analysis_parameters.g1s_quality_control = true;
analysis_parameters.g1_frames_reqd_before_g1s = 10;
analysis_parameters.sg2_frames_reqd_after_g1s = 10;
analysis_parameters.max_g1s_noise_frames = 10;
analysis_parameters.frames_before_g1s_to_examine = 5 / analysis_parameters.framerate;
analysis_parameters.birthsize_measuring_frames = [6:12];
analysis_parameters.min_cycle_duration_hours = 5;
% I think the following line is deprecated:
% analysis_parameters.geminin_threshold = 100000;
analysis_parameters.smoothing_param = 5;
analysis_parameters.max_fraction_diff_from_sibling_mean = 0.2;
analysis_parameters.max_birth_size = 100000;
analysis_parameters.birth_frame_threshold = 200;

analysis_parameters.average_instantaneous_growth_rate_over_num_frames = 3;


%% Gather data

% Create data structure
for cond = 1:num_conditions
    if cond == 1
        data(cond).treatment = 'PBS';
        switch expt_name
            case 'DFB_180627_HMEC_1GFiii_palbo_2'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [1 2 3];
                    case 'aivia'
                        data(cond).positions_list = [1 2 3 5 6 7 8 9 10 11 12];
                end
                
            case 'DFB_180803_HMEC_D5_1'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [1];
                    case 'aivia'
                        data(cond).positions_list = [1 2 3 4];
                end
        end
        
        
        
    elseif cond == 2
        data(cond).treatment = '40 nM palbociclib';
        switch expt_name
            case 'DFB_180627_HMEC_1GFiii_palbo_2'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [13 14 15];
                    case 'aivia'
                        data(cond).positions_list = [13 14];
                end
                
            case 'DFB_180803_HMEC_D5_1'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [13];
                    case 'aivia'
                        data(cond).positions_list = [13 14 15 16];
                end
        end
        
    end
end

% Gather and analyze data for each position. Strategy depends on how the
% traces were generated.
if strcmp(tracking_strategy,'clicking')
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            position_folder = [expt_folder '\Pos' num2str(pos)];
            load([position_folder '\TrackingData.mat']);
            load([position_folder '\Measurements.mat']);
            load([position_folder '\Family_Relationships.mat']);
            
            for fn = fieldnames(saved_data)'
                data(cond).position(pos).tracking_measurements.(fn{1}) = saved_data.(fn{1});
            end
            for fn = fieldnames(measurements_struct)'
                data(cond).position(pos).tracking_measurements.(fn{1}) = measurements_struct.(fn{1});
            end
            data(cond).position(pos).tree = tree;
            
            clear saved_data
            clear measurements_struct
            
            disp(['Analyzing tracking data for position ' num2str(pos) '.'])
            data(cond).position(pos).analysis =...
                analyze_tracking_data_clicking(data(cond).position(pos).tracking_measurements,...
                data(cond).position(pos).tree, analysis_parameters);
        end
    end
    
elseif strcmp(tracking_strategy,'aivia')
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            disp(['Analyzing tracking data for position ' num2str(pos) '.'])
            [data(cond).position(pos).analysis, data(cond).position(pos).tree] =...
                analyze_tracking_data_aivia(expt_folder, expt_name, pos, analysis_parameters);
            data(cond).position(pos).tracking_measurements.all_tracknums =...
                1:length(data(cond).position(pos).analysis);
        end
    end
end


%% Collate measurements

% Collate all area and size measurements for all cells across all
% timepoints into one giant list
if measure_area_vs_fluorescence
    data(cond).all_area_measurements = [];
    data(cond).all_size_measurements = [];
    data(cond).all_area_measurements_avoiding_ends = [];
    data(cond).all_size_measurements_avoiding_ends = [];
    
    % Lop off last value so V and dV have equal numbers of data points
    data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast = [];
    data(cond).all_instantaneous_size_increase_measurements_avoiding_ends = [];
    
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                data(cond).all_area_measurements = [data(cond).all_area_measurements;...
                    data(cond).position(pos).analysis(c).area_measurements];
                data(cond).all_size_measurements = [data(cond).all_size_measurements;...
                    data(cond).position(pos).analysis(c).size_measurements];
                data(cond).all_area_measurements_avoiding_ends = [data(cond).all_area_measurements_avoiding_ends;...
                    data(cond).position(pos).analysis(c).area_measurements_avoiding_ends];
                data(cond).all_size_measurements_avoiding_ends = [data(cond).all_size_measurements_avoiding_ends;...
                    data(cond).position(pos).analysis(c).size_measurements_avoiding_ends];
                
                data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast = [data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast;...
                    data(cond).position(pos).analysis(c).size_measurements_avoiding_ends(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames)];
                data(cond).all_instantaneous_size_increase_measurements_avoiding_ends = [data(cond).all_instantaneous_size_increase_measurements_avoiding_ends;...
                    (data(cond).position(pos).analysis(c).size_measurements_avoiding_ends(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) -...
                    data(cond).position(pos).analysis(c).size_measurements_avoiding_ends(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))];
                
                % In case of
                % analysis_parameters.average_instantaneous_growth_rate_over_num_frames
                % is equal to 1, can just use diff function
%                 data(cond).all_instantaneous_size_increase_measurements_avoiding_ends = [data(cond).all_instantaneous_size_increase_measurements_avoiding_ends;...
%                     diff(data(cond).position(pos).analysis(c).size_measurements_avoiding_ends)];
            end
        end
    end
end

% Collate birth sizes, G1/S sizes, G2/M sizes
if measure_sizes_at_birth_and_other_times
    for cond = 1:num_conditions
        num_total_born_cells = 0;
        num_total_born_cells_similar_to_sister = 0;
        
        data(cond).all_birth_sizes = [];
        data(cond).first_gen_birth_sizes = [];
        data(cond).second_gen_birth_sizes = [];
        data(cond).third_gen_and_beyond_birth_sizes = [];
        
        data(cond).all_good_birth_sizes = [];
        data(cond).first_gen_good_birth_sizes = [];
        data(cond).second_gen_good_birth_sizes = [];
        data(cond).third_gen_and_beyond_good_birth_sizes = [];
        
        data(cond).early_birth_sizes = [];
        data(cond).late_birth_sizes = [];
        
        data(cond).all_good_birth_areas = [];
        data(cond).first_gen_good_birth_areas = [];
        data(cond).second_gen_good_birth_areas = [];
        data(cond).third_gen_and_beyond_good_birth_areas = [];
        
        data(cond).all_good_g1s_sizes = [];
        data(cond).first_gen_good_g1s_sizes = [];
        data(cond).second_gen_good_g1s_sizes = [];
        data(cond).third_gen_and_beyond_good_g1s_sizes = [];
        
        data(cond).all_good_g2m_sizes = [];
        
        data(cond).all_good_g1_growths = [];
        data(cond).all_good_sg2_growths = [];
        data(cond).all_good_complete_cycle_growths = [];
        
        data(cond).all_instantaneous_g1_sizes_nolast = [];
        data(cond).all_instantaneous_g1_size_increases = [];
        data(cond).all_instantaneous_sg2_sizes_nolast = [];
        data(cond).all_instantaneous_sg2_size_increases = [];
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if data(cond).position(pos).analysis(c).is_born
                    
                    num_total_born_cells = num_total_born_cells + 1;
                    
                    data(cond).position(pos).analysis(c).has_valid_birth_size = true;
                    
                    % Compare birth sizes with sisters'
                    thiscell_birth_size = data(cond).position(pos).analysis(c).birth_size;
                    thiscell_mother = data(cond).position(pos).tree(c).mother_id;
                    thiscell_and_sister = [data(cond).position(pos).tree(thiscell_mother).daughter1_id,...
                        data(cond).position(pos).tree(thiscell_mother).daughter2_id];
                    if isempty(thiscell_birth_size) || ~(thiscell_birth_size > 0)
                        disp(['Position ' num2str(pos) ' cell ' num2str(c) ' does not have a positive birth size.'])
                        data(cond).position(pos).analysis(c).has_valid_birth_size = false;
                    elseif(length(unique(nonzeros(thiscell_and_sister))) ~= 2)
                        disp(['Position ' num2str(pos) ' cell ' num2str(c) ' does not have a sister.'])
                    else
                        sister = thiscell_and_sister(c ~= thiscell_and_sister);
                        sister_birth_size = data(cond).position(pos).analysis(sister).birth_size;
                        data(cond).position(pos).analysis(c).sister_birth_size = sister_birth_size;
                        
                        if abs(thiscell_birth_size - mean([thiscell_birth_size, sister_birth_size]))/...
                                mean([thiscell_birth_size, sister_birth_size]) > analysis_parameters.max_fraction_diff_from_sibling_mean
                            
                            data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister = false;
                            disp(['Position ' num2str(pos) ' cell ' num2str(c) ' is too different from its sister.'])
                            disp(['Cell ' num2str(c) ' has birth size: ' num2str(thiscell_birth_size)])
                            disp(['Cell ' num2str(sister) ' has birth size: ' num2str(sister_birth_size)])
                        else
                            
                            % If sister checks out, add it to birth size list
                            data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister = true;
                            num_total_born_cells_similar_to_sister = num_total_born_cells_similar_to_sister + 1;
                            
                            data(cond).all_birth_sizes = [data(cond).all_birth_sizes,...
                                data(cond).position(pos).analysis(c).birth_size];
                            if data(cond).position(pos).analysis(c).generation == 1
                                data(cond).first_gen_birth_sizes = [data(cond).first_gen_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            elseif data(cond).position(pos).analysis(c).generation == 2
                                data(cond).second_gen_birth_sizes = [data(cond).second_gen_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            elseif data(cond).position(pos).analysis(c).generation >= 3
                                data(cond).third_gen_and_beyond_birth_sizes = [data(cond).third_gen_and_beyond_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            end
                            if data(cond).position(pos).analysis(c).is_born_early_in_movie
                                data(cond).early_birth_sizes = [data(cond).early_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            else
                                data(cond).late_birth_sizes = [data(cond).late_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            end
                            
                            % Quality checks: if it has a complete cell
                            % cycle and passes G1/S
                            % and is born smaller than a set maximum size, add
                            % it to the "good" list
                            if data(cond).position(pos).analysis(c).has_complete_cycle && data(cond).position(pos).analysis(c).passes_g1s &&...
                                    data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size
                                data(cond).all_good_birth_sizes = [data(cond).all_good_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                                data(cond).all_good_birth_areas = [data(cond).all_good_birth_areas,...
                                    data(cond).position(pos).analysis(c).birth_area];
                                
                                data(cond).all_good_g1s_sizes = [data(cond).all_good_g1s_sizes,...
                                    data(cond).position(pos).analysis(c).g1s_size];
                                if data(cond).position(pos).analysis(c).generation == 1
                                    data(cond).first_gen_good_g1s_sizes = [data(cond).first_gen_good_g1s_sizes,...
                                        data(cond).position(pos).analysis(c).g1s_size];
                                elseif data(cond).position(pos).analysis(c).generation == 2
                                    data(cond).second_gen_good_g1s_sizes = [data(cond).second_gen_good_g1s_sizes,...
                                        data(cond).position(pos).analysis(c).g1s_size];
                                elseif data(cond).position(pos).analysis(c).generation >= 3
                                    data(cond).third_gen_and_beyond_good_g1s_sizes = [data(cond).third_gen_and_beyond_good_g1s_sizes,...
                                        data(cond).position(pos).analysis(c).g1s_size];
                                end
                                
                                
                                data(cond).all_good_g2m_sizes = [data(cond).all_good_g2m_sizes,...
                                    data(cond).position(pos).analysis(c).g2m_size];
                                
                                data(cond).all_good_g1_growths = [data(cond).all_good_g1_growths,...
                                    data(cond).position(pos).analysis(c).g1_growth];
                                data(cond).all_good_sg2_growths = [data(cond).all_good_sg2_growths,...
                                    data(cond).position(pos).analysis(c).sg2_growth];
                                data(cond).all_good_complete_cycle_growths = [data(cond).all_good_complete_cycle_growths,...
                                    data(cond).position(pos).analysis(c).complete_cycle_growth];
                                
                                if data(cond).position(pos).analysis(c).generation == 1
                                    data(cond).first_gen_good_birth_sizes = [data(cond).first_gen_good_birth_sizes,...
                                        data(cond).position(pos).analysis(c).birth_size];
                                    data(cond).first_gen_good_birth_areas = [data(cond).first_gen_good_birth_areas,...
                                        data(cond).position(pos).analysis(c).birth_area];
                                elseif data(cond).position(pos).analysis(c).generation == 2
                                    data(cond).second_gen_good_birth_sizes = [data(cond).second_gen_good_birth_sizes,...
                                        data(cond).position(pos).analysis(c).birth_size];
                                    data(cond).second_gen_good_birth_areas = [data(cond).second_gen_good_birth_areas,...
                                        data(cond).position(pos).analysis(c).birth_area];
                                elseif data(cond).position(pos).analysis(c).generation >= 3
                                    data(cond).third_gen_and_beyond_good_birth_sizes = [data(cond).third_gen_and_beyond_good_birth_sizes,...
                                        data(cond).position(pos).analysis(c).birth_size];
                                    data(cond).third_gen_and_beyond_good_birth_areas = [data(cond).third_gen_and_beyond_good_birth_areas,...
                                        data(cond).position(pos).analysis(c).birth_area];
                                end
                                
                                
                                data(cond).all_instantaneous_g1_sizes_nolast = [data(cond).all_instantaneous_g1_sizes_nolast;...
                                    data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames)];
                                data(cond).all_instantaneous_g1_size_increases = [data(cond).all_instantaneous_g1_size_increases;...
                                    (data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) -...
                                    data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))];
                                
                                data(cond).all_instantaneous_sg2_sizes_nolast = [data(cond).all_instantaneous_sg2_sizes_nolast;...
                                    data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames)];
                                data(cond).all_instantaneous_sg2_size_increases = [data(cond).all_instantaneous_sg2_size_increases;...
                                    (data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) -...
                                    data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))];
                                
                                % In case of
                                % analysis_parameters.average_instantaneous_growth_rate_over_num_frames
                                % is equal to 1, can just use diff function
                                %                                 data(cond).all_instantaneous_g1_sizes_nolast = [data(cond).all_instantaneous_g1_sizes_nolast;...
                                %                                     data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1:end-1)];
%                                 data(cond).all_instantaneous_g1_size_increases = [data(cond).all_instantaneous_g1_size_increases;...
%                                     diff(data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1)];
%                                 data(cond).all_instantaneous_sg2_sizes_nolast = [data(cond).all_instantaneous_sg2_sizes_nolast;...
%                                     data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1:end-1)];
%                                 data(cond).all_instantaneous_sg2_size_increases = [data(cond).all_instantaneous_sg2_size_increases;...
%                                     diff(data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2)];
                                
                                
                            end
                        end
                    end
                end
            end
        end
    end
end

% Collate cell cycle phase lengths
if measure_lengths_of_phases
    for cond = 1:num_conditions
        
        data(cond).incomplete_g1_lengths_due_to_movie_end_hours = [];
        data(cond).incomplete_g1_lengths_due_to_untrackability_hours = [];
        
        data(cond).all_complete_cycle_lengths = [];
        data(cond).first_gen_complete_cycle_lengths = [];
        data(cond).second_gen_complete_cycle_lengths = [];
        data(cond).third_gen_and_beyond_complete_cycle_lengths = [];
        
        data(cond).all_g1_lengths = [];
        data(cond).first_gen_g1_lengths = [];
        data(cond).second_gen_g1_lengths = [];
        data(cond).third_gen_and_beyond_g1_lengths = [];
        
        data(cond).early_g1_lengths = [];
        data(cond).late_g1_lengths = [];
        
        data(cond).all_sg2_lengths = [];
        data(cond).first_gen_sg2_lengths = [];
        data(cond).second_gen_sg2_lengths = [];
        data(cond).third_gen_and_beyond_sg2_lengths = [];
        
        data(cond).all_good_complete_cycle_lengths = [];
        data(cond).first_gen_good_complete_cycle_lengths = [];
        data(cond).second_gen_good_complete_cycle_lengths = [];
        data(cond).third_gen_and_beyond_good_complete_cycle_lengths = [];
        
        data(cond).all_good_g1_lengths = [];
        data(cond).first_gen_good_g1_lengths = [];
        data(cond).second_gen_good_g1_lengths = [];
        data(cond).third_gen_and_beyond_good_g1_lengths = [];
        
        data(cond).all_good_sg2_lengths = [];
        data(cond).first_gen_good_sg2_lengths = [];
        data(cond).second_gen_good_sg2_lengths = [];
        data(cond).third_gen_and_beyond_good_sg2_lengths = [];
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                
                % Look at cells that are born but don't pass G1
                if ~isempty(data(cond).position(pos).analysis(c).is_born) && data(cond).position(pos).analysis(c).is_born &&...
                        (isempty(data(cond).position(pos).analysis(c).passes_g1s) || data(cond).position(pos).analysis(c).passes_g1s == false)
                    thiscell_lastframe = data(cond).position(pos).analysis(c).lastframe;
                    if thiscell_lastframe == analysis_parameters.movie_end_frame
                        data(cond).incomplete_g1_lengths_due_to_movie_end_hours = [data(cond).incomplete_g1_lengths_due_to_movie_end_hours;...
                            (thiscell_lastframe - data(cond).position(pos).analysis(c).firstframe) * analysis_parameters.framerate];
                    else
                        data(cond).incomplete_g1_lengths_due_to_untrackability_hours = [data(cond).incomplete_g1_lengths_due_to_untrackability_hours;...
                            (thiscell_lastframe - data(cond).position(pos).analysis(c).firstframe) * analysis_parameters.framerate];
                    end
                end
                
                if data(cond).position(pos).analysis(c).passes_g1s
                    if data(cond).position(pos).analysis(c).has_complete_cycle
                        
                        % Get all cycle phase lengths for all cells
                        data(cond).all_complete_cycle_lengths = [data(cond).all_complete_cycle_lengths,...
                            data(cond).position(pos).analysis(c).trace_duration_hours];
                        data(cond).all_g1_lengths = [data(cond).all_g1_lengths,...
                            data(cond).position(pos).analysis(c).g1_length_hours];
                        data(cond).all_sg2_lengths = [data(cond).all_sg2_lengths,...
                            data(cond).position(pos).analysis(c).sg2_length_hours];
                        
                        if data(cond).position(pos).analysis(c).generation == 1
                            data(cond).first_gen_complete_cycle_lengths = [data(cond).first_gen_complete_cycle_lengths,...
                                data(cond).position(pos).analysis(c).trace_duration_hours];
                            data(cond).first_gen_g1_lengths = [data(cond).first_gen_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                            data(cond).first_gen_sg2_lengths = [data(cond).first_gen_sg2_lengths,...
                                data(cond).position(pos).analysis(c).sg2_length_hours];
                        elseif data(cond).position(pos).analysis(c).generation == 2
                            data(cond).second_gen_complete_cycle_lengths = [data(cond).second_gen_complete_cycle_lengths,...
                                data(cond).position(pos).analysis(c).trace_duration_hours];
                            data(cond).second_gen_g1_lengths = [data(cond).second_gen_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                            data(cond).second_gen_sg2_lengths = [data(cond).second_gen_sg2_lengths,...
                                data(cond).position(pos).analysis(c).sg2_length_hours];
                        elseif data(cond).position(pos).analysis(c).generation >= 3
                            data(cond).third_gen_and_beyond_complete_cycle_lengths = [data(cond).third_gen_and_beyond_complete_cycle_lengths,...
                                data(cond).position(pos).analysis(c).trace_duration_hours];
                            data(cond).third_gen_and_beyond_g1_lengths = [data(cond).third_gen_and_beyond_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                            data(cond).third_gen_and_beyond_sg2_lengths = [data(cond).third_gen_and_beyond_sg2_lengths,...
                                data(cond).position(pos).analysis(c).sg2_length_hours];
                        end
                        if data(cond).position(pos).analysis(c).is_born_early_in_movie
                            data(cond).early_g1_lengths = [data(cond).early_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                        else
                            data(cond).late_g1_lengths = [data(cond).late_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                        end
                        
                        % Get cycle phase lengths only for cells that have passed
                        % quality tests.
                        if data(cond).position(pos).analysis(c).has_valid_birth_size &&...
                                data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size &&...
                                ~isempty(data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister) &&...
                                data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister
                            
                            data(cond).all_good_complete_cycle_lengths = [data(cond).all_good_complete_cycle_lengths,...
                                data(cond).position(pos).analysis(c).trace_duration_hours];
                            data(cond).all_good_g1_lengths = [data(cond).all_good_g1_lengths,...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                            data(cond).all_good_sg2_lengths = [data(cond).all_good_sg2_lengths,...
                                data(cond).position(pos).analysis(c).sg2_length_hours];
                            
                            if data(cond).position(pos).analysis(c).generation == 1
                                data(cond).first_gen_good_complete_cycle_lengths = [data(cond).first_gen_good_complete_cycle_lengths,...
                                    data(cond).position(pos).analysis(c).trace_duration_hours];
                                data(cond).first_gen_good_g1_lengths = [data(cond).first_gen_good_g1_lengths,...
                                    data(cond).position(pos).analysis(c).g1_length_hours];
                                data(cond).first_gen_good_sg2_lengths = [data(cond).first_gen_good_sg2_lengths,...
                                    data(cond).position(pos).analysis(c).sg2_length_hours];
                            elseif data(cond).position(pos).analysis(c).generation == 2
                                data(cond).second_gen_good_complete_cycle_lengths = [data(cond).second_gen_good_complete_cycle_lengths,...
                                    data(cond).position(pos).analysis(c).trace_duration_hours];
                                data(cond).second_gen_good_g1_lengths = [data(cond).second_gen_good_g1_lengths,...
                                    data(cond).position(pos).analysis(c).g1_length_hours];
                                data(cond).second_gen_good_sg2_lengths = [data(cond).second_gen_good_sg2_lengths,...
                                    data(cond).position(pos).analysis(c).sg2_length_hours];
                            elseif data(cond).position(pos).analysis(c).generation >= 3
                                data(cond).third_gen_and_beyond_good_complete_cycle_lengths = [data(cond).third_gen_and_beyond_good_complete_cycle_lengths,...
                                    data(cond).position(pos).analysis(c).trace_duration_hours];
                                data(cond).third_gen_and_beyond_good_g1_lengths = [data(cond).third_gen_and_beyond_good_g1_lengths,...
                                    data(cond).position(pos).analysis(c).g1_length_hours];
                                data(cond).third_gen_and_beyond_good_sg2_lengths = [data(cond).third_gen_and_beyond_good_sg2_lengths,...
                                    data(cond).position(pos).analysis(c).sg2_length_hours];
                            end
                        end
                    end
                end
            end
        end
    end
end

% For these measurements, gather only cells that pass G1/S. (Need not have
% complete cycle.)
if measure_g1s_probabilities
    for cond = 1:num_conditions
        
        data(cond).all_frame_indices_wrt_g1s_thisframe = [];
        data(cond).all_g1s_happens_here_thisframe = [];
        data(cond).all_areas_up_to_g1s_thisframe = [];
        data(cond).all_sizes_up_to_g1s_thisframe = [];
        data(cond).all_geminins_up_to_g1s_thisframe = [];
        data(cond).all_protein_amts_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_area_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_size_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_g1s_happens_here_for_born_cells_thisframe = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe = [];
        
        data(cond).all_frame_indices_wrt_g1s_nextframe = [];
        data(cond).all_g1s_happens_here_nextframe = [];
        data(cond).all_areas_up_to_g1s_nextframe = [];
        data(cond).all_sizes_up_to_g1s_nextframe = [];
        data(cond).all_geminins_up_to_g1s_nextframe = [];
        data(cond).all_protein_amts_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_area_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_size_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_g1s_happens_here_for_born_cells_nextframe = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe = [];
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if data(cond).position(pos).analysis(c).passes_g1s
                    data(cond).all_frame_indices_wrt_g1s_thisframe = [data(cond).all_frame_indices_wrt_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_thisframe];
                    data(cond).all_g1s_happens_here_thisframe = [data(cond).all_g1s_happens_here_thisframe;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_thisframe];
                    data(cond).all_areas_up_to_g1s_thisframe = [data(cond).all_areas_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_thisframe];
                    data(cond).all_sizes_up_to_g1s_thisframe = [data(cond).all_sizes_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_thisframe];
                    data(cond).all_geminins_up_to_g1s_thisframe = [data(cond).all_geminins_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_thisframe];
                    
                    data(cond).all_frame_indices_wrt_g1s_nextframe = [data(cond).all_frame_indices_wrt_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_nextframe];
                    data(cond).all_g1s_happens_here_nextframe = [data(cond).all_g1s_happens_here_nextframe;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_nextframe];
                    data(cond).all_areas_up_to_g1s_nextframe = [data(cond).all_areas_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_nextframe];
                    data(cond).all_sizes_up_to_g1s_nextframe = [data(cond).all_sizes_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_nextframe];
                    data(cond).all_geminins_up_to_g1s_nextframe = [data(cond).all_geminins_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_nextframe];
                    
                    
                    if measure_protein_concentrations
                        data(cond).all_protein_amts_up_to_g1s_thisframe = [data(cond).all_protein_amts_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_thisframe];
                        data(cond).all_protein_per_area_up_to_g1s_thisframe = [data(cond).all_protein_per_area_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_thisframe];
                        data(cond).all_protein_per_size_up_to_g1s_thisframe = [data(cond).all_protein_per_size_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_thisframe];
                        
                        data(cond).all_protein_amts_up_to_g1s_nextframe = [data(cond).all_protein_amts_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_nextframe];
                        data(cond).all_protein_per_area_up_to_g1s_nextframe = [data(cond).all_protein_per_area_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_nextframe];
                        data(cond).all_protein_per_size_up_to_g1s_nextframe = [data(cond).all_protein_per_size_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_nextframe];
                    end
                    
                    if data(cond).position(pos).analysis(c).is_born
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_thisframe];
                        data(cond).all_g1s_happens_here_for_born_cells_thisframe = [data(cond).all_g1s_happens_here_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_thisframe];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe =  [data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_thisframe];
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_nextframe];
                        data(cond).all_g1s_happens_here_for_born_cells_nextframe = [data(cond).all_g1s_happens_here_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_nextframe];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe =  [data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_nextframe];
                        
                        if measure_protein_concentrations
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_thisframe];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_nextframe];
                        end
                    end
                end
            end
        end
    end
end

save([expt_folder '\' tracking_strategy '_Data.mat'],'data');

%% Plot results

% load([expt_folder '\' tracking_strategy '_Data.mat'])

figure_folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots';
if strcmp(tracking_strategy,'clicking')
    figure_subfolder = [figure_folder '\' expt_name '\ManualTracking'];
elseif strcmp(tracking_strategy,'aivia')
    figure_subfolder = [figure_folder '\' expt_name '\Aivia'];
end
if ~exist(figure_subfolder,'dir')
    mkdir(figure_subfolder)
end

% Plot size vs area
if measure_area_vs_fluorescence
    for cond = 1:num_conditions
        figure()
        hold on
        scatter(data(cond).all_area_measurements, data(cond).all_size_measurements)
        scatter(data(cond).all_area_measurements_avoiding_ends, data(cond).all_size_measurements_avoiding_ends)
        title(data(cond).treatment)
        xlabel('Area measurements')
        ylabel('Size measurements')
        legend('All cells','Avoiding ends')
        hold off
        saveas(gcf, [figure_subfolder '\AllAreaMeasurements_' data(cond).treatment '.png'])
        
        plot_scatter_with_line(data(cond).all_area_measurements_avoiding_ends,...
            data(cond).all_size_measurements_avoiding_ends);
        title(data(cond).treatment)
        xlabel('Area measurements')
        ylabel('Size measurements')
        saveas(gcf, [figure_subfolder '\AllAreaMeasurements_WithLine_' data(cond).treatment '.png'])
    end
end

% Plot histograms and CDFs of birth sizes, cell cycle times, g1 lengths,
% g1s sizes, sg2 lengths
if measure_sizes_at_birth_and_other_times && measure_lengths_of_phases
    all_data_types_to_plot = {'Birth_sizes','Complete_cell_cycle_length','G1_length','G1S_size','SG2_length'};
    all_cell_classes_to_plot = {'all','first_gen','second_gen','early','late','incomplete_movie_ends','incomplete_untrackability'};
    all_plottypes = {'histogram','cdf'};
    
    % all_data_types_to_plot = {'G1 lengths'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                figure()
                hold on
                leg = cell(num_conditions,1);
                leg_loc = 'northeast';
                for cond = 1:num_conditions
                    
                    leg{cond} = data(cond).treatment;
                    
                    if strcmp(data_type_to_plot,'Birth_sizes')
                        x_axis_label = 'Birth size';
                        
                        if strcmp(cell_class_to_plot,'all')
                            data_to_plot(cond).to_plot = data(cond).all_birth_sizes;
                            graph_title = 'All cells';
                        elseif strcmp(cell_class_to_plot,'first_gen')
                            data_to_plot(cond).to_plot = data(cond).first_gen_birth_sizes;
                            graph_title = 'First generation cells';
                        elseif strcmp(cell_class_to_plot,'second_gen')
                            data_to_plot(cond).to_plot = data(cond).second_gen_birth_sizes;
                            graph_title = 'Second generation cells';
                        elseif strcmp(cell_class_to_plot,'early')
                            data_to_plot(cond).to_plot = data(cond).early_birth_sizes;
                            graph_title = ['Cells born before frame ' num2str(analysis_parameters.birth_frame_threshold)];
                        elseif strcmp(cell_class_to_plot,'late')
                            data_to_plot(cond).to_plot = data(cond).late_birth_sizes;
                            graph_title = ['Cells born after frame ' num2str(analysis_parameters.birth_frame_threshold)];
                        end
                        
                    elseif strcmp(data_type_to_plot,'Complete_cell_cycle_length')
                        x_axis_label = 'Complete cell cycle length (h)';
                        if strcmp(cell_class_to_plot,'all')
                            data_to_plot(cond).to_plot = data(cond).all_complete_cycle_lengths;
                            graph_title = 'All cells';
                        elseif strcmp(cell_class_to_plot,'first_gen')
                            data_to_plot(cond).to_plot = data(cond).first_gen_complete_cycle_lengths;
                            graph_title = 'First generation cells';
                        elseif strcmp(cell_class_to_plot,'second_gen')
                            data_to_plot(cond).to_plot = data(cond).second_gen_complete_cycle_lengths;
                            graph_title = 'Second generation cells';
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1_length')
                        x_axis_label = 'G1 length (h)';
                        if strcmp(cell_class_to_plot,'all')
                            data_to_plot(cond).to_plot = data(cond).all_g1_lengths;
                            graph_title = 'All cells';
                        elseif strcmp(cell_class_to_plot,'first_gen')
                            data_to_plot(cond).to_plot = data(cond).first_gen_g1_lengths;
                            graph_title = 'First generation cells';
                        elseif strcmp(cell_class_to_plot,'second_gen')
                            data_to_plot(cond).to_plot = data(cond).second_gen_g1_lengths;
                            graph_title = 'Second generation cells';
                        elseif strcmp(cell_class_to_plot,'early')
                            data_to_plot(cond).to_plot = data(cond).early_g1_lengths;
                            graph_title = ['Cells born before frame ' num2str(analysis_parameters.birth_frame_threshold)];
                        elseif strcmp(cell_class_to_plot,'late')
                            data_to_plot(cond).to_plot = data(cond).late_g1_lengths;
                            graph_title = ['Cells born after frame ' num2str(analysis_parameters.birth_frame_threshold)];
                        elseif strcmp(cell_class_to_plot,'incomplete_movie_ends')
                            data_to_plot(cond).to_plot = data(cond).incomplete_g1_lengths_due_to_movie_end_hours;
                            graph_title = ['Cells with incomplete G1 due to movie end'];
                        elseif strcmp(cell_class_to_plot,'incomplete_untrackability')
                            data_to_plot(cond).to_plot = data(cond).incomplete_g1_lengths_due_to_untrackability_hours;
                            graph_title = ['Cells with incomplete G1 due to untrackability'];
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size')
                        x_axis_label = 'G1/S size';
                        if strcmp(cell_class_to_plot,'all')
                            data_to_plot(cond).to_plot = data(cond).all_good_g1s_sizes;
                            graph_title = 'All cells';
                        elseif strcmp(cell_class_to_plot,'first_gen')
                            data_to_plot(cond).to_plot = data(cond).first_gen_good_g1s_sizes;
                            graph_title = 'First generation cells';
                        elseif strcmp(cell_class_to_plot,'second_gen')
                            data_to_plot(cond).to_plot = data(cond).second_gen_good_g1s_sizes;
                            graph_title = 'Second generation cells';
                        end
                        
                    elseif strcmp(data_type_to_plot,'SG2_length')
                        x_axis_label = 'S/G2/M length (h)';
                        if strcmp(cell_class_to_plot,'all')
                            data_to_plot(cond).to_plot = data(cond).all_sg2_lengths;
                            graph_title = 'All cells';
                        elseif strcmp(cell_class_to_plot,'first_gen')
                            data_to_plot(cond).to_plot = data(cond).first_gen_sg2_lengths;
                            graph_title = 'First generation cells';
                        elseif strcmp(cell_class_to_plot,'second_gen')
                            data_to_plot(cond).to_plot = data(cond).second_gen_sg2_lengths;
                            graph_title = 'Second generation cells';
                        end
                    end
                    
                    if strcmp(plottype,'histogram')
                        histogram(data_to_plot(cond).to_plot)
                        y_axis_label = 'Count';
                        
                    elseif strcmp(plottype,'cdf')
                        cdfplot(data_to_plot(cond).to_plot)
                        y_axis_label = 'Cumulative probability';
                        leg_loc = 'southeast';
                    end
                end
                
                title(graph_title)
                xlabel(x_axis_label)
                ylabel(y_axis_label)
                legend(leg,'Location',leg_loc)
                hold off
                saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' cell_class_to_plot{1} '_' plottype{1} '.png']);
            end
        end
    end
end



% Plot scatterplots
% For these scatterplots to work, it is crucial that the same quality
% control tests be applied to both axes (i.e., birth sizes and G1 lengths).
% Currently that means has_complete_cycle and
% birth_size_is_similar_to_sister.
if measure_sizes_at_birth_and_other_times && measure_lengths_of_phases
    all_data_types_to_plot = {'Birth_size_vs_G1_length','Birth_size_vs_SG2_length','Birth_size_vs_Complete_cycle_length',...
        'Birth_area_vs_G1_length','G1S_size_vs_SG2_length','Birth_size_vs_G1_growth','G1S_size_vs_SG2_growth','Instantaneous_sizes_vs_growths'};
    all_cell_classes_to_plot = {'all_good','first_gen_good','second_gen_good','G1_cells_good','SG2_cells_good'};
    all_plottypes = {'scatter_with_line'};
    
    % all_data_types_to_plot = {'Birth_size_vs_G1_growth'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                for cond = 1:num_conditions
                    
                    is_there_something_to_plot = false;
                    
                    if strcmp(data_type_to_plot,'Instantaneous_sizes_vs_growths')
                        x_axis_label = 'Size (AU)';
                        y_axis_label = ['Instantaneous growth rate (AU/' num2str(60*analysis_parameters.framerate * analysis_parameters.average_instantaneous_growth_rate_over_num_frames) 'min)'];
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast;
                            data_to_scatter(cond).y = data(cond).all_instantaneous_size_increase_measurements_avoiding_ends;
                            graph_title = [data(cond).treatment ', all pairwise measurements'];
                            is_there_something_to_plot = true;
                        elseif(strcmp(cell_class_to_plot,'G1_cells_good'))
                            data_to_scatter(cond).x = data(cond).all_instantaneous_g1_sizes_nolast;
                            data_to_scatter(cond).y = data(cond).all_instantaneous_g1_size_increases;
                            graph_title = [data(cond).treatment ', G1 pairwise measurements'];
                            is_there_something_to_plot = true;
                            
                        elseif(strcmp(cell_class_to_plot,'SG2_cells_good'))
                            data_to_scatter(cond).x = data(cond).all_instantaneous_sg2_sizes_nolast;
                            data_to_scatter(cond).y = data(cond).all_instantaneous_sg2_size_increases;
                            graph_title = [data(cond).treatment ', SG2 pairwise measurements'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_G1_length')
                        x_axis_label = 'Birth size';
                        y_axis_label = 'G1 length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_g1_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'first_gen_good')
                            data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).first_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'second_gen_good')
                            data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).second_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_SG2_length')
                        x_axis_label = 'Birth size';
                        y_axis_label = 'S/G2/M length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_sg2_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'first_gen_good')
                            data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).first_gen_good_sg2_lengths;
                            graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'second_gen_good')
                            data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).second_gen_good_sg2_lengths;
                            graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_Complete_cycle_length')
                        x_axis_label = 'Birth size';
                        y_axis_label = 'Complete cycle length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_complete_cycle_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'first_gen_good')
                            data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).first_gen_good_complete_cycle_lengths;
                            graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'second_gen_good')
                            data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).second_gen_good_complete_cycle_lengths;
                            graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_area_vs_G1_length')
                        x_axis_label = 'Birth area (px�)';
                        y_axis_label = 'G1 length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_areas;
                            data_to_scatter(cond).y = data(cond).all_good_g1_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'first_gen_good')
                            data_to_scatter(cond).x = data(cond).first_gen_good_birth_areas;
                            data_to_scatter(cond).y = data(cond).first_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'second_gen_good')
                            data_to_scatter(cond).x = data(cond).second_gen_good_birth_areas;
                            data_to_scatter(cond).y = data(cond).second_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_length')
                        x_axis_label = 'G1S size';
                        y_axis_label = 'SG2 length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_g1s_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_sg2_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_G1_growth')
                        x_axis_label = 'Birth size';
                        y_axis_label = 'G1 growth';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_g1_growths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_growth')
                        x_axis_label = 'G1S size';
                        y_axis_label = 'SG2 growth';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_g1s_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_sg2_growths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                    end
                    
                    if isempty(data_to_scatter(cond).x) || isempty(data_to_scatter(cond).y)
                        is_there_something_to_plot = false;
                    end
                    
                    if is_there_something_to_plot
                        if strcmp(plottype,'scatter_with_line')
                            plot_scatter_with_line(data_to_scatter(cond).x, data_to_scatter(cond).y);
                        end
                        
                        title(gca,graph_title)
                        xlabel(gca,x_axis_label)
                        ylabel(gca,y_axis_label)
                        
                        saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' data(cond).treatment '_'...
                            cell_class_to_plot{1} '_' plottype{1} '.png']);
                    end
                end
            end
        end
    end
end

if measure_g1s_probabilities
    disp(['Condition 1: number of cells that pass G1/S = ' num2str(sum(data(1).all_g1s_happens_here_thisframe))])
    disp(['Condition 2: number of cells that pass G1/S = ' num2str(sum(data(2).all_g1s_happens_here_thisframe))])
    all_data_types_to_plot = {...
        %         'Relative_frame_vs_G1S_probability',...
        'Age_vs_G1S_probability','Area_vs_G1S_probability',...
        'Size_vs_G1S_probability','Geminin_vs_G1S_probability'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'Rb_amt_vs_G1S_probability',...
            'Rb_per_area_vs_G1S_probability','Rb_per_size_vs_G1S_probability'};
    end
    all_cell_classes_to_plot = {'pass_thisframe','pass_nextframe'};
    all_plottypes = {'binning_with_logit'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                for cond = 1:num_conditions
                    
                    is_there_something_to_plot = false;
                    
                    if strcmp(data_type_to_plot,'Relative_frame_vs_G1S_probability')
                        x_axis_label = 'Relative frame';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_frame_indices_wrt_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_frame_indices_wrt_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Age_vs_G1S_probability')
                        x_axis_label = 'Cell age (h)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Area_vs_G1S_probability')
                        x_axis_label = 'Nuclear area (px2)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_areas_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_areas_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Size_vs_G1S_probability')
                        x_axis_label = 'Size (AU)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_sizes_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_sizes_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Geminin_vs_G1S_probability')
                        x_axis_label = 'Geminin (AU)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_geminins_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_geminins_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Rb_amt_vs_G1S_probability')
                        x_axis_label = 'Rb amount (AU)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_protein_amts_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_protein_amts_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Rb_per_area_vs_G1S_probability')
                        x_axis_label = 'Rb per nuclear area (AU/px2)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_area_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_area_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Rb_per_size_vs_G1S_probability')
                        x_axis_label = 'Rb per size (AU/AU)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_size_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_size_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                    end
                    
                    if isempty(data_to_scatter(cond).x) || isempty(data_to_scatter(cond).y)
                        is_there_something_to_plot = false;
                    end
                    
                    if is_there_something_to_plot
                        switch plottype{1}
                            case 'logit'
                                % scatter(data_to_scatter(cond).x, data_to_scatter(cond).y);
                                plot_scatter_with_logit(data_to_scatter(cond).x,data_to_scatter(cond).y);
                                
                            case 'binning'
                                bin_discrete_outcomes(data_to_scatter(cond).x,data_to_scatter(cond).y);
                                
                            case 'binning_with_logit'
                                bin_discrete_outcomes_with_logit(data_to_scatter(cond).x,data_to_scatter(cond).y);
                                
                        end
                        
                        title(gca,graph_title)
                        xlabel(gca,x_axis_label)
                        ylabel(gca,y_axis_label)
                        
                        saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' data(cond).treatment '_'...
                            cell_class_to_plot{1} '_' plottype{1} '.png'])
                    end
                end
            end
        end
    end
    
    all_data_types_to_plot = {'Size_and_Age_vs_G1S_probability'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'Age_and_[Rb]_vs_G1S_probability'};
    end
    all_cell_classes_to_plot = {'pass_thisframe','pass_nextframe'};
    all_plottypes = {'two_var_logit'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                for cond = 1:num_conditions
                    
                    is_there_something_to_plot = false;
                    
                    if strcmp(data_type_to_plot,'Size_and_Age_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Size (AU)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Age_and_[Rb]_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Rb concentration (AU/AU)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        end
                        
                        
                    end
                    
                    if isempty(data_to_scatter(cond).x) || isempty(data_to_scatter(cond).y) || isempty(data_to_scatter(cond).z)
                        is_there_something_to_plot = false;
                    end
                    
                    if is_there_something_to_plot
                        switch plottype{1}
                            case 'two_var_logit'
                                
                                two_variable_logistic_regression(data_to_scatter(cond).x, data_to_scatter(cond).y, data_to_scatter(cond).z);
                                
                                title(gca,graph_title)
                                xlabel(x_axis_label)
                                ylabel(y_axis_label)
                                zlabel(z_axis_label)
                                colorbar()
                                saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' data(cond).treatment '_'...
                                    cell_class_to_plot{1} '_' plottype{1} '.png'])
                                saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' data(cond).treatment '_'...
                                    cell_class_to_plot{1} '_' plottype{1} '.fig'])
                                
                        end
                    end
                end
            end
        end
    end
end


% save([expt_folder '\data.mat'],'data')

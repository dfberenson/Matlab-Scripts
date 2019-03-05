clear all
close all

%% Set parameters

tracking_strategy = 'clicking';
calculate_half_of_mother_premitotic_size = true;
% 
% tracking_strategy = 'aivia';
% calculate_half_of_mother_premitotic_size = false;


% MUST CHANGE BACKGROUND SUBTRACTION FORMULA DEPENDING ON WHAT KIND OF
% MOVIE

% source_folder = 'E:\Manually tracked measurements';
% expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
% table_expt_folder = [source_folder '\' expt_name];

table_source_folder = 'E:\Manually tracked measurements';
% table_source_folder = 'E:\Aivia';
image_source_folder = 'F:\Manually tracked imaging experiments';
expt_name = 'DFB_180803_HMEC_D5_1';
% expt_name = 'DFB_180829_HMEC_D5_1';
% expt_name = 'DFB_181108_HMEC_D5_palbo_1';
table_expt_folder = [table_source_folder '\' expt_name];
image_expt_folder = [image_source_folder '\' expt_name];


% source_folder = 'E:\Manually tracked measurements';
% expt_name = 'DFB_180822_HMEC_1GFiii_1';
% table_expt_folder = [source_folder '\' expt_name];

% Choose types of measurements
measure_area_vs_fluorescence = true;
measure_sizes_at_birth_and_other_times = true;
measure_lengths_of_phases = true;
measure_g1s_probabilities = true;

% Set analysis parameters
analysis_parameters = struct;

switch expt_name
    case 'DFB_180627_HMEC_1GFiii_palbo_2'
        measure_protein_concentrations = false;
        num_conditions = 2;
        analysis_parameters.order_of_channels = 'prg';
        analysis_parameters.size_channel = 'r';
        analysis_parameters.geminin_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 421;
        analysis_parameters.segmentation_parameters.threshold = 200;
        analysis_parameters.segmentation_parameters.strel_size = 1;
        analysis_parameters.geminin_threshold = 20000;
        analysis_parameters.second_line_min_slope = 50000/20;
        
    case 'DFB_180803_HMEC_D5_1'
        measure_protein_concentrations = true;
        num_conditions = 2;
        analysis_parameters.order_of_channels = 'pgrf';
        analysis_parameters.size_channel = 'f';
        analysis_parameters.geminin_channel = 'r';
        analysis_parameters.protein_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 432;
        analysis_parameters.segmentation_parameters.threshold = 272;
        analysis_parameters.segmentation_parameters.strel_size = 3;
        analysis_parameters.geminin_threshold = 0.17;
        analysis_parameters.second_line_min_slope = 0.05/20;
        
    case 'DFB_180822_HMEC_1GFiii_1'
        measure_protein_concentrations = false;
        num_conditions = 2;
        analysis_parameters.order_of_channels = 'prg';
        analysis_parameters.size_channel = 'r';
        analysis_parameters.geminin_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 432;
        analysis_parameters.segmentation_parameters.threshold = 200;
        analysis_parameters.segmentation_parameters.strel_size = 1;
        analysis_parameters.geminin_threshold = 20000;
        analysis_parameters.second_line_min_slope = 50000/20;
        
    case 'DFB_180829_HMEC_D5_1'
        measure_protein_concentrations = true;
        num_conditions = 3;
        analysis_parameters.order_of_channels = 'pgrf';
        analysis_parameters.size_channel = 'f';
        analysis_parameters.geminin_channel = 'r';
        analysis_parameters.protein_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 432;
        analysis_parameters.segmentation_parameters.threshold = 272;
        analysis_parameters.segmentation_parameters.strel_size = 3;
        analysis_parameters.geminin_threshold = 0.17;
        analysis_parameters.second_line_min_slope = 0.05/20;
        
    case 'DFB_181108_HMEC_D5_palbo_1'
        measure_protein_concentrations = true;
        num_conditions = 2;
        analysis_parameters.order_of_channels = 'pgrf';
        analysis_parameters.size_channel = 'f';
        analysis_parameters.geminin_channel = 'r';
        analysis_parameters.protein_channel = 'g';
        analysis_parameters.movie_start_frame = 1;
        analysis_parameters.movie_end_frame = 432;
        analysis_parameters.segmentation_parameters.threshold = 272;
        analysis_parameters.segmentation_parameters.strel_size = 3;
        analysis_parameters.geminin_threshold = 0.17;
        analysis_parameters.second_line_min_slope = 0.05/20;
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
analysis_parameters.compare_birth_size_to_sister = false;

analysis_parameters.g1s_quality_control = true;
analysis_parameters.g1_frames_reqd_before_g1s = 4 / analysis_parameters.framerate;
analysis_parameters.sg2_frames_reqd_after_g1s = 2 / analysis_parameters.framerate;
analysis_parameters.max_g1s_noise_frames = 10;
analysis_parameters.frames_before_g1s_to_examine = Inf / analysis_parameters.framerate;
analysis_parameters.birthsize_measuring_frames = [12:18];
analysis_parameters.min_cycle_duration_hours = 5;
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
                        data(cond).positions_list = [1 3 4 5];
                    case 'aivia'
                        data(cond).positions_list = [1 2 3 4 5 6 7 8 9];
                end
                
            case 'DFB_180822_HMEC_1GFiii_1'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [1];
                    case 'aivia'
                        data(cond).positions_list = [];
                end
                
            case 'DFB_180829_HMEC_D5_1'
                switch tracking_strategy
                    case 'aivia'
                        data(cond).positions_list = [2 3 7 8 9 10 11 12];
                end
                
            case 'DFB_181108_HMEC_D5_palbo_1'
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [];
                    case 'aivia'
                        data(cond).positions_list = [1 3 4 6 8 10];
                end
        end
        
        
        
    elseif cond == 2
        switch expt_name
            case 'DFB_180627_HMEC_1GFiii_palbo_2'
                data(cond).treatment = '40 nM palbociclib';
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [13 14 15];
                    case 'aivia'
                        data(cond).positions_list = [13 14];
                end
                
            case 'DFB_180803_HMEC_D5_1'
                data(cond).treatment = '40 nM palbociclib';
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [13 14 15 16];
                    case 'aivia'
                        data(cond).positions_list = [13 14 15 16 17 18 19 20 21];
                end
                
            case 'DFB_180822_HMEC_1GFiii_1'
                data(cond).treatment = '100 nM palbociclib';
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [25];
                    case 'aivia'
                        data(cond).positions_list = [];
                end
                
            case 'DFB_180829_HMEC_D5_1'
                data(cond).treatment = '50 nM palbociclib';
                switch tracking_strategy
                    case 'aivia'
                        data(cond).positions_list = [13:23];
                end
                
            case 'DFB_181108_HMEC_D5_palbo_1'
                data(cond).treatment = '100 nM palbociclib';
                switch tracking_strategy
                    case 'clicking'
                        data(cond).positions_list = [];
                    case 'aivia'
                        data(cond).positions_list = [25 26 29 30 31 34 36];
                end
        end
        
    elseif cond == 3
        switch expt_name
            case 'DFB_180829_HMEC_D5_1'
                data(cond).treatment = '100 nM palbociclib';
                switch tracking_strategy
                    case 'aivia'
                        data(cond).positions_list = [25:35];
                end
        end
    end
end

%% Analyze data

% Gather and analyze data for each position. Strategy depends on how the
% traces were generated.
if strcmp(tracking_strategy,'clicking')
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            position_folder = [table_expt_folder '\Pos' num2str(pos)];
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
            
            while length(data(cond).position(pos).tracking_measurements.all_area_traces) <....
                    max(data(cond).position(pos).tracking_measurements.all_tracknums)
                data(cond).position(pos).tracking_measurements.all_tracknums = data(cond).position(pos).tracking_measurements.all_tracknums(1:end-1)
            end
            
            disp(['Analyzing tracking data for position ' num2str(pos) '.'])
            data(cond).position(pos).analysis =...
                analyze_tracking_data_clicking(data(cond).position(pos).tracking_measurements,...
                data(cond).position(pos).tree, analysis_parameters);
            
            % Go back into data to calculate birth size as half of mother's
            % premitotic size
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if data(cond).position(pos).analysis(c).is_born
                    mother = data(cond).position(pos).tree(c).mother_id;
                    if data(cond).position(pos).analysis(mother).has_mitosis
                        if length(data(cond).position(pos).analysis(mother).size_measurements_smooth) > 15
                            data(cond).position(pos).analysis(c).has_calculated_half_of_mother_premitotic_size = true;
                            data(cond).position(pos).analysis(c).half_of_mother_premitotic_size =...
                                data(cond).position(pos).analysis(mother).size_measurements_smooth(end-15) / 2;
                        end
                        if length(data(cond).position(pos).analysis(mother).area_measurements_smooth) > 15
                            data(cond).position(pos).analysis(c).has_calculated_half_of_mother_premitotic_area = true;
                            data(cond).position(pos).analysis(c).half_of_mother_premitotic_area =...
                                data(cond).position(pos).analysis(mother).area_measurements_smooth(end-15) / 2;
                        end
                    end
                end
            end
            
        end
    end
    
elseif strcmp(tracking_strategy,'aivia')
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            disp(['Analyzing tracking data for position ' num2str(pos) '.'])
            [data(cond).position(pos).analysis, data(cond).position(pos).tree] =...
                analyze_tracking_data_aivia(table_expt_folder, image_expt_folder, expt_name, pos, analysis_parameters);
            data(cond).position(pos).tracking_measurements.all_tracknums =...
                1:length(data(cond).position(pos).analysis);
        end
    end
end

% %% Fictional data to test analysis
%
% clear data
% data = struct;
% data(1).position(1).analysis = d(1).position(1).analysis;
% num_conditions = 1;
% data(1).positions_list = 1;
% data(1).position(1).tracking_measurements.all_tracknums = d(1).position(1).tracking_measurements.all_tracknums;
% data(1).position(1).tree = d(1).position(1).tree;
% data(1).treatment = 'test';

%% Collate measurements

% Collate all area and size measurements for all cells across all
% timepoints into one giant list
if measure_area_vs_fluorescence
    data(cond).all_area_measurements = [];
    data(cond).all_size_measurements = [];
    data(cond).all_area_measurements_avoiding_ends = [];
    data(cond).all_size_measurements_avoiding_ends = [];
    data(cond).whichcell_avoiding_ends = [];
    whichcell_avoiding_ends = 0;
    
    % Lop off last value so V and dV have equal numbers of data points
    data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast = [];
    data(cond).all_instantaneous_size_increase_measurements_avoiding_ends = [];
    
    for cond = 1:num_conditions
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                
                whichcell_avoiding_ends = whichcell_avoiding_ends + 1;
                
                if max(data(cond).position(pos).analysis(c).area_measurements) > 25000
                    disp(['Cond ' num2str(cond) ' pos ' num2str(pos) ' cell ' num2str(c)])
                end
                
                data(cond).all_area_measurements = [data(cond).all_area_measurements;...
                    data(cond).position(pos).analysis(c).area_measurements];
                data(cond).all_size_measurements = [data(cond).all_size_measurements;...
                    data(cond).position(pos).analysis(c).size_measurements];
                data(cond).all_area_measurements_avoiding_ends = [data(cond).all_area_measurements_avoiding_ends;...
                    data(cond).position(pos).analysis(c).area_measurements_avoiding_ends];
                data(cond).all_size_measurements_avoiding_ends = [data(cond).all_size_measurements_avoiding_ends;...
                    data(cond).position(pos).analysis(c).size_measurements_avoiding_ends];
                data(cond).whichcell_avoiding_ends = [data(cond).whichcell_avoiding_ends;...
                    whichcell_avoiding_ends * ones(length(data(cond).position(pos).analysis(c).area_measurements_avoiding_ends),1)];
                
                data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast = [data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast;...
                    (data(cond).position(pos).analysis(c).size_measurements_avoiding_ends(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) +...
                    data(cond).position(pos).analysis(c).size_measurements_avoiding_ends(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))/2];
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
        
        data(cond).all_good_g1s_areas = [];
        data(cond).all_good_g1s_sizes = [];
        data(cond).first_gen_good_g1s_sizes = [];
        data(cond).second_gen_good_g1s_sizes = [];
        data(cond).third_gen_and_beyond_good_g1s_sizes = [];
        
        data(cond).all_good_g2m_areas = [];
        data(cond).all_good_g2m_sizes = [];
        
        data(cond).all_good_g2m_areas_with_measured_mother_premitotic_area = [];
        data(cond).all_good_g2m_sizes_with_measured_mother_premitotic_size = [];
        data(cond).all_good_half_of_mother_premitotic_area_with_daughter_g2m_area = [];
        data(cond).all_good_half_of_mother_premitotic_size_with_daughter_g2m_size = [];

                
        data(cond).all_good_g1_growths = [];
        data(cond).all_good_sg2_growths = [];
        data(cond).all_good_complete_cycle_growths = [];
        
        data(cond).all_instantaneous_g1_sizes_nolast = [];
        data(cond).all_instantaneous_g1_size_increases = [];
        data(cond).all_instantaneous_sg2_sizes_nolast = [];
        data(cond).all_instantaneous_sg2_size_increases = [];
        
        data(cond).good_size_traces = {};
        data(cond).good_smooth_size_traces = {};
        data(cond).good_area_traces = {};
        data(cond).good_smooth_area_traces = {};
        data(cond).good_geminin_traces = {};
        data(cond).good_smooth_geminin_traces = {};
        data(cond).unique_cell_id = 1;
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if ~isempty(data(cond).position(pos).analysis(c).is_born) && data(cond).position(pos).analysis(c).is_born
                    
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
                            data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister = true;
                            num_total_born_cells_similar_to_sister = num_total_born_cells_similar_to_sister + 1;
                        end
                    end
                    
                    if ~analysis_parameters.compare_birth_size_to_sister ||...
                            (~isempty(data(cond).position(pos).birth_size_is_similar_to_sister &&...
                            data(cond).position(pos).birth_size_is_similar_to_sister))
                        
                        % If sister checks out, add it to birth size list
                        
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
                        if ~isempty(data(cond).position(pos).analysis(c).has_complete_cycle) &&...
                                data(cond).position(pos).analysis(c).has_complete_cycle &&...
                                data(cond).position(pos).analysis(c).passes_g1s &&...
                                data(cond).position(pos).analysis(c).has_valid_birth_size &&...
                                data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size
                            
                            data(cond).all_good_birth_sizes = [data(cond).all_good_birth_sizes,...
                                data(cond).position(pos).analysis(c).birth_size];
                            data(cond).all_good_birth_areas = [data(cond).all_good_birth_areas,...
                                data(cond).position(pos).analysis(c).birth_area];
                            
                            data(cond).all_good_g1s_areas = [data(cond).all_good_g1s_areas,...
                                data(cond).position(pos).analysis(c).g1s_area];
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
                            
                            
                            data(cond).all_good_g2m_areas = [data(cond).all_good_g2m_areas,...
                                data(cond).position(pos).analysis(c).g2m_area];
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
                            
                            if calculate_half_of_mother_premitotic_size
                                if data(cond).position(pos).analysis(c).has_calculated_half_of_mother_premitotic_size
                                    data(cond).all_good_g2m_areas_with_measured_mother_premitotic_area = [data(cond).all_good_g2m_areas_with_measured_mother_premitotic_area;...
                                        data(cond).position(pos).analysis(c).g2m_area];
                                    data(cond).all_good_g2m_sizes_with_measured_mother_premitotic_size = [data(cond).all_good_g2m_sizes_with_measured_mother_premitotic_size;...
                                        data(cond).position(pos).analysis(c).g2m_size];
                                    data(cond).all_good_half_of_mother_premitotic_area_with_daughter_g2m_area = [data(cond).all_good_half_of_mother_premitotic_area_with_daughter_g2m_area;...
                                        data(cond).position(pos).analysis(c).half_of_mother_premitotic_area];
                                    data(cond).all_good_half_of_mother_premitotic_size_with_daughter_g2m_size = [data(cond).all_good_half_of_mother_premitotic_size_with_daughter_g2m_size;...
                                        data(cond).position(pos).analysis(c).half_of_mother_premitotic_size];
                                end
                            end
                            
                            data(cond).all_instantaneous_g1_sizes_nolast = [data(cond).all_instantaneous_g1_sizes_nolast;...
                                (data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) +...
                                data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))/2];
                            data(cond).all_instantaneous_g1_size_increases = [data(cond).all_instantaneous_g1_size_increases;...
                                (data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) -...
                                data(cond).position(pos).analysis(c).instantaneous_sizes_during_g1(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))];
                            
                            data(cond).all_instantaneous_sg2_sizes_nolast = [data(cond).all_instantaneous_sg2_sizes_nolast;...
                                (data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) +...
                                data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))/2];
                            data(cond).all_instantaneous_sg2_size_increases = [data(cond).all_instantaneous_sg2_size_increases;...
                                (data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 + analysis_parameters.average_instantaneous_growth_rate_over_num_frames : end) -...
                                data(cond).position(pos).analysis(c).instantaneous_sizes_during_sg2(1 : end - analysis_parameters.average_instantaneous_growth_rate_over_num_frames))];
                            
                            data(cond).good_size_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).size_measurements;
                            data(cond).good_smooth_size_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).size_measurements_smooth;
                            data(cond).good_area_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).area_measurements;
                            data(cond).good_smooth_area_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).area_measurements_smooth;
                            data(cond).good_geminin_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).geminin_measurements;
                            data(cond).good_smooth_geminin_traces{data(cond).unique_cell_id} = data(cond).position(pos).analysis(c).geminin_measurements_smooth;
                            
                            data(cond).unique_cell_id =  data(cond).unique_cell_id + 1;
                            
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
                                (~analysis_parameters.compare_birth_size_to_sister ||...
                                (~isempty(data(cond).position(pos).birth_size_is_similar_to_sister &&...
                                data(cond).position(pos).birth_size_is_similar_to_sister)))
                            
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

% Also measure sizes at G1/S and G2/M
if measure_sizes_at_birth_and_other_times
    for cond = 1:num_conditions
        
        data(cond).g1s_sizes_for_cells_that_divide = [];
        data(cond).g1s_areas_for_cells_that_divide = [];
        data(cond).sg2_lengths_for_cells_that_divide = [];
        data(cond).g2m_sizes_for_cells_that_divide = [];
        data(cond).g2m_areas_for_cells_that_divide = [];        
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if ~isempty(data(cond).position(pos).analysis(c).passes_g1s) &&...
                        data(cond).position(pos).analysis(c).passes_g1s &&...
                        data(cond).position(pos).analysis(c).has_mitosis
                    %                         data(cond).position(pos).analysis(c).has_complete_cycle &&...
                    %                         data(cond).position(pos).analysis(c).has_valid_birth_size &&...
                    %                         data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size &&...
                    %                         ~isempty(data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister) &&...
                    %                         data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister
                    %
                    %                     figure,plot(data(cond).position(pos).analysis(c).protein_measurements)
                    %                     title(['Condition ' num2str(cond) ' position ' num2str(pos) ' cell ' num2str(c)])
                    
                   
                    data(cond).g1s_sizes_for_cells_that_divide = [data(cond).g1s_sizes_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).g1s_size];
                    data(cond).g1s_areas_for_cells_that_divide = [data(cond).g1s_areas_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).g1s_area];
                    data(cond).sg2_lengths_for_cells_that_divide = [data(cond).sg2_lengths_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).sg2_length_hours];
                    data(cond).g2m_sizes_for_cells_that_divide = [data(cond).g2m_sizes_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).g2m_size];
                    data(cond).g2m_areas_for_cells_that_divide = [data(cond).g2m_areas_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).g2m_area];
                end
            end
        end
    end
end

% Also measure protein accumulation during SG2
if measure_protein_concentrations
    for cond = 1:num_conditions
        data(cond).g1s_protein_amts_for_cells_that_divide = [];
        data(cond).sg2_protein_increases_for_cells_that_divide = [];
        data(cond).sg2_protein_accumulation_rates_for_cells_that_divide = [];
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if ~isempty(data(cond).position(pos).analysis(c).passes_g1s) &&...
                        data(cond).position(pos).analysis(c).passes_g1s &&...
                        data(cond).position(pos).analysis(c).has_mitosis
                    %                         data(cond).position(pos).analysis(c).has_complete_cycle &&...
                    %                         data(cond).position(pos).analysis(c).has_valid_birth_size &&...
                    %                         data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size &&...
                    %                         ~isempty(data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister) &&...
                    %                         data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister
                    %
                    %                     figure,plot(data(cond).position(pos).analysis(c).protein_measurements)
                    %                     title(['Condition ' num2str(cond) ' position ' num2str(pos) ' cell ' num2str(c)])
                    
                    
                    disp(['Condition ' num2str(cond) ' cell ' num2str(c) ': '])
                    disp(['Inc ' num2str(data(cond).position(pos).analysis(c).sg2_protein_increase)])
                    disp(['Rate ' num2str(data(cond).position(pos).analysis(c).sg2_protein_accumulation_slope_perframe)])
                    disp(['Size ' num2str(data(cond).position(pos).analysis(c).g1s_size)])
                    disp(['Length ' num2str(data(cond).position(pos).analysis(c).sg2_length_hours)])
                    
                    data(cond).g1s_protein_amts_for_cells_that_divide = [data(cond).g1s_protein_amts_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).g1s_protein_amt];
                    data(cond).sg2_protein_increases_for_cells_that_divide = [data(cond).sg2_protein_increases_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).sg2_protein_increase];
                    data(cond).sg2_protein_accumulation_rates_for_cells_that_divide = [data(cond).sg2_protein_accumulation_rates_for_cells_that_divide;...
                        data(cond).position(pos).analysis(c).sg2_protein_accumulation_slope_perframe];
                end
            end
        end
    end
end

% Also measure birth size and G1 lengths for cells that are born and passed G1/S,
% regardless of whether they complete the cell cycle.
if measure_lengths_of_phases && measure_sizes_at_birth_and_other_times
    for cond = 1:num_conditions
        
        data(cond).birth_sizes_cells_born_and_pass_g1s = [];
        data(cond).birth_areas_cells_born_and_pass_g1s = [];
        data(cond).g1s_sizes_cells_born_and_pass_g1s = [];
        data(cond).g1s_areas_cells_born_and_pass_g1s = [];
        data(cond).g1_lengths_cells_born_and_pass_g1s = [];
        
        data(cond).cells_that_shrink_during_g1 = [];
        
        data(cond).half_of_mother_premitotic_size = [];
        data(cond).half_of_mother_premitotic_area = [];
        data(cond).g1s_sizes_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic = [];
        data(cond).g1s_lengths_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic = [];
        data(cond).g1s_areas_cells_born_and_pass_g1s_and_have_calculated_half_area_of_mother_premitotic = [];
        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if ~data(cond).position(pos).analysis(c).has_something_gone_horribly_wrong &&...
                        ~isempty(data(cond).position(pos).analysis(c).is_born) &&...
                        data(cond).position(pos).analysis(c).is_born &&...
                        ~isempty(data(cond).position(pos).analysis(c).passes_g1s) &&...
                        data(cond).position(pos).analysis(c).passes_g1s &&...
                        ~isempty(data(cond).position(pos).analysis(c).g1_length_hours) &&...
                        data(cond).position(pos).analysis(c).has_valid_birth_size &&...
                        data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size &&...
                        (~analysis_parameters.compare_birth_size_to_sister ||...
                        (~isempty(data(cond).position(pos).birth_size_is_similar_to_sister &&...
                        data(cond).position(pos).birth_size_is_similar_to_sister)))
                    
                    data(cond).birth_sizes_cells_born_and_pass_g1s = [data(cond).birth_sizes_cells_born_and_pass_g1s;...
                        data(cond).position(pos).analysis(c).birth_size];
                    data(cond).birth_areas_cells_born_and_pass_g1s = [data(cond).birth_areas_cells_born_and_pass_g1s;...
                        data(cond).position(pos).analysis(c).birth_area];
                    data(cond).g1s_sizes_cells_born_and_pass_g1s = [data(cond).g1s_sizes_cells_born_and_pass_g1s;...
                        data(cond).position(pos).analysis(c).g1s_size];
                    data(cond).g1s_areas_cells_born_and_pass_g1s = [data(cond).g1s_areas_cells_born_and_pass_g1s;...
                        data(cond).position(pos).analysis(c).g1s_area];
                    data(cond).g1_lengths_cells_born_and_pass_g1s = [data(cond).g1_lengths_cells_born_and_pass_g1s;...
                        data(cond).position(pos).analysis(c).g1_length_hours];
                    
                    if data(cond).position(pos).analysis(c).birth_size > data(cond).position(pos).analysis(c).g1s_size
                        data(cond).cells_that_shrink_during_g1 = [data(cond).cells_that_shrink_during_g1; [pos c]];
                    end
                    
                    if calculate_half_of_mother_premitotic_size
                        if data(cond).position(pos).analysis(c).has_calculated_half_of_mother_premitotic_size
                            data(cond).half_of_mother_premitotic_size = [data(cond).half_of_mother_premitotic_size;...
                                data(cond).position(pos).analysis(c).half_of_mother_premitotic_size];
                            data(cond).g1s_sizes_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic = [data(cond).g1s_sizes_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic;...
                                data(cond).position(pos).analysis(c).g1s_size];
                            data(cond).g1s_lengths_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic = [data(cond).g1s_lengths_cells_born_and_pass_g1s_and_have_calculated_half_size_of_mother_premitotic;...
                                data(cond).position(pos).analysis(c).g1_length_hours];
                            data(cond).half_of_mother_premitotic_area = [data(cond).half_of_mother_premitotic_area;...
                                data(cond).position(pos).analysis(c).half_of_mother_premitotic_area];
                            data(cond).g1s_areas_cells_born_and_pass_g1s_and_have_calculated_half_area_of_mother_premitotic = [data(cond).g1s_areas_cells_born_and_pass_g1s_and_have_calculated_half_area_of_mother_premitotic;...
                                data(cond).position(pos).analysis(c).g1s_area];
                        end
                    end
                end
            end
        end
    end
end

% Gather individual traces for passes-G1S and for complete cell cycles
% and store them in a cell array.
for cond = 1:num_conditions
    
    data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_trace_start = cell(0);
    data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s = cell(0);
    data(cond).all_individual_pass_g1s_traces_areas = cell(0);
    data(cond).all_individual_pass_g1s_traces_sizes = cell(0);
    data(cond).all_individual_pass_g1s_traces_volumes = cell(0);
    data(cond).all_individual_pass_g1s_traces_geminin = cell(0);
    data(cond).all_individual_pass_g1s_traces_protein_amts = cell(0);
    data(cond).all_individual_pass_g1s_traces_protein_per_area = cell(0);
    data(cond).all_individual_pass_g1s_traces_protein_per_volume = cell(0);
    data(cond).all_individual_pass_g1s_traces_protein_per_size = cell(0);
    
    data(cond).all_individual_complete_traces_frame_indices_wrt_birth = cell(0);
    data(cond).all_individual_complete_traces_frame_indices_wrt_g1s = cell(0);
    data(cond).all_individual_complete_traces_areas = cell(0);
    data(cond).all_individual_complete_traces_sizes = cell(0);
    data(cond).all_individual_complete_traces_volumes = cell(0);
    data(cond).all_individual_complete_traces_geminin = cell(0);
    data(cond).all_individual_complete_traces_protein_amts = cell(0);
    data(cond).all_individual_complete_traces_protein_per_area = cell(0);
    data(cond).all_individual_complete_traces_protein_per_volume = cell(0);
    data(cond).all_individual_complete_traces_protein_per_size = cell(0);
    for pos = data(cond).positions_list
        for c = data(cond).position(pos).tracking_measurements.all_tracknums
            if data(cond).position(pos).analysis(c).passes_g1s
                % For each cell that passes G1/S, store its individual
                % trace as part of a cell array
                data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_trace_start = [data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_trace_start;...
                    (1:length(data(cond).position(pos).analysis(c).all_frame_indices_wrt_g1s))'];
                data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s = [data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s;...
                    data(cond).position(pos).analysis(c).all_frame_indices_wrt_g1s'];
                data(cond).all_individual_pass_g1s_traces_areas = [data(cond).all_individual_pass_g1s_traces_areas;...
                    data(cond).position(pos).analysis(c).area_measurements];
                data(cond).all_individual_pass_g1s_traces_sizes = [data(cond).all_individual_pass_g1s_traces_sizes;...
                    data(cond).position(pos).analysis(c).size_measurements];
                data(cond).all_individual_pass_g1s_traces_volumes = [data(cond).all_individual_pass_g1s_traces_volumes;...
                    data(cond).position(pos).analysis(c).area_measurements .^1.5];
                data(cond).all_individual_pass_g1s_traces_geminin = [data(cond).all_individual_pass_g1s_traces_geminin;...
                    data(cond).position(pos).analysis(c).geminin_measurements];
                if measure_protein_concentrations
                    data(cond).all_individual_pass_g1s_traces_protein_amts = [data(cond).all_individual_pass_g1s_traces_protein_amts;...
                        data(cond).position(pos).analysis(c).protein_measurements];
                    data(cond).all_individual_pass_g1s_traces_protein_per_area = [data(cond).all_individual_pass_g1s_traces_protein_per_area;...
                        data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).area_measurements_smooth];
                    data(cond).all_individual_pass_g1s_traces_protein_per_volume = [data(cond).all_individual_pass_g1s_traces_protein_per_volume;...
                        data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).area_measurements_smooth .^ 1.5];
                    data(cond).all_individual_pass_g1s_traces_protein_per_size = [data(cond).all_individual_pass_g1s_traces_protein_per_size;...
                        data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).size_measurements_smooth];
                end
                
                % For each cell that completes cell cycle, store its individual
                % trace as part of a cell array
                if data(cond).position(pos).analysis(c).has_complete_cycle
                    data(cond).all_individual_complete_traces_frame_indices_wrt_birth = [data(cond).all_individual_complete_traces_frame_indices_wrt_birth;...
                        (1:length(data(cond).position(pos).analysis(c).all_frame_indices_wrt_g1s))'];
                    data(cond).all_individual_complete_traces_frame_indices_wrt_g1s = [data(cond).all_individual_complete_traces_frame_indices_wrt_g1s;...
                        data(cond).position(pos).analysis(c).all_frame_indices_wrt_g1s'];
                    data(cond).all_individual_complete_traces_areas = [data(cond).all_individual_complete_traces_areas;...
                        data(cond).position(pos).analysis(c).area_measurements];
                    data(cond).all_individual_complete_traces_sizes = [data(cond).all_individual_complete_traces_sizes;...
                        data(cond).position(pos).analysis(c).size_measurements];
                    data(cond).all_individual_complete_traces_volumes = [data(cond).all_individual_complete_traces_volumes;...
                        data(cond).position(pos).analysis(c).area_measurements .^1.5];
                    data(cond).all_individual_complete_traces_geminin = [data(cond).all_individual_complete_traces_geminin;...
                        data(cond).position(pos).analysis(c).geminin_measurements];
                    if measure_protein_concentrations
                        data(cond).all_individual_complete_traces_protein_amts = [data(cond).all_individual_complete_traces_protein_amts;...
                            data(cond).position(pos).analysis(c).protein_measurements];
                        data(cond).all_individual_complete_traces_protein_per_area = [data(cond).all_individual_complete_traces_protein_per_area;...
                            data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).area_measurements_smooth];
                        data(cond).all_individual_complete_traces_protein_per_volume = [data(cond).all_individual_complete_traces_protein_per_volume;...
                            data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).area_measurements_smooth .^ 1.5];
                        data(cond).all_individual_complete_traces_protein_per_size = [data(cond).all_individual_complete_traces_protein_per_size;...
                            data(cond).position(pos).analysis(c).protein_measurements ./ data(cond).position(pos).analysis(c).size_measurements_smooth];
                    end
                end
            end
        end
    end
end

% For the following instantaneous measurements, gather only cells that pass G1/S.
% (Need not have complete cycle.)
if measure_g1s_probabilities
    for cond = 1:num_conditions
        data(cond).all_frame_indices_wrt_g1s_thisframe = [];
        data(cond).all_g1s_happens_here_thisframe = [];
        data(cond).all_areas_up_to_g1s_thisframe = [];
        data(cond).all_sizes_up_to_g1s_thisframe = [];
        data(cond).all_volumes_up_to_g1s_thisframe = [];
        data(cond).all_geminins_up_to_g1s_thisframe = [];
        data(cond).all_protein_amts_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_area_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_size_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_volume_up_to_g1s_thisframe = [];
        data(cond).all_protein_per_area_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_g1s_happens_here_for_born_cells_thisframe = [];
        data(cond).all_areas_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_volumes_up_to_g1s_for_born_cells_thisframe = [];
        data(cond).all_protein_amts_up_to_g1s_for_born_cells_thisframe = [];
        
        data(cond).all_frame_indices_wrt_g1s_nextframe = [];
        data(cond).all_g1s_happens_here_nextframe = [];
        data(cond).all_areas_up_to_g1s_nextframe = [];
        data(cond).all_sizes_up_to_g1s_nextframe = [];
        data(cond).all_volumes_up_to_g1s_nextframe = [];
        data(cond).all_geminins_up_to_g1s_nextframe = [];
        data(cond).all_protein_amts_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_area_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_size_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_volume_up_to_g1s_nextframe = [];
        data(cond).all_protein_per_area_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_g1s_happens_here_for_born_cells_nextframe = [];
        data(cond).all_areas_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe = [];
        data(cond).all_volumes_up_to_g1s_for_born_cells_nextframe = [];
                data(cond).all_protein_amts_up_to_g1s_for_born_cells_nextframe = [];

        
        data(cond).all_frame_indices_wrt_g1s_1hrs_ahead = [];
        data(cond).all_g1s_happens_here_1hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_1hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_1hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_1hrs_ahead = [];
        data(cond).all_geminins_up_to_g1s_1hrs_ahead = [];
        data(cond).all_protein_amts_up_to_g1s_1hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_1hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_1hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_1hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_1hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_for_born_cells_1hrs_ahead = [];
                data(cond).all_protein_amts_up_to_g1s_for_born_cells_1hrs_ahead = [];

        
        data(cond).all_frame_indices_wrt_g1s_2hrs_ahead = [];
        data(cond).all_g1s_happens_here_2hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_2hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_2hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_2hrs_ahead = [];
        data(cond).all_geminins_up_to_g1s_2hrs_ahead = [];
        data(cond).all_protein_amts_up_to_g1s_2hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_2hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_2hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_2hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_2hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_for_born_cells_2hrs_ahead = [];
                data(cond).all_protein_amts_up_to_g1s_for_born_cells_2hrs_ahead = [];

        
        data(cond).all_frame_indices_wrt_g1s_3hrs_ahead = [];
        data(cond).all_g1s_happens_here_3hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_3hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_3hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_3hrs_ahead = [];
        data(cond).all_geminins_up_to_g1s_3hrs_ahead = [];
        data(cond).all_protein_amts_up_to_g1s_3hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_3hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_3hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_3hrs_ahead = [];
        data(cond).all_protein_per_area_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_protein_per_size_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead = [];
        data(cond).all_areas_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_sizes_up_to_g1s_for_born_cells_3hrs_ahead = [];
        data(cond).all_volumes_up_to_g1s_for_born_cells_3hrs_ahead = [];
                data(cond).all_protein_amts_up_to_g1s_for_born_cells_3hrs_ahead = [];

        
        for pos = data(cond).positions_list
            for c = data(cond).position(pos).tracking_measurements.all_tracknums
                if data(cond).position(pos).analysis(c).passes_g1s
                    
                    % Gather values that may predict G1/S transition and
                    % associated binary outcomes
                    
                    if max(data(cond).position(pos).analysis(c).areas_up_to_g1s_nextframe) > 5000
                        disp('help')
                    end
                    
                    % Predictions relative to G1/S happening at the current
                    % frame
                    data(cond).all_frame_indices_wrt_g1s_thisframe = [data(cond).all_frame_indices_wrt_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_thisframe];
                    data(cond).all_g1s_happens_here_thisframe = [data(cond).all_g1s_happens_here_thisframe;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_thisframe];
                    data(cond).all_areas_up_to_g1s_thisframe = [data(cond).all_areas_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_thisframe];
                    data(cond).all_volumes_up_to_g1s_thisframe = [data(cond).all_volumes_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).volumes_up_to_g1s_thisframe];
                    data(cond).all_sizes_up_to_g1s_thisframe = [data(cond).all_sizes_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_thisframe];
                    data(cond).all_geminins_up_to_g1s_thisframe = [data(cond).all_geminins_up_to_g1s_thisframe;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_thisframe];
                    
                    % Predictions relative to G1/S happening at the next
                    % frame
                    data(cond).all_frame_indices_wrt_g1s_nextframe = [data(cond).all_frame_indices_wrt_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_nextframe];
                    data(cond).all_g1s_happens_here_nextframe = [data(cond).all_g1s_happens_here_nextframe;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_nextframe];
                    data(cond).all_areas_up_to_g1s_nextframe = [data(cond).all_areas_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_nextframe];
                    data(cond).all_volumes_up_to_g1s_nextframe = [data(cond).all_volumes_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).volumes_up_to_g1s_nextframe];
                    data(cond).all_sizes_up_to_g1s_nextframe = [data(cond).all_sizes_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_nextframe];
                    data(cond).all_geminins_up_to_g1s_nextframe = [data(cond).all_geminins_up_to_g1s_nextframe;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_nextframe];
                    
                    % Predictions relative to G1/S happening 1 hours down
                    % the line
                    
                    data(cond).all_frame_indices_wrt_g1s_1hrs_ahead = [data(cond).all_frame_indices_wrt_g1s_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_1hrs_ahead];
                    data(cond).all_g1s_happens_here_1hrs_ahead = [data(cond).all_g1s_happens_here_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_1hrs_ahead];
                    data(cond).all_areas_up_to_g1s_1hrs_ahead = [data(cond).all_areas_up_to_g1s_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_1hrs_ahead];
                    data(cond).all_volumes_up_to_g1s_1hrs_ahead = [data(cond).all_volumes_up_to_g1s_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).volumes_up_to_g1s_1hrs_ahead];
                    data(cond).all_sizes_up_to_g1s_1hrs_ahead = [data(cond).all_sizes_up_to_g1s_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_1hrs_ahead];
                    data(cond).all_geminins_up_to_g1s_1hrs_ahead = [data(cond).all_geminins_up_to_g1s_1hrs_ahead;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_1hrs_ahead];
                    
                    % Predictions relative to G1/S happening 2 hours down
                    % the line
                    
                    data(cond).all_frame_indices_wrt_g1s_2hrs_ahead = [data(cond).all_frame_indices_wrt_g1s_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_2hrs_ahead];
                    data(cond).all_g1s_happens_here_2hrs_ahead = [data(cond).all_g1s_happens_here_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_2hrs_ahead];
                    data(cond).all_areas_up_to_g1s_2hrs_ahead = [data(cond).all_areas_up_to_g1s_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_2hrs_ahead];
                    data(cond).all_volumes_up_to_g1s_2hrs_ahead = [data(cond).all_volumes_up_to_g1s_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).volumes_up_to_g1s_2hrs_ahead];
                    data(cond).all_sizes_up_to_g1s_2hrs_ahead = [data(cond).all_sizes_up_to_g1s_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_2hrs_ahead];
                    data(cond).all_geminins_up_to_g1s_2hrs_ahead = [data(cond).all_geminins_up_to_g1s_2hrs_ahead;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_2hrs_ahead];
                    
                    % Predictions relative to G1/S happening 3 hours down
                    % the line
                    
                    data(cond).all_frame_indices_wrt_g1s_3hrs_ahead = [data(cond).all_frame_indices_wrt_g1s_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).frame_indices_wrt_g1s_3hrs_ahead];
                    data(cond).all_g1s_happens_here_3hrs_ahead = [data(cond).all_g1s_happens_here_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).g1s_happens_here_3hrs_ahead];
                    data(cond).all_areas_up_to_g1s_3hrs_ahead = [data(cond).all_areas_up_to_g1s_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).areas_up_to_g1s_3hrs_ahead];
                    data(cond).all_volumes_up_to_g1s_3hrs_ahead = [data(cond).all_volumes_up_to_g1s_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).volumes_up_to_g1s_3hrs_ahead];
                    data(cond).all_sizes_up_to_g1s_3hrs_ahead = [data(cond).all_sizes_up_to_g1s_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).sizes_up_to_g1s_3hrs_ahead];
                    data(cond).all_geminins_up_to_g1s_3hrs_ahead = [data(cond).all_geminins_up_to_g1s_3hrs_ahead;...
                        data(cond).position(pos).analysis(c).geminin_up_to_g1s_3hrs_ahead];
                    
                    
                    if measure_protein_concentrations
                        data(cond).all_protein_amts_up_to_g1s_thisframe = [data(cond).all_protein_amts_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_thisframe];
                        data(cond).all_protein_per_area_up_to_g1s_thisframe = [data(cond).all_protein_per_area_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_thisframe];
                        data(cond).all_protein_per_size_up_to_g1s_thisframe = [data(cond).all_protein_per_size_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_thisframe];
                        data(cond).all_protein_per_volume_up_to_g1s_thisframe = [data(cond).all_protein_per_volume_up_to_g1s_thisframe;...
                            data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_thisframe];
                        
                        data(cond).all_protein_amts_up_to_g1s_nextframe = [data(cond).all_protein_amts_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_nextframe];
                        data(cond).all_protein_per_area_up_to_g1s_nextframe = [data(cond).all_protein_per_area_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_nextframe];
                        data(cond).all_protein_per_size_up_to_g1s_nextframe = [data(cond).all_protein_per_size_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_nextframe];
                        data(cond).all_protein_per_volume_up_to_g1s_nextframe = [data(cond).all_protein_per_volume_up_to_g1s_nextframe;...
                            data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_nextframe];
                        
                        data(cond).all_protein_amts_up_to_g1s_1hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_1hrs_ahead];
                        data(cond).all_protein_per_area_up_to_g1s_1hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_1hrs_ahead];
                        data(cond).all_protein_per_size_up_to_g1s_1hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_1hrs_ahead];
                        data(cond).all_protein_per_volume_up_to_g1s_1hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_1hrs_ahead];
                        
                        data(cond).all_protein_amts_up_to_g1s_2hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_2hrs_ahead];
                        data(cond).all_protein_per_area_up_to_g1s_2hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_2hrs_ahead];
                        data(cond).all_protein_per_size_up_to_g1s_2hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_2hrs_ahead];
                        data(cond).all_protein_per_volume_up_to_g1s_2hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_2hrs_ahead];
                        
                        data(cond).all_protein_amts_up_to_g1s_3hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_3hrs_ahead];
                        data(cond).all_protein_per_area_up_to_g1s_3hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_3hrs_ahead];
                        data(cond).all_protein_per_size_up_to_g1s_3hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_3hrs_ahead];
                        data(cond).all_protein_per_volume_up_to_g1s_3hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_3hrs_ahead];
                    end
                    
                    if ~isempty(data(cond).position(pos).analysis(c).is_born) && data(cond).position(pos).analysis(c).is_born
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_thisframe];
                        data(cond).all_g1s_happens_here_for_born_cells_thisframe = [data(cond).all_g1s_happens_here_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_thisframe];
                        data(cond).all_areas_up_to_g1s_for_born_cells_thisframe =  [data(cond).all_areas_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).areas_up_to_g1s_thisframe];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe =  [data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_thisframe];
                        data(cond).all_volumes_up_to_g1s_for_born_cells_thisframe =  [data(cond).all_volumes_up_to_g1s_for_born_cells_thisframe;...
                            data(cond).position(pos).analysis(c).volumes_up_to_g1s_thisframe];
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_nextframe];
                        data(cond).all_g1s_happens_here_for_born_cells_nextframe = [data(cond).all_g1s_happens_here_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_nextframe];
                        data(cond).all_areas_up_to_g1s_for_born_cells_nextframe =  [data(cond).all_areas_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).areas_up_to_g1s_nextframe];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe =  [data(cond).all_sizes_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_nextframe];
                        data(cond).all_volumes_up_to_g1s_for_born_cells_nextframe =  [data(cond).all_volumes_up_to_g1s_for_born_cells_nextframe;...
                            data(cond).position(pos).analysis(c).volumes_up_to_g1s_nextframe];
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_1hrs_ahead];
                        data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead = [data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_1hrs_ahead];
                        data(cond).all_areas_up_to_g1s_for_born_cells_1hrs_ahead =  [data(cond).all_areas_up_to_g1s_for_born_cells_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).areas_up_to_g1s_1hrs_ahead];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_1hrs_ahead =  [data(cond).all_sizes_up_to_g1s_for_born_cells_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_1hrs_ahead];
                        data(cond).all_volumes_up_to_g1s_for_born_cells_1hrs_ahead =  [data(cond).all_volumes_up_to_g1s_for_born_cells_1hrs_ahead;...
                            data(cond).position(pos).analysis(c).volumes_up_to_g1s_1hrs_ahead];
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_2hrs_ahead];
                        data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead = [data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_2hrs_ahead];
                        data(cond).all_areas_up_to_g1s_for_born_cells_2hrs_ahead =  [data(cond).all_areas_up_to_g1s_for_born_cells_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).areas_up_to_g1s_2hrs_ahead];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_2hrs_ahead =  [data(cond).all_sizes_up_to_g1s_for_born_cells_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_2hrs_ahead];
                        data(cond).all_volumes_up_to_g1s_for_born_cells_2hrs_ahead =  [data(cond).all_volumes_up_to_g1s_for_born_cells_2hrs_ahead;...
                            data(cond).position(pos).analysis(c).volumes_up_to_g1s_2hrs_ahead];
                        
                        data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead = [data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).age_in_hours_up_to_g1s_3hrs_ahead];
                        data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead = [data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).g1s_happens_here_3hrs_ahead];
                        data(cond).all_areas_up_to_g1s_for_born_cells_3hrs_ahead =  [data(cond).all_areas_up_to_g1s_for_born_cells_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).areas_up_to_g1s_3hrs_ahead];
                        data(cond).all_sizes_up_to_g1s_for_born_cells_3hrs_ahead =  [data(cond).all_sizes_up_to_g1s_for_born_cells_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).sizes_up_to_g1s_3hrs_ahead];
                        data(cond).all_volumes_up_to_g1s_for_born_cells_3hrs_ahead =  [data(cond).all_volumes_up_to_g1s_for_born_cells_3hrs_ahead;...
                            data(cond).position(pos).analysis(c).volumes_up_to_g1s_3hrs_ahead];
                        
                        if measure_protein_concentrations
                            data(cond).all_protein_amts_up_to_g1s_for_born_cells_thisframe = [data(cond).all_protein_amts_up_to_g1s_for_born_cells_thisframe;...
                                data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_thisframe];
                            data(cond).all_protein_per_area_up_to_g1s_for_born_cells_thisframe = [data(cond).all_protein_per_area_up_to_g1s_for_born_cells_thisframe;...
                                data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_thisframe];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_thisframe];
                            data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_thisframe = [data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_thisframe;...
                                data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_thisframe];
                            
                            data(cond).all_protein_amts_up_to_g1s_for_born_cells_nextframe = [data(cond).all_protein_amts_up_to_g1s_for_born_cells_nextframe;...
                                data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_nextframe];
                            data(cond).all_protein_per_area_up_to_g1s_for_born_cells_nextframe = [data(cond).all_protein_per_area_up_to_g1s_for_born_cells_nextframe;...
                                data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_nextframe];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_nextframe;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_nextframe];
                            data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_nextframe = [data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_nextframe;...
                                data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_nextframe];
                            
                            data(cond).all_protein_amts_up_to_g1s_for_born_cells_1hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_for_born_cells_1hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_1hrs_ahead];
                            data(cond).all_protein_per_area_up_to_g1s_for_born_cells_1hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_for_born_cells_1hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_1hrs_ahead];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_1hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_1hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_1hrs_ahead];
                            data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_1hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_1hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_1hrs_ahead];
                            
                            data(cond).all_protein_amts_up_to_g1s_for_born_cells_2hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_for_born_cells_2hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_2hrs_ahead];
                            data(cond).all_protein_per_area_up_to_g1s_for_born_cells_2hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_for_born_cells_2hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_2hrs_ahead];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_2hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_2hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_2hrs_ahead];
                            data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_2hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_2hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_2hrs_ahead];
                            
                            data(cond).all_protein_amts_up_to_g1s_for_born_cells_3hrs_ahead = [data(cond).all_protein_amts_up_to_g1s_for_born_cells_3hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_amt_up_to_g1s_3hrs_ahead];
                            data(cond).all_protein_per_area_up_to_g1s_for_born_cells_3hrs_ahead = [data(cond).all_protein_per_area_up_to_g1s_for_born_cells_3hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_area_up_to_g1s_3hrs_ahead];
                            data(cond).all_protein_per_size_up_to_g1s_for_born_cells_3hrs_ahead = [data(cond).all_protein_per_size_up_to_g1s_for_born_cells_3hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_size_up_to_g1s_3hrs_ahead];
                            data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_3hrs_ahead = [data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_3hrs_ahead;...
                                data(cond).position(pos).analysis(c).protein_per_volume_up_to_g1s_3hrs_ahead];
                            
                        end
                    end
                end
            end
        end
    end
end

save([table_expt_folder '\' tracking_strategy '_Data.mat'],'data','-v7.3');

%% Plot results

% load([table_expt_folder '\' tracking_strategy '_Data.mat'])

figure_folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots';
if strcmp(tracking_strategy,'clicking')
    figure_subfolder = [figure_folder '\' expt_name '\ManualTracking'];
elseif strcmp(tracking_strategy,'aivia')
    figure_subfolder = [figure_folder '\' expt_name '\Aivia'];
end

% figure_subfolder = ['C:\Users\Skotheim Lab\Desktop\Test'];

if ~exist(figure_subfolder,'dir')
    mkdir(figure_subfolder)
end

table_folder = 'C:\Users\Skotheim Lab\Desktop\Tables';
if strcmp(tracking_strategy,'clicking')
    table_subfolder = [table_folder '\' expt_name '\ManualTracking'];
elseif strcmp(tracking_strategy,'aivia')
    table_subfolder = [table_folder '\' expt_name '\Aivia'];
end

if ~exist(table_subfolder,'dir')
    mkdir(table_subfolder)
end

% Create tables with data for scatterplots (i.e., one data point per cell)
for cond = 1:num_conditions
    G1_tables{cond} = table;
    G1_tables{cond}.birth_sizes = data(cond).birth_sizes_cells_born_and_pass_g1s;
    G1_tables{cond}.birth_areas = data(cond).birth_areas_cells_born_and_pass_g1s;
    G1_tables{cond}.birth_volumes = data(cond).birth_areas_cells_born_and_pass_g1s .^ 1.5;
    G1_tables{cond}.g1_lengths = data(cond).g1_lengths_cells_born_and_pass_g1s;
    G1_tables{cond}.g1s_sizes = data(cond).g1s_sizes_cells_born_and_pass_g1s;
    G1_tables{cond}.g1s_areas = data(cond).g1s_areas_cells_born_and_pass_g1s;
    G1_tables{cond}.g1s_volumes = data(cond).g1s_areas_cells_born_and_pass_g1s .^1.5;
    G1_tables{cond}.g1_size_growths = data(cond).g1s_sizes_cells_born_and_pass_g1s - data(cond).birth_sizes_cells_born_and_pass_g1s;
    
    
    %     if exist([table_subfolder '\G1_table_' data(cond).treatment '.xlsx'], 'file') == 2
    %         delete([table_subfolder '\G1_table_' data(cond).treatment '.xlsx']);
    %     end
    writetable(G1_tables{cond}, [table_subfolder '\G1_table_' data(cond).treatment '.xlsx']);
    if measure_protein_concentrations
        SG2_tables{cond} = table;
        SG2_tables{cond}.G1S_sizes = data(cond).g1s_sizes_for_cells_that_divide;
        SG2_tables{cond}.G1S_areas = data(cond).g1s_areas_for_cells_that_divide;
        SG2_tables{cond}.G1S_volumes = data(cond).g1s_areas_for_cells_that_divide .^1.5;
        SG2_tables{cond}.SG2_lengths = data(cond).sg2_lengths_for_cells_that_divide;
        SG2_tables{cond}.G1S_Rb_amounts = data(cond).g1s_protein_amts_for_cells_that_divide;
        SG2_tables{cond}.SG2_Rb_increase = data(cond).sg2_protein_increases_for_cells_that_divide;
        SG2_tables{cond}.SG2_Rb_accumulation_rate = data(cond).sg2_protein_accumulation_rates_for_cells_that_divide ./ analysis_parameters.framerate;
        %     if exist([table_subfolder '\SG2_table_' data(cond).treatment '.xlsx'], 'file') == 2
        %         delete([table_subfolder '\SG2_table_' data(cond).treatment '.xlsx']);
        %     end
        writetable(SG2_tables{cond}, [table_subfolder '\SG2_table_' data(cond).treatment '.xlsx']);
    end
end

% Plot size vs area
if measure_area_vs_fluorescence
    for cond = 1:num_conditions
        figure()
        hold on
        scatter(data(cond).all_area_measurements, data(cond).all_size_measurements)
        scatter(data(cond).all_area_measurements_avoiding_ends, data(cond).all_size_measurements_avoiding_ends)
        title(data(cond).treatment)
        xlabel('Nuclear area measurements (px2)')
        ylabel('Size measurements (AU)')
        legend('All cells','Avoiding ends')
        hold off
        saveas(gcf, [figure_subfolder '\AllAreaMeasurements_' data(cond).treatment '.png'])
        
        plot_scatter_with_line(data(cond).all_area_measurements_avoiding_ends,...
            data(cond).all_size_measurements_avoiding_ends);
        title(data(cond).treatment)
        xlabel('Area measurements (px2)')
        ylabel('Size measurements (AU)')
        legend('Avoiding ends')
        saveas(gcf, [figure_subfolder '\AllAreaMeasurements_WithLine_' data(cond).treatment '.png'])
        
        plot_scatter_with_line(data(cond).all_area_measurements_avoiding_ends.^1.5,...
            data(cond).all_size_measurements_avoiding_ends);
        title(data(cond).treatment)
        xlabel('Volume estimate assuming spherical nucleus (px3)')
        ylabel('Size measurements (AU)')
        legend('Avoiding ends')
        saveas(gcf, [figure_subfolder '\AllVolumeMeasurements_WithLine_' data(cond).treatment '.png'])
    end
end

% Plot histograms and CDFs of birth sizes, cell cycle times, g1 lengths,
% g1s sizes, sg2 lengths
if measure_sizes_at_birth_and_other_times && measure_lengths_of_phases
    all_data_types_to_plot = {'Birth_sizes','Complete_cell_cycle_length','G1_length','G1S_size','SG2_length'};
    all_cell_classes_to_plot = {'all','first_gen','second_gen','early','late',...
        'incomplete_movie_ends','incomplete_untrackability'};
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
                    
                    if isempty(data_to_plot(cond).to_plot)
                        continue
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
% Currently that means has_complete_cycle and has_valid_birth_size but
% NOT birth_size_is_similar_to_sister. Check
% analysis_parameters.compare_birth_size_to_sister.
if measure_sizes_at_birth_and_other_times && measure_lengths_of_phases
    all_data_types_to_plot = {'Birth_size_vs_G1_length','Birth_size_vs_SG2_length','Birth_size_vs_Complete_cycle_length',...
        'Birth_area_vs_G1_length','Birth_volume_vs_G1_length','G1S_size_vs_SG2_length','Birth_size_vs_G1_growth','G1S_size_vs_SG2_growth',...
        'Birth_size_vs_Complete_cycle_growth','Instantaneous_sizes_vs_growths'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'G1S_size_vs_SG2_protein_increase','G1S_size_vs_SG2_protein_accumulation_rate',...
            'G1S_area_vs_SG2_protein_increase','G1S_area_vs_SG2_protein_accumulation_rate',...
            'G1S_volume_vs_SG2_protein_increase','G1S_volume_vs_SG2_protein_accumulation_rate'};
    end
    all_cell_classes_to_plot = {'all_good','first_gen_good','second_gen_good','G1_cells_good','SG2_cells_good','pass_g1s_not_necessarily_complete'};
    all_plottypes = {'scatter_with_line','scatter_with_bins'};
    
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
                        elseif strcmp(cell_class_to_plot,'pass_g1s_not_necessarily_complete')
                            data_to_scatter(cond).x = data(cond).birth_sizes_cells_born_and_pass_g1s;
                            data_to_scatter(cond).y = data(cond).g1_lengths_cells_born_and_pass_g1s;
                            graph_title = [data(cond).treatment ', cells that are born and pass G1/S'];
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
                        x_axis_label = 'Birth area (px²)';
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
                        elseif strcmp(cell_class_to_plot,'pass_g1s_not_necessarily_complete')
                            data_to_scatter(cond).x = data(cond).birth_areas_cells_born_and_pass_g1s;
                            data_to_scatter(cond).y = data(cond).g1_lengths_cells_born_and_pass_g1s;
                            graph_title = [data(cond).treatment ', cells that are born and pass G1/S'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_volume_vs_G1_length')
                        x_axis_label = 'Birth volume (px3)';
                        y_axis_label = 'G1 length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_areas .^1.5;
                            data_to_scatter(cond).y = data(cond).all_good_g1_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'first_gen_good')
                            data_to_scatter(cond).x = data(cond).first_gen_good_birth_areas .^1.5;
                            data_to_scatter(cond).y = data(cond).first_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'second_gen_good')
                            data_to_scatter(cond).x = data(cond).second_gen_good_birth_areas .^1.5;
                            data_to_scatter(cond).y = data(cond).second_gen_good_g1_lengths;
                            graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_g1s_not_necessarily_complete')
                            data_to_scatter(cond).x = data(cond).birth_areas_cells_born_and_pass_g1s .^ 1.5;
                            data_to_scatter(cond).y = data(cond).g1_lengths_cells_born_and_pass_g1s;
                            graph_title = [data(cond).treatment ', cells that are born and pass G1/S'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_length')
                        x_axis_label = 'G1S size (AU)';
                        y_axis_label = 'SG2 length (h)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_g1s_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_sg2_lengths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_G1_growth')
                        x_axis_label = 'Birth size (AU)';
                        y_axis_label = 'G1 growth (AU)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_g1_growths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_growth')
                        x_axis_label = 'G1S size (AU)';
                        y_axis_label = 'SG2 growth (AU)';
                        
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_g1s_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_sg2_growths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Birth_size_vs_Complete_cycle_growth')
                        x_axis_label = 'Birth size (AU)';
                        y_axis_label = 'Complete cycle growth (AU)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                            data_to_scatter(cond).y = data(cond).all_good_g1_growths + data(cond).all_good_sg2_growths;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_protein_increase')
                        x_axis_label = 'G1S size (AU)';
                        y_axis_label = 'Increase in Rb amt during SG2 (AU)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_sizes_for_cells_that_divide;
                            data_to_scatter(cond).y = data(cond).sg2_protein_increases_for_cells_that_divide;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_size_vs_SG2_protein_accumulation_rate')
                        x_axis_label = 'G1S size (AU)';
                        y_axis_label = 'Average Rb accumulation rate during SG2 (AU/h)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_sizes_for_cells_that_divide;
                            data_to_scatter(cond).y = data(cond).sg2_protein_accumulation_rates_for_cells_that_divide / analysis_parameters.framerate;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_area_vs_SG2_protein_increase')
                        x_axis_label = 'G1S area (px2)';
                        y_axis_label = 'Increase in Rb amt during SG2 (AU)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_areas_for_cells_that_divide;
                            data_to_scatter(cond).y = data(cond).sg2_protein_increases_for_cells_that_divide;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_area_vs_SG2_protein_accumulation_rate')
                        x_axis_label = 'G1S area (px2)';
                        y_axis_label = 'Average Rb accumulation rate during SG2 (AU/h)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_areas_for_cells_that_divide;
                            data_to_scatter(cond).y = data(cond).sg2_protein_accumulation_rates_for_cells_that_divide / analysis_parameters.framerate;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_volume_vs_SG2_protein_increase')
                        x_axis_label = 'G1S volume (px3)';
                        y_axis_label = 'Increase in Rb amt during SG2 (AU)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_areas_for_cells_that_divide .^1.5;
                            data_to_scatter(cond).y = data(cond).sg2_protein_increases_for_cells_that_divide;
                            graph_title = [data(cond).treatment ', all cells that complete cycle'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'G1S_volume_vs_SG2_protein_accumulation_rate')
                        x_axis_label = 'G1S volume (px3)';
                        y_axis_label = 'Average Rb accumulation rate during SG2 (AU/h)';
                        if strcmp(cell_class_to_plot,'all_good')
                            data_to_scatter(cond).x = data(cond).g1s_areas_for_cells_that_divide .^1.5;
                            data_to_scatter(cond).y = data(cond).sg2_protein_accumulation_rates_for_cells_that_divide / analysis_parameters.framerate;
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
                        elseif strcmp(plottype,'scatter_with_bins')
                            plot_scatter_with_bins(data_to_scatter(cond).x, data_to_scatter(cond).y);
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

% Create tables with individual complete traces (i.e., one column per cell)
for cond = 1:num_conditions
    all_data_types_to_write = {'Ages_wrt_birth','Ages_wrt_g1s',...
        'Areas','Volumes','Sizes','Geminin'};
    if measure_protein_concentrations
        all_data_types_to_write = {all_data_types_to_write{:},'Rb','Rb_per_area',...
            'Rb_per_volume','Rb_per_size'};
    end
    all_cell_classes_to_write = {'complete'};
    all_tabletypes = {'NaN_padded'};
    for data_type_to_write = all_data_types_to_write
        for cell_class_to_write = all_cell_classes_to_write
            for tabletype = all_tabletypes
                max_trace_length = 0;
                switch cell_class_to_write{1}
                    case 'complete'
                        num_traces = length(data(cond).all_individual_complete_traces_frame_indices_wrt_birth);
                        for i = 1:num_traces
                            max_trace_length = max(max_trace_length, length(data(cond).all_individual_complete_traces_frame_indices_wrt_birth{i}));
                        end
                        switch tabletype{1}
                            case 'NaN_padded'
                                all_traces_padded = NaN(max_trace_length,num_traces);
                                for i = 1:num_traces
                                    switch data_type_to_write{1}
                                        case 'Ages_wrt_birth'
                                            thistrace = data(cond).all_individual_complete_traces_frame_indices_wrt_birth{i} * analysis_parameters.framerate;
                                        case 'Ages_wrt_g1s'
                                            thistrace = data(cond).all_individual_complete_traces_frame_indices_wrt_g1s{i} * analysis_parameters.framerate;
                                        case 'Areas'
                                            thistrace = data(cond).all_individual_complete_traces_areas{i};
                                        case 'Volumes'
                                            thistrace = data(cond).all_individual_complete_traces_volumes{i};
                                        case 'Sizes'
                                            thistrace = data(cond).all_individual_complete_traces_sizes{i};
                                        case 'Geminin'
                                            thistrace = data(cond).all_individual_complete_traces_geminin{i};
                                        case 'Rb'
                                            thistrace = data(cond).all_individual_complete_traces_protein_amts{i};
                                        case 'Rb_per_area'
                                            thistrace = data(cond).all_individual_complete_traces_protein_per_area{i};
                                        case 'Rb_per_volume'
                                            thistrace = data(cond).all_individual_complete_traces_protein_per_volume{i};
                                        case 'Rb_per_size'
                                            thistrace = data(cond).all_individual_complete_traces_protein_per_size{i};
                                    end
                                    all_traces_padded(1:length(thistrace),i) = thistrace;
                                end
                                if ~isempty(all_traces_padded)
                                    xlswrite([table_subfolder '\Trace_table_' data(cond).treatment '.xlsx'], all_traces_padded, data_type_to_write{1});
                                end
                        end
                end
            end
        end
    end
end


% Plot individual cell traces, aligned to birth or to G1/S
if measure_g1s_probabilities
    all_data_types_to_plot = {'Aligned_areas','Aligned_volumes','Aligned_sizes','Aligned_geminin'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'Aligned_protein','Aligned_protein_per_area',...
            'Aligned_protein_per_volume','Aligned_protein_per_size'};
    end
    all_cell_classes_to_plot = {'pass_g1s','complete'};
    all_plottypes = {'wrt_birth','wrt_g1s'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                for cond = 1:num_conditions
                    
                    is_there_something_to_plot = false;
                    
                    switch cell_class_to_plot{1}
                        case 'pass_g1s'
                            switch plottype{1}
                                case 'wrt_birth'
                                    x_axis_label = 'Time relative to birth (h)';
                                    x_coord_cell_array = data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_trace_start;
                                    graph_title = [data(cond).treatment ', cells that pass G1/S with traces aligned to trace start'];
                                    
                                case 'wrt_g1s'
                                    x_axis_label = 'Time relative to G1/S (h)';
                                    x_coord_cell_array = data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s;
                                    graph_title = [data(cond).treatment ', cells that pass G1/S with traces aligned to G1/S'];
                            end
                            
                            switch data_type_to_plot{1}
                                case 'Aligned_areas'
                                    y_axis_label = 'Area (px2)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_areas;
                                    
                                case 'Aligned_volumes'
                                    y_axis_label = 'Volume (px3)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_volumes;
                                    
                                case 'Aligned_sizes'
                                    y_axis_label = 'Size (AU)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_sizes;
                                    
                                case 'Aligned_geminin'
                                    y_axis_label = 'Geminin (AU)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_geminin;
                                    
                                case 'Aligned_protein'
                                    y_axis_label = 'Rb amt (AU)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_protein_amts;
                                    
                                case 'Aligned_protein_per_area';
                                    y_axis_label = 'Rb amt per area (AU/px2)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_protein_per_area;
                                    
                                case 'Aligned_protein_per_volume';
                                    y_axis_label = 'Rb amt per volume (AU/px3)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_protein_per_volume;
                                    
                                case 'Aligned_protein_per_size';
                                    y_axis_label = 'Rb amt per size (AU/AU)';
                                    y_coord_cell_array = data(cond).all_individual_pass_g1s_traces_protein_per_size;
                            end
                            
                        case 'complete'
                            switch plottype{1}
                                case 'wrt_birth'
                                    x_axis_label = 'Time relative to birth (h)';
                                    x_coord_cell_array = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
                                    graph_title = [data(cond).treatment ', cells that complete cell cycle with traces aligned to birth'];
                                    
                                case 'wrt_g1s'
                                    x_axis_label = 'Time relative to G1/S (h)';
                                    x_coord_cell_array = data(cond).all_individual_complete_traces_frame_indices_wrt_g1s;
                                    graph_title = [data(cond).treatment ', cells that complete cell cycle with traces aligned to G1/S'];
                            end
                            
                            switch data_type_to_plot{1}
                                case 'Aligned_areas'
                                    y_axis_label = 'Area (px2)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_areas;
                                    
                                case 'Aligned_volumes'
                                    y_axis_label = 'Volume (px3)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_volumes;
                                    
                                case 'Aligned_sizes'
                                    y_axis_label = 'Size (AU)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_sizes;
                                    
                                case 'Aligned_geminin'
                                    y_axis_label = 'Geminin (AU)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_geminin;
                                    
                                case 'Aligned_protein'
                                    y_axis_label = 'Rb amt (AU)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_protein_amts;
                                    
                                case 'Aligned_protein_per_area';
                                    y_axis_label = 'Rb amt per area (AU/px2)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_protein_per_area;
                                    
                                case 'Aligned_protein_per_volume';
                                    y_axis_label = 'Rb amt per volume (AU/px3)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_protein_per_volume;
                                    
                                case 'Aligned_protein_per_size';
                                    y_axis_label = 'Rb amt per size (AU/AU)';
                                    y_coord_cell_array = data(cond).all_individual_complete_traces_protein_per_size;
                            end
                            
                            assert(length(x_coord_cell_array) == length(y_coord_cell_array));
                            all_x_coords = [];
                            all_y_coords = [];
                            if length(x_coord_cell_array) > 0
                            
                            figure()
                            hold on
                            for individual_trace_num = 1:length(x_coord_cell_array)
                                if size(x_coord_cell_array{individual_trace_num},1) ~= size(y_coord_cell_array{individual_trace_num},1)
                                    x_coord_cell_array{individual_trace_num} = x_coord_cell_array{individual_trace_num}';
                                end
                                assert(size(x_coord_cell_array{individual_trace_num},1) == size(y_coord_cell_array{individual_trace_num},1));
                                plot(x_coord_cell_array{individual_trace_num},y_coord_cell_array{individual_trace_num}, 'linewidth',0.01)
                                all_x_coords = [all_x_coords; x_coord_cell_array{individual_trace_num}];
                                all_y_coords = [all_y_coords; y_coord_cell_array{individual_trace_num}];
                            end
                            unique_x_coords = unique(all_x_coords);
                            mean_y_coords = [];
                            y_coords_for_each_x = cell(1,length(unique_x_coords));
                            for unique_x_coord_num = 1:length(unique_x_coords)
                                for individual_trace_num = 1:length(x_coord_cell_array)
                                    thistrace_x_coords = x_coord_cell_array{individual_trace_num};
                                    thistrace_y_coords = y_coord_cell_array{individual_trace_num};
                                    y_coords_for_each_x{unique_x_coord_num} = [y_coords_for_each_x{unique_x_coord_num},...
                                        thistrace_y_coords(thistrace_x_coords == unique_x_coords(unique_x_coord_num))];
                                end
                                y_coords_for_this_x = y_coords_for_each_x{unique_x_coord_num};
                                mean_y_coords(unique_x_coord_num,1) = mean(y_coords_for_this_x(~isnan(y_coords_for_this_x) & ~isinf(y_coords_for_this_x)));
                            end
                            plot(unique_x_coords,mean_y_coords, 'linewidth',5,'Color','k')
                            
                            xlabel(x_axis_label)
                            ylabel(y_axis_label)
                            title(graph_title)
                            axis([-inf inf min(0,prctile(all_y_coords,1)) prctile(all_y_coords,99.9)])
                            saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' data(cond).treatment '_'...
                                cell_class_to_plot{1} '_' plottype{1} '.png'])
                            end
                    end
                end
            end
        end
    end
end


% Calculate and plot logistic regressions
if measure_g1s_probabilities
    disp(['Condition 1: number of cells that pass G1/S = ' num2str(sum(data(1).all_g1s_happens_here_thisframe))])
    disp(['Condition 2: number of cells that pass G1/S = ' num2str(sum(data(2).all_g1s_happens_here_thisframe))])
    disp(['Condition 1: number of cells that are born and pass G1/S = ' num2str(sum(data(1).all_g1s_happens_here_for_born_cells_thisframe))])
    disp(['Condition 2: number of cells that are born and pass G1/S = ' num2str(sum(data(2).all_g1s_happens_here_for_born_cells_thisframe))])
    
    % One variable logistic regression
    all_data_types_to_plot = {...
        %         'Relative_frame_vs_G1S_probability',...
        'Age_vs_G1S_probability','Area_vs_G1S_probability',...
        'Size_vs_G1S_probability','Volume_vs_G1S_probability','Geminin_vs_G1S_probability'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'Rb_amt_vs_G1S_probability',...
            'Rb_per_area_vs_G1S_probability','Rb_per_size_vs_G1S_probability','Rb_per_volume_vs_G1S_probability'};
    end
    all_cell_classes_to_plot = {'pass_thisframe','pass_nextframe','pass_1hrs_ahead','pass_2hrs_ahead','pass_3hrs_ahead'};
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_frame_indices_wrt_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_frame_indices_wrt_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_frame_indices_wrt_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_areas_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_areas_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_areas_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_sizes_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_sizes_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_sizes_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Volume_vs_G1S_probability')
                        x_axis_label = 'Volume (px3)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_volumes_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_volumes_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_volumes_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_volumes_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_volumes_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_geminins_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_geminins_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_geminins_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_amts_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_amts_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_amts_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_area_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_area_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_area_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_size_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_size_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_size_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Rb_per_volume_vs_G1S_probability')
                        x_axis_label = 'Rb per volume (AU/px3)';
                        y_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_volume_up_to_g1s_thisframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_protein_per_volume_up_to_g1s_nextframe;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_volume_up_to_g1s_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_volume_up_to_g1s_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_protein_per_volume_up_to_g1s_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_g1s_happens_here_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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
    
    % Two variable logistic regression
    all_data_types_to_plot = {'Area_and_Age_vs_G1S_probability','Size_and_Age_vs_G1S_probability','Volume_and_Age_vs_G1S_probability'};
    if measure_protein_concentrations
        all_data_types_to_plot = {all_data_types_to_plot{:},'Age_and_[Rb_per_area]_vs_G1S_probability',...
            'Age_and_[Rb_per_size]_vs_G1S_probability','Age_and_[Rb_per_volume]_vs_G1S_probability'};
    end
    all_cell_classes_to_plot = {'pass_thisframe','pass_nextframe','pass_1hrs_ahead','pass_2hrs_ahead','pass_3hrs_ahead'};
    all_plottypes = {'two_var_logit'};
    
    for data_type_to_plot = all_data_types_to_plot
        for cell_class_to_plot = all_cell_classes_to_plot
            for plottype = all_plottypes
                for cond = 1:num_conditions
                    
                    is_there_something_to_plot = false;
                    
                    if strcmp(data_type_to_plot,'Area_and_Age_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Area (px2)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_areas_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_areas_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_areas_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_areas_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_areas_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Size_and_Age_vs_G1S_probability')
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_sizes_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_sizes_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_sizes_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Volume_and_Age_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Volume (px3)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_volumes_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_volumes_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_volumes_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_volumes_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_volumes_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Age_and_[Rb_per_area]_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Rb concentration per area (AU/px2)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Age_and_[Rb_per_size]_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Rb concentration per size (AU/AU)';
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
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
                            is_there_something_to_plot = true;
                        end
                        
                    elseif strcmp(data_type_to_plot,'Age_and_[Rb_per_volume]_vs_G1S_probability')
                        x_axis_label = 'Age (h)';
                        y_axis_label = 'Rb concentration per volume (AU/px3)';
                        z_axis_label = 'G1/S probability';
                        
                        if strcmp(cell_class_to_plot,'pass_thisframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_thisframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at this frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_nextframe')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).y = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_nextframe;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_nextframe;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S at next frame'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_1hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_1hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_1hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 1 hour'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_2hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_2hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_2hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 2 hours'];
                            is_there_something_to_plot = true;
                        elseif strcmp(cell_class_to_plot,'pass_3hrs_ahead')
                            data_to_scatter(cond).x = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).y = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_3hrs_ahead;
                            data_to_scatter(cond).z = data(cond).all_g1s_happens_here_for_born_cells_3hrs_ahead;
                            graph_title = [data(cond).treatment ', all cells that pass G1/S in 3 hours'];
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


% save([table_expt_folder '\data.mat'],'data')

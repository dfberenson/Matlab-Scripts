clear all
close all

%% Set parameters

% tracking_strategy = 'clicking';
tracking_strategy = 'aivia';

% source_folder = 'E:\Manually tracked measurements';
source_folder = 'E:\Aivia';
expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
expt_folder = [source_folder '\' expt_name];

num_conditions = 1;

% Set analysis parameters
analysis_parameters = struct;
analysis_parameters.order_of_channels = 'prg';
analysis_parameters.size_channel = 'r';
analysis_parameters.geminin_channel = 'g';
analysis_parameters.movie_start_frame = 1;
analysis_parameters.movie_end_frame = 421;
analysis_parameters.segmentation_parameters.gaussian_width = 2;
analysis_parameters.segmentation_parameters.threshold = 200;
analysis_parameters.segmentation_parameters.strel_shape = 'disk';
analysis_parameters.segmentation_parameters.strel_size = 1;
analysis_parameters.framerate = 1/6;
analysis_parameters.num_first_frames_to_avoid = 5;
analysis_parameters.num_last_frames_to_avoid = 10;
analysis_parameters.frames_to_check_nearby = 20;
analysis_parameters.min_frames_above = 15;
analysis_parameters.threshold = 20000;
analysis_parameters.plot = false;
analysis_parameters.strategy = 'all';
analysis_parameters.birthsize_measuring_frames = [6:12];
analysis_parameters.min_cycle_duration_hours = 5;
analysis_parameters.geminin_threshold = 100000;
analysis_parameters.smoothing_param = 5;
analysis_parameters.max_fraction_diff_from_sibling_mean = 0.2;
analysis_parameters.max_birth_size = 100000;
analysis_parameters.birth_frame_threshold = 200;

%% Gather data

% Create data structure
for cond = 1:num_conditions
    if cond == 1
        data(cond).treatment = 'PBS';
        data(cond).positions_list = [1 2 3 5 6 7 8 9 10 11 12];
%         data(cond).positions_list = [];

    elseif cond == 2
        data(cond).treatment = '40 nM palbociclib';
        data(cond).positions_list = [13 14 15];
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
data(cond).all_area_measurements = [];
data(cond).all_size_measurements = [];
data(cond).all_area_measurements_avoiding_ends = [];
data(cond).all_size_measurements_avoiding_ends = [];
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
        end
    end
end

% Collate birth sizes, G1/S sizes, G2/M sizes
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
                        
                        % Quality checks: if it has a complete cell cycle
                        % and is born smaller than a set maximum size, add
                        % it to the "good" list
                        if data(cond).position(pos).analysis(c).has_complete_cycle &&...
                                data(cond).position(pos).analysis(c).birth_size < analysis_parameters.max_birth_size;
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
                        end
                    end
                end
            end
        end
    end
end

% Collate cell cycle phase lengths
for cond = 1:num_conditions
    
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

save([expt_folder '\Data.mat'],'data');

%% Plot results

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


% Plot histograms and CDFs of birth sizes, cell cycle times, g1 lengths,
% g1s sizes, sg2 lengths
all_data_types_to_plot = {'Birth_sizes','Complete_cell_cycle_length','G1_length','G1S_size','SG2_length'};
all_cell_classes_to_plot = {'all','first_gen','second_gen','early','late'};
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




% Plot scatterplots
% For these scatterplots to work, it is crucial that the same quality
% control tests be applied to both axes (i.e., birth sizes and G1 lengths).
% Currently that means has_complete_cycle and
% birth_size_is_similar_to_sister.

all_data_types_to_plot = {'Birth_size_vs_G1_length','Birth_size_vs_SG2_length','Birth_size_vs_Complete_cycle_length',...
    'Birth_area_vs_G1_length','G1S_size_vs_SG2_length','Birth_size_vs_G1_growth','G1S_size_vs_SG2_growth'};
all_cell_classes_to_plot = {'all_good','first_gen_good','second_gen_good'};
all_plottypes = {'scatter_with_line'};

% all_data_types_to_plot = {'Birth_size_vs_G1_growth'};

for data_type_to_plot = all_data_types_to_plot
    for cell_class_to_plot = all_cell_classes_to_plot
        for plottype = all_plottypes
            for cond = 1:num_conditions
                
                is_there_something_to_plot = false;
                
                if strcmp(data_type_to_plot,'Birth_size_vs_G1_length')
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



% save([expt_folder '\data.mat'],'data')

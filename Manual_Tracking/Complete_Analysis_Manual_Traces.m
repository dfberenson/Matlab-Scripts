clear all
close all

%% Set parameters

folder = 'E:\Manually tracked measurements';
expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
expt_folder = [folder '\' expt_name];

num_conditions = 2;

% Set analysis parameters
analysis_parameters = struct;
analysis_parameters.framerate = 1/6;
analysis_parameters.num_first_frames_to_avoid = 5;
analysis_parameters.num_last_frames_to_avoid = 10;
analysis_parameters.birthsize_measuring_frames = [6:12];
analysis_parameters.min_cycle_duration_hours = 5;
analysis_parameters.geminin_threshold = 100000;
analysis_parameters.smoothing_param = 5;
analysis_parameters.max_fraction_diff_from_sibling_mean = 0.2;

%% Gather data

% Create data structure
for cond = 1:num_conditions
    if cond == 1
        data(cond).treatment = 'PBS';
        data(cond).positions_list = [1 2 3];
    elseif cond == 2
        data(cond).treatment = '40 nM palbociclib';
        data(cond).positions_list = [13 14 15];
    end
end

% Gather data for each position
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
    end
end

% Analyze tracking data for each position
for cond = 1:num_conditions
    for pos = data(cond).positions_list
        disp(['Analyzing tracking data for position ' num2str(pos) '.'])
        data(cond).position(pos).analysis =...
            analyze_tracking_data(data(cond).position(pos).tracking_measurements,...
            data(cond).position(pos).tree, analysis_parameters);
    end
end

%% Collate measurements

% Collate all area and size measurements for all cells across all
% timepoints into one giant list
data(cond).all_area_measurements = [];
data(cond).all_size_measurements = [];
data(cond).all_area_measurements_avoiding_ends = [];
data(cond).all_size_measurements_avoiding_ends = [];
        data(cond).all_instantaneous_g1_areas = [];
        data(cond).all_instantaneous_sg2_areas = [];
        data(cond).all_instantaneous_g1_sizes = [];
        data(cond).all_instantaneous_sg2_sizes = [];
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
            
            data(cond).all_instantaneous_g1_areas = [data(cond).all_instantaneous_g1_areas;...
                data(cond).position(pos).analysis(c).g1_areas];
             data(cond).all_instantaneous_sg2_areas = [data(cond).all_instantaneous_sg2_areas;...
                data(cond).position(pos).analysis(c).sg2_areas];
             data(cond).all_instantaneous_g1_sizes = [data(cond).all_instantaneous_g1_sizes;...
                data(cond).position(pos).analysis(c).g1_sizes];
             data(cond).all_instantaneous_sg2_sizes = [data(cond).all_instantaneous_sg2_sizes;...
                data(cond).position(pos).analysis(c).sg2_sizes];
        end
    end
end

% Collate birth sizes
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
    for pos = data(cond).positions_list
        for c = data(cond).position(pos).tracking_measurements.all_tracknums
            if data(cond).position(pos).analysis(c).is_born
                
                num_total_born_cells = num_total_born_cells + 1;
                
                % Compare birth sizes with sisters'
                thiscell_birth_size = data(cond).position(pos).analysis(c).birth_size;
                thiscell_mother = data(cond).position(pos).tree(c).mother_id;
                thiscell_and_sister = [data(cond).position(pos).tree(thiscell_mother).daughter1_id,...
                    data(cond).position(pos).tree(thiscell_mother).daughter2_id];
                if(length(unique(nonzeros(thiscell_and_sister))) ~= 2)
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
                        
                        % If it has a complete cell cycle in addition to
                        % having its sister check out, add it to the 'good'
                        % list
                        if data(cond).position(pos).analysis(c).has_complete_cycle
                            data(cond).all_good_birth_sizes = [data(cond).all_good_birth_sizes,...
                                data(cond).position(pos).analysis(c).birth_size];
                            if data(cond).position(pos).analysis(c).generation == 1
                                data(cond).first_gen_good_birth_sizes = [data(cond).first_gen_good_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            elseif data(cond).position(pos).analysis(c).generation == 2
                                data(cond).second_gen_good_birth_sizes = [data(cond).second_gen_good_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
                            elseif data(cond).position(pos).analysis(c).generation >= 3
                                data(cond).third_gen_and_beyond_good_birth_sizes = [data(cond).third_gen_and_beyond_good_birth_sizes,...
                                    data(cond).position(pos).analysis(c).birth_size];
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
                
                % Get cycle phase lengths only for cells that have passed
                % quality tests.
                if data(cond).position(pos).analysis(c).birth_size_is_similar_to_sister
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

save([expt_folder '\data.mat'],'data')

%% Plot results

figure_folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots';
figure_subfolder = [figure_folder '\' expt_name '\ManualTracking'];
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
% sg2 lengths
all_data_types_to_plot = {'Birth_sizes','Complete_cell_cycle_length','G1_length','SG2_length'};
all_cell_classes_to_plot = {'all','first_gen','second_gen'};
all_plottypes = {'histogram','cdf'};

% all_data_types_to_plot = {'G1 lengths'};

for data_type_to_plot = all_data_types_to_plot
    for cell_class_to_plot = all_cell_classes_to_plot
        for plottype = all_plottypes
            figure()
            hold on
            leg = cell(num_conditions,1);
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
                end
            end
            
            title(graph_title)
            xlabel(x_axis_label)
            ylabel(y_axis_label)
            legend(leg)
            hold off
            saveas(gcf, [figure_subfolder '\' data_type_to_plot{1} '_' cell_class_to_plot{1} '_' plottype{1} '.png']);
                
        end
    end
end

        
        

% Plot G1 length vs birth size
% For these scatterplots to work, it is crucial that the same quality
% control tests be applied to both axes (i.e., birth sizes and G1 lengths).
% Currently that means has_complete_cycle and
% birth_size_is_similar_to_sister.

all_data_types_to_plot = {'Birth_size_vs_G1_length','Birth_size_vs_SG2_length','Birth_size_vs_Complete_cycle_length'};
all_cell_classes_to_plot = {'all_good','first_gen_good','second_gen_good'};
all_plottypes = {'scatter_with_line'};

for data_type_to_plot = all_data_types_to_plot
    for cell_class_to_plot = all_cell_classes_to_plot
        for plottype = all_plottypes
            for cond = 1:num_conditions
                
                if strcmp(data_type_to_plot,'Birth_size_vs_G1_length')
                    x_axis_label = 'Birth size';
                    y_axis_label = 'G1 length (h)';
                    
                    if strcmp(cell_class_to_plot,'all_good')
                        data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).all_good_g1_lengths;
                        graph_title = [data(cond).treatment ', all cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'first_gen_good')
                        data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).first_gen_good_g1_lengths;
                        graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'second_gen_good')
                        data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).second_gen_good_g1_lengths;
                        graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                    end
                end
                
                if strcmp(data_type_to_plot,'Birth_size_vs_SG2_length')
                    x_axis_label = 'Birth size';
                    y_axis_label = 'S/G2/M length (h)';
                    
                    if strcmp(cell_class_to_plot,'all_good')
                        data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).all_good_sg2_lengths;
                        graph_title = [data(cond).treatment ', all cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'first_gen_good')
                        data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).first_gen_good_sg2_lengths;
                        graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'second_gen_good')
                        data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).second_gen_good_sg2_lengths;
                        graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                    end
                end
                
                if strcmp(data_type_to_plot,'Birth_size_vs_Complete_cycle_length')
                    x_axis_label = 'Birth size';
                    y_axis_label = 'Complete cycle length (h)';
                    
                    if strcmp(cell_class_to_plot,'all_good')
                        data_to_scatter(cond).x = data(cond).all_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).all_good_complete_cycle_lengths;
                        graph_title = [data(cond).treatment ', all cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'first_gen_good')
                        data_to_scatter(cond).x = data(cond).first_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).first_gen_good_complete_cycle_lengths;
                        graph_title = [data(cond).treatment ', first generation cells that complete cycle'];
                    elseif strcmp(cell_class_to_plot,'second_gen_good')
                        data_to_scatter(cond).x = data(cond).second_gen_good_birth_sizes;
                        data_to_scatter(cond).y = data(cond).second_gen_good_complete_cycle_lengths;
                        graph_title = [data(cond).treatment ', second generation cells that complete cycle'];
                    end
                end
                
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




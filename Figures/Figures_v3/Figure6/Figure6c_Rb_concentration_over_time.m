
clear all
close all

load('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Figures\MyColormap.mat')

load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')
framerate = 1/6;

cond = 1;

frame_numbers = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
frame_numbers_wrt_g1s = data(cond).all_individual_complete_traces_frame_indices_wrt_g1s;
nuclear_volumes = data(cond).all_individual_complete_traces_volumes;
ef1a_crimson_intensities = data(cond).all_individual_complete_traces_sizes;
rb_amounts = data(cond).all_individual_complete_traces_protein_amts;
rb_per_size = data(cond).all_individual_complete_traces_protein_per_size;
rb_per_volume = data(cond).all_individual_complete_traces_protein_per_volume;

birth_sizes = data(cond).all_good_birth_sizes;

% frame_numbers_wrt_g1s = data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s;
% nuclear_volumes = data(cond).all_individual_pass_g1s_traces_volumes;
% ef1a_crimson_intensities = data(cond).all_individual_pass_g1s_traces_sizes;
% rb_amounts = data(cond).all_individual_pass_g1s_traces_protein_amts;
% rb_per_size = data(cond).all_individual_pass_g1s_traces_protein_per_size;
% rb_per_volume = data(cond).all_individual_pass_g1s_traces_protein_per_volume;

frames_to_skip_at_start = 5;
frames_to_skip_at_end = 12;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_crimson_intensities));
num_traces = length(frame_numbers);

eliminate_zeros = true;
max_zeroes_to_allow = 20;
smooth_big_jumps = true;
windowsize = 9;
maxjump = 0.5;

sort_by_trace_length = true;
sort_by_birth_size = false;

show_all_plots = false;
show_figure_plots = true;

% Get maximum trace length
all_clean_trace_lengths = [];
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    all_clean_trace_lengths(trace) = length(thistrace_clean_framenumbers);
end

max_clean_trace_length = max(all_clean_trace_lengths);

if sort_by_trace_length
[~,order] = sort(all_clean_trace_lengths);
end
if sort_by_birth_size
    [~,order] = sort(birth_sizes);
end

g1s_aligned_matrix_width = 300;

frame_numbers_matrix = nan(num_traces,max_clean_trace_length);
frame_numbers_matrix_wrt_g1s = nan(num_traces,max_clean_trace_length);
nuclear_volumes_matrix = nan(num_traces,max_clean_trace_length);
crimson_matrix = nan(num_traces,max_clean_trace_length);
rb_amt_matrix = nan(num_traces,max_clean_trace_length);
rb_per_size_matrix = nan(num_traces,max_clean_trace_length);
rb_per_volume_matrix = nan(num_traces,max_clean_trace_length);

frame_numbers_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);
nuclear_volumes_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);
crimson_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);
rb_amt_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);
rb_per_size_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);
rb_per_volume_matrix_aligned_g1s = nan(num_traces,g1s_aligned_matrix_width);


for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_framenumbers_wrt_g1s = frame_numbers_wrt_g1s{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    thistrace_crimson = ef1a_crimson_intensities{trace};
    thistrace_rb_amt = rb_amounts{trace};
    thistrace_rb_per_size = rb_per_size{trace};
    thistrace_rb_per_volume = rb_per_volume{trace};
    
    thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_framenumbers_wrt_g1s = thistrace_framenumbers_wrt_g1s(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_crimson = thistrace_crimson(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_rb_amt = thistrace_rb_amt(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_rb_per_size = thistrace_rb_per_size(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_rb_per_volume = thistrace_rb_per_volume(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        
    for t = 1:length(thistrace_clean_framenumbers)
        if eliminate_zeros
            if thistrace_clean_nuclearvolumes(t) == 0
                if t == 1
                    thistrace_clean_nuclearvolumes(t) = thistrace_clean_nuclearvolumes(t+1);
                else
                    thistrace_clean_nuclearvolumes(t) = (thistrace_clean_nuclearvolumes(t-1) + thistrace_clean_nuclearvolumes(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_nuclearvolumes = movmedian(thistrace_clean_nuclearvolumes,windowsize);
            if abs(thistrace_clean_nuclearvolumes(t) - thistrace_clean_smooth_nuclearvolumes(t)) > maxjump*thistrace_clean_smooth_nuclearvolumes(t)
                thistrace_clean_nuclearvolumes(t) = thistrace_clean_smooth_nuclearvolumes(t);
            end
        end
    end
    
    for t = 1:length(thistrace_clean_framenumbers)
        if eliminate_zeros
            if thistrace_clean_crimson(t) == 0
                if t == 1
                    thistrace_clean_crimson(t) = thistrace_clean_crimson(t+1);
                else
                    thistrace_clean_crimson(t) = (thistrace_clean_crimson(t-1) + thistrace_clean_crimson(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_crimson = movmedian(thistrace_clean_crimson,windowsize);
            if abs(thistrace_clean_crimson(t) - thistrace_clean_smooth_crimson(t)) > maxjump*thistrace_clean_smooth_crimson(t)
                thistrace_clean_crimson(t) = thistrace_clean_smooth_crimson(t);
            end
        end
    end
    
    for t = 1:length(thistrace_clean_framenumbers)
        if eliminate_zeros
            if thistrace_clean_rb_amt(t) == 0
                if t == 1
                    thistrace_clean_rb_amt(t) = thistrace_clean_rb_amt(t+1);
                else
                    thistrace_clean_rb_amt(t) = (thistrace_clean_rb_amt(t-1) + thistrace_clean_rb_amt(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_rb_amt = movmedian(thistrace_clean_rb_amt,windowsize);
            if abs(thistrace_clean_rb_amt(t) - thistrace_clean_smooth_rb_amt(t)) > maxjump*thistrace_clean_smooth_rb_amt(t)
                thistrace_clean_rb_amt(t) = thistrace_clean_smooth_rb_amt(t);
            end
        end
        
        if eliminate_zeros
            if thistrace_clean_rb_per_size(t) == 0
                if t == 1
                    thistrace_clean_rb_per_size(t) = thistrace_clean_rb_per_size(t+1);
                else
                    thistrace_clean_rb_per_size(t) = (thistrace_clean_rb_per_size(t-1) + thistrace_clean_rb_per_size(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_rb_per_size = movmedian(thistrace_clean_rb_per_size,windowsize);
            if abs(thistrace_clean_rb_per_size(t) - thistrace_clean_smooth_rb_per_size(t)) > maxjump*thistrace_clean_smooth_rb_per_size(t)
                thistrace_clean_rb_per_size(t) = thistrace_clean_smooth_rb_per_size(t);
            end
        end
        
        if eliminate_zeros
            if thistrace_clean_rb_per_volume(t) == 0
                if t == 1
                    thistrace_clean_rb_per_volume(t) = thistrace_clean_rb_per_volume(t+1);
                else
                    thistrace_clean_rb_per_volume(t) = (thistrace_clean_rb_per_volume(t-1) + thistrace_clean_rb_per_volume(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_rb_per_volume = movmedian(thistrace_clean_rb_per_volume,windowsize);
            if abs(thistrace_clean_rb_per_volume(t) - thistrace_clean_smooth_rb_per_volume(t)) > maxjump*thistrace_clean_smooth_rb_per_volume(t)
                thistrace_clean_rb_per_volume(t) = thistrace_clean_smooth_rb_per_volume(t);
            end
        end
    end
            
        frame_numbers_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers;
        frame_numbers_matrix_wrt_g1s(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers_wrt_g1s;
        nuclear_volumes_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_nuclearvolumes;
        crimson_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_crimson;
        rb_amt_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_rb_amt;
        rb_per_size_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_rb_per_size;
        rb_per_volume_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_rb_per_volume;
        
        frame_numbers_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_framenumbers_wrt_g1s;
        nuclear_volumes_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_nuclearvolumes;
        crimson_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_crimson;
        rb_amt_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_rb_amt;
        rb_per_size_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_rb_per_size;
        rb_per_volume_matrix_aligned_g1s(trace,thistrace_clean_framenumbers_wrt_g1s + 200) = thistrace_clean_rb_per_volume;
    
        if length(thistrace_clean_nuclearvolumes(thistrace_clean_nuclearvolumes == 0)) > max_zeroes_to_allow
            bad_traces = [bad_traces trace];
        end
        
end

frame_numbers_matrix_sorted = frame_numbers_matrix(order,:);
frame_numbers_matrix_wrt_g1s_sorted = frame_numbers_matrix_wrt_g1s(order,:);
nuclear_volumes_matrix_sorted = nuclear_volumes_matrix(order,:);
crimson_matrix_sorted = crimson_matrix(order,:);
rb_amt_matrix_sorted = rb_amt_matrix(order,:);
rb_per_size_matrix_sorted = rb_per_size_matrix(order,:);
rb_per_volume_matrix_sorted = rb_per_volume_matrix(order,:);

is_in_g1_matrix = frame_numbers_matrix_wrt_g1s <= 0;
g1_frame_numbers_matrix = frame_numbers_matrix;
g1_nuclear_volumes_matrix = nuclear_volumes_matrix;
g1_crimson_matrix = crimson_matrix;
g1_rb_amt_matrix = rb_amt_matrix;
g1_rb_per_size_matrix = rb_per_size_matrix;
g1_rb_per_volume_matrix = rb_per_volume_matrix;

g1_frame_numbers_matrix(~is_in_g1_matrix) = nan;
g1_nuclear_volumes_matrix(~is_in_g1_matrix) = nan;
g1_crimson_matrix(~is_in_g1_matrix) = nan;
g1_rb_amt_matrix(~is_in_g1_matrix) = nan;
g1_rb_per_size_matrix(~is_in_g1_matrix) = nan;
g1_rb_per_volume_matrix(~is_in_g1_matrix) = nan;

num_g1_cells_by_timepoint = zeros(1,length(g1_frame_numbers_matrix));
for t = 1:length(num_g1_cells_by_timepoint)
    frame_nums_this_timepoint = g1_frame_numbers_matrix(:,t);
    num_g1_cells_by_timepoint(t) = length(frame_nums_this_timepoint(~isnan(frame_nums_this_timepoint)));
end

num_g1_cells_by_timepoint_aligned_g1s = zeros(1,g1s_aligned_matrix_width);
for t = 1:length(num_g1_cells_by_timepoint_aligned_g1s)
    frame_nums_this_timepoint = frame_numbers_matrix_aligned_g1s(:,t);
    num_g1_cells_by_timepoint_aligned_g1s(t) = length(frame_nums_this_timepoint(~isnan(frame_nums_this_timepoint)));
end

%% Plot cells relative to birth
if show_all_plots
    figure
    hold on
    box on
    cmap = winter(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            nuclear_volumes_matrix_sorted(trace,:)/mean(nuclear_volumes_matrix_sorted(~isnan(nuclear_volumes_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    plot((1:length(frame_numbers_matrix_sorted))*framerate,...
        nanmean(nuclear_volumes_matrix_sorted)/mean(nuclear_volumes_matrix_sorted(~isnan(nuclear_volumes_matrix_sorted))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    axis('square')
    xticks([0 10 20 30 40 50])
    yticks([0 3 6])
    
    
    figure
    hold on
    box on
    cmap = autumn(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            crimson_matrix_sorted(trace,:)/mean(crimson_matrix_sorted(~isnan(crimson_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    plot((1:length(frame_numbers_matrix_sorted))*framerate,...
        nanmean(crimson_matrix_sorted)/mean(crimson_matrix_sorted(~isnan(crimson_matrix_sorted))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('prEF1-mCherry-NLS intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    yticks([0 2 4])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            rb_amt_matrix_sorted(trace,:)/mean(rb_amt_matrix_sorted(~isnan(rb_amt_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    plot((1:length(frame_numbers_matrix_sorted))*framerate,...
        nanmean(rb_amt_matrix_sorted)/mean(rb_amt_matrix_sorted(~isnan(rb_amt_matrix_sorted))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('Rb intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    yticks([0 2 4])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            rb_per_size_matrix_sorted(trace,:)/mean(rb_per_size_matrix_sorted(~(isnan(rb_per_size_matrix_sorted) | isinf(rb_per_size_matrix_sorted)))),...
            'Color',cmap(trace,:))
    end
    plot((1:length(frame_numbers_matrix_sorted))*framerate,...
        nanmean(rb_per_size_matrix_sorted)/mean(rb_per_size_matrix_sorted(~isnan(rb_per_size_matrix_sorted))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    axis('square')
    xticks([0 10 20 30 40 50])
    yticks([0 2 4])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            rb_per_volume_matrix_sorted(trace,:)/mean(rb_per_volume_matrix_sorted(~(isnan(rb_per_volume_matrix_sorted) | isinf(rb_per_volume_matrix_sorted)))),...
            'Color',cmap(trace,:))
    end
    plot((1:length(frame_numbers_matrix_sorted))*framerate,...
        nanmean(rb_per_volume_matrix_sorted)/mean(rb_per_volume_matrix_sorted(~isnan(rb_per_volume_matrix_sorted))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('[Rb] per volume')
    axis('square')
    xticks([0 10 20 30 40 50])
    yticks([0 2 4])
end

if show_all_plots
    figure
    h = pcolor(nuclear_volumes_matrix_sorted);
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('Nuclear volume, all cells')
    colorbar()
    
    figure
    h = pcolor(crimson_matrix_sorted);
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('prEF1a-E2-Crimson-NLS, all cells')
    colorbar()
    
    
    figure
    h = pcolor(rb_amt_matrix_sorted);
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('Rb-GFP amount, all cells')
    colorbar()
    
    
    figure
    h = pcolor(rb_per_size_matrix_sorted);
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('[Rb-GFP] per prEF1a-E2-Crimson-NLS, all cells')
    colorbar()
    
    
    figure
    h = pcolor(rb_per_volume_matrix_sorted);
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('[Rb-GFP] per nuclear volume, all cells')
    colorbar()
end


%% Plot cells relative to G1/S
if show_all_plots
    frames_to_plot = -30:3:30;
    
    figure
    hold on
    box on
    cmap = winter(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_wrt_g1s_sorted(trace,:)*framerate,...
            nuclear_volumes_matrix_sorted(trace,:)/mean(nuclear_volumes_matrix_sorted(~isnan(nuclear_volumes_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    xlabel('Time from G1/S (h)')
    ylabel('Nuclear volume')
    axis('square')
    yticks([0 3 6])
    
    figure
    hold on
    box on
    cmap = autumn(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_wrt_g1s_sorted(trace,:)*framerate,...
            crimson_matrix_sorted(trace,:)/mean(crimson_matrix_sorted(~isnan(crimson_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    xlabel('Time from G1/S (h)')
    ylabel('prEF1-mCherry-NLS intensity')
    axis('square')
    yticks([0 2 4])
    
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_wrt_g1s_sorted(trace,:)*framerate,...
            rb_amt_matrix_sorted(trace,:)/mean(rb_amt_matrix_sorted(~isnan(rb_amt_matrix_sorted))),...
            'Color',cmap(trace,:))
    end
    xlabel('Time from G1/S (h)')
    ylabel('Rb intensity')
    axis('square')
    yticks([0 2 4])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_wrt_g1s_sorted(trace,:)*framerate,...
            rb_per_size_matrix_sorted(trace,:)/mean(rb_per_size_matrix_sorted(~(isnan(rb_per_size_matrix_sorted) | isinf(rb_per_size_matrix_sorted)))),...
            'Color',cmap(trace,:))
    end
    xlabel('Time from G1/S (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    axis('square')
    yticks([0 2 4])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_wrt_g1s_sorted(trace,:)*framerate,...
            rb_per_volume_matrix_sorted(trace,:)/mean(rb_per_volume_matrix_sorted(~(isnan(rb_per_volume_matrix_sorted) | isinf(rb_per_volume_matrix_sorted)))),...
            'Color',cmap(trace,:))
    end
    xlabel('Time from G1/S (h)')
    ylabel('[Rb] per volume')
    axis('square')
    yticks([0 2 4])
end

if show_all_plots
    % Means and standard errors
    figure
    hold on
    box on
    shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
        nanmean(nuclear_volumes_matrix_aligned_g1s)/mean(nuclear_volumes_matrix_aligned_g1s(~isnan(nuclear_volumes_matrix_aligned_g1s))),...
        nanstd(nuclear_volumes_matrix_aligned_g1s)/mean(nuclear_volumes_matrix_aligned_g1s(~isnan(nuclear_volumes_matrix_aligned_g1s)))./sqrt(num_g1_cells_by_timepoint_aligned_g1s))
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    title('Traces normalized to overall data mean')
    axis([-inf inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
        nanmean(crimson_matrix_aligned_g1s)/mean(crimson_matrix_aligned_g1s(~isnan(crimson_matrix_aligned_g1s))),...
        nanstd(crimson_matrix_aligned_g1s)/mean(crimson_matrix_aligned_g1s(~isnan(crimson_matrix_aligned_g1s)))./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS intensity')
    title('Traces normalized to overall data mean')
    axis([-inf inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
        nanmean(rb_amt_matrix_aligned_g1s)/mean(rb_amt_matrix_aligned_g1s(~isnan(rb_amt_matrix_aligned_g1s))),...
        nanstd(rb_amt_matrix_aligned_g1s)/mean(rb_amt_matrix_aligned_g1s(~isnan(rb_amt_matrix_aligned_g1s)))./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb intensity')
    title('Traces normalized to overall data mean')
    axis([-inf inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
        nanmean(rb_per_size_matrix_aligned_g1s)/mean(rb_per_size_matrix_aligned_g1s(~isnan(rb_per_size_matrix_aligned_g1s))),...
        nanstd(rb_per_size_matrix_aligned_g1s)/mean(rb_per_size_matrix_aligned_g1s(~isnan(rb_per_size_matrix_aligned_g1s)))./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    title('Traces normalized to overall data mean')
    axis([-inf inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
        nanmean(rb_per_volume_matrix_aligned_g1s)/mean(rb_per_volume_matrix_aligned_g1s(~isnan(rb_per_volume_matrix_aligned_g1s))),...
        nanstd(rb_per_volume_matrix_aligned_g1s)/mean(rb_per_volume_matrix_aligned_g1s(~isnan(rb_per_volume_matrix_aligned_g1s)))./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per volume')
    title('Traces normalized to overall data mean')
    axis([-inf inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
end

%% Plot cells relative to birth but only cells in G1
if show_all_plots
    % Individual traces with means
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(g1_frame_numbers_matrix(trace,:)*framerate,...
            g1_nuclear_volumes_matrix(trace,:)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix))),...
            'Color',cmap(trace,:))
    end
    plot((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(g1_frame_numbers_matrix(trace,:)*framerate,...
            g1_crimson_matrix(trace,:)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix))),...
            'Color',cmap(trace,:))
    end
    plot((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('prEF1-mCherry-NLS intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(g1_frame_numbers_matrix(trace,:)*framerate,...
            g1_rb_amt_matrix(trace,:)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix))),...
            'Color',cmap(trace,:))
    end
    plot((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('Rb intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(g1_frame_numbers_matrix(trace,:)*framerate,...
            g1_rb_per_size_matrix(trace,:)/mean(g1_rb_per_size_matrix(~(isnan(g1_rb_per_size_matrix) | isinf(g1_rb_per_size_matrix)))),...
            'Color',cmap(trace,:))
    end
    plot((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix)/mean(g1_rb_per_size_matrix(~isnan(g1_rb_per_size_matrix))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    for trace = num_traces:-1:1
        plot(frame_numbers_matrix_sorted(trace,:)*framerate,...
            g1_rb_per_volume_matrix(trace,:)/mean(g1_rb_per_volume_matrix(~(isnan(g1_rb_per_volume_matrix) | isinf(g1_rb_per_volume_matrix)))),...
            'Color',cmap(trace,:))
    end
    plot((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix)/mean(g1_rb_per_volume_matrix(~isnan(g1_rb_per_volume_matrix))),'k','LineWidth',5)
    xlabel('Time from birth (h)')
    ylabel('[Rb] per volume')
    axis('square')
    xticks([0 10 20 30 40 50])
end

if show_all_plots
    % Means and standard deviations
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix))),...
        nanstd(g1_nuclear_volumes_matrix)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix))))
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix))),...
        nanstd(g1_crimson_matrix)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix))))
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix))),...
        nanstd(g1_rb_amt_matrix)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix))))
    xlabel('Time from birth (h)')
    ylabel('Rb intensity')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix)/mean(g1_rb_per_size_matrix(~isnan(g1_rb_per_size_matrix))),...
        nanstd(g1_rb_per_size_matrix)/mean(g1_rb_per_size_matrix(~isnan(g1_rb_per_size_matrix))))
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    axis('square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix)/mean(g1_rb_per_volume_matrix(~isnan(g1_rb_per_volume_matrix))),...
        nanstd(g1_rb_per_volume_matrix)/mean(g1_rb_per_volume_matrix(~isnan(g1_rb_per_volume_matrix))))
    xlabel('Time from birth (h)')
    ylabel('[Rb] per volume')
    axis('square')
    xticks([0 10 20 30 40 50])
end

% Means and standard errors
if show_all_plots
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix))),...
        nanstd(g1_nuclear_volumes_matrix)/mean(g1_nuclear_volumes_matrix(~isnan(g1_nuclear_volumes_matrix)))./sqrt(num_g1_cells_by_timepoint))
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix))),...
        nanstd(g1_crimson_matrix)/mean(g1_crimson_matrix(~isnan(g1_crimson_matrix)))./sqrt(num_g1_cells_by_timepoint),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS intensity')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix))),...
        nanstd(g1_rb_amt_matrix)/mean(g1_rb_amt_matrix(~isnan(g1_rb_amt_matrix)))./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb intensity')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix)/mean(g1_rb_per_size_matrix(~isnan(g1_rb_per_size_matrix))),...
        nanstd(g1_rb_per_size_matrix)/mean(g1_rb_per_size_matrix(~isnan(g1_rb_per_size_matrix)))./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    cmap = summer(num_traces);
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix)/mean(g1_rb_per_volume_matrix(~isnan(g1_rb_per_volume_matrix))),...
        nanstd(g1_rb_per_volume_matrix)/mean(g1_rb_per_volume_matrix(~isnan(g1_rb_per_volume_matrix)))./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per volume')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
end

if show_all_plots
    figure
    h = pcolor(g1_nuclear_volumes_matrix/nanmean(g1_nuclear_volumes_matrix(:)));
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('Nuclear volume')
    colorbar()
    
    figure
    h = pcolor(g1_crimson_matrix/nanmean(g1_crimson_matrix(:)));
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('prEF1a-E2-Crimson-NLS')
    colorbar()
    
    
    figure
    h = pcolor(g1_rb_amt_matrix/nanmean(g1_rb_amt_matrix(:)));
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('Rb-GFP amount')
    colorbar()
    
    
    figure
    h = pcolor(g1_rb_per_size_matrix/nanmean(g1_rb_per_size_matrix(:)));
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('[Rb-GFP] per prEF1a-E2-Crimson-NLS')
    colorbar()
    
    
    figure
    h = pcolor(g1_rb_per_volume_matrix/nanmean(g1_rb_per_volume_matrix(:)));
    colormap(mymap)
    shading flat
    xlabel('Time from birth (h)')
    title('[Rb-GFP] per nuclear volume')
    colorbar()
end

%% Normalize each trace to its own mean instead of the global mean

if show_figure_plots
    g1_nuclear_volumes_matrix_each_normalized = g1_nuclear_volumes_matrix;
    g1_crimson_matrix_each_normalized = g1_crimson_matrix;
    g1_rb_amt_matrix_each_normalized = g1_rb_amt_matrix;
    g1_rb_per_size_matrix_each_normalized = g1_rb_per_size_matrix;
    g1_rb_per_volume_matrix_each_normalized = g1_rb_per_volume_matrix;
    
    for trace = 1:num_traces
        g1_nuclear_volumes_matrix_each_normalized(trace,:) = g1_nuclear_volumes_matrix(trace,:)/nanmean(g1_nuclear_volumes_matrix(trace,:));
        g1_crimson_matrix_each_normalized(trace,:) = g1_crimson_matrix(trace,:)/nanmean(g1_crimson_matrix(trace,:));
        g1_rb_amt_matrix_each_normalized(trace,:) = g1_rb_amt_matrix(trace,:)/nanmean(g1_rb_amt_matrix(trace,:));
        g1_rb_per_size_matrix_each_normalized(trace,:) = g1_rb_per_size_matrix(trace,:)/nanmean(g1_rb_per_size_matrix(trace,:));
        g1_rb_per_volume_matrix_each_normalized(trace,:) = g1_rb_per_volume_matrix(trace,:)/nanmean(g1_rb_per_volume_matrix(trace,:));
    end
    
    % Normalized means and standard deviations
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix_each_normalized),...
        nanstd(g1_nuclear_volumes_matrix_each_normalized),'k')
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix_each_normalized),...
        nanstd(g1_crimson_matrix_each_normalized),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix_each_normalized),...
        nanstd(g1_rb_amt_matrix_each_normalized),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb amount')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix_each_normalized),...
        nanstd(g1_rb_per_size_matrix_each_normalized),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix_each_normalized),...
        nanstd(g1_rb_per_volume_matrix_each_normalized),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per nuclear volume')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix_each_normalized),...
        nanstd(g1_nuclear_volumes_matrix_each_normalized)./sqrt(num_g1_cells_by_timepoint),'k')
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix_each_normalized),...
        nanstd(g1_crimson_matrix_each_normalized)./sqrt(num_g1_cells_by_timepoint),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix_each_normalized),...
        nanstd(g1_rb_amt_matrix_each_normalized)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb amount')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix_each_normalized),...
        nanstd(g1_rb_per_size_matrix_each_normalized)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix_each_normalized),...
        nanstd(g1_rb_per_volume_matrix_each_normalized)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per nuclear volume')
    title('Each trace normalized to its mean, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
end

%% Normalize each trace to its own first value

if show_figure_plots
    g1_nuclear_volumes_matrix_each_normalized_to_birth = g1_nuclear_volumes_matrix;
    g1_crimson_matrix_each_normalized_to_birth = g1_crimson_matrix;
    g1_rb_amt_matrix_each_normalized_to_birth = g1_rb_amt_matrix;
    g1_rb_per_size_matrix_each_normalized_to_birth = g1_rb_per_size_matrix;
    g1_rb_per_volume_matrix_each_normalized_to_birth = g1_rb_per_volume_matrix;
    
    for trace = 1:num_traces
        g1_nuclear_volumes_matrix_each_normalized_to_birth(trace,:) = g1_nuclear_volumes_matrix(trace,:)/mean(g1_nuclear_volumes_matrix(trace,1:13));
        g1_crimson_matrix_each_normalized_to_birth(trace,:) = g1_crimson_matrix(trace,:)/median(g1_crimson_matrix(trace,1:13));
        g1_rb_amt_matrix_each_normalized_to_birth(trace,:) = g1_rb_amt_matrix(trace,:)/median(g1_rb_amt_matrix(trace,1:13));
        g1_rb_per_size_matrix_each_normalized_to_birth(trace,:) = g1_rb_per_size_matrix(trace,:)/median(g1_rb_per_size_matrix(trace,1:13));
        g1_rb_per_volume_matrix_each_normalized_to_birth(trace,:) = g1_rb_per_volume_matrix(trace,:)/median(g1_rb_per_volume_matrix(trace,1:13));
    end
    
    % Normalized means and standard deviations
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix_each_normalized_to_birth),...
        nanstd(g1_nuclear_volumes_matrix_each_normalized_to_birth),'k')
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix_each_normalized_to_birth),...
        nanstd(g1_crimson_matrix_each_normalized_to_birth),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_amt_matrix_each_normalized_to_birth),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb amount')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_per_size_matrix_each_normalized_to_birth),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_per_volume_matrix_each_normalized_to_birth),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per nuclear volume')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_nuclear_volumes_matrix_each_normalized_to_birth),...
        nanstd(g1_nuclear_volumes_matrix_each_normalized_to_birth)./sqrt(num_g1_cells_by_timepoint),'k')
    xlabel('Time from birth (h)')
    ylabel('Nuclear volume')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_crimson_matrix_each_normalized_to_birth),...
        nanstd(g1_crimson_matrix_each_normalized_to_birth)./sqrt(num_g1_cells_by_timepoint),'r')
    xlabel('Time from birth (h)')
    ylabel('prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_amt_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_amt_matrix_each_normalized_to_birth)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('Rb amount')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_size_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_per_size_matrix_each_normalized_to_birth)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
    
    figure
    hold on
    box on
    shadedErrorBar((nanmean(g1_frame_numbers_matrix))*framerate,...
        nanmean(g1_rb_per_volume_matrix_each_normalized_to_birth),...
        nanstd(g1_rb_per_volume_matrix_each_normalized_to_birth)./sqrt(num_g1_cells_by_timepoint),'g')
    xlabel('Time from birth (h)')
    ylabel('[Rb] per nuclear volume')
    title('Each trace normalized to its birth, G1 traces only')
    axis([0 inf 0 inf],'square')
    xticks([0 10 20 30 40 50])
end


%% Heatmaps aligned by G1/S
% The x-axis is 200 when it is really 0 hours from G1/S

if show_figure_plots
figure
h = pcolor(nuclear_volumes_matrix_aligned_g1s(order,:)/nanmean(nuclear_volumes_matrix_aligned_g1s(:)));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('Nuclear volume, normalized to overall mean')
colorbar()

figure
h = pcolor(crimson_matrix_aligned_g1s(order,:)/nanmean(crimson_matrix_aligned_g1s(:)));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
title('prEF1a-E2-Crimson-NLS, normalized to overall mean')
colorbar()

figure
h = pcolor(rb_amt_matrix_aligned_g1s(order,:)/nanmean(rb_amt_matrix_aligned_g1s(:)));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('Rb-GFP amount, normalized to overall mean')
colorbar()

% THIS IS THE ONE FOR THE PAPER
figure
h = pcolor(rb_per_size_matrix_aligned_g1s(order,:)/nanmean(rb_per_size_matrix_aligned_g1s(:)));
colormap(mymap)
shading flat
% xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
yticklabels([])
% title('[Rb-GFP] per prEF1a-E2-Crimson-NLS, normalized to overall mean')
axis('square')
line([200 200 0 60],'k')
clrbr = colorbar();
clrbr.Location = 'northoutside';

figure
h = pcolor(rb_per_volume_matrix_aligned_g1s(order,:)/nanmean(rb_per_volume_matrix_aligned_g1s(:)));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('[Rb-GFP] per nuclear volume, normalized to overall mean')
colorbar()
end

nuclear_volumes_matrix_aligned_g1s_each_normalized = nuclear_volumes_matrix_aligned_g1s;
crimson_matrix_aligned_g1s_each_normalized = crimson_matrix_aligned_g1s;
rb_amt_matrix_aligned_g1s_each_normalized = rb_amt_matrix_aligned_g1s;
rb_per_size_matrix_aligned_g1s_each_normalized = rb_per_size_matrix_aligned_g1s;
rb_per_volume_matrix_aligned_g1s_each_normalized = rb_per_volume_matrix_aligned_g1s;

for trace = 1:num_traces
    nuclear_volumes_matrix_aligned_g1s_each_normalized(trace,:) = nuclear_volumes_matrix_aligned_g1s(trace,:)/nanmean(nuclear_volumes_matrix_aligned_g1s(trace,:));
    crimson_matrix_aligned_g1s_each_normalized(trace,:) = crimson_matrix_aligned_g1s(trace,:)/nanmean(crimson_matrix_aligned_g1s(trace,:));
    rb_amt_matrix_aligned_g1s_each_normalized(trace,:) = rb_amt_matrix_aligned_g1s(trace,:)/nanmean(rb_amt_matrix_aligned_g1s(trace,:));
    rb_per_size_matrix_aligned_g1s_each_normalized(trace,:) = rb_per_size_matrix_aligned_g1s(trace,:)/nanmean(rb_per_size_matrix_aligned_g1s(trace,:));
    rb_per_volume_matrix_aligned_g1s_each_normalized(trace,:) = rb_per_volume_matrix_aligned_g1s(trace,:)/nanmean(rb_per_volume_matrix_aligned_g1s(trace,:));
end

if show_figure_plots
figure
h = pcolor(nuclear_volumes_matrix_aligned_g1s_each_normalized(order,:));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('Nuclear volume, each trace normalized to its mean')
colorbar()

figure
h = pcolor(crimson_matrix_aligned_g1s_each_normalized(order,:));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('prEF1a-E2-Crimson-NLS, each trace normalized to its mean')
colorbar()

figure
h = pcolor(rb_amt_matrix_aligned_g1s_each_normalized(order,:));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('Rb-GFP amount, each trace normalized to its mean')
colorbar()

figure
h = pcolor(rb_per_size_matrix_aligned_g1s_each_normalized(order,:));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('[Rb-GFP] per prEF1a-E2-Crimson-NLS, each trace normalized to its mean')
colorbar()

figure
h = pcolor(rb_per_volume_matrix_aligned_g1s_each_normalized(order,:));
colormap(mymap)
shading flat
xlabel('Time from G1/S (frames)')
xticks([20 80 140 200 260])
xticklabels([])
title('[Rb-GFP] per nuclear volume, each trace normalized to its mean')
colorbar()
end

if show_all_plots

% Means and standard errors
figure
hold on
box on
shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
    nanmean(nuclear_volumes_matrix_aligned_g1s_each_normalized),...
    nanstd(nuclear_volumes_matrix_aligned_g1s_each_normalized)./sqrt(num_g1_cells_by_timepoint_aligned_g1s))
xlabel('Time from G1/S (h)')
ylabel('Nuclear volume')
title('Each trace normalized to its mean')
axis([-inf inf 0 inf],'square')

figure
hold on
box on
shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
    nanmean(crimson_matrix_aligned_g1s_each_normalized),...
    nanstd(crimson_matrix_aligned_g1s_each_normalized)./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'r')
xlabel('Time from G1/S (h)')
ylabel('prEF1a-E2-Crimson-NLS intensity')
title('Each trace normalized to its mean')
axis([-inf inf 0 inf],'square')

figure
hold on
box on
shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
    nanmean(rb_amt_matrix_aligned_g1s_each_normalized),...
    nanstd(rb_amt_matrix_aligned_g1s_each_normalized)./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
xlabel('Time from G1/S (h)')
ylabel('Rb intensity')
title('Each trace normalized to its mean')
axis([-inf inf 0 inf],'square')

figure
hold on
box on
shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
    nanmean(rb_per_size_matrix_aligned_g1s_each_normalized),...
    nanstd(rb_per_size_matrix_aligned_g1s_each_normalized)./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
xlabel('Time from G1/S (h)')
ylabel('[Rb] per prEF1a-E2-Crimson-NLS')
title('Each trace normalized to its mean')
axis([-inf inf 0 inf],'square')

figure
hold on
box on
cmap = summer(num_traces);
shadedErrorBar((nanmean(frame_numbers_matrix_aligned_g1s))*framerate,...
    nanmean(rb_per_volume_matrix_aligned_g1s_each_normalized),...
    nanstd(rb_per_volume_matrix_aligned_g1s_each_normalized)./sqrt(num_g1_cells_by_timepoint_aligned_g1s),'g')
xlabel('Time from G1/S (h)')
ylabel('[Rb] per volume')
title('Each trace normalized to its mean')
axis([-inf inf 0 inf],'square')
end

clear all
close all


analysis_parameters.framerate = 1/6;
analysis_parameters.num_first_frames_to_avoid = 5;
analysis_parameters.num_last_frames_to_avoid = 10;
analysis_parameters.frames_to_check_nearby = 20;
analysis_parameters.min_frames_above = 15;
analysis_parameters.plot = false;
analysis_parameters.strategy = 'all';
analysis_parameters.min_total_trace_frames = 30;
analysis_parameters.geminin_threshold = 0.17;
analysis_parameters.g1s_quality_control = false;

for cell = [7 10 14 27 31 39]
    
    cell_str = ['Cell ' num2str(cell)];
    T = readtable('C:\Users\Skotheim Lab\Desktop\Tables\DFB_180803_HMEC_D5_1\ManualTracking\Individual_Manual_Traces_40 nM palbociclib.xlsx','Sheet',cell_str);
    num_channels = 3;
    trace_length = size(T,1) / (num_channels*2);
    
    clear traces
    clear smooth_traces
    clear concentration_trace
    clear smooth_concentration_trace
    
    % T should be constructed as follows:
    % Ch1 ROI
    % Ch1 bckgd
    % Ch2 ROI
    % Ch2 bckgd
    % Ch3 ROI
    % Ch3 bckgd
    
    % For this experiment:
    % DFB_180803_HMEC_D5_1_Pos13
    % Rb-GFP nucleus
    % Rb-GFP background
    % Geminin cell
    % Geminin background
    % EF1a-Crimson cell
    % EF1a-Crimson background
    
    for i = 1:trace_length
        for c = 1:num_channels
            traces(i,c) = T.IntDen(i*(num_channels*2) - (num_channels*2-c*2+1)) - T.IntDen(i*(num_channels*2) - (num_channels*2-c*2));
        end
    end
    
    figure('Name',cell_str)
    
    for c = 1:num_channels
        subplot(2,2,c)
        switch c
            case 1
                y_axis_label = 'Rb-Clover';
                color = 'g';
            case 2
                y_axis_label = 'Geminin-mCherry';
                color = 'm';
            case 3
                y_axis_label = 'EF1a-Crimson';
                color = 'r';
        end
        
        hold on
        plot(traces(:,c),color)
        smooth_traces(:,c) = movmedian(traces(:,c),11);
        plot(smooth_traces(:,c),'k')
        hold off
        axis([0 inf 0 max(traces(:,c))])
        xlabel('Frame')
        ylabel(y_axis_label)
    end
    
    g1s_frame = get_g1s_frame(traces(:,2) ./ traces(:,3), analysis_parameters);
    
    all_traces{cell} = traces;
    all_frames_wrt_birth{cell} = [1:trace_length]';
    all_frames_wrt_g1s{cell} = all_frames_wrt_birth{cell} - g1s_frame;
    
    subplot(2,2,4)
    hold on
    concentration_trace = smooth_traces(:,1) ./ smooth_traces(:,3);
    plot(concentration_trace)
    smooth_concentration_trace = movmedian(concentration_trace,11);
    plot(smooth_concentration_trace)
    hold off
    axis([0 inf 0 max(concentration_trace(:))])
    xlabel('Frame')
    ylabel('Rb per EF1a')
    title(num2str(g1s_frame))
    saveas(gcf,['C:\Users\Skotheim Lab\Desktop\Tables\DFB_180803_HMEC_D5_1\ManualTracking\Individual_Manual_Traces_40 nM palbociclib Cell ' num2str(cell) '.png']);
end

% Plot all traces aligned
figure('Name','Aligned wrt birth')
for c = 1:num_channels
    subplot(2,2,c)
    switch c
        case 1
            y_axis_label = 'Rb-Clover';
            color = 'g';
        case 2
            y_axis_label = 'Geminin-mCherry';
            color = 'm';
        case 3
            y_axis_label = 'EF1a-Crimson';
            color = 'r';
    end
    hold on
    for cell = [7 10 14 27 31 39]
        plot(all_frames_wrt_birth{cell},all_traces{cell}(:,c),color)
        xlabel('Frame wrt birth')
        ylabel(y_axis_label)
    end
end
subplot(2,2,4)
hold on
for cell = [7 10 14 27 31 39]
    plot(all_frames_wrt_birth{cell},all_traces{cell}(:,1) ./ all_traces{cell}(:,3),'k')
    xlabel('Frame wrt birth')
    ylabel('Rb per EF1a')
end
hold off
 
 
% Plot all traces aligned
figure('Name','Aligned wrt G1/S')
for c = 1:num_channels
    subplot(2,2,c)
    switch c
        case 1
            y_axis_label = 'Rb-Clover';
            color = 'g';
        case 2
            y_axis_label = 'Geminin-mCherry';
            color = 'm';
        case 3
            y_axis_label = 'EF1a-Crimson';
            color = 'r';
    end
    
    hold on
    for cell = [7 10 14 27 31 39]
        plot(all_frames_wrt_g1s{cell},all_traces{cell}(:,c),color)
        xlabel('Frame wrt birth')
        ylabel(y_axis_label)
    end
end
subplot(2,2,4)
hold on
for cell = [7 10 14 27 31 39]
    plot(all_frames_wrt_g1s{cell},all_traces{cell}(:,1) ./ all_traces{cell}(:,3),'k')
    xlabel('Frame wrt G1/S')
    ylabel('Rb per EF1a')
end
hold off


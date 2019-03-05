
clear all
close all

% load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
% load('E:\Manually tracked measurements\DFB_180822_HMEC_1GFiii_1\clicking_Data.mat')
load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')

framerate = 1/6;

cond = 1;

frame_numbers = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
frame_numbers_wrt_g1s = data(cond).all_individual_complete_traces_frame_indices_wrt_g1s;
nuclear_volumes = data(cond).all_individual_complete_traces_volumes;
ef1a_size_intensities = data(cond).all_individual_complete_traces_sizes;
geminin_intensities = data(cond).all_individual_complete_traces_geminin;
rb_intensities = data(cond).all_individual_complete_traces_protein_amts;

frames_to_skip_at_start = 5;
frames_to_skip_at_end = 10;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_size_intensities));
num_traces = length(frame_numbers);

eliminate_zeros = true;
smooth_big_jumps = true;
windowsize = 1;
maxjump = 0.5;

% tracenums_to_plot = [1 2 11 14 20 23 28 33 37 38 42 44 45 54 58];
tracenums_to_plot = [38 58];

% % Get maximum trace length
% all_clean_trace_lengths = [];
% for trace = 1:num_traces
%     thistrace_framenumbers = frame_numbers{trace};
%     thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
%     all_clean_trace_lengths(trace) = length(thistrace_clean_framenumbers);
% end
% [~,ascending_order_of_trace_lengths] = sort(all_clean_trace_lengths);
% max_clean_trace_length = max(all_clean_trace_lengths);
%
% frame_numbers_matrix = nan(num_traces,max_clean_trace_length);
% frame_numbers_matrix_wrt_g1s = nan(num_traces,max_clean_trace_length);
% nuclear_volumes_matrix = nan(num_traces,max_clean_trace_length);
% size_matrix = nan(num_traces,max_clean_trace_length);

for trace = 1:num_traces
    if any(trace == tracenums_to_plot)
        thistrace_framenumbers = frame_numbers{trace};
        thistrace_framenumbers_wrt_g1s = frame_numbers_wrt_g1s{trace};
        thistrace_nuclearvolumes = nuclear_volumes{trace};
        thistrace_size = ef1a_size_intensities{trace};
        thistrace_geminin = geminin_intensities{trace};
        thistrace_rb = rb_intensities{trace};
        
        thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        thistrace_clean_framenumbers_wrt_g1s = thistrace_framenumbers_wrt_g1s(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        thistrace_clean_size = thistrace_size(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        thistrace_clean_geminin = thistrace_geminin(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        thistrace_clean_rb = thistrace_rb(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
        
        thistrace_clean_nuclearvolumes = movmedian(thistrace_clean_nuclearvolumes,windowsize);
        thistrace_clean_size = movmedian(thistrace_clean_size,windowsize);
        thistrace_clean_geminin = movmedian(thistrace_clean_geminin,windowsize);
        thistrace_clean_rb = movmedian(thistrace_clean_rb,windowsize);
        
        num_segments = floor((length(thistrace_clean_framenumbers)) / 6) - 1;
%         
%         figure()
%         
%         %         nucvol_figure = figure()
%         subplot(2, 2, 1)
%         hold on
%         box on
%         plot(thistrace_clean_framenumbers*framerate,thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes),'-k')
%         axis([0 inf 0 inf],'square')
%         xticks([0 4 8 12])
%         yticks([0.5 1 1.5])
%         xlabel('Time from birth (h)')
%         ylabel('Nuclear volume')
%         
%         %         size_figure = figure()
%         subplot(2, 2, 2)
%         hold on
%         box on
%         plot(thistrace_clean_framenumbers*framerate,thistrace_clean_size/mean(thistrace_clean_size),'-r')
%         axis([0 inf 0 inf],'square')
%         xticks([0 4 8 12])
%         yticks([0.5 1 1.5])
%         xlabel('Time from birth (h)')
%         ylabel('prEF1-mCherry-NLS intensity')
%         
%         %         geminin_figure = figure()
%         subplot(2, 2, 3)
%         hold on
%         box on
%         plot(thistrace_clean_framenumbers*framerate,thistrace_clean_geminin/mean(thistrace_clean_geminin),'-g')
%         axis([0 inf 0 inf],'square')
%         xticks([0 4 8 12])
%         yticks([0.5 1 1.5])
%         xlabel('Time from birth (h)')
%         ylabel('Geminin intensity')
%         
%         %         rb_figure = figure()
%         subplot(2, 2, 4)
%         hold on
%         box on
%         plot(thistrace_clean_framenumbers*framerate,thistrace_clean_rb/mean(thistrace_clean_rb),'-m')
%         axis([0 inf 0 inf],'square')
%         xticks([0 4 8 12])
%         yticks([0.5 1 1.5])
%         xlabel('Time from birth (h)')
%         ylabel('Rb-Clover intensity')
        
        figure
        hold on
        box on
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_size/mean(thistrace_clean_size),'-r')
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_geminin/mean(thistrace_clean_geminin),'-m')
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_rb/mean(thistrace_clean_rb),'-g')
        %         plot(thistrace_clean_framenumbers*framerate,thistrace_clean_rb ./ thistrace_clean_size,'-k')
        line([thistrace_clean_framenumbers(find(thistrace_clean_framenumbers_wrt_g1s == 0))*framerate thistrace_clean_framenumbers(find(thistrace_clean_framenumbers_wrt_g1s == 0))*framerate],...
            [0 2.5],'Color','k')
        axis([0 14 0 2.5],'square')
        xticks([0 4 8 12])
        yticks([0.5 1 1.5 2 2.5])
        xlabel('Time from birth (h)')
        ylabel('Fluorescence intensity')
        
        
        
    end
    %     for seg = 1:num_segments
    %         thissegment = 6*(seg - 1) + 1 : 6*(seg+1);
    %         thisseg_nuclearvolume_fit = polyfit(thistrace_clean_framenumbers(thissegment),thistrace_clean_nuclearvolumes(thissegment)/mean(thistrace_clean_nuclearvolumes),1);
    %         segment_nuclearvolume_fitted_line = polyval(thisseg_nuclearvolume_fit,thistrace_clean_framenumbers(thissegment));
    %         segment_nuclearvolume_residuals = thistrace_clean_nuclearvolumes(thissegment)/mean(thistrace_clean_nuclearvolumes) - segment_nuclearvolume_fitted_line;
    %         thistrace_nuclearvolume_residuals(seg,:) = segment_nuclearvolume_residuals;
    %
    %         thisseg_size_fit = polyfit(thistrace_clean_framenumbers(thissegment),thistrace_clean_size(thissegment)/mean(thistrace_clean_size),1);
    %         segment_size_fitted_line = polyval(thisseg_size_fit,thistrace_clean_framenumbers(thissegment));
    %         segment_size_residuals = thistrace_clean_size(thissegment)/mean(thistrace_clean_size) - segment_size_fitted_line;
    %         thistrace_size_residuals(seg,:) = segment_size_residuals;
    %
    %         if trace == tracenum_to_plot
    %             figure(nucvol_figure)
    %             plot(thistrace_clean_framenumbers(thissegment)*framerate,segment_nuclearvolume_fitted_line,'--b')
    %             figure(size_figure)
    %             plot(thistrace_clean_framenumbers(thissegment)*framerate,segment_size_fitted_line,'--m')
    %         end
    %
    %     end
    %     sum_squared_relative_residuals_nuclearvolume(trace) = sum(thistrace_nuclearvolume_residuals(:) .^ 2);
    %     sum_squared_relative_residuals_size(trace) = sum(thistrace_size_residuals(:) .^ 2);
    %
    %     sum_squared_relative_diff_nuclearvolume(trace) = sum(diff(thistrace_clean_nuclearvolumes / mean(thistrace_clean_nuclearvolumes)) .^2);
    %     sum_squared_relative_diff_size(trace) = sum(diff(thistrace_clean_size / mean(thistrace_clean_size)) .^2);
    %
    %     frame_numbers_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers;
    %     frame_numbers_matrix_wrt_g1s(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers_wrt_g1s;
    %     nuclear_volumes_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_nuclearvolumes;
    %     size_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_size;
end

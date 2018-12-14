
clear all
close all

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
framerate = 1/6;

cond = 1;

frame_numbers = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
nuclear_volumes = data(cond).all_individual_complete_traces_volumes;
ef1a_mcherry_intensities = data(cond).all_individual_complete_traces_sizes;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_mcherry_intensities));
num_traces = length(frame_numbers);

winter_cmap = winter(num_traces);
autumn_cmap = autumn(num_traces);

eliminate_zeros = true;
smooth_big_jumps = true;
windowsize = 9;
maxjump = 0.5;

tracenum_to_plot = 22;

% Plot nuclear volume traces over time
figure
hold on
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    assert(length(thistrace_framenumbers) == length(thistrace_nuclearvolumes))
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(6:end-12);
    
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
    
    fit1 = polyfit(thistrace_clean_framenumbers,thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes),1);
    fitted_line = polyval(fit1,thistrace_clean_framenumbers);
    
    %     figure,hold on
    %         plot(thistrace_clean_framenumbers*framerate,fitted_line)
    %     plot(thistrace_clean_framenumbers*framerate,thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes))
    
    residuals = thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes) - fitted_line;
    %     relative_residuals = residuals ./ fitted_line;
    %     sum_squared_relative_residuals_nuclearvolume(trace) = sum(relative_residuals .^ 2);
    sum_squared_relative_residuals_nuclearvolume(trace) = sum(residuals .^ 2);
    
    
    plot(thistrace_clean_framenumbers*framerate,thistrace_clean_nuclearvolumes,'Color',winter_cmap(trace,:))
    
    if trace == tracenum_to_plot
        trace_to_plot_clean_framenumbers = thistrace_clean_framenumbers;
        trace_to_plot_clean_scaled_nuclearvolumes = thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes);
        trace_to_plot_nuclearvolumes_fittedline = fitted_line;
    end
end
xlabel('Time relative to birth (h)')
ylabel('Nuclear volume')
hold off

% Plot mCherry traces over time
figure
hold on
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_mcherry = ef1a_mcherry_intensities{trace};
    assert(length(thistrace_framenumbers) == length(thistrace_mcherry))
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_mcherry = thistrace_mcherry(6:end-12);
    
    for t = 1:length(thistrace_clean_framenumbers)
        if eliminate_zeros
            if thistrace_clean_mcherry(t) == 0
                if t == 1
                    thistrace_clean_mcherry(t) = thistrace_clean_mcherry(t+1);
                else
                    thistrace_clean_mcherry(t) = (thistrace_clean_mcherry(t-1) + thistrace_clean_mcherry(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_mcherry = movmedian(thistrace_clean_mcherry,windowsize);
            if abs(thistrace_clean_mcherry(t) - thistrace_clean_smooth_mcherry(t)) > maxjump*thistrace_clean_smooth_mcherry(t)
                thistrace_clean_mcherry(t) = thistrace_clean_smooth_mcherry(t);
            end
        end
    end
    
    fit1 = polyfit(thistrace_clean_framenumbers,thistrace_clean_mcherry/mean(thistrace_clean_mcherry),1);
    fitted_line = polyval(fit1,thistrace_clean_framenumbers);
    
    %     plot(thistrace_clean_framenumbers*framerate,fitted_line)
    
    residuals = thistrace_clean_mcherry/mean(thistrace_clean_mcherry) - fitted_line;
    %     relative_residuals = residuals ./ fitted_line;
    %     sum_squared_relative_residuals_mcherry(trace) = sum(relative_residuals .^ 2);
    sum_squared_relative_residuals_mcherry(trace) = sum(residuals .^ 2);
    
    plot(thistrace_clean_framenumbers*framerate,thistrace_clean_mcherry,'Color',autumn_cmap(trace,:))
    
    if trace == tracenum_to_plot
        trace_to_plot_clean_scaled_mcherry = thistrace_clean_mcherry/mean(thistrace_clean_mcherry);
        trace_to_plot_mcherry_fittedline = fitted_line;
    end
end
xlabel('Time relative to birth (h)')
ylabel('prEF1a-mCherry-NLS intensity')
hold off

figure
hold on
plot(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_clean_scaled_nuclearvolumes,'k')
plot(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_nuclearvolumes_fittedline,'b')
xlabel('Time relative to birth (h)')
ylabel('Nuclear volume')
legend('Measured nuclear volume','Fitted line')
fitlm(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_clean_scaled_nuclearvolumes)

figure
hold on
plot(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_clean_scaled_mcherry,'r')
plot(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_mcherry_fittedline,'m')
xlabel('Time relative to birth (h)')
ylabel('prEF1a-mCherry-NLS intensity')
legend('Measured mCherry','Fitted line')
fitlm(trace_to_plot_clean_framenumbers*framerate,trace_to_plot_clean_scaled_mcherry)


% Sum of squared residuals is calculated by normalizing each clean trace to
% its mean, then fitting a line, then taking residuals, then summing their
% square, then averaging across all traces.

mean_sum_sq_rel_resids = [mean(sum_squared_relative_residuals_nuclearvolume) mean(sum_squared_relative_residuals_mcherry)];
stderr_sum_sq_rel_resids = [std(sum_squared_relative_residuals_nuclearvolume) std(sum_squared_relative_residuals_mcherry)] / sqrt(num_traces);
[h,p,ci,stats] = ttest2(sum_squared_relative_residuals_nuclearvolume,sum_squared_relative_residuals_mcherry)

figure
hold on
[bar,err] = barwitherr(stderr_sum_sq_rel_resids,mean_sum_sq_rel_resids,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 2.5 0 2])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1a-mCherry-NLS'})
ylabel('Sum of squared residuals')
hold off

birth_sizes = data(cond).all_good_birth_sizes;
g2m_sizes = data(cond).all_good_g2m_sizes;
relative_size_increase_wrt_birth = g2m_sizes ./ birth_sizes;

birth_volumes = data(cond).all_good_birth_areas .^ 1.5;
g2m_volumes = data(cond).all_good_g2m_areas .^ 1.5;
relative_volume_increase_wrt_birth = g2m_volumes ./ birth_volumes;

mean_increase_wrt_birth(1) = mean(relative_volume_increase_wrt_birth);
median_increase_wrt_birth(1) = median(relative_volume_increase_wrt_birth);
stdev_increase_wrt_birth(1) = std(relative_volume_increase_wrt_birth);
stderr_increase_wrt_birth(1) = std(relative_volume_increase_wrt_birth)/sqrt(length(relative_volume_increase_wrt_birth));
mean_increase_wrt_birth(2) = mean(relative_size_increase_wrt_birth);
median_increase_wrt_birth(2) = median(relative_size_increase_wrt_birth);
stdev_increase_wrt_birth(2) = std(relative_size_increase_wrt_birth);
stderr_increase_wrt_birth(2) = std(relative_size_increase_wrt_birth)/sqrt(length(relative_size_increase_wrt_birth));

figure
hold on
[bar,err] = barwitherr(stderr_increase_wrt_birth, median_increase_wrt_birth,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 2.5 0 3])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1a-mCherry-NLS'})
ylabel('Relative increase over cell cycle')
hold off

half_of_mother_premitotic_size = data(cond).all_good_half_of_mother_premitotic_size_with_daughter_g2m_size;
g2m_size_with_half_mother_premitotic_size = data(cond).all_good_g2m_sizes_with_measured_mother_premitotic_size;
relative_size_increase_wrt_half_premitotic = g2m_size_with_half_mother_premitotic_size ./ half_of_mother_premitotic_size;
good_size_indices = ~(isnan(relative_size_increase_wrt_half_premitotic) | isinf(relative_size_increase_wrt_half_premitotic));
half_of_mother_premitotic_volume = data(cond).all_good_half_of_mother_premitotic_area_with_daughter_g2m_area .^ 1.5;
g2m_volume_with_half_mother_premitotic_volume = data(cond).all_good_g2m_areas_with_measured_mother_premitotic_area .^ 1.5;
relative_volume_increase_wrt_half_premitotic = g2m_volume_with_half_mother_premitotic_volume ./ half_of_mother_premitotic_volume;
good_volume_indices = ~(isnan(relative_volume_increase_wrt_half_premitotic) | isinf(relative_volume_increase_wrt_half_premitotic));

mean_increase_wrt_half_premitotic(1) = mean(relative_volume_increase_wrt_half_premitotic(good_volume_indices));
median_increase_wrt_half_premitotic(1) = median(relative_volume_increase_wrt_half_premitotic(good_volume_indices));
stdev_increase_wrt_half_premitotic(1) = std(relative_volume_increase_wrt_half_premitotic(good_volume_indices));
stderr_increase_wrt_half_premitotic(1) = std(relative_volume_increase_wrt_half_premitotic(good_volume_indices))/sqrt(length(relative_volume_increase_wrt_half_premitotic(good_volume_indices)));
mean_increase_wrt_half_premitotic(2) = mean(relative_size_increase_wrt_half_premitotic(good_size_indices));
median_increase_wrt_half_premitotic(2) = median(relative_size_increase_wrt_half_premitotic(good_size_indices));
stdev_increase_wrt_half_premitotic(2) = std(relative_size_increase_wrt_half_premitotic(good_size_indices));
stderr_increase_wrt_half_premitotic(2) = std(relative_size_increase_wrt_half_premitotic(good_size_indices))/sqrt(length(relative_size_increase_wrt_half_premitotic(good_size_indices)));

figure
hold on
[bar,err] = barwitherr(stderr_increase_wrt_half_premitotic, median_increase_wrt_half_premitotic,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 2.5 0 4])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1a-mCherry-NLS'})
ylabel('Relative increase over cell cycle, compared to half of mother')
hold off


mean(g2m_sizes) / mean(birth_sizes)
mean(g2m_volumes) / mean(birth_volumes)
median(g2m_sizes) / median(birth_sizes)
median(g2m_volumes) / median(birth_volumes)

mean(g2m_sizes ./ birth_sizes)
mean(g2m_volumes ./ birth_volumes)

median(g2m_sizes ./ birth_sizes)
median(g2m_volumes ./ birth_volumes)

std(g2m_sizes ./ birth_sizes)
std(g2m_volumes ./ birth_volumes)
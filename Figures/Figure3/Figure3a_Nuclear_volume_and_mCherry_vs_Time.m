
clear all
close all

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
framerate = 1/6;


frame_numbers = data(1).all_individual_complete_traces_frame_indices_wrt_birth;
nuclear_volumes = data(1).all_individual_complete_traces_volumes;
ef1a_mcherry_intensities = data(1).all_individual_complete_traces_sizes;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_mcherry_intensities));
num_traces = length(frame_numbers);

winter_cmap = winter(num_traces);
autumn_cmap = autumn(num_traces);

figure
hold on
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    assert(length(thistrace_framenumbers) == length(thistrace_nuclearvolumes))
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(6:end-12);
    
    for t = 1:length(thistrace_clean_framenumbers)
        if thistrace_clean_nuclearvolumes(t) == 0
            if t == 1
                thistrace_clean_nuclearvolumes(t) = thistrace_clean_nuclearvolumes(t+1);
            else
                thistrace_clean_nuclearvolumes(t) = (thistrace_clean_nuclearvolumes(t-1) + thistrace_clean_nuclearvolumes(t+1))/2;
            end
        end
    end
    
    fit1 = polyfit(thistrace_clean_framenumbers,thistrace_clean_nuclearvolumes,1);
    fitted_line = polyval(fit1,thistrace_clean_framenumbers);
    
%     plot(thistrace_clean_framenumbers*framerate,fitted_line)
    
    residuals = thistrace_clean_nuclearvolumes - fitted_line;
    relative_residuals = residuals ./ fitted_line;
    sum_squared_relative_residuals_nuclearvolume(trace) = sum(relative_residuals .^ 2);
    
    plot(thistrace_clean_framenumbers*framerate,thistrace_clean_nuclearvolumes,'Color',winter_cmap(trace,:))
end
xlabel('Time relative to birth (h)')
ylabel('Nuclear volume')
hold off

figure
hold on

for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_mcherry = ef1a_mcherry_intensities{trace};
    assert(length(thistrace_framenumbers) == length(thistrace_mcherry))
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_mcherry = thistrace_mcherry(6:end-12);
    
    for t = 1:length(thistrace_clean_framenumbers)
        if thistrace_clean_mcherry(t) == 0
            if t == 1
                thistrace_clean_mcherry(t) = thistrace_clean_mcherry(t+1);
            else
                thistrace_clean_mcherry(t) = (thistrace_clean_mcherry(t-1) + thistrace_clean_mcherry(t+1))/2;
            end
        end
    end
    
    fit1 = polyfit(thistrace_clean_framenumbers,thistrace_clean_mcherry,1);
    fitted_line = polyval(fit1,thistrace_clean_framenumbers);
    
%     plot(thistrace_clean_framenumbers*framerate,fitted_line)
    
    residuals = thistrace_clean_mcherry - fitted_line;
    relative_residuals = residuals ./ fitted_line;
    sum_squared_relative_residuals_mcherry(trace) = sum(relative_residuals .^ 2);
    
    plot(thistrace_clean_framenumbers*framerate,thistrace_clean_mcherry,'Color',autumn_cmap(trace,:))
end
xlabel('Time relative to birth (h)')
ylabel('prEF1a-mCherry-NLS intensity')
hold off

mean_sum_sq_rel_resids = [mean(sum_squared_relative_residuals_nuclearvolume) mean(sum_squared_relative_residuals_mcherry)];
stderr_sum_sq_rel_resids = [std(sum_squared_relative_residuals_nuclearvolume) std(sum_squared_relative_residuals_mcherry)] / sqrt(num_traces);

figure
hold on
[bar,err] = barwitherr(stderr_sum_sq_rel_resids,mean_sum_sq_rel_resids,'k')
bar.FaceColor = 'k'
err.LineWidth = 2
err.CapSize = 40
axis([0.5 2.5 0 5])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1a-mCherry-NLS'})
ylabel('Sum of squared normalized residuals')
hold off

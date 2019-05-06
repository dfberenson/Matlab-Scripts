
clear all
close all

load('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Figures\MyColormap.mat')

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
% load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')
framerate = 1/6;

cond = 1;

frame_numbers = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
frame_numbers_wrt_g1s = data(cond).all_individual_complete_traces_frame_indices_wrt_g1s;
% nuclear_volumes = data(cond).all_individual_complete_traces_areas;
nuclear_volumes = data(cond).all_individual_complete_traces_volumes;
ef1a_mcherry_intensities = data(cond).all_individual_complete_traces_sizes;
geminin_intensities = data(cond).all_individual_complete_traces_geminin;

frames_to_skip_at_start = 5;
frames_to_skip_at_end = 10;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_mcherry_intensities));
num_traces = length(frame_numbers);

eliminate_zeros = true;
smooth_big_jumps = true;
windowsize = 9;
maxjump = 0.5;

tracenum_to_plot = 13;
% This is overall trace number 31 from position 1
plot_wrt_g1s = false;
plot_discrete_derivatives = false;

% Get maximum trace length
all_clean_trace_lengths = [];
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    all_clean_trace_lengths(trace) = length(thistrace_clean_framenumbers);
end
[~,ascending_order_of_trace_lengths] = sort(all_clean_trace_lengths);
max_clean_trace_length = max(all_clean_trace_lengths);

frame_numbers_matrix = nan(num_traces,max_clean_trace_length);
frame_numbers_matrix_wrt_g1s = nan(num_traces,max_clean_trace_length);
nuclear_volumes_matrix = nan(num_traces,max_clean_trace_length);
mcherry_matrix = nan(num_traces,max_clean_trace_length);
geminin_matrix = nan(num_traces,max_clean_trace_length);

for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_framenumbers_wrt_g1s = frame_numbers_wrt_g1s{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    thistrace_mcherry = ef1a_mcherry_intensities{trace};
    thistrace_geminin = geminin_intensities{trace};
    
    thistrace_clean_framenumbers = thistrace_framenumbers(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_framenumbers_wrt_g1s = thistrace_framenumbers_wrt_g1s(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_mcherry = thistrace_mcherry(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    thistrace_clean_geminin = thistrace_geminin(frames_to_skip_at_start+1:end-frames_to_skip_at_end);
    
    for t = 1:length(thistrace_clean_framenumbers)
        if eliminate_zeros
            if thistrace_clean_nuclearvolumes(t) == 0
                if t == 1
                    thistrace_clean_nuclearvolumes(t) = thistrace_clean_nuclearvolumes(t+1);
                elseif t == length(thistrace_clean_framenumbers)
                    thistrace_clean_nuclearvolumes(t) = thistrace_clean_nuclearvolumes(t-1)'
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
            if thistrace_clean_mcherry(t) == 0
                if t == 1
                    thistrace_clean_mcherry(t) = thistrace_clean_mcherry(t+1);
                elseif t == length(thistrace_clean_framenumbers)
                    thistrace_clean_mcherry(t) = thistrace_clean_mcherry(t-1)'
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
    
    num_segments = floor((length(thistrace_clean_framenumbers)) / 6);
    if trace == tracenum_to_plot
        
        timepoints_to_plot = thistrace_clean_framenumbers*framerate;
        nuclearvolumes_to_plot = thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes);
        mcherry_to_plot = thistrace_clean_mcherry/mean(thistrace_clean_mcherry);
        geminin_to_plot = thistrace_clean_geminin/mean(thistrace_clean_geminin);
        
        nucvol_figure = figure()
        hold on
        box on
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_nuclearvolumes/mean(thistrace_clean_nuclearvolumes),'-k')
        axis([0 14 0 2],'square')
        xticks([0 4 8 12])
        yticks([0 0.5 1 1.5 2])
        xlabel('Time from birth (h)')
        ylabel('Nuclear volume')
        
        mcherry_figure = figure()
        hold on
        box on
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_mcherry/mean(thistrace_clean_mcherry),'-r')
        axis([0 14 0 2],'square')
        xticks([0 4 8 12])
        yticks([0 0.5 1 1.5 2])
        xlabel('Time from birth (h)')
        ylabel('prEF1-mCherry-NLS intensity')
        
        geminin_figure = figure()
        hold on
        box on
        plot(thistrace_clean_framenumbers*framerate,thistrace_clean_geminin/mean(thistrace_clean_geminin),'-g')
                axis([0 14 -2 2],'square')
        xticks([0 4 8 12])
        yticks([0 0.5 1 1.5 2])
        xlabel('Time from birth (h)')
        ylabel('Geminin intensity')
                
    end
    for seg = 1:num_segments
        thissegment = (seg - 1)/framerate + 1 : min((seg+1)/framerate, length(thistrace_clean_framenumbers));
        
        thisseg_nuclearvolume_fit = polyfit(thistrace_clean_framenumbers(thissegment),thistrace_clean_nuclearvolumes(thissegment)/mean(thistrace_clean_nuclearvolumes),1);
        segment_nuclearvolume_fitted_line = polyval(thisseg_nuclearvolume_fit,thistrace_clean_framenumbers(thissegment));
        segment_nuclearvolume_residuals = thistrace_clean_nuclearvolumes(thissegment)/mean(thistrace_clean_nuclearvolumes) - segment_nuclearvolume_fitted_line;
        if length(segment_nuclearvolume_residuals) < 2/framerate
            segment_nuclearvolume_residuals(length(segment_nuclearvolume_residuals) + 1 : 2/framerate) = 0;
        end
        thistrace_nuclearvolume_residuals(seg,:) = segment_nuclearvolume_residuals;
        
        
        thisseg_mcherry_fit = polyfit(thistrace_clean_framenumbers(thissegment),thistrace_clean_mcherry(thissegment)/mean(thistrace_clean_mcherry),1);
        segment_mcherry_fitted_line = polyval(thisseg_mcherry_fit,thistrace_clean_framenumbers(thissegment));
        segment_mcherry_residuals = thistrace_clean_mcherry(thissegment)/mean(thistrace_clean_mcherry) - segment_mcherry_fitted_line;
        if length(segment_mcherry_residuals) < 2/framerate
            segment_mcherry_residuals(length(segment_mcherry_residuals) + 1 : 2/framerate) = 0;
        end
        thistrace_mcherry_residuals(seg,:) = segment_mcherry_residuals;
        
        if trace == tracenum_to_plot
            figure(nucvol_figure)
            plot(thistrace_clean_framenumbers(thissegment)*framerate,segment_nuclearvolume_fitted_line,'--b')
            figure(mcherry_figure)
            plot(thistrace_clean_framenumbers(thissegment)*framerate,segment_mcherry_fitted_line,'--m')
        end
        
    end
    sum_squared_relative_residuals_nuclearvolume(trace) = sum(thistrace_nuclearvolume_residuals(:) .^ 2);
    sum_squared_relative_residuals_mcherry(trace) = sum(thistrace_mcherry_residuals(:) .^ 2);
    
    sum_squared_relative_diff_nuclearvolume(trace) = sum(diff(thistrace_clean_nuclearvolumes / mean(thistrace_clean_nuclearvolumes)) .^2);
    sum_squared_relative_diff_mcherry(trace) = sum(diff(thistrace_clean_mcherry / mean(thistrace_clean_mcherry)) .^2);
    
    frame_numbers_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers;
    frame_numbers_matrix_wrt_g1s(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_framenumbers_wrt_g1s;
    nuclear_volumes_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_nuclearvolumes;
    mcherry_matrix(trace,thistrace_clean_framenumbers - frames_to_skip_at_start) = thistrace_clean_mcherry;
end

frame_numbers_matrix_sorted_by_length = frame_numbers_matrix(ascending_order_of_trace_lengths,:);
frame_numbers_matrix_wrt_g1s_sorted_by_length = frame_numbers_matrix_wrt_g1s(ascending_order_of_trace_lengths,:);

% Plot cells relative to birth

nuclear_volumes_matrix_sorted_by_length = nuclear_volumes_matrix(ascending_order_of_trace_lengths,:);
figure
% h = pcolor(nuclear_volumes_matrix_sorted_by_length ./ nuclear_volumes_matrix_sorted_by_length(:,1));
h = pcolor(nuclear_volumes_matrix_sorted_by_length ./ mean(nuclear_volumes_matrix_sorted_by_length(~isnan(nuclear_volumes_matrix_sorted_by_length))));
colormap(mymap)
shading flat
axis('square')
xticks([0 60 120 180 240])
xticklabels([])
yticklabels([])
% xlabel('Time from birth (h)')
% title('Nuclear volume')
colorbar

mcherry_matrix_sorted_by_length = mcherry_matrix(ascending_order_of_trace_lengths,:);
figure
% h = pcolor(mcherry_matrix_sorted_by_length ./ mcherry_matrix_sorted_by_length(:,1));
h = pcolor(mcherry_matrix_sorted_by_length /mean(mcherry_matrix_sorted_by_length(~isnan(mcherry_matrix_sorted_by_length))));
colormap(mymap)
shading flat
axis('square')
xticks([0 60 120 180 240])
xticklabels([])
yticklabels([])
% xlabel('Time from birth (h)')
% title('prEF1a-mCherry-NLS')
colorbar

figure
hold on
box on
cmap = winter(num_traces);
for trace = num_traces:-1:1
    plot(frame_numbers_matrix_sorted_by_length(trace,:)*framerate,...
        nuclear_volumes_matrix_sorted_by_length(trace,:)/mean(nuclear_volumes_matrix_sorted_by_length(~isnan(nuclear_volumes_matrix_sorted_by_length))),...
        'Color',cmap(trace,:))
end
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
    plot(frame_numbers_matrix_sorted_by_length(trace,:)*framerate,...
        mcherry_matrix_sorted_by_length(trace,:)/mean(mcherry_matrix_sorted_by_length(~isnan(mcherry_matrix_sorted_by_length))),...
        'Color',cmap(trace,:))
end
xlabel('Time from birth (h)')
ylabel('prEF1-mCherry-NLS intensity')
axis('square')
xticks([0 10 20 30 40 50])
yticks([0 2 4])

% Sum of squared residuals is calculated by normalizing each clean trace to
% its mean, then fitting line segments, then taking residuals, then summing their
% square, then averaging across all traces.

mean_sum_sq_rel_resids = [mean(sum_squared_relative_residuals_nuclearvolume) mean(sum_squared_relative_residuals_mcherry)];
stderr_sum_sq_rel_resids = [std(sum_squared_relative_residuals_nuclearvolume) std(sum_squared_relative_residuals_mcherry)] / sqrt(num_traces);
[h,p,ci,stats] = ttest2(sum_squared_relative_residuals_nuclearvolume,sum_squared_relative_residuals_mcherry)

figure
hold on
box on
[bar,err] = barwitherr(stderr_sum_sq_rel_resids,mean_sum_sq_rel_resids,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 2.5 0 2],'square')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1-mCherry-NLS'})
ylabel('Sum of squared residuals')
yticks([0 1 2 3])
hold off


% 
% mean_sum_sq_diff = [mean(sum_squared_relative_diff_nuclearvolume) mean(sum_squared_relative_diff_mcherry)];
% stderr_sum_sq_diff = [std(sum_squared_relative_diff_nuclearvolume) std(sum_squared_relative_diff_mcherry)] / sqrt(num_traces);
% [h,p,ci,stats] = ttest2(sum_squared_relative_diff_nuclearvolume,sum_squared_relative_diff_mcherry)
% 
% figure
% hold on
% box on
% [bar,err] = barwitherr(stderr_sum_sq_diff,mean_sum_sq_diff,'k');
% bar.FaceColor = 'k';
% err.LineWidth = 2;
% err.CapSize = 40;
% axis([0.5 2.5 0 1],'square')
% set(gca, 'XTick', [1 2])
% set(gca, 'XTickLabel', {'Nuclear volume' 'prEF1-mCherry-NLS'})
% ylabel('Sum of squared discrete derivative')
% yticks([0 0.5 1])
% hold off




%% Plot cells relative to G1/S

if plot_wrt_g1s
frames_to_plot = -30:3:30;

figure
hold on
box on
cmap = winter(num_traces);
for trace = num_traces:-1:1
    plot(frame_numbers_matrix_wrt_g1s_sorted_by_length(trace,:)*framerate,...
        nuclear_volumes_matrix_sorted_by_length(trace,:)/mean(nuclear_volumes_matrix_sorted_by_length(~isnan(nuclear_volumes_matrix_sorted_by_length))),...
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
    plot(frame_numbers_matrix_wrt_g1s_sorted_by_length(trace,:)*framerate,...
        mcherry_matrix_sorted_by_length(trace,:)/mean(mcherry_matrix_sorted_by_length(~isnan(mcherry_matrix_sorted_by_length))),...
        'Color',cmap(trace,:))
end
xlabel('Time from G1/S (h)')
ylabel('prEF1-mCherry-NLS intensity')
axis('square')
yticks([0 2 4])


[means,stdevs,stderrs] = bindata(frame_numbers_matrix_wrt_g1s(~isnan(frame_numbers_matrix_wrt_g1s)),...
    nuclear_volumes_matrix(~isnan(nuclear_volumes_matrix)),frames_to_plot);
figure
hold on
box on
shadedErrorBar(frames_to_plot,means,stderrs)
axis('square')
xlabel('Frame relative to G1/S')
ylabel('Nuclear volume')

[means,stdevs,stderrs] = bindata(frame_numbers_matrix_wrt_g1s(~isnan(frame_numbers_matrix_wrt_g1s)),...
    mcherry_matrix(~isnan(mcherry_matrix)),frames_to_plot);
figure
hold on
box on
shadedErrorBar(frames_to_plot,means,stderrs,'r')
axis('square')
xlabel('Frame relative to G1/S')
ylabel('mCherry')

end
if plot_discrete_derivatives

differentiated_nuclear_volumes_matrix = diff(nuclear_volumes_matrix,1,2);
differentiated_nuclear_volumes_matrix = [differentiated_nuclear_volumes_matrix, nan(size(differentiated_nuclear_volumes_matrix,1),1)];

differentiated_mcherry_matrix = diff(mcherry_matrix,1,2);
differentiated_mcherry_matrix = [differentiated_mcherry_matrix, nan(size(differentiated_mcherry_matrix,1),1)];

[means,stdevs,stderrs] = bindata(frame_numbers_matrix_wrt_g1s(~isnan(frame_numbers_matrix_wrt_g1s)),...
    differentiated_nuclear_volumes_matrix(~isnan(frame_numbers_matrix_wrt_g1s)),frames_to_plot);
figure
hold on
box on
shadedErrorBar(frames_to_plot,means,stderrs)
axis('square')
xlabel('Frame relative to G1/S')
ylabel('Time derivative of nuclear volume')

[means,stdevs,stderrs] = bindata(frame_numbers_matrix_wrt_g1s(~isnan(frame_numbers_matrix_wrt_g1s)),...
    differentiated_mcherry_matrix(~isnan(frame_numbers_matrix_wrt_g1s)),frames_to_plot);
figure
hold on
box on
shadedErrorBar(frames_to_plot,means,stderrs,'r')
axis('square')
xlabel('Frame relative to G1/S')
ylabel('Time derivative of mCherry')

diff_mcherry_g1 = [];
diff_mcherry_sg2 = [];

for i = 1:size(frame_numbers_matrix_wrt_g1s,1)
    for j = 1:size(frame_numbers_matrix_wrt_g1s,2)
        if frame_numbers_matrix_wrt_g1s(i,j) < 0
            diff_mcherry_g1 = [diff_mcherry_g1; differentiated_mcherry_matrix(i,j)];
        elseif frame_numbers_matrix_wrt_g1s(i,j) > 0
            diff_mcherry_sg2 = [diff_mcherry_sg2; differentiated_mcherry_matrix(i,j)];
        end
    end
end

disp(['Mean time derivative of mCherry G1: ' num2str(nanmean(diff_mcherry_g1))])
disp(['Mean time derivative of mCherry during SG2: ' num2str(nanmean(diff_mcherry_sg2))])
end

%% Animate plots

% Nuclear volume animation
x = timepoints_to_plot;
y = nuclearvolumes_to_plot;

figure()
hold on
box on
plt = plot(x(1),y(1),'-k')
axis([0 14 0 2],'square')
xticks([0 4 8 12])
yticks([0 0.5 1 1.5 2])
xlabel('Time from birth (h)')
ylabel('Nuclear volume')
M(1) = getframe;

for k = 2:length(x)
    plt.XData = x(1:k);
    plt.YData = y(1:k);
    drawnow
    M(k) = getframe;
end

figure
box on
plot(x,y,'-k')
axis([0 14 0 2],'square')
xticks([0 4 8 12])
yticks([0 0.5 1 1.5 2])
xlabel('Time from birth (h)')
ylabel('Nuclear volume')
% movie(M)

V = VideoWriter('C:\Users\Skotheim Lab\Desktop\Movies\NucVol.avi','Motion JPEG AVI');
V.FrameRate = 5;
open(V);
writeVideo(V,M);
close(V);

% mCherry animation

x = timepoints_to_plot;
y = mcherry_to_plot;

figure()
hold on
box on
plt = plot(x(1),y(1),'-r')
axis([0 14 0 2],'square')
xticks([0 4 8 12])
yticks([0 0.5 1 1.5 2])
xlabel('Time from birth (h)')
ylabel('prEF1a-mCherry-NLS')
M(1) = getframe;

for k = 2:length(x)
    plt.XData = x(1:k);
    plt.YData = y(1:k);
    drawnow
    M(k) = getframe;
end

figure
box on
plot(x,y,'-r')
axis([0 14 0 2],'square')
xticks([0 4 8 12])
yticks([0 0.5 1 1.5 2])
xlabel('Time from birth (h)')
ylabel('prEF1a-mCherry-NLS')

V = VideoWriter('C:\Users\Skotheim Lab\Desktop\Movies\mCherry.avi','Motion JPEG AVI');
V.FrameRate = 5;
open(V);
writeVideo(V,M);
close(V);

% Geminin animation

x = timepoints_to_plot;
y = geminin_to_plot;

figure()
hold on
box on
plt = plot(x(1),y(1),'-g')
axis([0 14 -1 5],'square')
xticks([0 4 8 12])
yticks([-1 0 1 2 3 4 5])
xlabel('Time from birth (h)')
ylabel('Geminin')
M(1) = getframe;

for k = 2:length(x)
    plt.XData = x(1:k);
    plt.YData = y(1:k);
    drawnow
    M(k) = getframe;
end

figure
box on
axis([0 14 0 2],'square')
xticks([0 4 8 12])
yticks([0 0.5 1 1.5 2])
xlabel('Time from birth (h)')
ylabel('Geminin')
movie(M)

V = VideoWriter('C:\Users\Skotheim Lab\Desktop\Movies\Geminin.avi','Motion JPEG AVI');
V.FrameRate = 5;
open(V);
writeVideo(V,M);
close(V);
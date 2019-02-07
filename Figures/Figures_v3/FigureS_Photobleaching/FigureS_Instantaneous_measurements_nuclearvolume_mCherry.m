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

eliminate_zeros = true;
smooth_big_jumps = true;
windowsize = 9;
maxjump = 0.5;

figure
hold on
scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

figure
hold on
x = data(1).all_area_measurements_avoiding_ends .^ 1.5 / mean(data(1).all_area_measurements_avoiding_ends .^ 1.5);
y = data(1).all_size_measurements_avoiding_ends / mean(data(1).all_size_measurements_avoiding_ends);
[values, centers] = hist3([x(:) y(:)],[251 251]);
imagesc(centers{:}, values.')
colormap(flipud(gray))
colorbar
axis xy

randomfivepercent = rand(length(data(1).all_area_measurements_avoiding_ends),1) < 0.05;

figure
hold on
scatter(data(1).all_area_measurements_avoiding_ends(randomfivepercent) .^ 1.5, data(1).all_size_measurements_avoiding_ends(randomfivepercent),'.k')
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,10,data(1).whichcell_avoiding_ends)
colormap('colorcube')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

num_cells_to_plot = 15;
% cells_to_plot = randperm(max(data(1).whichcell_avoiding_ends),num_cells_to_plot);
cells_to_plot = [4,12,49,59,92,98,103,132,135,142,151,158,170,176,207];
indices_to_plot = ismember(data(1).whichcell_avoiding_ends,cells_to_plot);

renumbered_cells_to_plot = zeros(length(data(1).whichcell_avoiding_ends),1);

for c = 1:length(cells_to_plot)
    cellnum = cells_to_plot(c);
    renumbered_cells_to_plot(find(data(1).whichcell_avoiding_ends == cellnum)) = c;
end

figure
hold on
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
% scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
%     10,data(1).whichcell_avoiding_ends(indices_to_plot),'filled')
scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
    10,renumbered_cells_to_plot(indices_to_plot),'filled')
colormap('jet')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

fitlm(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends)


% Get maximum trace length
all_clean_trace_lengths = [];
for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    all_clean_trace_lengths(trace) = length(thistrace_clean_framenumbers);
end
[~,ascending_order_of_trace_lengths] = sort(all_clean_trace_lengths);
max_clean_trace_length = max(all_clean_trace_lengths);

frame_numbers_matrix = nan(num_traces,max_clean_trace_length);
nuclear_volumes_matrix = nan(num_traces,max_clean_trace_length);
mcherry_matrix = nan(num_traces,max_clean_trace_length);

for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    thistrace_mcherry = ef1a_mcherry_intensities{trace};
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(6:end-12);
    thistrace_clean_mcherry = thistrace_mcherry(6:end-12);

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
    
    frame_numbers_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_framenumbers;
    nuclear_volumes_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_nuclearvolumes;
    mcherry_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_mcherry;
end


for t = 1:max_clean_trace_length
    ft = fitlm(nuclear_volumes_matrix(:,t),mcherry_matrix(:,t));
    slopes_by_age(t) = ft.Coefficients.Estimate(2);
    r2_vals_by_age(t) = ft.Rsquared.Ordinary;
    num_cells_by_age(t) = sum(~isnan(frame_numbers_matrix(:,t)));
end

figure
box on
hold on
plot(5:length(slopes_by_age)+4,slopes_by_age)
axis([0 inf 0 inf],'square')
xlabel('Cell age')
ylabel('Slope of nuclear volume vs mCherry')
fitlm(1:length(slopes_by_age),slopes_by_age,'Weights',num_cells_by_age)

figure
box on
hold on
plot(5:length(slopes_by_age)+4,r2_vals_by_age)
axis([0 inf 0 1],'square')
xlabel('Cell age')
ylabel('R^2 value for nuclear volume vs mCherry')
fitlm(1:length(r2_vals_by_age),r2_vals_by_age,'Weights',num_cells_by_age)


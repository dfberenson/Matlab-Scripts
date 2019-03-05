clear all
close all

load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')
framerate = 1/6;

cond = 1;

frame_numbers = data(cond).all_individual_complete_traces_frame_indices_wrt_birth;
nuclear_volumes = data(cond).all_individual_complete_traces_volumes;
ef1a_mcrimson_intensities = data(cond).all_individual_complete_traces_sizes;

assert(length(frame_numbers) == length(nuclear_volumes) && length(frame_numbers) == length(ef1a_mcrimson_intensities));
num_traces = length(frame_numbers);

eliminate_zeros = true;
smooth_big_jumps = true;
windowsize = 9;
maxjump = 0.5;

figure
hold on
scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
xlabel('Nuclear volume')
ylabel('prEF1a-mCrimson-NLS')
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
ylabel('prEF1a-mCrimson-NLS')
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
ylabel('prEF1a-mCrimson-NLS')
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
mcrimson_matrix = nan(num_traces,max_clean_trace_length);

for trace = 1:num_traces
    thistrace_framenumbers = frame_numbers{trace};
    thistrace_nuclearvolumes = nuclear_volumes{trace};
    thistrace_mcrimson = ef1a_mcrimson_intensities{trace};
    
    thistrace_clean_framenumbers = thistrace_framenumbers(6:end-12);
    thistrace_clean_nuclearvolumes = thistrace_nuclearvolumes(6:end-12);
    thistrace_clean_mcrimson = thistrace_mcrimson(6:end-12);

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
            if thistrace_clean_mcrimson(t) == 0
                if t == 1
                    thistrace_clean_mcrimson(t) = thistrace_clean_mcrimson(t+1);
                else
                    thistrace_clean_mcrimson(t) = (thistrace_clean_mcrimson(t-1) + thistrace_clean_mcrimson(t+1))/2;
                end
            end
        end
        
        if smooth_big_jumps
            thistrace_clean_smooth_mcrimson = movmedian(thistrace_clean_mcrimson,windowsize);
            if abs(thistrace_clean_mcrimson(t) - thistrace_clean_smooth_mcrimson(t)) > maxjump*thistrace_clean_smooth_mcrimson(t)
                thistrace_clean_mcrimson(t) = thistrace_clean_smooth_mcrimson(t);
            end
        end
    end
    
    frame_numbers_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_framenumbers;
    nuclear_volumes_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_nuclearvolumes;
    mcrimson_matrix(trace,thistrace_clean_framenumbers - 5) = thistrace_clean_mcrimson;
end


% for t = 1:max_clean_trace_length

% Look only at timepoints for which we have at least 10 cells
for t = find(sum(~isnan(frame_numbers_matrix)) > 10)
    disp(['Analyzing timepoint ' num2str(t)])
    extant_cell_indices = find(~isnan(frame_numbers_matrix(:,t)));
    ft = fitlm(nuclear_volumes_matrix(extant_cell_indices,t),mcrimson_matrix(extant_cell_indices,t));
    slopes_by_age(t) = ft.Coefficients.Estimate(2);
    r2_vals_by_age(t) = ft.Rsquared.Ordinary;
    num_cells_by_age(t) = sum(~isnan(frame_numbers_matrix(:,t)));
    
    for strap = 1:1000
        resampled_cell_indices = datasample(extant_cell_indices,num_cells_by_age(t));
        resampled_ft = fitlm(nuclear_volumes_matrix(resampled_cell_indices,t),mcrimson_matrix(resampled_cell_indices,t));
        bootstrapped_slopes(strap) = resampled_ft.Coefficients.Estimate(2);
        bootstrapped_r2(strap) = resampled_ft.Rsquared.Ordinary;
    end
    
    slope_errors_by_age(:,t) = [prctile(bootstrapped_slopes,95) - slopes_by_age(t); slopes_by_age(t) - prctile(bootstrapped_slopes,5)];
    r2_errors_by_age(:,t) = [prctile(bootstrapped_r2,95) - r2_vals_by_age(t); r2_vals_by_age(t) - prctile(bootstrapped_r2,5)];
end

save('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\mCrimson_slopes_over_time.mat')

figure
box on
hold on
shadedErrorBar((5:length(slopes_by_age)+4)*framerate, movmedian(slopes_by_age,13),movmedian(slope_errors_by_age,13))
axis([0 inf -inf inf],'square')
xlabel('Cell age (h)')
ylabel('Slope of prEF1-mCrimson-NLS vs nuclear volume')
fitlm(1:length(slopes_by_age),slopes_by_age,'Weights',num_cells_by_age)

figure
box on
hold on
shadedErrorBar((5:length(r2_vals_by_age)+4)*framerate,movmedian(r2_vals_by_age,13),movmedian(r2_errors_by_age,13))
axis([0 inf 0 1],'square')
xlabel('Cell age (h)')
ylabel('R^2 value for prEF1a-mCrimson-NLS vs nuclear volume')
fitlm(1:length(r2_vals_by_age),r2_vals_by_age,'Weights',num_cells_by_age)


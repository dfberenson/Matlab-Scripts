
clear all
close all

% xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos19_manual_measurements.xlsx';
% all_cellnums = [1:5];
xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos21_manual_measurements.xlsx';
all_cellnums = [1:8];
% xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos11_manual_measurements.xlsx';
% all_cellnums = 1:4;

% xlsx_fpath_1 = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos19_manual_measurements.xlsx';
% all_cellnums_1 = [1:5];
% xlsx_fpath_2 = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos21_manual_measurements.xlsx';
% all_cellnums_2 = [1:10];

framerate = 1/12;
num_measurements_per_timepoint = 6;

whichcell = [];
collated_phase_net = [];
collated_nuclear_volume = [];
collated_mcherry_net = [];

volume_power = 1.5;

subtract_phase = true;

windowsize = 17;

for c = all_cellnums
    % Good cells are actually 3-10, but here we number them 1-8
    T{c} = readtable(xlsx_fpath,'Sheet',c+2);
    
    % for c = 1:length([all_cellnums_1 all_cellnums_2])
    %     if any(c == all_cellnums_1)
    %         T{c} = readtable(xlsx_fpath_1,'Sheet',c);
    %     else
    %         T{c} = readtable(xlsx_fpath_2,'Sheet',c-length(all_cellnums_1));
    %     end
    
    [len,~] = size(T{c});
    total_frames = len / num_measurements_per_timepoint;
    
    disp(['Cell ' num2str(c) ' has this many frames: ' num2str(total_frames)])
    
    cell_area = zeros(total_frames,1);
    nuclear_area = zeros(total_frames,1);
    phase_fore = zeros(total_frames,1);
    phase_back = zeros(total_frames,1);
    phase_net = zeros(total_frames,1);
    gfp_fore = zeros(total_frames,1);
    gfp_back = zeros(total_frames,1);
    gfp_net = zeros(total_frames,1);
    mcherry_fore = zeros(total_frames,1);
    mcherry_back = zeros(total_frames,1);
    mcherry_net = zeros(total_frames,1);
    
    for i = 1:total_frames
        cell_area(i) = T{c}{num_measurements_per_timepoint*i-5,'Area'};
        nuclear_area(i) = T{c}{num_measurements_per_timepoint*i-3,'Area'};
        phase_fore(i) = T{c}{num_measurements_per_timepoint*i-5,'RawIntDen'};
        phase_back(i) = T{c}{num_measurements_per_timepoint*i-4,'RawIntDen'};
        gfp_fore(i) = T{c}{num_measurements_per_timepoint*i-3,'RawIntDen'};
        gfp_back(i) = T{c}{num_measurements_per_timepoint*i-1,'RawIntDen'};
        mcherry_fore(i) = T{c}{num_measurements_per_timepoint*i-2,'RawIntDen'};
        mcherry_back(i) = T{c}{num_measurements_per_timepoint*i-0,'RawIntDen'};
    end
    
    % Eliminate saturated frames
    for i = 1:total_frames
        if T{c}{num_measurements_per_timepoint*i-5,'Mean'} == 65535
            phase_fore(i) = mean([phase_fore(i-1) phase_fore(i+1)]);
            phase_back(i) = mean([phase_back(i-1) phase_back(i+1)]);
        end
    end
    
    if subtract_phase
        phase_net = phase_fore - phase_back;
    else
        phase_net = phase_fore;
    end
    gfp_net = gfp_fore - gfp_back;
    mcherry_net = mcherry_fore - mcherry_back;
    
    whichcell = [whichcell; ones(total_frames,1)*c];
    collated_phase_net = [collated_phase_net; phase_net];
    collated_nuclear_volume = [collated_nuclear_volume; nuclear_area .^volume_power];
    collated_mcherry_net = [collated_mcherry_net; mcherry_net];
    
    normalized_nuclear_volume = nuclear_area .^volume_power / mean(nuclear_area .^volume_power);
    normalized_phase_net = phase_net / mean(phase_net);
    normalized_mcherry_net = mcherry_net / mean(mcherry_net);
    
    
    if c+2 == 6
        
        timepoints_to_plot = 1/framerate : total_frames - 2/framerate;
        
        raw_fig = figure();
        box on
        hold on
        %     plot(timepoints, cell_area / mean(cell_area))
        plot(timepoints_to_plot*framerate, normalized_nuclear_volume(timepoints_to_plot),'-b')
        plot(timepoints_to_plot*framerate, normalized_phase_net(timepoints_to_plot),'-k')
        %     plot(timepoints, gfp_net / mean(gfp_net))
        plot(timepoints_to_plot*framerate, normalized_mcherry_net(timepoints_to_plot),'-r')
        %         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Measurement')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
        movmedian_fig = figure();
        box on
        hold on
        %     plot(timepoints, cell_area / mean(cell_area))
        plot(timepoints_to_plot*framerate, movmedian(normalized_nuclear_volume(timepoints_to_plot),windowsize) ,'-b')
        plot(timepoints_to_plot*framerate, movmedian(normalized_phase_net(timepoints_to_plot),windowsize), '-k')
        %     plot(timepoints, gfp_net / mean(gfp_net))
        plot(timepoints_to_plot*framerate, movmedian(normalized_mcherry_net(timepoints_to_plot),windowsize),'-r')
        %         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Measurement')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
        spline_fig = figure();
        box on
        hold on
        nuclearvolume_fitted_spline = fit(timepoints_to_plot',normalized_nuclear_volume(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints_to_plot*framerate,feval(nuclearvolume_fitted_spline,timepoints_to_plot),'-b')
        phase_fitted_spline = fit(timepoints_to_plot',normalized_phase_net(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints_to_plot*framerate,feval(phase_fitted_spline,timepoints_to_plot),'-k')
        mcherry_fitted_spline = fit(timepoints_to_plot',normalized_mcherry_net(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints_to_plot*framerate,feval(mcherry_fitted_spline,timepoints_to_plot),'-r')
        %         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Normalized cell size metric')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
    end
    
    num_segments = floor(total_frames * framerate) - 1;
    for seg = 1:num_segments
        thissegment = ((seg - 1)/framerate + 1/framerate : (seg+1)/framerate)';
        thisseg_phase_fit = polyfit(thissegment,normalized_phase_net(thissegment),1);
        segment_phase_fitted_line = polyval(thisseg_phase_fit,thissegment);
        segment_phase_residuals = normalized_phase_net(thissegment) - segment_phase_fitted_line;
        thistrace_phase_residuals(seg,:) = segment_phase_residuals;
        
        thisseg_nuclearvolume_fit = polyfit(thissegment,normalized_nuclear_volume(thissegment),1);
        segment_nuclearvolume_fitted_line = polyval(thisseg_nuclearvolume_fit,thissegment);
        segment_nuclearvolume_residuals = normalized_nuclear_volume(thissegment) - segment_nuclearvolume_fitted_line;
        thistrace_nuclearvolume_residuals(seg,:) = segment_nuclearvolume_residuals;
        
        thisseg_mcherry_fit = polyfit(thissegment,normalized_mcherry_net(thissegment),1);
        segment_mcherry_fitted_line = polyval(thisseg_mcherry_fit,thissegment);
        segment_mcherry_residuals = normalized_mcherry_net(thissegment) - segment_mcherry_fitted_line;
        thistrace_mcherry_residuals(seg,:) = segment_mcherry_residuals;
        
        sum_squared_relative_residuals_phase(c) = sum(thistrace_phase_residuals(:) .^2);
        sum_squared_relative_residuals_nuclearvolume(c) = sum(thistrace_nuclearvolume_residuals(:) .^ 2);
        sum_squared_relative_residuals_mcherry(c) = sum(thistrace_mcherry_residuals(:) .^ 2);
        
        if c+2 == 6
            figure(raw_fig)
            hold on
            plot(thissegment*framerate,segment_nuclearvolume_fitted_line,'--b')
            plot(thissegment*framerate,segment_phase_fitted_line,'--k')
            plot(thissegment*framerate,segment_mcherry_fitted_line,'--r')
            hold off
        end
    end
    
end

mean_sum_sq_rel_resids = [mean(sum_squared_relative_residuals_phase) mean(sum_squared_relative_residuals_nuclearvolume) mean(sum_squared_relative_residuals_mcherry)];
stderr_sum_sq_rel_resids = [std(sum_squared_relative_residuals_phase) std(sum_squared_relative_residuals_nuclearvolume) std(sum_squared_relative_residuals_mcherry)] / sqrt(length(all_cellnums));

relative_residuals_matrix = [sum_squared_relative_residuals_phase; sum_squared_relative_residuals_nuclearvolume; sum_squared_relative_residuals_mcherry]';
[p,tbl,stats] = anova1(relative_residuals_matrix);
cmpr = multcompare(stats);


figure
hold on
box on
[bar,err] = barwitherr(stderr_sum_sq_rel_resids,mean_sum_sq_rel_resids,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 16],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'Dry mass' 'Nuclear volume' 'prEF1-mCherry-NLS'})
ylabel('Sum of squared residuals')
yticks([0 4 8 12 16])
hold off

% figure
% hold on
% plot(timepoints, normalized_nuclear_volume ./ normalized_phase_net, '-k')
% plot(timepoints, normalized_mcherry_net ./ normalized_phase_net, '-r')
% legend('Nuclear volume','prEF1a-mCherry-NLS')
% xlabel('Cell age (h)')
% ylabel('Ratio to dry mass')
% hold off


% Plot correlation of nuclear volume or mCherry with dry mass.
% Each dot is a single time measurement for a single cell.
% Dots can be colorized by what cell they come from.
figure
hold on
scatter(collated_phase_net / mean(collated_phase_net),collated_nuclear_volume / mean(collated_nuclear_volume), '.k')
% scatter(collated_phase_net / mean(collated_phase_net), collated_nuclear_volume / mean(collated_nuclear_volume), 100, whichcell, '.')
% colormap('winter')
xlabel('Dry mass')
ylabel('Nuclear volume')
axis([0 inf 0 inf])
hold off
fitlm(collated_nuclear_volume,collated_phase_net)

figure
hold on
scatter(collated_phase_net / mean(collated_phase_net), collated_mcherry_net / mean(collated_mcherry_net), '.k')
% scatter(collated_phase_net / mean(collated_phase_net), collated_mcherry_net / mean(collated_mcherry_net), 100, whichcell, '.')
% colormap('autumn')
xlabel('Dry mass')
ylabel('prEF1a-mCherry-NLS')
axis([0 inf 0 inf])
hold off
fitlm(collated_mcherry_net,collated_phase_net)


% Plot binned means and standard deviations
bincenters = linspace(min(collated_phase_net / mean(collated_phase_net)),max(collated_phase_net / mean(collated_phase_net)),20);

[means,stdevs,stderrs] = bindata(collated_phase_net / mean(collated_phase_net), collated_nuclear_volume / mean(collated_nuclear_volume), bincenters);
figure
box on
hold on
shadedErrorBar(bincenters,means,stdevs,'b',1)
shadedErrorBar(bincenters,means,stderrs,'k')
axis([0 inf 0 inf],'square')
xticks([0 1 2])
yticks([0 0.5 1 1.5])
xlabel('Dry mass')
ylabel('Nuclear volume')

[means,stdevs,stderrs] = bindata(collated_phase_net / mean(collated_phase_net), collated_mcherry_net / mean(collated_mcherry_net), bincenters);
figure
box on
hold on
shadedErrorBar(bincenters,means,stdevs,'m',1)
shadedErrorBar(bincenters,means,stderrs,'r')
axis([0 inf 0 inf],'square')
xticks([0 1 2])
yticks([0 0.5 1 1.5])
xlabel('Dry mass')
ylabel('prEF1a-mCherry-NLS')
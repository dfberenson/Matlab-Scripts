
clear all
close all

% xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos19_manual_measurements.xlsx';
% all_cellnums = [1:5];
xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos21_manual_measurements.xlsx';
all_cellnums = [1:10];

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

for c = all_cellnums
    T{c} = readtable(xlsx_fpath,'Sheet',c);
    
    % for c = 1:length([all_cellnums_1 all_cellnums_2])
    %     if any(c == all_cellnums_1)
    %         T{c} = readtable(xlsx_fpath_1,'Sheet',c);
    %     else
    %         T{c} = readtable(xlsx_fpath_2,'Sheet',c-length(all_cellnums_1));
    %     end
    
    [len,~] = size(T{c});
    total_frames = len / num_measurements_per_timepoint;
    timepoints = 0 : framerate : framerate * (total_frames-1);
    
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
    
    phase_net = phase_fore - phase_back;
    gfp_net = gfp_fore - gfp_back;
    mcherry_net = mcherry_fore - mcherry_back;
    
    whichcell = [whichcell; ones(total_frames,1)*c];
    collated_phase_net = [collated_phase_net; phase_net];
    collated_nuclear_volume = [collated_nuclear_volume; nuclear_area .^1.5];
    collated_mcherry_net = [collated_mcherry_net; mcherry_net];
    
    normalized_nuclear_volume = nuclear_area .^1.5 / median(nuclear_area .^1.5);
    normalized_phase_net = phase_net / median(phase_net);
    normalized_mcherry_net = mcherry_net / median(mcherry_net);
    
    %     if c == 5 || c == 6
    if c == 6
        
        timepoints_to_plot = 1/framerate : length(timepoints)-1/framerate;
        
        figure
        box on
        hold on
        %     plot(timepoints, cell_area / mean(cell_area))
        plot(timepoints(timepoints_to_plot), normalized_nuclear_volume(timepoints_to_plot),'-b')
        plot(timepoints(timepoints_to_plot), normalized_phase_net(timepoints_to_plot),'-k')
        %     plot(timepoints, gfp_net / mean(gfp_net))
        plot(timepoints(timepoints_to_plot), normalized_mcherry_net(timepoints_to_plot),'-r')
%         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Measurement')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
        figure
        box on
        hold on
        %     plot(timepoints, cell_area / mean(cell_area))
        plot(timepoints(timepoints_to_plot), movmedian(normalized_nuclear_volume(timepoints_to_plot),17) ,'-b')
        plot(timepoints(timepoints_to_plot), movmedian(normalized_phase_net(timepoints_to_plot),17), '-k')
        %     plot(timepoints, gfp_net / mean(gfp_net))
        plot(timepoints(timepoints_to_plot), movmedian(normalized_mcherry_net(timepoints_to_plot),17),'-r')
        %         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Measurement')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
        figure
        box on
        hold on
        nuclearvolume_fitted_spline = fit(timepoints(timepoints_to_plot)',normalized_nuclear_volume(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints(timepoints_to_plot),feval(nuclearvolume_fitted_spline,timepoints(timepoints_to_plot)),'-b')
        phase_fitted_spline = fit(timepoints(timepoints_to_plot)',normalized_phase_net(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints(timepoints_to_plot),feval(phase_fitted_spline,timepoints(timepoints_to_plot)),'-k')
        mcherry_fitted_spline = fit(timepoints(timepoints_to_plot)',normalized_mcherry_net(timepoints_to_plot),'smoothingspline','SmoothingParam',0.9);
        plot(timepoints(timepoints_to_plot),feval(mcherry_fitted_spline,timepoints(timepoints_to_plot)),'-r')
        %         legend('Nuclear volume','Dry mass','prEF1a-mCherry-NLS')
        xlabel('Time from birth (h)')
        ylabel('Measurement')
        axis([0 inf 0 inf],'square')
        xticks([0 10 20])
        yticks([0 0.5 1 1.5])
        hold off
        
        squared_changes_in_nuclear_volume = diff(normalized_nuclear_volume(timepoints_to_plot)).^2;
        squared_changes_in_phase_net = diff(normalized_phase_net(timepoints_to_plot)).^2;
        squared_changes_in_mcherry_net = diff(normalized_mcherry_net(timepoints_to_plot)).^2;
        
        mean_squared_changes_in_nuclear_volume = mean(squared_changes_in_nuclear_volume);
        mean_squared_changes_in_phase_net = mean(squared_changes_in_phase_net);
        mean_squared_changes_in_mcherry_net = mean(squared_changes_in_mcherry_net);
        
        stdev_squared_changes_in_nuclear_volume = std(squared_changes_in_nuclear_volume);
        stdev_squared_changes_in_phase_net = std(squared_changes_in_phase_net);
        stdev_squared_changes_in_mcherry_net = std(squared_changes_in_mcherry_net);
        
        stderr_squared_changes_in_nuclear_volume = std(squared_changes_in_nuclear_volume) / sqrt(length(squared_changes_in_nuclear_volume));
        stderr_squared_changes_in_phase_net = std(squared_changes_in_phase_net) / sqrt(length(squared_changes_in_phase_net));
        stderr_squared_changes_in_mcherry_net = std(squared_changes_in_mcherry_net) / sqrt(length(squared_changes_in_mcherry_net));
        
        figure
        box on
        hold on
        [bar,err] = barwitherr([stderr_squared_changes_in_nuclear_volume,stderr_squared_changes_in_phase_net,stderr_squared_changes_in_mcherry_net],...
            [mean_squared_changes_in_nuclear_volume,mean_squared_changes_in_phase_net,mean_squared_changes_in_mcherry_net],'k');
        bar.FaceColor = 'k';
        err.LineWidth = 2;
        err.CapSize = 40;
        axis([0.5 3.5 0 0.05],'square')
        yticks([0 0.02 0.04])
        set(gca, 'XTick', [1 2 3])
        set(gca, 'XTickLabel', {'Nuclear volume' 'Dry mass' 'prEF1a-mCherry-NLS'})
        set(gca, 'FontSize',16)
        ylabel('Average square of discrete derivative')
        hold off
        
    end
    
    
    
    % figure
    % hold on
    % plot(timepoints, normalized_nuclear_volume ./ normalized_phase_net, '-k')
    % plot(timepoints, normalized_mcherry_net ./ normalized_phase_net, '-r')
    % legend('Nuclear volume','prEF1a-mCherry-NLS')
    % xlabel('Cell age (h)')
    % ylabel('Ratio to dry mass')
    % hold off
    
end

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
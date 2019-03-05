
clear all
close all

framerate = 1/6;

smoothen = true;
must_be_born = false;
bin_by_ages = true;

show_all_plots = false;
show_some_plots = false;
numbins = 6;

% Binning is restricted to within these percentiles.
% Logistic fits are also restricted to these percentiles.
low_prctile = 5;
high_prctile = 95;

for cond = 1:2
    
    if cond == 1
        load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_PBS.mat')
        exptnums = 1:2;
    elseif cond == 2
        load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_40-50nM_palbo.mat')
        exptnums = 1:2;
    elseif cond == 3
        load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_100nM_palbo.mat')
        exptnums = 2:2;
    end
    
    expt_type{1} = 'PBS';
    expt_type{2} = '40-50nM palbo';
    expt_type{3} = '100nM palbo';
    
    % Gather data, using 'thisframes' offset
    
    for expt = exptnums
        if must_be_born == true

            frame_indices{expt} = logdata(expt).all_frame_indices_up_to_g1s_wrt_g1s_for_born_cells;
            
            ages{expt} = logdata(expt).all_ages_in_hours_up_to_g1s_for_born_cells;
            sizes{expt} = logdata(expt).all_sizes_up_to_g1s_for_born_cells;
            rb_per_size{expt} = logdata(expt).all_rb_per_size_up_to_g1s_for_born_cells;
            volumes{expt} = logdata(expt).all_volumes_up_to_g1s_for_born_cells;
            rb_per_volume{expt} = logdata(expt).all_rb_per_volume_up_to_g1s_for_born_cells;
            g1s_happens_here{expt} = logdata(expt).all_g1s_happens_here_for_born_cells;
            
        else
            frame_indices{expt} = logdata(expt).all_frame_indices_up_to_g1s_wrt_g1s;
            
            sizes{expt} = logdata(expt).all_sizes_up_to_g1s;
            rb_per_size{expt} = logdata(expt).all_rb_per_size_up_to_g1s;
            volumes{expt} = logdata(expt).all_volumes_up_to_g1s;
            rb_per_volume{expt} = logdata(expt).all_rb_per_volume_up_to_g1s;
            g1s_happens_here{expt} = logdata(expt).all_g1s_happens_here;
        end
    end
    
    collated_frame_indices = [];
    collated_sizes = [];
    collated_rb_per_size = [];
    collated_volumes = [];
    collated_rb_per_volume = [];
    collated_g1s_happens_here = [];
    if must_be_born
        collated_ages = [];
    end
    
    for expt = exptnums
        
        % Do not adjust for each expt's mean
        mean_sizes(expt) = 1;
        mean_rb_per_size(expt) = 1;
        mean_volumes(expt) = 1;
        mean_rb_per_volume(expt) = 1;
        
        %         % Adjust for each expt's mean
        %         mean_sizes(expt) = nanmean(sizes{expt});
        %         mean_rb_per_size(expt) = nanmean(rb_per_size{expt});
        %         mean_volumes(expt) = nanmean(volumes{expt});
        %         mean_rb_per_volume(expt) = nanmean(rb_per_volume{expt});
        
        collated_frame_indices = [collated_frame_indices; frame_indices{expt}];
        collated_sizes = [collated_sizes; sizes{expt}/mean_sizes(expt)];
        collated_rb_per_size = [collated_rb_per_size; rb_per_size{expt}/mean_rb_per_size(expt)];
        collated_volumes = [collated_volumes; volumes{expt}/mean_volumes(expt)];
        collated_rb_per_volume = [collated_rb_per_volume; rb_per_volume{expt}/mean_rb_per_volume(expt)];
        collated_g1s_happens_here = [collated_g1s_happens_here; g1s_happens_here{expt}];
        if must_be_born
            collated_ages = [collated_ages; ages{expt}];
        end
    end
    
    % Get indices of G1/S frames
    collated_g1s_indices = find(collated_g1s_happens_here);
    assert(isequal(collated_g1s_indices, find(collated_frame_indices == 0)))
    
    % Get indices of trace starts (i.e., one frame after each G1/S)
    collated_trace_start_indices = [1; collated_g1s_indices+1];
    collated_trace_start_indices(end) = [];
    
    % Count traces
    num_traces = length(collated_g1s_indices);
    
    for trace = 1:num_traces
        g1_lengths(trace) = length(collated_trace_start_indices(trace) : collated_g1s_indices(trace));
    end
    figure
    histogram(g1_lengths,20)
    title([expt_type{cond} ' G1 length, frames'])
    
    % Go back in time no more than the start of the shortest trace
    all_frames_before = 1:min(-collated_frame_indices(collated_trace_start_indices));
    
    % Only look at whole-hour offsets. Since frames_before = 1 really means
    % to check 'thisframe' and frames_before = 2 means to check
    % 'nextframe', we want to check frames_before = 2,8,14,20,etc.
%     all_frames_before = all_frames_before(mod(all_frames_before - 1, 1/framerate) == 0);
    
    % Algorithm to adjust for each frames_before offset
    for frames_before = all_frames_before
        
        % Get indices for the timepoint the right number of frames before each
        % G1/S. The minus-one offset makes it run from 0 to (max_length - 1)
        collated_g1s_indices_frames_before = collated_g1s_indices - (frames_before - 1);
        
        % Get the valid indices for all measurements up to and including the chosen
        % timepoint, but not timepoints afterward
        valid_indices_this_frames_before = [];
        for trace = 1:num_traces
            assert(collated_trace_start_indices(trace) < collated_g1s_indices_frames_before(trace))
            valid_indices_this_frames_before = [valid_indices_this_frames_before;...
                (collated_trace_start_indices(trace) : collated_g1s_indices_frames_before(trace))'];
            
            if smoothen
                % Smoothen traces into new giant vectors
                smoothened_collated_sizes = collated_sizes;
                smoothened_collated_rb_per_size = collated_rb_per_size;
                
                smoothened_collated_sizes(collated_trace_start_indices(trace) : collated_g1s_indices_frames_before(trace)) =...
                    smoothen_traces(collated_sizes(collated_trace_start_indices(trace) : collated_g1s_indices_frames_before(trace)));
                smoothened_collated_rb_per_size(collated_trace_start_indices(trace) : collated_g1s_indices_frames_before(trace)) =...
                    smoothen_traces(collated_rb_per_size(collated_trace_start_indices(trace) : collated_g1s_indices_frames_before(trace)));
            end
        end
        
        % Extract the measurements for the valid indices
        g1s_happens_here_this_frames_before = collated_g1s_happens_here;
        g1s_happens_here_this_frames_before(collated_g1s_indices_frames_before) = 1;
        g1s_happens_here_this_frames_before = g1s_happens_here_this_frames_before(valid_indices_this_frames_before);
        
        if ~smoothen
            sizes_this_frames_before = collated_sizes(valid_indices_this_frames_before);
            rb_per_size_this_frames_before = collated_rb_per_size(valid_indices_this_frames_before);
        elseif smoothen
            sizes_this_frames_before = smoothened_collated_sizes(valid_indices_this_frames_before);
            rb_per_size_this_frames_before = smoothened_collated_rb_per_size(valid_indices_this_frames_before);
        end
        
        if must_be_born
            ages_this_frames_before = collated_ages(valid_indices_this_frames_before);
        end
        
        if show_all_plots == true
            % figure()
            % subplot(1,2,1)
            bin_discrete_outcomes_with_logit(sizes_this_frames_before,g1s_happens_here_this_frames_before);
            xlabel('prEF1-mCrimson')
            ylabel('G1/S probability')
            % subplot(1,2,2)
            bin_discrete_outcomes_with_logit(rb_per_size_this_frames_before,g1s_happens_here_this_frames_before);
            xlabel('[Rb] per prEF1-mCrimson')
            ylabel('G1/S probability')
        end
        
        if must_be_born
            num_subplots = 3;
        else
            num_subplots = 2;
        end
        
        %         binsizes = linspace(min(sizes_this_frames_before) , max(sizes_this_frames_before) , numbins);
        binsizes = linspace(prctile(sizes_this_frames_before/nanmean(sizes_this_frames_before),low_prctile), prctile(sizes_this_frames_before/nanmean(sizes_this_frames_before),high_prctile), numbins);
        [means,error_below,error_above,Ns] = bootstrap(sizes_this_frames_before/nanmean(sizes_this_frames_before),g1s_happens_here_this_frames_before,binsizes);
        %         disp('Weighted linear fit to sizes')
        binfit_size = fitlm(binsizes,means,'Weights',Ns);
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
            figure()
            subplot(1,num_subplots,1)
            box on
            shadedErrorBar(binsizes,means,[error_above, error_below]');
            title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
            xlabel('prEF1-mCrimson')
            ylabel('G1/S probability')
            axis('square')
        end
        
        %         binsizes = linspace(min(rb_per_size_this_frames_before) , max(rb_per_size_this_frames_before) , numbins);
        binsizes = linspace(prctile(rb_per_size_this_frames_before/nanmean(rb_per_size_this_frames_before),low_prctile), prctile(rb_per_size_this_frames_before/nanmean(rb_per_size_this_frames_before),high_prctile), numbins);
        [means,error_below,error_above,Ns] = bootstrap(rb_per_size_this_frames_before/nanmean(rb_per_size_this_frames_before),g1s_happens_here_this_frames_before,binsizes);
        %         disp('Weighted linear fit to [Rb]')
        binfit_rb = fitlm(binsizes,means,'Weights',Ns);
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
            subplot(1,num_subplots,2)
            box on
            shadedErrorBar(binsizes,means,[error_above, error_below]');
            title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
            xlabel('[Rb] per prEF1-mCrimson')
            ylabel('G1/S probability')
            axis('square')
        end
        
        if must_be_born
            binsizes = linspace(0,max(ages_this_frames_before),numbins);
            [means,error_below,error_above,Ns] = bootstrap(ages_this_frames_before,g1s_happens_here_this_frames_before,binsizes);
            binfit_age = fitlm(binsizes,means,'Weights',Ns);
            if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
                subplot(1,num_subplots,3)
                box on
                shadedErrorBar(binsizes,means,[error_above, error_below]');
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
                xlabel('Cell age (h)')
                ylabel('G1/S probability')
                axis('square')
            end
            
            if bin_by_ages
                % For 40-50nM palbo, 120 mins before, we get a downward
                % slope by exactly copying the age range (2.3-7.4h) for the
                % row of bins on the 2D binnning that slopes down, but this
                % is not robust even to small changes in age range.
                age_bins = {[0 inf],[2.3 7.4],[7.4 12.6]};
                for age_bin = age_bins
                    age_bin_min = age_bin{1}(1);
                    age_bin_max = age_bin{1}(2);
                    these_age_indices_this_frames_before = age_bin_min <= ages_this_frames_before & ages_this_frames_before <= age_bin_max;
                    num_subplots = 2;
                    
                    if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
                        figure()
                        suptitle([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, restricted to cells in age window ' num2str(age_bin_min) ' to ' num2str(age_bin_max) ' h'])
                    end
                    
                    binsizes = linspace(prctile(sizes_this_frames_before(these_age_indices_this_frames_before),low_prctile), prctile(sizes_this_frames_before(these_age_indices_this_frames_before),high_prctile), numbins);
                    [means,error_below,error_above,Ns] = bootstrap(sizes_this_frames_before(these_age_indices_this_frames_before),g1s_happens_here_this_frames_before(these_age_indices_this_frames_before),binsizes);
                    if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
                        subplot(1,num_subplots,1)
                        box on
                        shadedErrorBar(binsizes,means,[error_above, error_below]');
                        title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
                        xlabel('prEF1-mCrimson')
                        ylabel('G1/S probability')
                        axis('square')
                    end
                    
                    binsizes = linspace(prctile(rb_per_size_this_frames_before(these_age_indices_this_frames_before),low_prctile), prctile(rb_per_size_this_frames_before(these_age_indices_this_frames_before),high_prctile), numbins);
                    [means,error_below,error_above,Ns] = bootstrap(rb_per_size_this_frames_before(these_age_indices_this_frames_before),g1s_happens_here_this_frames_before(these_age_indices_this_frames_before),binsizes);
                    if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
                        subplot(1,num_subplots,2)
                        box on
                        shadedErrorBar(binsizes,means,[error_above, error_below]');
                        title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
                        xlabel('[Rb] per prEF1-mCrimson')
                        ylabel('G1/S probability')
                        axis('square')
                    end
                end
            end
        end
        
        [size_b,size_dev,size_stats] = glmfit(sizes_this_frames_before/nanmean(sizes_this_frames_before),g1s_happens_here_this_frames_before,'binomial');
        [rb_b,rb_dev,rb_stats] = glmfit(rb_per_size_this_frames_before/nanmean(rb_per_size_this_frames_before),g1s_happens_here_this_frames_before,'binomial');
        
        size_slopes_logit(frames_before) = size_b(2);
        size_p_logit(frames_before) = size_stats.p(2);
        
        rb_slopes_logit(frames_before) = rb_b(2);
        rb_p_logit(frames_before) = rb_stats.p(2);
        
        size_slopes_bins(frames_before) = binfit_size.Coefficients.Estimate(2);
        size_p_bins(frames_before) = binfit_size.Coefficients.pValue(2);
        
        rb_slopes_bins(frames_before) = binfit_rb.Coefficients.Estimate(2);
        rb_p_bins(frames_before) = binfit_rb.Coefficients.pValue(2);
        
        if must_be_born
            [age_b,age_dev,age_stats] = glmfit(ages_this_frames_before,g1s_happens_here_this_frames_before,'binomial');
            
            age_slopes_logit(frames_before) = age_b(2);
            age_p_logit(frames_before) = age_stats.p(2);
            
            age_slopes_bins(frames_before) = binfit_age.Coefficients.Estimate(2);
            age_p_bins(frames_before) = binfit_age.Coefficients.pValue(2);
        end
        
        
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, 0:30))
            [fig, x_and_y_pvals] = two_variable_logistic_regression(sizes_this_frames_before, rb_per_size_this_frames_before, g1s_happens_here_this_frames_before,low_prctile,high_prctile,low_prctile,high_prctile);
            title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
            xlabel(['Size, p = ' num2str(x_and_y_pvals(1))])
            ylabel(['[Rb] concentration, p = ' num2str(x_and_y_pvals(2))])
            cb = colorbar;
            cb.Label.String = 'G1/S transition rate per 10 mins';
            
            [means, error_below, error_above, Ns, fig] = two_variable_binning(sizes_this_frames_before, rb_per_size_this_frames_before, g1s_happens_here_this_frames_before,low_prctile,high_prctile,low_prctile,high_prctile);
            title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
            xlabel(['Size'])
            ylabel(['[Rb] concentration'])
            cb = colorbar;
            cb.Label.String = 'G1/S transition rate per 10 mins';
            
            if must_be_born
                [fig, x_and_y_pvals] = two_variable_logistic_regression(ages_this_frames_before, sizes_this_frames_before, g1s_happens_here_this_frames_before, 0,high_prctile,low_prctile,high_prctile);
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
                xlabel(['Age, p = ' num2str(x_and_y_pvals(1))])
                ylabel(['Size, p = ' num2str(x_and_y_pvals(2))])
                cb = colorbar;
                cb.Label.String = 'G1/S transition rate per 10 mins';
                
                [means, error_below, error_above, Ns, fig] = two_variable_binning(ages_this_frames_before, sizes_this_frames_before, g1s_happens_here_this_frames_before, 0,high_prctile,low_prctile,high_prctile);
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
                xlabel(['Age'])
                ylabel(['Size'])
                cb = colorbar;
                cb.Label.String = 'G1/S transition rate per 10 mins';
                
                [fig, x_and_y_pvals] = two_variable_logistic_regression(ages_this_frames_before, rb_per_size_this_frames_before, g1s_happens_here_this_frames_before, 0,high_prctile,low_prctile,high_prctile);
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
                xlabel(['Age, p = ' num2str(x_and_y_pvals(1))])
                ylabel(['[Rb] concentration, p = ' num2str(x_and_y_pvals(2))])
                cb = colorbar;
                cb.Label.String = 'G1/S transition rate per 10 mins';
                
                [means, error_below, error_above, Ns, fig] = two_variable_binning(ages_this_frames_before, rb_per_size_this_frames_before, g1s_happens_here_this_frames_before, 0,high_prctile,low_prctile,high_prctile);
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
                xlabel(['Age'])
                ylabel(['[Rb] concentration'])
                cb = colorbar;
                cb.Label.String = 'G1/S transition rate per 10 mins';
                
                [fig, x_and_y_and_z_pvals] = three_variable_logistic_regression(ages_this_frames_before, sizes_this_frames_before, rb_per_size_this_frames_before, g1s_happens_here_this_frames_before);
                title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before, G1/S probability'])
                xlabel(['Age, p = ' num2str(x_and_y_and_z_pvals(1))])
                ylabel(['Size, p = ' num2str(x_and_y_and_z_pvals(2))])
                zlabel(['[Rb] concentration, p = ' num2str(x_and_y_and_z_pvals(3))])
                cb = colorbar;
                cb.Label.String = 'G1/S transition rate per 10 mins';
            end
        end
        
    end
    
    figure
    suptitle(expt_type{cond})
    
    subplot(2,2,1)
    hold on
    yyaxis left
    plot(framerate*(all_frames_before-1),size_slopes_logit(all_frames_before))
    ylabel('Slope wrt size')
    yyaxis right
    plot(framerate*(all_frames_before-1),rb_slopes_logit(all_frames_before))
    ylabel('Slope wrt [Rb]')
    xlabel('Time before G1/S (h)')
    title('Logistic regression')
    
    subplot(2,2,3)
    hold on
    plot(framerate*(all_frames_before-1),log10(size_p_logit(all_frames_before)))
    plot(framerate*(all_frames_before-1),log10(rb_p_logit(all_frames_before)))
    xlabel('Time before G1/S (h)')
    ylabel('Log p-Value')
    title('Logistic regression')
    legend('Size','[Rb]')
    
    subplot(2,2,2)
    hold on
    yyaxis left
    plot(framerate*(all_frames_before-1),size_slopes_bins(all_frames_before))
    ylabel('Slope wrt size')
    yyaxis right
    plot(framerate*(all_frames_before-1),rb_slopes_bins(all_frames_before))
    ylabel('Slope wrt [Rb]')
    xlabel('Time before G1/S (h)')
    title('Linear regression to binned means')
    
    subplot(2,2,4)
    hold on
    plot(framerate*(all_frames_before-1),log10(size_p_bins(all_frames_before)))
    plot(framerate*(all_frames_before-1),log10(rb_p_bins(all_frames_before)))
    xlabel('Time before G1/S (h)')
    ylabel('Log p-Value')
    title('Linear regression to binned means')
    legend('Size','[Rb]')
    
    if must_be_born
        figure
        suptitle(expt_type{cond})
        
        subplot(2,2,1)
        hold on
        yyaxis left
        plot(framerate*(all_frames_before-1),size_slopes_logit(all_frames_before))
        ylabel('Slope wrt size')
        yyaxis right
        plot(framerate*(all_frames_before-1),age_slopes_logit(all_frames_before))
        ylabel('Slope wrt Age')
        xlabel('Time before G1/S (h)')
        title('Logistic regression')
        
        subplot(2,2,3)
        hold on
        plot(framerate*(all_frames_before-1),log10(size_p_logit(all_frames_before)))
        plot(framerate*(all_frames_before-1),log10(age_p_logit(all_frames_before)))
        xlabel('Time before G1/S (h)')
        ylabel('Log p-Value')
        title('Logistic regression')
        legend('Size','Age')
        
        subplot(2,2,2)
        hold on
        yyaxis left
        plot(framerate*(all_frames_before-1),size_slopes_bins(all_frames_before))
        ylabel('Slope wrt size')
        yyaxis right
        plot(framerate*(all_frames_before-1),age_slopes_bins(all_frames_before))
        ylabel('Slope wrt Age')
        xlabel('Time before G1/S (h)')
        title('Linear regression to binned means')
        
        subplot(2,2,4)
        hold on
        plot(framerate*(all_frames_before-1),log10(size_p_bins(all_frames_before)))
        plot(framerate*(all_frames_before-1),log10(age_p_bins(all_frames_before)))
        xlabel('Time before G1/S (h)')
        ylabel('Log p-Value')
        title('Linear regression to binned means')
        legend('Size','Age')
        
    end
    
    figure
    hold on
    box on
    plot(framerate*(all_frames_before-1),log10(size_p_logit(all_frames_before)),'-k')
    axis('square')
    xlabel('Time before G1/S (h)')
    ylabel('Log p-Value')
    
    figure
    hold on
    box on
    plot(framerate*(all_frames_before-1),log10(size_p_logit(all_frames_before)))
    plot(framerate*(all_frames_before-1),log10(rb_p_logit(all_frames_before)))
    axis('square')
    xlabel('Time before G1/S (h)')
    ylabel('Log p-Value')
    title('Logistic regression')
    legend('Size','[Rb]')
    
    figure
    hold on
    plot(collated_sizes,'b')
    plot([collated_g1s_happens_here]*5*10^5,'m')
    
end


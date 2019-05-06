
clear all
close all

framerate = 1/6;

smoothen = true;
must_be_born = false;
bin_by_ages = true;

show_all_plots = false;
show_some_plots = true;
% The flatness at low [Rb] values disappears if we look at 13 frames before
% rather than 1 frame before
% frame_to_show = 1;
frame_to_show = 13;
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
    
    %     % Do not normalize to overall mean
    %     mean_overall_sizes = 1;
    %     mean_overall_rb_per_size = 1;
    %     mean_overall_volumes = 1;
    %     mean_overall_rb_per_volume = 1;
    
    % Normalize to overall mean
    mean_overall_sizes = nanmean(collated_sizes);
    mean_overall_rb_per_size = nanmean(collated_rb_per_size);
    mean_overall_volumes = nanmean(collated_volumes);
    mean_overall_rb_per_volume = nanmean(collated_rb_per_volume);
    
    collated_sizes = collated_sizes/mean_overall_sizes;
    collated_rb_per_size = collated_rb_per_size/mean_overall_rb_per_size;
    collated_volumes = collated_volumes/mean_overall_volumes;
    collated_rb_per_volume = collated_rb_per_volume/mean_overall_rb_per_volume;
    
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
    all_frames_before = all_frames_before(mod(all_frames_before - 1, 1/framerate) == 0);
    
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
            xlabel('prEF1-E2-Crimson')
            ylabel('G1/S probability')
            % subplot(1,2,2)
            bin_discrete_outcomes_with_logit(rb_per_size_this_frames_before,g1s_happens_here_this_frames_before);
            xlabel('[Rb] per prEF1-E2-Crimson')
            ylabel('G1/S probability')
        end
        
        if must_be_born
            num_subplots = 3;
        else
            num_subplots = 2;
        end
        
        if must_be_born
                %         binsizes = linspace(min(sizes_this_frames_before) , max(sizes_this_frames_before) , numbins);
        binsizes = linspace(prctile(ages_this_frames_before,low_prctile), prctile(ages_this_frames_before,high_prctile), numbins);
        [means,error_below,error_above,Ns] = bootstrap(ages_this_frames_before,g1s_happens_here_this_frames_before,binsizes);
        %         disp('Weighted linear fit to sizes')
        binfit_age = fitlm(binsizes,means,'Weights',Ns);
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, frame_to_show))
            figure()
            %             subplot(1,num_subplots,1)
            box on
            shadedErrorBar(binsizes,means,[error_above, error_below]');
            %             title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
            xlabel('Cell age (h)')
            ylabel('G1/S rate (10 mins)-1')
            axis([0 inf 0 inf],'square')
            xticks([0 5 10 15 20 25 30 35])
            yticks([0:0.01:0.05])
        end
        end
        
        %         binsizes = linspace(min(sizes_this_frames_before) , max(sizes_this_frames_before) , numbins);
        binsizes = linspace(prctile(sizes_this_frames_before,low_prctile), prctile(sizes_this_frames_before,high_prctile), numbins);
        [means,error_below,error_above,Ns] = bootstrap(sizes_this_frames_before,g1s_happens_here_this_frames_before,binsizes);
        %         disp('Weighted linear fit to sizes')
        binfit_size = fitlm(binsizes,means,'Weights',Ns);
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, frame_to_show))
            figure()
            %             subplot(1,num_subplots,1)
            box on
            shadedErrorBar(binsizes,means,[error_above, error_below]');
            %             title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
            xlabel('prEF1-E2-Crimson')
            ylabel('G1/S rate (10 mins)-1')
            axis([0 2 0 inf],'square')
            xticks([0 0.5 1 1.5 2])
            yticks([0 0.01 0.02 0.03 0.04 0.05])
        end
        
        %         binsizes = linspace(min(rb_per_size_this_frames_before) , max(rb_per_size_this_frames_before) , numbins);
        binsizes = linspace(prctile(rb_per_size_this_frames_before,low_prctile), prctile(rb_per_size_this_frames_before,high_prctile), numbins);
        [means,error_below,error_above,Ns] = bootstrap(rb_per_size_this_frames_before,g1s_happens_here_this_frames_before,binsizes);
        %         disp('Weighted linear fit to [Rb]')
        binfit_rb = fitlm(binsizes,means,'Weights',Ns);
        if show_all_plots == true || (show_some_plots == true && ismember(frames_before, frame_to_show))
            figure()
            %             subplot(1,num_subplots,2)
            box on
            shadedErrorBar(binsizes,means,[error_above, error_below]');
            %             title([expt_type{cond} ' ' num2str(10*(frames_before-1)) ' minutes before'])
            xlabel('[Rb] per prEF1-E2-Crimson')
            ylabel('G1/S rate (10 mins)-1')
            axis([0 2 0 inf],'square')
            yticks([0 : 0.005 : 0.04])
            xticks([0 0.5 1 1.5 2 2.5])
        end
        
    end
end


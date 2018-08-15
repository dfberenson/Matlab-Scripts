% Function written by Anna Rajaratnam and Daniel Berenson 7 Aug 2018


function g1s_frame = get_g1s_frame(geminin_trace, analysis_params)
% geminin_trace should be a column vector of the geminin values
% analysis_params needs the following fields:
% strategy = which strategy to employ
% num_first_frames_to_avoid = how many frames to skip at start
% num_last_frames_to_avoid = how many frames to skip at end
% threshold = Geminin threshold
% frames_to_check_nearby = how many frames to look ahead or behind
% min_frames_above = how many frames must be above threshold
% plot = whether or not to plot

% Returns a whole number index corresponding to where the kink occurs; or,
% returns [] if no good kink is discovered.

[h,w] = size(geminin_trace);
assert(h == 1 || w == 1)

assert(strcmp(analysis_params.strategy,'threshold') || strcmp(analysis_params.strategy,'derivative') ||...
    strcmp(analysis_params.strategy,'bilinear') || strcmp(analysis_params.strategy,'all'))

if h == 1
    geminin_trace = geminin_trace';
end

% The trace needs to be at least a certain number of frames before it is
% even worth trying to find where G1/S occurs
if length(geminin_trace) < analysis_params.min_total_trace_frames
    g1s_frame = [];
    return
end

% Clean up geminin trace by replacing negative numbers or NaNs with 0
geminin_trace(~(geminin_trace > 0)) = 0;
% Clean up geminin trace by replacing Inf with 0
geminin_trace(isinf(geminin_trace)) = 0;

x_vals = (1:length(geminin_trace))';

if strcmp(analysis_params.strategy,'threshold')
    has_it_previously_crossed_thresh_and_stayed_above = false;
    
    for i = analysis_params.num_first_frames_to_avoid + 1 : length(geminin_trace)
        frames_above = 0;
        
        if geminin_trace(i) > analysis_params.threshold
            % If current value is above threshold, check ahead and count
            % how many future frames are also above threshold.
            for j = i + 1 : min(i + analysis_params.frames_to_check_nearby, length(geminin_trace))
                if geminin_trace(j) > analysis_params.threshold
                    frames_above = frames_above + 1;
                end
            end
            
            if frames_above >= analysis_params.min_frames_above
                % If enough future frames are also above threshold, and this
                % is the first time this happened, record this frame number.
                if has_it_previously_crossed_thresh_and_stayed_above == false
                    g1s_frame = i;
                    has_it_previously_crossed_thresh_and_stayed_above = true;
                end
            end
        end
    end
    
    % If it never crosses and stays above, return []
    if has_it_previously_crossed_thresh_and_stayed_above == false
        g1s_frame = [];
    end
    
    if analysis_params.plot == true
        hold on
        plot(geminin_trace)
        plot(g1s_frame, geminin_trace(g1s_frame), 'y*')
        hold off
    end
    
elseif strcmp(analysis_params.strategy,'derivative')
    % Fit a sixth-degree polynomial and take first three derivatives
    p = polyfit(x_vals, geminin_trace, 6);
    fitted_vals = polyval(p,x_vals);
    first_derivs = diff(fitted_vals);
    second_derivs = diff(first_derivs);
    third_derivs = diff(second_derivs);
    % Find zero-crossing indices where third derivative goes from positive
    % to negative
    third_deriv_pos_to_neg_zci = find(third_derivs(1:end-1)>0 & third_derivs(2:end) < 0);
    
    % Adjust x values for each derivative to account for edges
    first_deriv_x_vals = (1.5:1:length(geminin_trace)-0.5)';
    second_deriv_x_vals = (2:1:length(geminin_trace)-1)';
    third_deriv_x_vals = (2.5:1:length(geminin_trace)-1.5)';
    
    % There could be zero, one, or two pos-to-neg ZCIs.
    % If there is only one, return it.
    
    if length(third_deriv_pos_to_neg_zci) == 0 || length(third_deriv_pos_to_neg_zci) > 2
        g1s_frame = [];
        
    elseif length(third_deriv_pos_to_neg_zci) == 1
        g1s_frame = third_deriv_pos_to_neg_zci;
        
        % If there are two, check which one has the larger change in the first
        % derivative before and after. This distinguishes between straight
        % lines (either flat or inclined) and concave points in the curve.
    elseif length(third_deriv_pos_to_neg_zci) == 2
        checkpoint_one_below = round(max(1,third_deriv_x_vals(third_deriv_pos_to_neg_zci(1)) - analysis_params.frames_to_check_nearby));
        checkpoint_one_above = round(min(length(first_derivs),third_deriv_x_vals(third_deriv_pos_to_neg_zci(1)) + analysis_params.frames_to_check_nearby));
        checkpoint_two_below = round(max(1,third_deriv_x_vals(third_deriv_pos_to_neg_zci(2)) - analysis_params.frames_to_check_nearby));
        checkpoint_two_above = round(min(length(first_derivs),third_deriv_x_vals(third_deriv_pos_to_neg_zci(2)) + analysis_params.frames_to_check_nearby));
        
        first_deriv_value_at_checkpoint_one_below = first_derivs(checkpoint_one_below);
        first_deriv_value_at_checkpoint_one_above = first_derivs(checkpoint_one_above);
        first_deriv_value_at_checkpoint_two_below = first_derivs(checkpoint_two_below);
        first_deriv_value_at_checkpoint_two_above = first_derivs(checkpoint_two_above);
        
        first_deriv_difference_across_checkpoint_one = first_deriv_value_at_checkpoint_one_above - first_deriv_value_at_checkpoint_one_below;
        first_deriv_difference_across_checkpoint_two = first_deriv_value_at_checkpoint_two_above - first_deriv_value_at_checkpoint_two_below;
        
        if first_deriv_difference_across_checkpoint_one > first_deriv_difference_across_checkpoint_two
            g1s_frame = third_deriv_x_vals(third_deriv_pos_to_neg_zci(1));
        else
            g1s_frame = third_deriv_x_vals(third_deriv_pos_to_neg_zci(2));
        end
    end
    
    if analysis_params.plot == true
        figure()
        hold on
        plot(third_deriv_x_vals(g1s_frame),third_derivs(g1s_frame), 'b*')
        plot(x_vals,geminin_trace)
        plot(x_vals,fitted_vals)
        hold off
    end
    
elseif strcmp(analysis_params.strategy,'bilinear')
    clean_trace = geminin_trace(analysis_params.num_first_frames_to_avoid + 1 : end - analysis_params.num_last_frames_to_avoid);
    clean_x_vals = (1:length(clean_trace))';
    
    ftype = fittype('max(a,b*x+c)');
    maxfit = fit(clean_x_vals,clean_trace,ftype,'StartPoint',[1 1 1]);
    g1s_frame = round((maxfit.a - maxfit.c)/maxfit.b + analysis_params.num_first_frames_to_avoid);
    
    if analysis_params.plot == true
        figure()
        hold on
        plot(clean_x_vals,clean_trace)
        plot(maxfit)
        hold off
    end
    
    if g1s_frame < 1
        %         g1s_frame = 1;
        g1s_frame = [];
    elseif g1s_frame > length(geminin_trace)
        %         g1s_frame=length(geminin_trace);
        g1s_frame = [];
    end
    
    if isfield(analysis_params, 'second_line_min_slope') && maxfit.b < analysis_params.second_line_min_slope
        g1s_frame = [];
    end
    
elseif strcmp(analysis_params.strategy,'all')
    plot_final = analysis_params.plot;
    analysis_params.plot = false;
    analysis_params.strategy = 'threshold';
    g1s_frame_by_threshold = get_g1s_frame(geminin_trace, analysis_params);
    analysis_params.strategy = 'derivative';
    g1s_frame_by_derivative = get_g1s_frame(geminin_trace, analysis_params);
    analysis_params.strategy = 'bilinear';
    g1s_frame_by_bilinear = get_g1s_frame(geminin_trace, analysis_params);
    analysis_params.strategy = 'all';
    g1s_frame = median([g1s_frame_by_threshold, g1s_frame_by_derivative, g1s_frame_by_bilinear]);
    
    tight_clustering = true;
    if analysis_params.require_tight_clustering_of_strategies == true
        % If we require tight clustering of strategies, check to make sure
        % all strategies returned nonempty values, and then check to make
        % sure at least two of them are closer than the
        % max_g1s_noise_frames
        if isempty(g1s_frame_by_threshold) || isempty(g1s_frame_by_derivative)...
                || isempty(g1s_frame_by_bilinear) ||...
                min([abs(g1s_frame_by_threshold - g1s_frame_by_derivative),...
                abs(g1s_frame_by_derivative - g1s_frame_by_threshold),...
                abs(g1s_frame_by_bilinear - g1s_frame_by_threshold)]) >...
                analysis_params.max_g1s_noise_frames
            g1s_frame = [];
            tight_clustering = false;
        end
    end
    
    if plot_final == true
        figure()
        hold on
        scatter(g1s_frame_by_threshold, geminin_trace(round(g1s_frame_by_threshold)), 360,'co')
        scatter(g1s_frame_by_derivative, geminin_trace(round(g1s_frame_by_derivative)), 360,'g+')
        scatter(g1s_frame_by_bilinear, geminin_trace(round(g1s_frame_by_bilinear)), 360,'rd')
        scatter(g1s_frame,geminin_trace(round(g1s_frame)),720,'bx')
        if tight_clustering == true
            title('Good tight clustering')
        else
            title('Bad not tight clustering')
        end
        legend('Threshold','Derivative','Bilinear','Median')
        plot(x_vals, geminin_trace)
        hold off
    end
    
end

end
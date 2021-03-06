

framerate = 1/12;
min_cycle_duration_hours = 8;
min_cycle_duration_frames = min_cycle_duration_hours / framerate;
min_initial_startframe = 5;
geminin_threshold = 10000;
geminin_slope_threshold = 100;
min_sg2_frames_above_thresh = 20;
frames_to_skip_at_start = 5;
frames_to_skip_at_end = 10;

s = saved_data;
all_red_flat_traces = measurements_struct.all_red_flat_integrated_intensity_traces;
all_green_flat_traces = measurements_struct.all_green_flat_integrated_intensity_traces;

size_control_struct = struct;

%% Loop and plot
for c = s.all_tracknums
% for c = 6
    size_control_struct(c).isgood = true;
    
    thiscell_red = all_red_flat_traces(:,c);
    thiscell_green = all_green_flat_traces(:,c);
    
    thiscell_geminin = thiscell_green;
    
    startframe = s.track_metadata(c).firstframe;
    endframe = s.track_metadata(c).lastframe;
    
    if startframe == -1 || endframe == -1
        size_control_struct(c).isgood = false;
        continue
    end
    
    if startframe <= min_initial_startframe
        size_control_struct(c).isgood = false
        continue
    end
    
    size_control_struct(c).startframe = startframe;
    size_control_struct(c).endframe = endframe;
    
    % Minimum cell cycle duration of 10 h
    if endframe - startframe < min_cycle_duration_frames
        size_control_struct(c).isgood = false;
        continue
    end
    
    inbound_frames = (startframe + frames_to_skip_at_start : endframe - frames_to_skip_at_end)';
    thiscell_red_inbounds = thiscell_red(inbound_frames);
    thiscell_green_inbounds = thiscell_green(inbound_frames);
    thiscell_geminin_inbounds = thiscell_geminin(inbound_frames);
    
    % Make sure enough cells are above the threshold
    thiscell_geminin_isabovethresh = thiscell_geminin_inbounds > geminin_threshold;
    if sum(thiscell_geminin_isabovethresh) < min_sg2_frames_above_thresh
        size_control_struct(c).isgood = false;
        continue
    end
    
    % Get rid of one-off points that passed the threshold
    thiscell_geminin_isabovethresh = logical(movmedian(thiscell_geminin_isabovethresh,7));
    
    % Make sure geminin is sloping up sufficiently
    p = polyfit(inbound_frames(thiscell_geminin_isabovethresh), thiscell_geminin_inbounds(thiscell_geminin_isabovethresh), 1);
    if p(1) < geminin_slope_threshold
        size_control_struct(c).isgood = false;
        continue
    end
    
    intersection_with_zero = round(-p(2)/p(1));
    
    if intersection_with_zero < startframe
        size_control_struct(c).isgood = false;
        continue
    end
    
    %     figure()
    %     hold on
    %     plot(thiscell_geminin_inbounds)
    %     plot(polyval(p, inbound_frames))
    %     line([intersection_with_zero - startframe - frames_to_skip_at_start + 1,
    %         intersection_with_zero - startframe - frames_to_skip_at_start + 1],...
    %         [0 geminin_threshold*5])
    %     hold off
    
    size_control_struct(c).startframe = startframe;
    size_control_struct(c).g1s_frame = intersection_with_zero;
    
    figure,title(['Geminin flatfielded integrated intensity for cell ' num2str(c)]);
    hold on
    plot(thiscell_geminin,'g')
    line([intersection_with_zero intersection_with_zero],...
        [0 geminin_threshold*5])
    drawnow
    hold off
    
    
    thiscell_red_smooth = movmedian(thiscell_red, 5);
    birthsize = thiscell_red_smooth(startframe + frames_to_skip_at_start + 10);
    g1ssize = thiscell_red_smooth(intersection_with_zero);
    
    size_control_struct(c).birthsize = birthsize;
    size_control_struct(c).g1ssize = g1ssize;
end

%% Plot size control

for c = s.all_tracknums
    if size_control_struct(c).isgood
        aregood(c) = true;
        startframes(c) = size_control_struct(c).startframe;
        birthsizes(c) = size_control_struct(c).birthsize;
        g1ssizes(c) = size_control_struct(c).g1ssize;
        g1lengths(c) = size_control_struct(c).g1s_frame - size_control_struct(c).startframe;
    end
end


X = birthsizes(aregood);
Y = g1lengths(aregood) * framerate;
fig = plot_scatter_with_line(X,Y);
title('G1 length vs Birth size')
xlabel('Birth size (AU)')
ylabel('G1 length (h)')


figure,scatter(birthsizes(aregood), g1lengths(aregood) * framerate, 10, startframes(aregood) * framerate, 'filled')
title('G1 length vs Birth size, colorized by start frame')


min_starttime_hours = 24;
born_before_max_starttime = startframes < min_starttime_hours / framerate;

aregood_and_bornearly = logical(aregood .* born_before_max_starttime);

X = birthsizes(aregood_and_bornearly);
Y = g1lengths(aregood_and_bornearly) * framerate;
fig = plot_scatter_with_line(X,Y);
title(['G1 length vs Birth size, only cells born before ' num2str(min_starttime_hours) ' hours'])
xlabel('Birth size (AU)')
ylabel('G1 length (h)')

max_g1_length = 12;
has_g1_length_below_max = g1lengths < max_g1_length / framerate;

aregood_and_shortG1 = logical(aregood .* has_g1_length_below_max);

X = birthsizes(aregood_and_shortG1);
Y = g1lengths(aregood_and_shortG1) * framerate;
fig = plot_scatter_with_line(X,Y);
title(['G1 length vs Birth size, only cells with G1 shorter than ' num2str(max_g1_length) ' hours'])
xlabel('Birth size (AU)')
ylabel('G1 length (h)')

min_size = 3000;
has_size_above_min = birthsizes > min_size;

aregood_and_shortG1_and_bigenough = logical(aregood .* has_g1_length_below_max .* has_size_above_min);

X = birthsizes(aregood_and_shortG1_and_bigenough);
Y = g1lengths(aregood_and_shortG1_and_bigenough) * framerate;
fig = plot_scatter_with_line(X,Y);
title({['G1 length vs Birth size, only cells with G1 shorter than ' num2str(max_g1_length) ' hours'],...
    [' and also born larger than ' num2str(min_size)]})
xlabel('Birth size (AU )')
ylabel('G1 length (h)')


aregood_and_bornlate = logical(aregood .* ~born_before_max_starttime);

figure()
hold on
histogram(g1lengths(aregood_and_bornearly) * framerate,10,'FaceColor','r','FaceAlpha',0.9)
histogram(g1lengths(aregood_and_bornlate) * framerate,10,'FaceColor','g','FaceAlpha',0.6)
xlabel('G1 length (h)')
ylabel('Count')
legend(['Born before ' num2str(min_starttime_hours) ' hours'],['Born before ' num2str(min_starttime_hours) ' hours'])
hold off

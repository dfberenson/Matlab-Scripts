
framerate = 1/12;
d = struct;
s = saved_data;
m = measurements_struct.all_red_flat_integrated_intensity_traces;

% Looking at the data in m, the lineages tracked from frame 1 are:
% 1, 12, 17, 22, 29, 34, 45

cellnum = 45;

d = get_descendant_measurements(d, s, m, cellnum);

figure()
xlabel('Time (h)')
ylabel('mCherry (AU)')
hold on
for i = 1:length(d)
    if ~isempty(d(i).measurements)
        measured_frames = find(d(i).measurements);
        measured_timepoints = measured_frames * framerate;
        measurements = d(i).measurements(measured_frames);
        if d(i).divides
            plot(measured_timepoints, measurements, 'r')
        else
            plot(measured_timepoints, measurements, 'm')
        end
    end
end



framerate = 1/12;
d = struct;
s = saved_data;
m = measurements_struct.all_green_flat_integrated_intensity_traces;
d = get_descendant_measurements(d, s, m, cellnum);

figure()
xlabel('Time (h)')
ylabel('Geminin (AU)')
hold on
for i = 1:length(d)
    if ~isempty(d(i).measurements)
        measured_frames = find(d(i).measurements);
        measured_timepoints = measured_frames * framerate;
        measurements = d(i).measurements(measured_frames);
        if d(i).divides
            plot(measured_timepoints, measurements, 'g')
        else
            plot(measured_timepoints, measurements, 'c')
        end
    end
end
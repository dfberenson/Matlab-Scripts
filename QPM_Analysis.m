

%Plots at end censor data outside of nice central region

% NOT RAW for Fluo1, RAW for Fluo2
folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos2\DFB_170906_QuantPhase24h_1_MMStack_Pos2\FEATURES';
phase_prefix = 'MEAS_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
fluo1_prefix = 'MEAS_fluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
fluo2_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';

% RAW for Fluo1, NOT RAW for Fluo2
% folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos2\DFB_170906_QuantPhase24h_1_MMStack_Pos2\FEATURES';
% phase_prefix = 'MEAS_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo1_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo2_prefix = 'MEAS_fluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';

% Files called RAW
% folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos2\DFB_170906_QuantPhase24h_1_MMStack_Pos2\FEATURES';
% phase_prefix = 'MEAS_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo1_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo2_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';

%Files NOT called RAW
% folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos2\DFB_170906_QuantPhase24h_1_MMStack_Pos2\FEATURES';
% phase_prefix = 'MEAS_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo1_prefix = 'MEAS_fluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';
% fluo2_prefix = 'MEAS_fluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos2.ome';

%Pos4
% folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos4\DFB_170906_QuantPhase24h_1_MMStack_Pos4\FEATURES';
% phase_prefix = 'MEAS_DFB_170906_QuantPhase24h_1_MMStack_Pos4.ome';
% fluo1_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos4.ome';
% fluo2_prefix = 'MEAS_RAWfluo_INT_DFB_170906_QuantPhase24h_1_MMStack_Pos4.ome';

area_measurements = [];
phase_measurements = [];
fluo1_measurements = [];
fluo2_measurements = [];
X = [];
Y = [];
timepoint = [];
cell_num = [];

for t = [1:40]
    
    framestring = num2str(t,'%04d');
    file_phase = [folder '\' phase_prefix framestring '.txt'];
    file_fluo1 = [folder '\' fluo1_prefix framestring 'fluo1.tif.txt'];
    file_fluo2 = [folder '\' fluo2_prefix framestring 'fluo2.tif.txt'];
    
    phasetable = readtable(file_phase);
    fluo1table = readtable(file_fluo1);
    fluo2table = readtable(file_fluo2);
    
    thistime_area_measurements = table2array(phasetable(:,{'Surface_micron2_'}));
    thistime_phase_measurements = table2array(phasetable(:,{'Optical_volume_micron3_'}));
    thistime_fluo1_measurements = table2array(fluo1table(:,{'Optical_volume_micron3_'}));
    thistime_fluo2_measurements = table2array(fluo2table(:,{'Optical_volume_micron3_'}));
    thistime_X = table2array(phasetable(:,{'Surface_Centroid_X'}));
    thistime_Y = table2array(phasetable(:,{'Surface_Centroid_Y'}));
        thistime_timepoint = repelem(t,length(thistime_area_measurements))';
    thistime_cell_num = [1:length(thistime_area_measurements)]';
    
%     %Randomly shuffle order of measurements to confirm that changing the
%     %order matters as it should
%     thistime_area_measurements = thistime_area_measurements(randperm(length(thistime_area_measurements)))
%     thistime_phase_measurements = thistime_phase_measurements(randperm(length(thistime_phase_measurements)))
%     thistime_fluo1_measurements = thistime_fluo1_measurements(randperm(length(thistime_fluo1_measurements)))
%     thistime_fluo2_measurements = thistime_fluo2_measurements(randperm(length(thistime_fluo2_measurements)))
%     thistime_X = thistime_X(randperm(length(thistime_X)))
%     thistime_Y = thistime_Y(randperm(length(thistime_Y)))
    
    area_measurements = [area_measurements ; thistime_area_measurements];
    phase_measurements = [phase_measurements ; thistime_phase_measurements];
    fluo1_measurements = [fluo1_measurements ; thistime_fluo1_measurements];
    fluo2_measurements = [fluo2_measurements ; thistime_fluo2_measurements];
    X = [X ; thistime_X];
    Y = [Y ; thistime_Y];
        timepoint = [timepoint ; thistime_timepoint];
    cell_num = [cell_num ; thistime_cell_num];
    
%     area_measurements = [area_measurements ; table2array(phasetable(:,{'Surface_micron2_'}))];
%     phase_measurements = [phase_measurements ; table2array(phasetable(:,{'Optical_volume_micron3_'}))];
%     fluo1_measurements = [fluo1_measurements ; table2array(fluo1table(:,{'Optical_volume_micron3_'}))];
%     fluo2_measurements = [fluo2_measurements ; table2array(fluo2table(:,{'Optical_volume_micron3_'}))];
%     X = [X ; table2array(phasetable(:,{'Surface_Centroid_X'}))];
%     Y = [Y ; table2array(phasetable(:,{'Surface_Centroid_Y'}))];
    %Surface_Centroids are the same for across phase/fluo1/fluo2
    
end

xmin = 80;
xmax = 200;
ymin = 100;
ymax = 220;

xbad = 174;
ybad = 130;
% Missing data are assigned to (x,y) coordinate (174,130) for whatever reason
phasebad = 40;
% Censor cells with phase measurement below 40 (presumably due to
% missegmentation)

fig1 = figure('Name', 'Fig1: Fluo1 values at X,Y coordinates')
scatter(X,Y,10,fluo1_measurements)
line([xmin xmin],[ymin ymax])
line([xmax xmax],[ymin ymax])
line([xmin xmax],[ymin ymin])
line([xmin xmax],[ymax ymax])
fig2 = figure('Name', 'Fig2: Fluo1 nonzero at X,Y coordinates')
scatter(X,Y,10,fluo1_measurements == 0)
colormap('flag')
line([xmin xmin],[ymin ymax])
line([xmax xmax],[ymin ymax])
line([xmin xmax],[ymin ymin])
line([xmin xmax],[ymax ymax])

fig1a = figure('Name','Fig1a: Phase values at X,Y coordinates')
scatter(X,Y,10,phase_measurements)
line([xmin xmin],[ymin ymax])
line([xmax xmax],[ymin ymax])
line([xmin xmax],[ymin ymin])
line([xmin xmax],[ymax ymax])
fig2a = figure('Name','Fig2a: Phase < 40 at X,Y coordinates')
scatter(X,Y,10,phase_measurements < phasebad)
colormap('flag')
line([xmin xmin],[ymin ymax])
line([xmax xmax],[ymin ymax])
line([xmin xmax],[ymin ymin])
line([xmin xmax],[ymax ymax])

fig_hist = figure('Name','Histogram: Phase values')
hold on
histogram(phase_measurements(phase_measurements >= phasebad),0:10:200,'FaceColor','r')
histogram(phase_measurements(phase_measurements < phasebad),0:10:200, 'FaceColor','k')
xlabel('Phase optical mass')
ylabel('Count')
legend('Cells bigger than 40','Cells smaller than 40 (likely missegmented)')

in_frame_positions = (xmin < X & X < xmax & ymin < Y & Y < ymax & X ~= xbad & Y ~= ybad & phase_measurements > phasebad);

fig3 = plot_scatter_with_line(phase_measurements(in_frame_positions),fluo1_measurements(in_frame_positions))
fig3.Name = 'Figure 3: mCherry vs Phase'
xlabel('Phase optical volume')
ylabel('mCherry integrated intensity')

fig4 = plot_scatter_with_line(phase_measurements(in_frame_positions),fluo2_measurements(in_frame_positions))
fig4.Name = 'Figure 4: Geminin vs Phase'
xlabel('Phase optical volume')
ylabel('Geminin integrated intensity')

fig5 = plot_scatter_with_line(area_measurements(in_frame_positions),phase_measurements(in_frame_positions))
fig5.Name = 'Figure 5: Phase vs Area'
xlabel('Area')
ylabel('Phase optical volume')

fig6 = plot_scatter_with_line(area_measurements(in_frame_positions),fluo1_measurements(in_frame_positions))
fig6.Name = 'Figure 6: mCherry vs Area'
xlabel('Area')
ylabel('mCherry integrated intensity')

fig7 = plot_scatter_with_line(area_measurements(in_frame_positions),fluo2_measurements(in_frame_positions))
fig7.Name = 'Figure 7: Geminin vs Area'
xlabel('Area')
ylabel('Fluo2 integrated intensity')


% Some code to identify potentially problematic cells. Use the
% bad_timepoints and bad_cellnums variables to figure out where the bad
% cells are, then look at the table from that timepoint in those rows.
% bad = find(phase_measurements(in_frame_positions) < 40 & phase_measurements(in_frame_positions) > 30);
% timepoints_inframe = timepoint(in_frame_positions);
% bad_timepoints = timepoints_inframe(bad);
% cell_nums_inframe = cell_num(in_frame_positions);
% bad_cellnums = cell_nums_inframe(bad);



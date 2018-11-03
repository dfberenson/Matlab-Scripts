
data_folder = 'E:\QPM_Timelapse\Report from 13 June 18';
data_file = 'MEAS_Pos19.txt';
data_fpath = [data_folder '\' data_file];
T = readtable(data_fpath);

phase_areas = table2array(T(:,{'Surface_micron2_'}));
phase_optical_volume = table2array(T(:,{'Optical_volume_micron3_'}));
fluo1_areas = table2array(T(:,{'Surface_micron2__1'}));
fluo1_optical_volume = table2array(T(:,{'Optical_volume_micron3__1'}));
fluo2_areas = table2array(T(:,{'Surface_micron2__2'}));
fluo2_optical_volume = table2array(T(:,{'Optical_volume_micron3__2'}));

% % Check what happens with random permutations of data
% phase_areas = phase_areas(randperm(length(phase_areas)));
% phase_optical_volume = phase_optical_volume(randperm(length(phase_optical_volume)));
% fluo1_areas = fluo1_areas(randperm(length(fluo1_areas)));
% fluo1_optical_volume = fluo1_optical_volume(randperm(length(fluo1_optical_volume)));
% fluo2_areas = fluo2_areas(randperm(length(fluo2_areas)));
% fluo2_optical_volume = fluo2_optical_volume(randperm(length(fluo2_optical_volume)));


phase_areas(isnan(phase_areas)) = 0;
phase_optical_volume(isnan(phase_optical_volume)) = 0;
fluo1_areas(isnan(fluo1_areas)) = 0;
fluo1_optical_volume(isnan(fluo1_optical_volume)) = 0;
fluo2_areas(isnan(fluo2_areas)) = 0;
fluo2_optical_volume(isnan(fluo2_optical_volume)) = 0;

figure_folder = ['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\QPM' '\180613\Pos19'];
if ~exist(figure_folder,'dir')
    mkdir(figure_folder);
end

% fig0 = scatter3(phase_optical_volume, fluo1_areas, fluo1_optical_volume);
% xlabel('Phase optical volume')
% ylabel('Fluo1 area')
% zlabel('Fluo1 optical volume')

fig0 = scatter(phase_optical_volume,fluo1_optical_volume,10,fluo1_areas,'filled')
xlabel('Phase optical volume')
ylabel('mCherry optical volume')
colormap('Cool')
colorbar()
saveas(gcf,[figure_folder '\Fig0.png'])

fig1 = plot_scatter_with_line(fluo1_areas,fluo2_areas)
fig1.Name = 'Figure 1: Fluo2 area vs Fluo1 area';
xlabel('mCherry area')
ylabel('Geminin area')
saveas(gcf,[figure_folder '\Fig1.png'])


fig2 = plot_scatter_with_line(phase_areas, phase_optical_volume)
fig2.Name = 'Figure 2: Phase optical volume vs Phase area';
xlabel('Phase area')
ylabel('Phase optical volume')
saveas(gcf,[figure_folder '\Fig2.png'])


fig3 = plot_scatter_with_line(fluo1_areas,fluo1_optical_volume)
fig3.Name = 'Figure 3: Fluo1 optical volume vs Fluo1 area';
xlabel('mCherry area')
ylabel('mCherry optical volume')
saveas(gcf,[figure_folder '\Fig3.png'])


fig4 = plot_scatter_with_line(fluo2_areas,fluo2_optical_volume)
fig4.Name = 'Figure 4: Fluo2 optical volume vs Fluo2 area';
xlabel('Geminin area')
ylabel('Geminin optical volume')
saveas(gcf,[figure_folder '\Fig4.png'])


fig5 = plot_scatter_with_line(phase_optical_volume,fluo1_optical_volume)
fig5.Name = 'Figure 5: Fluo1 optical volume vs Phase optical volume';
xlabel('Phase optical volume')
ylabel('mCherry optical volume')
saveas(gcf,[figure_folder '\Fig5.png'])


fig5a = plot_scatter_with_line(phase_optical_volume(fluo1_areas < 300), fluo1_optical_volume(fluo1_areas < 300));
fig5a.Name = 'Figure 5a: Fluo1 optical volume vs Phase optical volume, only cells with nuclear area < 300';
xlabel('Phase optical volume')
ylabel('mCherry optical volume')
saveas(gcf,[figure_folder '\Fig5a.png'])


fig5b = plot_scatter_with_line(phase_optical_volume(fluo1_areas < 300), fluo1_optical_volume(fluo1_areas < 300),'no_intercept');
title('Figure 5b: Fluo1 optical volume vs Phase optical volume, only cells with nuclear area < 300, enforced 0-intercept')
xlabel('Phase optical volume')
ylabel('mCherry optical volume')
saveas(gcf,[figure_folder '\Fig5b.png'])


fig5c = plot_scatter_with_line(phase_optical_volume(fluo1_areas < 300), fluo1_optical_volume(fluo1_areas < 300) - 120,'no_intercept');
title('Figure 5c: Fluo1 optical volume vs Phase optical volume, only cells with nuclear area < 300, subtracted 120 from fluo1 optical volume, enforced 0-intercept')
xlabel('Phase optical volume')
ylabel('mCherry optical volume')
saveas(gcf,[figure_folder '\Fig5c.png'])


fig6 = plot_scatter_with_line(phase_optical_volume,fluo2_optical_volume)
fig6.Name = 'Figure 6: Fluo2 optical volume vs Phase optical volume';
xlabel('Phase optical volume')
ylabel('Geminin optical volume')
saveas(gcf,[figure_folder '\Fig6.png'])


fig7 = plot_scatter_with_line(phase_optical_volume,fluo1_areas)
title('Figure 7: Nuclear area vs phase optical volume')
xlabel('Phase optical volume')
ylabel('Nuclear area')
saveas(gcf,[figure_folder '\Fig7.png'])


fig7a = plot_scatter_with_line(phase_optical_volume(fluo1_areas < 300), fluo1_areas(fluo1_areas < 300))
title('Figure 7a: Nuclear area vs phase optical volume, only cells with nuclear area < 300')
xlabel('Phase optical volume')
ylabel('Nuclear area')
saveas(gcf,[figure_folder '\Fig7a.png'])


fig7b = plot_scatter_with_line(phase_optical_volume(fluo1_areas < 300), fluo1_areas(fluo1_areas < 300), 'no_intercept')
title('Figure 7b: Nuclear area vs phase optical volume, only cells with nuclear area < 300, enforced 0-intercept')
xlabel('Phase optical volume')
ylabel('Nuclear area')
saveas(gcf,[figure_folder '\Fig7b.png'])


%% For expt 170906:

%Plots at end censor data outside of nice central region

% NOT RAW for Fluo1, RAW for Fluo2
data_folder = 'E:\QPM_Timelapse\DFB_170906_QuantPhase24h_1_MMStack_Pos2\DFB_170906_QuantPhase24h_1_MMStack_Pos2\FEATURES';
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
    file_phase = [data_folder '\' phase_prefix framestring '.txt'];
    file_fluo1 = [data_folder '\' fluo1_prefix framestring 'fluo1.tif.txt'];
    file_fluo2 = [data_folder '\' fluo2_prefix framestring 'fluo2.tif.txt'];
    
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



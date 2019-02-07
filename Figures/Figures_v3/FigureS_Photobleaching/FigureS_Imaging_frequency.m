

clear all
close all

T_lowexposure = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_181114-181214_HMEC_BT45 cell cycle times.xlsx','Sheet','DFB_181114');
T_highexposure = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_181114-181214_HMEC_BT45 cell cycle times.xlsx','Sheet','DFB_181214');

framerate_highexposure = 1/3;
framerate_lowexposure = 1/3;

birthframes_lowexposure = T_lowexposure.BirthFrame(~isnan(T_lowexposure.BirthFrame));
mitosisframes_lowexposure = T_lowexposure.MitosisFrame(~isnan(T_lowexposure.MitosisFrame));
cellcycleframes_lowexposure = mitosisframes_lowexposure - birthframes_lowexposure;
cellcyclehours_lowexposure = cellcycleframes_lowexposure * framerate_lowexposure;

birthframes_highexposure = T_highexposure.BirthFrame(~isnan(T_highexposure.BirthFrame));
mitosisframes_highexposure = T_highexposure.MitosisFrame(~isnan(T_highexposure.MitosisFrame));
cellcycleframes_highexposure = mitosisframes_highexposure - birthframes_highexposure;
cellcyclehours_highexposure = cellcycleframes_highexposure * framerate_highexposure;


figure
hold on
histogram(cellcyclehours_highexposure,'FaceColor','blue')
histogram(cellcyclehours_lowexposure,'FaceColor','magenta')
legend('High exposure','Low exposure')
title('All dividing cells')
hold off


median_cellcycle_hours = [median(cellcyclehours_lowexposure) median(cellcyclehours_highexposure)];
stderr_cellcycle_hours = [std(cellcyclehours_lowexposure) std(cellcyclehours_highexposure)] ./...
    [sqrt(length(cellcyclehours_lowexposure)) sqrt(length(cellcyclehours_highexposure))];
[h,p,ci,stats] = ttest2(cellcyclehours_lowexposure,cellcyclehours_highexposure)


figure
box on
hold on
[bar,err] = barwitherr(stderr_cellcycle_hours,median_cellcycle_hours,'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 2.5 0 25],'square')
set(gca, 'FontSize', 16)
set(gca, 'YTick', [0 10 20])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Low exposure' 'High exposure'})
ylabel('Median cell cycle length')
hold off


clear all
close all

T_whitelight = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_181030_181103_HMEC_BT45 cell cycle times.xlsx','Sheet','DFB_181030');
T_fluorescent = readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_181030_181103_HMEC_BT45 cell cycle times.xlsx','Sheet','DFB_181103');

framerate_whitelight = 1/20;
framerate_fluorescent = 1/12;

imaged_maxframe_whitelight = 464;
imaged_maxframe_fluorescent = 258;
imaged_maxhours_whitelight = imaged_maxframe_whitelight * framerate_whitelight;
imaged_maxhours_fluorescent = imaged_maxframe_fluorescent * framerate_fluorescent;

equal_maxhours = min(imaged_maxhours_whitelight,imaged_maxhours_fluorescent);
equal_maxframe_whitelight = equal_maxhours / framerate_whitelight + 1;
equal_maxframe_fluorescent = equal_maxhours / framerate_fluorescent + 1;
% The +1 is to account for when a cell was in mitosis at the end of the
% movie but had not yet divided, and I recorded its mitosis frame as one
% frame after the last frame of the movie.

%% Analysis for only cells that divide:

birthframes_whitelight = T_whitelight.BirthFrame(~isnan(T_whitelight.BirthFrame));
mitosisframes_whitelight = T_whitelight.MitosisFrame(~isnan(T_whitelight.MitosisFrame));
mitosis_within_equal_maxframe_whitelight = mitosisframes_whitelight <= equal_maxframe_whitelight;
cellcycleframes_whitelight = mitosisframes_whitelight - birthframes_whitelight;
cellcyclehours_whitelight = cellcycleframes_whitelight * framerate_whitelight;

birthframes_fluorescent = T_fluorescent.BirthFrame(~isnan(T_fluorescent.BirthFrame));
mitosisframes_fluorescent = T_fluorescent.MitosisFrame(~isnan(T_fluorescent.MitosisFrame));
mitosis_within_equal_maxframe_fluorescent = mitosisframes_fluorescent <= equal_maxframe_fluorescent;
cellcycleframes_fluorescent = mitosisframes_fluorescent - birthframes_fluorescent;
cellcyclehours_fluorescent = cellcycleframes_fluorescent * framerate_fluorescent;

figure
hold on
histogram(cellcyclehours_whitelight,'FaceColor','magenta')
histogram(cellcyclehours_fluorescent,'FaceColor','blue')
legend('White light only','Blue and green light')
title('All measured cells')
hold off

figure
hold on
histogram(cellcyclehours_whitelight(mitosis_within_equal_maxframe_whitelight),'FaceColor','magenta')
histogram(cellcyclehours_fluorescent(mitosis_within_equal_maxframe_fluorescent),'FaceColor','blue')
legend('White light only','Blue and green light')
title('Limited to first 21.5h so movies are equally long')
hold off

[h,p,ci,stats] = ttest2(cellcyclehours_whitelight,cellcyclehours_fluorescent)
[h,p,ci,stats] = ttest2(cellcyclehours_whitelight(mitosis_within_equal_maxframe_whitelight),cellcyclehours_fluorescent(mitosis_within_equal_maxframe_fluorescent))

%% Analysis for only cells that don't divide

birthframes_whitelight_nodivide = T_whitelight.BirthFrame_NoMitosis(~isnan(T_whitelight.BirthFrame_NoMitosis));
mitosisframes_whitelight_nodivide = T_whitelight.LastMeasuredFrame_NoMitosis(~isnan(T_whitelight.LastMeasuredFrame_NoMitosis));
cellcycleframes_whitelight_nodivide = mitosisframes_whitelight_nodivide - birthframes_whitelight_nodivide;
cellcyclehours_whitelight_nodivide = cellcycleframes_whitelight_nodivide * framerate_whitelight;

birthframes_fluorescent_nodivide = T_fluorescent.BirthFrame_NoMitosis(~isnan(T_fluorescent.BirthFrame_NoMitosis));
mitosisframes_fluorescent_nodivide = T_fluorescent.LastMeasuredFrame_NoMitosis(~isnan(T_fluorescent.LastMeasuredFrame_NoMitosis));
cellcycleframes_fluorescent_nodivide = mitosisframes_fluorescent_nodivide - birthframes_fluorescent_nodivide;
cellcyclehours_fluorescent_nodivide = cellcycleframes_fluorescent_nodivide * framerate_fluorescent;

figure
hold on
scatter(birthframes_whitelight_nodivide*framerate_whitelight,cellcyclehours_whitelight_nodivide)
scatter(birthframes_fluorescent_nodivide*framerate_fluorescent,cellcyclehours_fluorescent_nodivide)
hold off
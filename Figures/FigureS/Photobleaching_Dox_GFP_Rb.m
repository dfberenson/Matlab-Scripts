
clear all
close all

completedata_gfp = [];
groups_gfp = [];
completedata_rb = [];
groups_rb = [];

fastframes_fpath = 'F:\DFB_imaging_experiments_2\DFB_181103_HMEC_fastframes_1\Manual Measurements_fastframes.xlsx';
slowframes_fpath = 'F:\DFB_imaging_experiments_2\DFB_181106_HMEC_slowframes_1\Manual Measurements_slowframes.xlsx';

T_gfp_before_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP before');
T_gfp_during_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP during');
T_gfp_after_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP after');
T_rb_before_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP-Rb before');
T_rb_during_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP-Rb during');
T_rb_after_fast = readtable(fastframes_fpath,'Sheet','Dox-GFP-Rb after');

% To get net values, do row 1 minus row 2, row 3 minus row 4, etc.
gfp_intden_before_fast = table2array(T_gfp_before_fast([1:2:height(T_gfp_before_fast)],'RawIntDen'))- table2array(T_gfp_before_fast([2:2:height(T_gfp_before_fast)],'RawIntDen'));
gfp_intden_during_fast = table2array(T_gfp_during_fast([1:2:height(T_gfp_during_fast)],'RawIntDen'))- table2array(T_gfp_during_fast([2:2:height(T_gfp_during_fast)],'RawIntDen'));
gfp_intden_after_fast = table2array(T_gfp_after_fast([1:2:height(T_gfp_after_fast)],'RawIntDen'))- table2array(T_gfp_after_fast([2:2:height(T_gfp_after_fast)],'RawIntDen'));
rb_intden_before_fast = table2array(T_rb_before_fast([1:2:height(T_rb_before_fast)],'RawIntDen'))- table2array(T_rb_before_fast([2:2:height(T_rb_before_fast)],'RawIntDen'));
rb_intden_during_fast = table2array(T_rb_during_fast([1:2:height(T_rb_during_fast)],'RawIntDen'))- table2array(T_rb_during_fast([2:2:height(T_rb_during_fast)],'RawIntDen'));
rb_intden_after_fast = table2array(T_rb_after_fast([1:2:height(T_rb_after_fast)],'RawIntDen'))- table2array(T_rb_after_fast([2:2:height(T_rb_after_fast)],'RawIntDen'));

median_gfp_before_fast = median(gfp_intden_before_fast);
median_rb_before_fast = median(rb_intden_before_fast);

completedata_fastframes = [gfp_intden_before_fast / median_gfp_before_fast; gfp_intden_during_fast / median_gfp_before_fast; gfp_intden_after_fast / median_gfp_before_fast;...
    rb_intden_before_fast / median_rb_before_fast; rb_intden_during_fast / median_rb_before_fast; rb_intden_after_fast / median_rb_before_fast];
groups_fastframes = [1*ones(length(gfp_intden_before_fast),1); 2*ones(length(gfp_intden_during_fast),1); 3*ones(length(gfp_intden_after_fast),1);...
    4*ones(length(rb_intden_before_fast),1); 5*ones(length(rb_intden_during_fast),1); 6*ones(length(rb_intden_after_fast),1)];

completedata_gfp = [gfp_intden_before_fast / median_gfp_before_fast; gfp_intden_during_fast / median_gfp_before_fast; gfp_intden_after_fast / median_gfp_before_fast];
groups_gfp = [1*ones(length(gfp_intden_before_fast),1); 2*ones(length(gfp_intden_during_fast),1); 3*ones(length(gfp_intden_after_fast),1)];
completedata_rb = [rb_intden_before_fast / median_rb_before_fast; rb_intden_during_fast / median_rb_before_fast; rb_intden_after_fast / median_rb_before_fast];
groups_rb = [1*ones(length(rb_intden_before_fast),1); 2*ones(length(rb_intden_during_fast),1); 3*ones(length(rb_intden_after_fast),1)];


T_gfp_before_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP before');
T_gfp_during_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP during');
T_gfp_after_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP after');
T_gfp_superafter_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP superafter');
T_rb_before_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP-Rb before');
T_rb_during_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP-Rb during');
T_rb_after_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP-Rb after');
T_rb_superafter_slow = readtable(slowframes_fpath,'Sheet','Dox-GFP-Rb after');

% To get net values, do row 1 minus row 2, row 3 minus row 4, etc.
gfp_intden_before_slow = table2array(T_gfp_before_slow([1:2:height(T_gfp_before_slow)],'RawIntDen'))- table2array(T_gfp_before_slow([2:2:height(T_gfp_before_slow)],'RawIntDen'));
gfp_intden_during_slow = table2array(T_gfp_during_slow([1:2:height(T_gfp_during_slow)],'RawIntDen'))- table2array(T_gfp_during_slow([2:2:height(T_gfp_during_slow)],'RawIntDen'));
gfp_intden_after_slow = table2array(T_gfp_after_slow([1:2:height(T_gfp_after_slow)],'RawIntDen'))- table2array(T_gfp_after_slow([2:2:height(T_gfp_after_slow)],'RawIntDen'));
gfp_intden_superafter_slow = table2array(T_gfp_superafter_slow([1:2:height(T_gfp_superafter_slow)],'RawIntDen')) - table2array(T_gfp_superafter_slow([2:2:height(T_gfp_superafter_slow)],'RawIntDen'));
rb_intden_before_slow = table2array(T_rb_before_slow([1:2:height(T_rb_before_slow)],'RawIntDen'))- table2array(T_rb_before_slow([2:2:height(T_rb_before_slow)],'RawIntDen'));
rb_intden_during_slow = table2array(T_rb_during_slow([1:2:height(T_rb_during_slow)],'RawIntDen'))- table2array(T_rb_during_slow([2:2:height(T_rb_during_slow)],'RawIntDen'));
rb_intden_after_slow = table2array(T_rb_after_slow([1:2:height(T_rb_after_slow)],'RawIntDen'))- table2array(T_rb_after_slow([2:2:height(T_rb_after_slow)],'RawIntDen'));
rb_intden_superafter_slow = table2array(T_rb_superafter_slow([1:2:height(T_rb_superafter_slow)],'RawIntDen')) - table2array(T_rb_superafter_slow([2:2:height(T_rb_superafter_slow)],'RawIntDen'));

median_gfp_before_slow = median(gfp_intden_before_slow);
median_rb_before_slow = median(rb_intden_before_slow);

completedata_slowframes = [gfp_intden_before_slow / median_gfp_before_slow; gfp_intden_during_slow / median_gfp_before_slow; gfp_intden_after_slow / median_gfp_before_slow;...
    rb_intden_before_slow / median_rb_before_slow; rb_intden_during_slow / median_rb_before_slow; rb_intden_after_slow / median_rb_before_slow; rb_intden_superafter_slow / median_rb_before_slow];
groups_slowframes = [1*ones(length(gfp_intden_before_slow),1); 2*ones(length(gfp_intden_during_slow),1); 3*ones(length(gfp_intden_after_slow),1);...
    4*ones(length(rb_intden_before_slow),1); 5*ones(length(rb_intden_during_slow),1); 6*ones(length(rb_intden_after_slow),1); 7*ones(length(rb_intden_superafter_slow),1)];

completedata_gfp = [completedata_gfp; gfp_intden_before_slow / median_gfp_before_slow; gfp_intden_during_slow / median_gfp_before_slow; gfp_intden_after_slow / median_gfp_before_slow; gfp_intden_superafter_slow / median_gfp_before_slow];
groups_gfp = [groups_gfp; 4*ones(length(gfp_intden_before_slow),1); 5*ones(length(gfp_intden_during_slow),1); 6*ones(length(gfp_intden_after_slow),1); 7*ones(length(gfp_intden_superafter_slow),1)];
completedata_rb = [completedata_rb; rb_intden_before_slow / median_rb_before_slow; rb_intden_during_slow / median_rb_before_slow; rb_intden_after_slow / median_rb_before_slow; rb_intden_superafter_slow / median_rb_before_slow];
groups_rb = [groups_rb; 4*ones(length(rb_intden_before_slow),1); 5*ones(length(rb_intden_during_slow),1); 6*ones(length(rb_intden_after_slow),1); 7*ones(length(rb_intden_superafter_slow),1)];

% figure
% boxplot(completedata_fastframes, groups_fastframes, 'Notch','on')
% xticklabels({'Dox-GFP, 0h','Dox-GFP, 10h','Dox-GFP, 21h','Dox-GFP-Rb, 0h','Dox-GFP-Rb, 10h','Dox-GFP-Rb, 21h'})
% ylabel('Normalized integrated intensity')
% title('Frames q5min')
% 
% figure
% boxplot(completedata_slowframes, groups_slowframes, 'Notch','on')
% xticklabels({'Dox-GFP, 0h','Dox-GFP, 10h','Dox-GFP, 21h','Dox-GFP-Rb, 0h','Dox-GFP-Rb, 10h','Dox-GFP-Rb, 21h'})
% ylabel('Normalized integrated intensity')
% title('Frames q30min')

figure
boxplot(completedata_gfp, groups_gfp, 'Notch','on')
xticklabels({'5min frames, 0h','5min frames, 10h','5min frames, 21h','30min frames, 0h','30min frames, 10h','30min frames, 22h','30min frames, 42h'})
ylabel('Normalized integrated intensity')
title('Dox-GFP')

figure
boxplot(completedata_rb, groups_rb, 'Notch','on')
xticklabels({'5min frames, 0h','5min frames, 10h','5min frames, 21h','30min frames, 0h','30min frames, 10h','30min frames, 22h','30min frames, 42h'})
ylabel('Normalized integrated intensity')
title('Dox-GFP-Rb')

%% ALSO DO STDERRS AND SEND TO EZ

mean_gfp_before_fast = mean(gfp_intden_before_fast);
stdev_gfp_before_fast = std(gfp_intden_before_fast);
mean_gfp_during_fast = mean(gfp_intden_during_fast);
stdev_gfp_during_fast = std(gfp_intden_during_fast);
mean_gfp_after_fast = mean(gfp_intden_after_fast);
stdev_gfp_after_fast = std(gfp_intden_after_fast);

mean_gfp_before_slow = mean(gfp_intden_before_slow);
stdev_gfp_before_slow = std(gfp_intden_before_slow);
mean_gfp_during_slow = mean(gfp_intden_during_slow);
stdev_gfp_during_slow = std(gfp_intden_during_slow);
mean_gfp_after_slow = mean(gfp_intden_after_slow);
stdev_gfp_after_slow = std(gfp_intden_after_slow);
mean_gfp_superafter_slow = mean(gfp_intden_superafter_slow);
stdev_gfp_superafter_slow = std(gfp_intden_superafter_slow);

mean_rb_before_fast = mean(rb_intden_before_fast);
stdev_rb_before_fast = std(rb_intden_before_fast);
mean_rb_during_fast = mean(rb_intden_during_fast);
stdev_rb_during_fast = std(rb_intden_during_fast);
mean_rb_after_fast = mean(rb_intden_after_fast);
stdev_rb_after_fast = std(rb_intden_after_fast);

mean_rb_before_slow = mean(rb_intden_before_slow);
stdev_rb_before_slow = std(rb_intden_before_slow);
mean_rb_during_slow = mean(rb_intden_during_slow);
stdev_rb_during_slow = std(rb_intden_during_slow);
mean_rb_after_slow = mean(rb_intden_after_slow);
stdev_rb_after_slow = std(rb_intden_after_slow);
mean_rb_superafter_slow = mean(rb_intden_superafter_slow);
stdev_rb_superafter_slow = std(rb_intden_superafter_slow);

mgbf = mean_gfp_before_fast;
mgbs = mean_gfp_before_slow;
mrbf = mean_rb_before_fast;
mrbs = mean_rb_before_slow;

figure
hold on
errorbar([0,10,22],[mean_gfp_before_fast / mgbf, mean_gfp_during_fast / mgbf, mean_gfp_after_fast / mgbf], [stdev_gfp_before_fast / mgbf, stdev_gfp_during_fast / mgbf, stdev_gfp_after_fast / mgbf])
errorbar([0,10,22],[mean_gfp_before_slow / mgbs, mean_gfp_during_slow / mgbs, mean_gfp_after_slow / mgbs], [stdev_gfp_before_slow / mgbs, stdev_gfp_during_slow / mgbs, stdev_gfp_after_slow / mgbs])
axis([-5 25 -2 10])
legend('Frames q5min','Frames q30min')
xlabel('Time (h)')
ylabel('Relative integrated fluorescence intensity')
title('Dox-GFP')

figure
hold on
errorbar([0,10,22],[mean_rb_before_fast / mrbf, mean_rb_during_fast / mrbf, mean_rb_after_fast / mrbf], [stdev_rb_before_fast / mrbf, stdev_rb_during_fast / mrbf, stdev_rb_after_fast / mrbf])
errorbar([0,10,22],[mean_rb_before_slow / mrbs, mean_rb_during_slow / mrbs, mean_rb_after_slow / mrbs], [stdev_rb_before_slow / mrbs, stdev_rb_during_slow / mrbs, stdev_rb_after_slow / mrbs])
axis([-5 25 -2 10])
legend('Frames q5min','Frames q30min')
xlabel('Time (h)')
ylabel('Relative integrated fluorescence intensity')
title('Dox-GFP-Rb')

figure
hold on
errorbar([0,10,22],[mean_gfp_before_fast / mgbf, mean_gfp_during_fast / mgbf, mean_gfp_after_fast / mgbf], [stdev_gfp_before_fast / mgbf, stdev_gfp_during_fast / mgbf, stdev_gfp_after_fast / mgbf])
errorbar([0,10,22,42],[mean_gfp_before_slow / mgbs, mean_gfp_during_slow / mgbs, mean_gfp_after_slow / mgbs, mean_gfp_superafter_slow / mgbs], [stdev_gfp_before_slow / mgbs, stdev_gfp_during_slow / mgbs, stdev_gfp_after_slow / mgbs, stdev_gfp_superafter_slow / mgbs])
axis([-5 45 -2 10])
legend('Frames q5min','Frames q30min')
xlabel('Time (h)')
ylabel('Relative integrated fluorescence intensity')
title('Dox-GFP')

figure
hold on
errorbar([0,10,22],[mean_rb_before_fast / mrbf, mean_rb_during_fast / mrbf, mean_rb_after_fast / mrbf], [stdev_rb_before_fast / mrbf, stdev_rb_during_fast / mrbf, stdev_rb_after_fast / mrbf])
errorbar([0,10,22,42],[mean_rb_before_slow / mrbs, mean_rb_during_slow / mrbs, mean_rb_after_slow / mrbs, mean_rb_superafter_slow / mrbs], [stdev_rb_before_slow / mrbs, stdev_rb_during_slow / mrbs, stdev_rb_after_slow / mrbs, stdev_rb_superafter_slow / mrbs])
axis([-5 45 -2 10])
legend('Frames q5min','Frames q30min')
xlabel('Time (h)')
ylabel('Relative integrated fluorescence intensity')
title('Dox-GFP-Rb')


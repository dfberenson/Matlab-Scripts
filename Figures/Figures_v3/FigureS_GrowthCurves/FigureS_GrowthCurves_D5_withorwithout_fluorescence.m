
clear all
close all

Cells_with = table2array(readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190212-190302_HMEC_D5_1 cell counts.xlsx','Sheet','DFB_190212 Fluorescence','ReadVariableNames',false));

normalize_individual_fields_of_view = false;

if normalize_individual_fields_of_view
Relative_with = Cells_with ./ Cells_with(1,:);
else
Relative_with = Cells_with ./ mean(Cells_with(1,:));
end

Mean_with = mean(Relative_with,2);

Stdev_with = std(Relative_with,0,2);

Stderr_with = std(Relative_with,0,2) / sqrt(size(Relative_with,1));
% 
% 
% figure
% hold on
% shadedErrorBar(0:12:60,Mean_with,Stdev_with,'k')
% 
% figure
% hold on
% box on
% shadedErrorBar(0:12:60,Mean_with,Stderr_with,'k')
% axis([0 inf 0 inf],'square')
% xticks([0 12 24 36 48 60])
% yticks([0 2 4 6 8])
% xlabel('Time (h)')
% ylabel('Fold change in cell number')


Cells_without = table2array(readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190212-190302_HMEC_D5_1 cell counts.xlsx','Sheet','DFB_190226 White','ReadVariableNames',false));

if normalize_individual_fields_of_view
Relative_without = Cells_without ./ Cells_without(1,:);
else
Relative_without = Cells_without ./ mean(Cells_without(1,:));
end

Mean_without = mean(Relative_without,2);

Stdev_without = std(Relative_without,0,2);

Stderr_without = std(Relative_without,0,2) / sqrt(size(Relative_without,1));

for t = 1:6
%     ttest2(Cells_with(t,:),Cells_without(t,:))
[this_h,this_p,this_ci,this_stats] = ttest2(Relative_with(t,:),Relative_without(t,:));
h(1,t) = this_h;
p(1,t) = this_p;
ci(:,t) = this_ci;
stats(1,t) = this_stats;
end

% 
% figure
% hold on
% shadedErrorBar(0:12:72,Mean_without,Stdev_without,'k')
% 
% figure
% hold on
% box on
% shadedErrorBar(0:12:72,Mean_without,Stderr_without,'k')
% axis([0 inf 0 inf],'square')
% xticks([0 12 24 36 48 60])
% yticks([0 2 4 6 8])
% xlabel('Time (h)')
% ylabel('Fold change in cell number')

figure
hold on
box on
shadedErrorBar(0:12:60,Mean_with,Stderr_with,'r')
shadedErrorBar(0:12:60,Mean_without(1:6),Stderr_without(1:6),'k')
% shadedErrorBar(0:12:60,Mean_without(1:6),Stderr_without(1:6),'k',1)
% Makes it transparent but rasterizes. Instead I just set it to 50% opacity
% in Illustrator.
axis([0 inf 0 inf],'square')
xticks([0 12 24 36 48 60])
yticks([0 2 4 6 8])
xlabel('Time (h)')
ylabel('Fold change in cell number')
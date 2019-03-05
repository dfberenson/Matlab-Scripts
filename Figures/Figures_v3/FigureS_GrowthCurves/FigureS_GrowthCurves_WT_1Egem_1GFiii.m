
clear all
close all

Cells_WT = table2array(readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190203_WT_1E_1GFiii_1 cell counts.xlsx','Sheet','WT','ReadVariableNames',false));
Cells_1Egem = table2array(readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190203_WT_1E_1GFiii_1 cell counts.xlsx','Sheet','1Egem','ReadVariableNames',false));
Cells_1GFiii = table2array(readtable('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190203_WT_1E_1GFiii_1 cell counts.xlsx','Sheet','1GFiii','ReadVariableNames',false));

Relative_WT = Cells_WT ./ Cells_WT(1,:);
Relative_1Egem = Cells_1Egem ./ Cells_1Egem(1,:);
Relative_1GFiii = Cells_1GFiii ./ Cells_1GFiii(1,:);

% Relative_WT = Cells_WT ./ Cells_WT(2,:);
% Relative_1Egem = Cells_1Egem ./ Cells_1Egem(2,:);
% Relative_1GFiii = Cells_1GFiii ./ Cells_1GFiii(2,:);

Mean_WT = mean(Relative_WT,2);
Mean_1Egem = mean(Relative_1Egem,2);
Mean_1GFiii = mean(Relative_1GFiii,2);

Stdev_WT = std(Relative_WT,0,2);
Stdev_1Egem = std(Relative_1Egem,0,2);
Stdev_1GFiii = std(Relative_1GFiii,0,2);

Stderr_WT = std(Relative_WT,0,2) / sqrt(size(Relative_WT,1));
Stderr_1Egem = std(Relative_1Egem,0,2) / sqrt(size(Relative_1Egem,1));
Stderr_1GFiii = std(Relative_1GFiii,0,2) / sqrt(size(Relative_1GFiii,1));


figure
hold on
shadedErrorBar(1:7,Mean_WT,Stdev_WT,'k')
shadedErrorBar(1:7,Mean_1Egem,Stdev_1Egem,'m')
shadedErrorBar(1:7,Mean_1GFiii,Stdev_1GFiii,'r')

figure
hold on
shadedErrorBar(1:7,Mean_WT,Stderr_WT,'k')
shadedErrorBar(1:7,Mean_1Egem,Stderr_1Egem,'m')
shadedErrorBar(1:7,Mean_1GFiii,Stderr_1GFiii,'r')

clear all
close all

median_mcherry = [222; 103; 205; 81; 129; 181; 134; 78; 51; 121];
fsc_r2 = [0.64; 0.56; 0.6; 0.54; 0.57; 0.55; 0.41; 0.35; 0.45; 0.51];

p = polyfit(median_mcherry,fsc_r2,1);

figure
box on
hold on
scatter(median_mcherry, fsc_r2, '+r')
plot(polyval(p,[0:250],'-r'))
axis([0 250 0 0.8],'square')
xlabel('Median mCherry')
ylabel('R^2 value')
yticks([0 0.4 0.8])
xticks([0 100 200])
title('Individual K562 clones')


clear all
close all

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')

volume_power = 1.5;

avg_volume = nanmean(data(1).all_instantaneous_g1_areas_unaveraged .^ 1.5);
avg_size = nanmean(data(1).all_instantaneous_g1_sizes_unaveraged);

figure
box on
hold on
scatter(data(1).all_instantaneous_g1_areas_unaveraged .^ volume_power / avg_volume, data(1).all_instantaneous_g1_sizes_unaveraged / avg_size, '.r');
scatter(data(1).all_instantaneous_sg2_areas_unaveraged .^ volume_power / avg_volume, data(1).all_instantaneous_sg2_sizes_unaveraged / avg_size, '.g');
xlabel('Nuclear volume')
ylabel('EF1-mCherry')
legend({'G1','SG2'})
axis([0 4 0 4],'square')
xticks([0:1:4])
yticks([0:1:4])
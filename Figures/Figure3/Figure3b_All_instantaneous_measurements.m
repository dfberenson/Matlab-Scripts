clear all
close all

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
% 
% figure
% hold on
% scatter(data(1).all_area_measurements .^ 1.5, data(1).all_size_measurements,'.k')
% xlabel('Nuclear volume')
% ylabel('prEF1a-mCherry-NLS')
% hold off

figure
hold on
scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

fitlm(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends)

% figure()
% hold on
% scatter(data(1).all_area_measurements .^ 1.5, data(1).all_size_measurements)
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends)
% xlabel('Nuclear volume')
% ylabel('prEF1a-mCherry-NLS')
% legend('All cells','Avoiding ends')
% hold off
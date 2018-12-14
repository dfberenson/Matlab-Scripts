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
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,10,data(1).whichcell_avoiding_ends)
colormap('colorcube')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

figure
hold on
x = data(1).all_area_measurements_avoiding_ends .^ 1.5 / mean(data(1).all_area_measurements_avoiding_ends .^ 1.5);
y = data(1).all_size_measurements_avoiding_ends / mean(data(1).all_size_measurements_avoiding_ends);
[values, centers] = hist3([x(:) y(:)],[251 251]);
imagesc(centers{:}, values.')
colormap(flipud(gray))
colorbar
axis xy

randomtenpercent = rand(length(data(1).all_area_measurements_avoiding_ends),1) < 0.05;

figure
hold on
scatter(data(1).all_area_measurements_avoiding_ends(randomtenpercent) .^ 1.5, data(1).all_size_measurements_avoiding_ends(randomtenpercent),'.k')
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,10,data(1).whichcell_avoiding_ends)
colormap('colorcube')
xlabel('Nuclear volume')
ylabel('prEF1a-mCherry-NLS')
hold off

num_cells_to_plot = 15;
% cells_to_plot = randperm(max(data(1).whichcell_avoiding_ends),num_cells_to_plot);
cells_to_plot = [4,12,49,59,92,98,103,132,135,142,151,158,170,176,207]
indices_to_plot = ismember(data(1).whichcell_avoiding_ends,cells_to_plot);

renumbered_cells_to_plot = zeros(length(data(1).whichcell_avoiding_ends),1);

for c = 1:length(cells_to_plot)
    cellnum = cells_to_plot(c);
    renumbered_cells_to_plot(find(data(1).whichcell_avoiding_ends == cellnum)) = c;
end

% figure
% hold on
% % scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
% scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
%     10,data(1).whichcell_avoiding_ends(indices_to_plot),'filled')
% % scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
% %     10,renumbered_cells_to_plot(indices_to_plot),'filled')
% colormap('jet')
% xlabel('Nuclear volume')
% ylabel('prEF1a-mCherry-NLS')
% hold off

figure
hold on
% scatter(data(1).all_area_measurements_avoiding_ends .^ 1.5, data(1).all_size_measurements_avoiding_ends,'.k')
% scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
%     10,data(1).whichcell_avoiding_ends(indices_to_plot),'filled')
scatter(data(1).all_area_measurements_avoiding_ends(indices_to_plot) .^ 1.5, data(1).all_size_measurements_avoiding_ends(indices_to_plot),...
    10,renumbered_cells_to_plot(indices_to_plot),'filled')
colormap('jet')
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
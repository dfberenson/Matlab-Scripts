
clear all
close all

xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_Pos21_manual_measurements.xlsx';
figure_folder = ['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\DFB_180501_Pos21_manual_measurements_Phasics'];
if ~exist(figure_folder,'dir')
    mkdir(figure_folder);
end

framerate = 1/12;

num_measurements_per_timepoint = 6;
smooth_factor = 13;

cells = struct;

cells_in_lineage = [2 5 6 7 8 9 10];
num_cells_in_lineage = length(cells_in_lineage);
lineage.ancestor_num = 2;
lineage.first_gen_descendant1_num = 5;
lineage.first_gen_descendant2_num = 6;
lineage.second_gen_descendant1_of_first_gen_descendant1 = 7;
lineage.second_gen_descendant2_of_first_gen_descendant1 = 8;
lineage.second_gen_descendant1_of_first_gen_descendant2 = 9;
lineage.second_gen_descendant2_of_first_gen_descendant2 = 10;

for c = cells_in_lineage
    T = readtable(xlsx_fpath,'Sheet',num2str(c));
    cells(c).raw_int_densities = table2array(T(:,{'RawIntDen'}));
    [cells(c).len,~] = size(T);
    cells(c).adj_len = cells(c).len / num_measurements_per_timepoint;
end


total_len = cells(lineage.ancestor_num).len + max(cells(lineage.first_gen_descendant1_num).len, cells(lineage.first_gen_descendant2_num).len);
if num_cells_in_lineage > 3
    first_gen_descendant1_lineage_len = cells(lineage.first_gen_descendant1_num).len +...
        max(cells(lineage.second_gen_descendant1_of_first_gen_descendant1).len,...
        cells(lineage.second_gen_descendant2_of_first_gen_descendant1).len);
    first_gen_descendant2_lineage_len = cells(lineage.first_gen_descendant2_num).len +...
        max(cells(lineage.second_gen_descendant1_of_first_gen_descendant2).len,...
        cells(lineage.second_gen_descendant2_of_first_gen_descendant2).len);
    total_len = cells(lineage.ancestor_num).len + max(first_gen_descendant1_lineage_len, first_gen_descendant2_lineage_len);
end

cells(lineage.ancestor_num).frames = 1:cells(lineage.ancestor_num).adj_len;
cells(lineage.first_gen_descendant1_num).frames = ...
    cells(lineage.ancestor_num).adj_len + 1 : cells(lineage.ancestor_num).adj_len + cells(lineage.first_gen_descendant1_num).adj_len;
cells(lineage.first_gen_descendant2_num).frames = ...
    cells(lineage.ancestor_num).adj_len + 1 : cells(lineage.ancestor_num).adj_len + cells(lineage.first_gen_descendant2_num).adj_len;
if num_cells_in_lineage > 3
    cells(lineage.second_gen_descendant1_of_first_gen_descendant1).frames = ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant1_num).adj_len + 1 : ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant1_num).adj_len + ...
        cells(lineage.second_gen_descendant1_of_first_gen_descendant1).adj_len;
    cells(lineage.second_gen_descendant2_of_first_gen_descendant1).frames = ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant1_num).adj_len + 1 : ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant1_num).adj_len + ...
        cells(lineage.second_gen_descendant2_of_first_gen_descendant1).adj_len;
    cells(lineage.second_gen_descendant1_of_first_gen_descendant2).frames = ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant2_num).adj_len + 1 : ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant2_num).adj_len + ...
        cells(lineage.second_gen_descendant1_of_first_gen_descendant2).adj_len;
    cells(lineage.second_gen_descendant2_of_first_gen_descendant2).frames = ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant2_num).adj_len + 1 : ...
        cells(lineage.ancestor_num).adj_len + ...
        cells(lineage.first_gen_descendant2_num).adj_len + ...
        cells(lineage.second_gen_descendant2_of_first_gen_descendant2).adj_len;
end

total_frames = total_len / num_measurements_per_timepoint;
timepoints = 0 : framerate : framerate * (total_frames-1);

for c = cells_in_lineage
        cells(c).measurements = zeros(total_frames,num_measurements_per_timepoint);
end

% Create a Measurements matrix for each cell, with each row being a
% timepoint and columns 1, 3, and 4 corresponding to Phase, GFP, and
% mCherry measurements.
for i = 1:total_frames
    for c = cells_in_lineage
        if ismember(i, cells(c).frames)
            for m = 1:num_measurements_per_timepoint
                cells(c).measurements(i,m) = cells(c).raw_int_densities(num_measurements_per_timepoint*(i - min(cells(c).frames) + 1) - num_measurements_per_timepoint + m);
            end
        end
    end
end

for c = cells_in_lineage
    cells(c).smooth = movmedian(cells(c).measurements, smooth_factor);
end

mCherry_multiplication_factor = 3;

for f = 1:6
    figure(f)
    hold on
    for c = cells_in_lineage
        if c == lineage.ancestor_num
            linestyle_black = '--k';
            linestyle_green = '--g';
            linestyle_red = '--r';
        elseif c == lineage.first_gen_descendant1_num
            linestyle_black = '-k';
            linestyle_green = '-g';
            linestyle_red = '-r';
        elseif c == lineage.first_gen_descendant2_num
            linestyle_black = ':k';
            linestyle_green = ':g';
            linestyle_red = ':r';
        elseif c == lineage.second_gen_descendant1_of_first_gen_descendant1
            linestyle_black = '-.k';
            linestyle_green = '-.g';
            linestyle_red = '-.r';
        elseif c == lineage.second_gen_descendant2_of_first_gen_descendant1
            linestyle_black = '-.k';
            linestyle_green = '-.g';
            linestyle_red = '-.r';
        elseif c == lineage.second_gen_descendant1_of_first_gen_descendant2
            linestyle_black = '-.b';
            linestyle_green = '-.c';
            linestyle_red = '-.m';
        elseif c == lineage.second_gen_descendant2_of_first_gen_descendant2
            linestyle_black = '-.b';
            linestyle_green = '-.c';
            linestyle_red = '-.m';
        end
        
        if f == 1
            plot(timepoints, cells(c).measurements(:,1), linestyle_black);
            plot(timepoints, cells(c).measurements(:,3), linestyle_green);
            plot(timepoints, cells(c).measurements(:,4), linestyle_red);
            legend('Raw phase','Raw GFP','Raw mCherry')
        elseif f == 2
            plot(timepoints, cells(c).measurements(:,1) - cells(c).measurements(:,2), linestyle_black);
            plot(timepoints, cells(c).measurements(:,3) - cells(c).measurements(:,5), linestyle_green);
            plot(timepoints, cells(c).measurements(:,4) - cells(c).measurements(:,6), linestyle_red);
            legend('Corrected phase','Corrected GFP','Corrected mCherry')
        elseif f == 3
            plot(timepoints, cells(c).measurements(:,1) - cells(c).measurements(:,2), linestyle_black);
            plot(timepoints, cells(c).measurements(:,3) - cells(c).measurements(:,5), linestyle_green);
            plot(timepoints, (cells(c).measurements(:,4) - cells(c).measurements(:,6))*mCherry_multiplication_factor, linestyle_red);
            legend('Corrected phase','Corrected GFP',['Corrected mCherry * ' num2str(mCherry_multiplication_factor)])
        elseif f == 4
            plot(timepoints, cells(c).smooth(:,1), linestyle_black);
            plot(timepoints, cells(c).smooth(:,3), linestyle_green);
            plot(timepoints, cells(c).smooth(:,4), linestyle_red);
            legend('Smooth Raw phase','Smooth Raw GFP','Smooth Raw mCherry')
        elseif f == 5
            plot(timepoints, cells(c).smooth(:,1) - cells(c).smooth(:,2), linestyle_black);
            plot(timepoints, cells(c).smooth(:,3) - cells(c).smooth(:,5), linestyle_green);
            plot(timepoints, cells(c).smooth(:,4) - cells(c).smooth(:,6), linestyle_red);
            legend('Smooth Corrected phase','Smooth Corrected GFP','Smooth Corrected mCherry')
        elseif f == 6
            plot(timepoints, cells(c).smooth(:,1) - cells(c).smooth(:,2), linestyle_black);
            plot(timepoints, cells(c).smooth(:,3) - cells(c).smooth(:,5), linestyle_green);
            plot(timepoints, (cells(c).smooth(:,4) - cells(c).smooth(:,6))*mCherry_multiplication_factor, linestyle_red);
            legend('Smooth Corrected phase','Smooth Corrected GFP',['Smooth mCherry * ' num2str(mCherry_multiplication_factor)])   
        end    
    end
    xlabel('Time (h)')
    ylabel('Integrated intensity (AU)')
    saveas(gcf, [figure_folder '\Cell_' num2str(lineage.ancestor_num) '_Figure_' num2str(f) '.png'])
end
        



clear all
close all

load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')

framerate = 1/6;
average_instantaneous_growth_rate_over_num_frames = 3;

all_cell_classes_to_plot =  {'all_good','G1_cells_good','SG2_cells_good'};
all_cell_classes_to_plot =  {'all_good'};

for cond = 1:2
    for cell_class_to_plot = all_cell_classes_to_plot;
        
        if strcmp(cell_class_to_plot,'all_good')
            X = data(cond).all_instantaneous_size_measurements_avoiding_ends_nolast;
            Y = data(cond).all_instantaneous_size_increase_measurements_avoiding_ends;
            graph_title = [data(cond).treatment ', all pairwise measurements'];
            is_there_something_to_plot = true;
        elseif(strcmp(cell_class_to_plot,'G1_cells_good'))
            X = data(cond).all_instantaneous_g1_sizes_nolast;
            Y = data(cond).all_instantaneous_g1_size_increases;
            graph_title = [data(cond).treatment ', G1 pairwise measurements'];
            is_there_something_to_plot = true;
        elseif(strcmp(cell_class_to_plot,'SG2_cells_good'))
            X = data(cond).all_instantaneous_sg2_sizes_nolast;
            Y = data(cond).all_instantaneous_sg2_size_increases;
            graph_title = [data(cond).treatment ', SG2 pairwise measurements'];
            is_there_something_to_plot = true;
        end
        
        % X values are the average size for timepoints 1 and 4, ie
        % estimated size at timepoint 2.5
        % Y values are difference in size between timepoints 1 and 4, ie
        % estimated slope at timepoint 2.5
        
        % If size(t=1) is 0, then size(t=2.5) is size(t=4)/2 and slope is
        % size(t=4)
        % If size(t=4) is 0, then size(t=2.5) is size(t=1)/2 and slope is
        % -size(t=1)
        % The result is an artifact at Y = 2X and Y = -2X.
        % I censored these timepoints below.
        bad_indices = (Y == 2*X | Y == -2*X);
        clean_X = X(~bad_indices);
        clean_Y = Y(~bad_indices);
        
        % Scale x and y axes so 1 AU is the mean X size
        clean_Y = clean_Y / mean(clean_X);
        clean_X = clean_X / mean(clean_X);
        
%         fitlm(clean_X,clean_Y)
        
        figure
        hold on
        scatter(clean_X, clean_Y, 0.01, '.k')
        bin_sizes = linspace(prctile(clean_X,5),prctile(clean_X,95),20);
        [means,stdevs,stderrs] = bindata(clean_X, clean_Y, bin_sizes);
        errorbar(bin_sizes,means,stderrs,'r','LineWidth',2)
        axis([prctile(clean_X,2.5) prctile(clean_X,97.5), prctile(clean_Y,2.5) prctile(clean_Y,97.5)])
        x_axis_label = 'prEF1a-mCrimson-NLS (AU)';
        y_axis_label = ['Instantaneous growth rate (AU/' num2str(60 * framerate * average_instantaneous_growth_rate_over_num_frames) 'min)'];
        title(gca,graph_title)
        xlabel(gca,x_axis_label)
        ylabel(gca,y_axis_label)
        
        % Convert growth units from (30m)^-1 to (20h)^-1
        scaled_clean_Y = clean_Y*20/(framerate * average_instantaneous_growth_rate_over_num_frames);
        
        fitlm(clean_X,scaled_clean_Y)
        
        figure
        hold on
        scatter(clean_X, scaled_clean_Y, 0.01, '.k')
        bin_sizes = linspace(prctile(clean_X,5),prctile(clean_X,95),20);
        [means,stdevs,stderrs] = bindata(clean_X, scaled_clean_Y, bin_sizes);
        errorbar(bin_sizes,means,stderrs,'r','LineWidth',2)
        axis([prctile(clean_X,2.5) prctile(clean_X,97.5), prctile(scaled_clean_Y,2.5) prctile(scaled_clean_Y,97.5)])
        x_axis_label = 'prEF1a-mCrimson-NLS (AU)';
        y_axis_label = ['Scaled instantaneous growth rate (AU/20h)'];
        title(gca,graph_title)
        xlabel(gca,x_axis_label)
        ylabel(gca,y_axis_label)
        
    end
end


% figure
% hold on
% scatter(X,Y)
% scatter(clean_X,clean_Y)
% scatter(X,2*X,'.k')
% scatter(X,-2*X,'.k')

clear all
close all

%% Initalize variables
all_data = struct;

source_folder = 'F:\DFB_imaging_experiments';
source_folder = 'I:\';
expt_name = 'DFB_180712_HMEC_1GFiii_phototox_1';
expt_type = 'before';
infix = '_MMStack_Pos';
suffixes = '.ome.tif';
max_stack_num = 0;
framerate = 3;
startframe = 1;
palbo_conc = 0;
hours_after_drug_addition_to_expt_start = 0;
drug_addition_after_frames = [0];
drug_addition_after_hours = 0;

order_of_colors = 'rgp';

gaussian_width = 2;
segmentation_threshold = 150;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

if ~exist([source_folder '\' expt_name  '\Segmentation'],'dir')
    mkdir([source_folder '\' expt_name   '\Segmentation']);
end

max_area = 900;
geminin_threshold = 135;

fileID = fopen([source_folder '\' expt_name '\Segmentation\Segmentation_Parameters.txt'],'w');
fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
fprintf(fileID,['Segmentation threshold > ' num2str(segmentation_threshold) '\r\n']);
fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['Max area: ' num2str(max_area) '\r\n']);
fprintf(fileID,['Geminin threshold: ' num2str(geminin_threshold) '\r\n']);
fclose(fileID);

cond1_title = 'MEGM medium with constant mCherry illumination';
cond2_title = 'MEGM medium';
cond3_title = 'MEGM medium replaced q24h';

cond1_pos_start = 1;
cond1_pos_end = 8;
cond2_pos_start = 9;
cond2_pos_end = 16;
cond3_pos_start = 17;
cond3_pos_end = 24;

overall_pos_start = min([cond1_pos_start,cond2_pos_start,cond3_pos_start]);
overall_pos_end = max([cond1_pos_end,cond2_pos_end,cond3_pos_end]);

cond1_positions = cond1_pos_start:cond1_pos_end;
cond2_positions = cond2_pos_start:cond2_pos_end;
cond3_positions = cond3_pos_start:cond3_pos_end;

% PBS_positions = [1 2 3 5 6 7 8 9 10 11 12];

overall_positions = [cond1_positions cond2_positions cond3_positions];


%% Go through each position to make measurements
tic
for pos = overall_positions
    close all
    position = num2str(pos);
    
    imstack0_length = 0;
    imstack1_length = 0;
    imstack2_length = 0;
    imstack3_length = 0;
    
    imstack0 = readStack([source_folder '\' expt_name '\' expt_name infix position suffixes]);
    [~,~,imstack0_length] = size(imstack0);
    if max_stack_num > 0
        imstack1 = readStack([source_folder '\' expt_name '\' expt_name infix position '_1' suffixes]);
        [~,~,imstack1_length] = size(imstack1);
        if max_stack_num > 1
            imstack2 = readStack([source_folder '\' expt_name '\' expt_name infix position '_2' suffixes]);
            [~,~,imstack2_length] = size(imstack2);
            if max_stack_num > 2
                imstack3 = readStack([source_folder '\' expt_name '\' expt_name infix position '_3' suffixes]);
                [~,~,imstack3_length] = size(imstack3);
            end
        end
    end
    
    imstack_complete_length = imstack0_length + imstack1_length + imstack2_length + imstack3_length;
    
    if strcmp(order_of_colors, 'prg_skip_pg')
        endframe = imstack_complete_length / 4;
        
        for i = startframe:endframe
            disp(['Position ' position '. Segmenting frame ' num2str(i)]);
            if i <= imstack0_length / 4
                raw_ch2 = imstack0(:,:,4*i-2);
                raw_ch3 = imstack0(:,:,4*i-1);
            end
            raw_red = raw_ch2;
            raw_green = raw_ch3;
            %     figure,imshow(raw_red,[])
            gaussian_filtered = imgaussfilt(raw_red,gaussian_width);
            %     figure,imshow(gaussian_filtered,[])
            thresholded = gaussian_filtered > segmentation_threshold;
            %     figure,imshow(thresholded)
            im_opened = imopen(thresholded,se);
            %     figure,imshow(im_opened)
            im_closed = imclose(im_opened,se);
            %     figure,imshow(im_closed)
            
            segmented_im = im_closed;
            [L,n] = bwlabel(segmented_im,4);
            
            if mod(i, 20) == 0
                figure,imshow(raw_red,[])
                figure,imshow(segmented_im)
            end
            
            for j = 1:n
                thiscellmask = L == j;
                label_props = regionprops(thiscellmask,'Area');
                raw_red_props = regionprops(thiscellmask, raw_red, 'MeanIntensity');
                raw_green_props = regionprops(thiscellmask, raw_green, 'MeanIntensity');
                
                areas(i,j) = label_props.Area;
                raw_red_means(i,j) = raw_red_props.MeanIntensity;
                raw_green_means(i,j) = raw_green_props.MeanIntensity;
            end
        end
    else
        endframe = imstack_complete_length / 3;
        
        for  i = startframe:endframe
            disp(['Position ' position '. Segmenting frame ' num2str(i)]);
            
            if i <= imstack0_length/3
                raw_ch1 = imstack0(:,:,3*i-2);
                raw_ch2 = imstack0(:,:,3*i-1);
                raw_ch3 = imstack0(:,:,3*i-0);
            elseif i <= (imstack0_length + imstack1_length)/3
                raw_ch1 = imstack1(:,:,3*(i-imstack0_length/3)-2);
                raw_ch2 = imstack1(:,:,3*(i-imstack0_length/3)-1);
                raw_ch3 = imstack1(:,:,3*(i-imstack0_length/3)-0);
            elseif i <= (imstack0_length + imstack1_length + imstack2_length)/3
                raw_ch1 = imstack2(:,:,3*(i-imstack0_length/3-imstack1_length/3)-2);
                raw_ch2 = imstack2(:,:,3*(i-imstack0_length/3-imstack1_length/3)-1);
                raw_ch3 = imstack2(:,:,3*(i-imstack0_length/3-imstack1_length/3)-0);
            elseif i <= (imstack0_length + imstack1_length + imstack2_length + imstack3_length)/3
                raw_ch1 = imstack3(:,:,3*(i-imstack0_length/3-imstack1_length/3-imstack2_length/3)-2);
                raw_ch2 = imstack3(:,:,3*(i-imstack0_length/3-imstack1_length/3-imstack2_length/3)-1);
                raw_ch3 = imstack3(:,:,3*(i-imstack0_length/3-imstack1_length/3-imstack2_length/3)-0);
            end
            
            if strcmp(order_of_colors, 'prg')
                raw_red = raw_ch2;
                raw_green = raw_ch3;
            elseif strcmp(order_of_colors, 'pgr')
                raw_green = raw_ch2;
                raw_red = raw_ch3;
            elseif strcmp(order_of_colors, 'rgp')
                raw_red = raw_ch1;
                raw_green = raw_ch2;
            end
            %     figure,imshow(raw_red,[])
            gaussian_filtered = imgaussfilt(raw_red,gaussian_width);
            %     figure,imshow(gaussian_filtered,[])
            thresholded = gaussian_filtered > segmentation_threshold;
            %     figure,imshow(thresholded)
            im_opened = imopen(thresholded,se);
            %     figure,imshow(im_opened)
            im_closed = imclose(im_opened,se);
            %     figure,imshow(im_closed)
            
            segmented_im = im_closed;
            [L,n] = bwlabel(segmented_im,4);
            
            if mod(i, 20) == 0
                figure,imshow(raw_red,[])
                figure,imshow(segmented_im)
            end
            
            for j = 1:n
                thiscellmask = L == j;
                label_props = regionprops(thiscellmask,'Area');
                raw_red_props = regionprops(thiscellmask, raw_red, 'MeanIntensity');
                raw_green_props = regionprops(thiscellmask, raw_green, 'MeanIntensity');
                
                areas(i,j) = label_props.Area;
                raw_red_means(i,j) = raw_red_props.MeanIntensity;
                raw_green_means(i,j) = raw_green_props.MeanIntensity;
            end           
        end
    end
    
    all_data(pos).areas = areas;
    all_data(pos).raw_red_means = raw_red_means;
    all_data(pos).raw_green_means = raw_green_means;
    
    clear imstack0
    clear imstack1
    clear imstack2
    clear imstack3
    clear areas
    clear raw_red_means
    clear raw_green_means
    
end

toc

%% Count cells and make plots for each position
% Start here if all_data is already loaded

timepoints = hours_after_drug_addition_to_expt_start : 1*framerate : hours_after_drug_addition_to_expt_start + (endframe-1)*framerate;
max_total_cells = 0;

figure_folder = ['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\' expt_name];
if ~exist(figure_folder,'dir')
    mkdir(figure_folder);
end

for pos = overall_positions
    position = num2str(pos);
    
    clear areas
    clear raw_red_means
    clear raw_green_means
    clear positive_areas
    clear singlecells
    clear sg2_cells
    clear total_cells
    
    areas = all_data(pos).areas;
    raw_red_means = all_data(pos).raw_red_means;
    raw_green_means = all_data(pos).raw_green_means;
    
    positive_areas = areas > 0;
    
    %     figure,histogram(areas(positive_areas));
    %     figure,histogram(raw_red_means(positive_areas));
    %     figure,histogram(raw_green_means(positive_areas));
    
    singlecells = areas > 0 & areas < max_area;
    
    %     figure,histogram(areas(singlecells));
    %     figure,histogram(raw_red_means(singlecells));
    %     figure,histogram(raw_green_means(singlecells));
    
    for i = startframe:endframe
        sg2_cells(i) = sum((raw_green_means(i,:) > geminin_threshold) .* singlecells(i,:));
        total_cells(i) = sum(singlecells(i,:));
    end
    
    all_data(pos).sg2_cells = sg2_cells;
    all_data(pos).total_cells = total_cells;
    max_total_cells = max(max_total_cells, max(total_cells));
    
    figure,plot(timepoints, sg2_cells(startframe:endframe)./total_cells(startframe:endframe))
    hold on
    for drug_addition_time = 1:length(drug_addition_after_hours)
        line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
            [0 1], 'Color', 'k')
    end
    hold off
    if strcmp(expt_type, 'before')
        xlabel('Time since imaging start (h)')
    elseif pos >= PBS_pos_start && pos <= PBS_pos_end
        xlabel('Time since PBS addition (h)')
    elseif pos >= palbo_pos_start && pos <= palbo_pos_end
        xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
    end
    ylabel('Fraction of Geminin+ cells')
    saveas(gcf, [figure_folder '\Pos' position '_FractionSG2.png'])
    
    figure,plot(timepoints, total_cells(startframe:endframe))
    hold on
    for drug_addition_time = 1:length(drug_addition_after_hours)
        line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
            [0 max_total_cells], 'Color', 'k')
    end
    hold off
    if strcmp(expt_type, 'before')
        xlabel('Time since imaging start (h)')
    elseif pos >= PBS_pos_start && pos <= PBS_pos_end
        xlabel('Time since PBS addition (h)')
    elseif pos >= palbo_pos_start && pos <= palbo_pos_end
        xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
    end
    ylabel('Number of cells')
    saveas(gcf, [figure_folder '\Pos' position '_NumberOfCells.png'])
    
    close all
end
%% Save data

save([figure_folder '\' expt_name '.mat'], 'source_folder', 'expt_name', 'infix', 'suffixes','expt_type',...
    'framerate','startframe','endframe','hours_after_drug_addition_to_expt_start','drug_addition_after_hours',...
    'cond1_positions', 'cond2_positions', 'cond3_positions', 'overall_positions', 'segmentation_threshold', 'max_area', 'geminin_threshold',...
    'order_of_colors','all_data')

% save([figure_folder '\' expt_name '.mat'], 'source_folder', 'expt_name', 'infix', 'suffixes','expt_type',...
%     'framerate','startframe','endframe','hours_after_drug_addition_to_expt_start','drug_addition_after_hours',...
%     'no_refresh_start', 'no_refresh_end', 'refresh_q48h_start', 'refresh_q48h_end', 'refresh_q24h_start', 'refresh_q24h_end', 'segmentation_threshold', 'max_area', 'geminin_threshold',...
%     'order_of_colors','all_data')

%% Plot all positions combined for PBS/palbo comparison

% Combine data across positions
for i = startframe:endframe
    all_sg2_cells_cond1(i) = 0;
    all_total_cells_cond1(i) = 0;
    for pos = cond1_positions
        all_sg2_cells_cond1(i) = all_sg2_cells_cond1(i) + all_data(pos).sg2_cells(i);
        all_total_cells_cond1(i) = all_total_cells_cond1(i) + all_data(pos).total_cells(i);
    end
    all_sg2_cells_cond2(i) = 0;
    all_total_cells_cond2(i) = 0;
    for pos = cond2_positions
        all_sg2_cells_cond2(i) = all_sg2_cells_cond2(i) + all_data(pos).sg2_cells(i);
        all_total_cells_cond2(i) = all_total_cells_cond2(i) + all_data(pos).total_cells(i);
    end
    all_sg2_cells_cond3(i) = 0;
    all_total_cells_cond3(i) = 0;
    for pos = cond3_positions
        all_sg2_cells_cond3(i) = all_sg2_cells_cond3(i) + all_data(pos).sg2_cells(i);
        all_total_cells_cond3(i) = all_total_cells_cond3(i) + all_data(pos).total_cells(i);
    end
end


% Plot
figure,plot(timepoints, all_sg2_cells_cond1(startframe:endframe)./all_total_cells_cond1(startframe:endframe))
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 1], 'Color', 'k')
end
hold off
xlabel('Time since PBS addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title(cond1_title)
saveas(gcf, [figure_folder '\All_cond1_positions_FractionSG2.png'])

figure,plot(timepoints, all_sg2_cells_cond2(startframe:endframe)./all_total_cells_cond2(startframe:endframe))
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 1], 'Color', 'k')
end
hold off
xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title(cond2_title)
saveas(gcf, [figure_folder '\All_cond2_positions_FractionSG2.png'])

figure,plot(timepoints, all_sg2_cells_cond3(startframe:endframe)./all_total_cells_cond3(startframe:endframe))
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 1], 'Color', 'k')
end
hold off
xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title(cond3_title)
saveas(gcf, [figure_folder '\All_cond3_positions_FractionSG2.png'])

figure,plot(timepoints, all_total_cells_cond1(startframe:endframe)./length(cond1_positions))
% Divide by number of corresponding positions to normalize per position
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 max_total_cells], 'Color', 'k')
end
hold off
xlabel('Time since PBS addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title(cond1_title)
saveas(gcf, [figure_folder '\All_cond1_positions_TotalCells.png'])

figure,plot(timepoints, all_total_cells_cond2(startframe:endframe)./length(cond2_positions))
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 max_total_cells], 'Color', 'k')
end
hold off
xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title(cond2_title)
saveas(gcf, [figure_folder '\All_cond2_positions_TotalCells.png'])

figure,plot(timepoints, all_total_cells_cond3(startframe:endframe)./length(cond3_positions))
hold on
for drug_addition_time = 1:length(drug_addition_after_hours)
    line([drug_addition_after_hours(drug_addition_time) drug_addition_after_hours(drug_addition_time)],...
        [0 max_total_cells], 'Color', 'k')
end
hold off
xlabel(['Time since ' num2str(palbo_conc) 'nM palbo addition (h)'])
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title(cond3_title)
saveas(gcf, [figure_folder '\All_cond3_positions_TotalCells.png'])

%% Plot all positions combined for refresh/no refresh comparison

% % Combine data across positions
% for i = startframe:endframe
%     all_sg2_cells_no_refresh(i) = 0;
%     all_total_cells_no_refresh(i) = 0;
%     for pos = no_refresh_start:no_refresh_end
%         all_sg2_cells_no_refresh(i) = all_sg2_cells_no_refresh(i) + all_data(pos).sg2_cells(i);
%         all_total_cells_no_refresh(i) = all_total_cells_no_refresh(i) + all_data(pos).total_cells(i);
%     end
%     all_sg2_cells_refresh_q48h(i) = 0;
%     all_total_cells_refresh_q48h(i) = 0;
%     for pos = refresh_q48h_start:refresh_q48h_end
%         all_sg2_cells_refresh_q48h(i) = all_sg2_cells_refresh_q48h(i) + all_data(pos).sg2_cells(i);
%         all_total_cells_refresh_q48h(i) = all_total_cells_refresh_q48h(i) + all_data(pos).total_cells(i);
%     end
%     all_sg2_cells_refresh_q24h(i) = 0;
%     all_total_cells_refresh_q24h(i) = 0;
%     for pos = refresh_q24h_start:refresh_q24h_end
%         all_sg2_cells_refresh_q24h(i) = all_sg2_cells_refresh_q24h(i) + all_data(pos).sg2_cells(i);
%         all_total_cells_refresh_q24h(i) = all_total_cells_refresh_q24h(i) + all_data(pos).total_cells(i);
%     end
% end

%
% % Plot
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_sg2_cells_no_refresh(startframe:endframe)./all_total_cells_no_refresh(startframe:endframe))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Fraction of Geminin+ cells')
% title('No media refresh')
% saveas(gcf, [figure_folder '\NoMediaRefresh_FractionSG2.png'])
%
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_sg2_cells_refresh_q48h(startframe:endframe)./all_total_cells_refresh_q48h(startframe:endframe))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Fraction of Geminin+ cells')
% title('Media refresh q48h')
% saveas(gcf, [figure_folder '\Refresh_q48h_FractionSG2.png'])
%
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_sg2_cells_refresh_q24h(startframe:endframe)./all_total_cells_refresh_q24h(startframe:endframe))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Fraction of Geminin+ cells')
% title('Media refresh q24h')
% saveas(gcf, [figure_folder '\Refresh_q24h_FractionSG2.png'])
%
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_total_cells_no_refresh(startframe:endframe)./(no_refresh_end - no_refresh_start + 1))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Average number of cells per position')
% title('No media refresh')
% saveas(gcf, [figure_folder '\NoMediaRefresh_TotalCells.png'])
%
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_total_cells_refresh_q48h(startframe:endframe)./(refresh_q48h_end - refresh_q48h_start + 1))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Average number of cells per position')
% title('Media refresh q48h')
% saveas(gcf, [figure_folder '\Refresh_q48h_TotalCells.png'])
%
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_total_cells_refresh_q24h(startframe:endframe)./(refresh_q24h_end - refresh_q24h_start + 1))
% xlabel('Time since PBS addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Average number of cells per position')
% title('Media refresh q24h')
% saveas(gcf, [figure_folder '\Refresh_q24h_TotalCells.png'])
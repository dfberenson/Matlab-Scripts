%% Initalize variables
all_data = struct;

source_folder = 'F:\DFB_imaging_experiments';
expt_name = 'DFB_180621_HMEC_1GFiii_lowexposure_1';
expt_type = 'before';
infix = '_MMStack_Pos';
suffixes = '.ome.tif';
framerate = 1/1;
startframe = 1;

% Don't forget to change the order of colors if necessary. Look for this
% comment text below.

gaussian_width = 2;
segmentation_threshold = 160;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

if ~exist([source_folder '\' expt_name  '\Segmentation'],'dir')
    mkdir([source_folder '\' expt_name   '\Segmentation']);
end

max_area = 900;
geminin_threshold = 400;

fileID = fopen([source_folder '\' expt_name '\Segmentation\Segmentation_Parameters.txt'],'w');
fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
fprintf(fileID,['Segmentation threshold > ' num2str(segmentation_threshold) '\r\n']);
fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['Max area: ' num2str(max_area) '\r\n']);
fprintf(fileID,['Geminin threshold: ' num2str(geminin_threshold) '\r\n']);
fclose(fileID);

% dmso_pos_start = 1;
% dmso_pos_end = 6;
% palbo_pos_start = 1;
% palbo_pos_end = 6;

% overall_pos_start = min(dmso_pos_start, palbo_pos_start);
% overall_pos_end = max(dmso_pos_end, palbo_pos_end);

no_refresh_start = 1;
no_refresh_end = 6;
refresh_q48h_start = 7;
refresh_q48h_end = 12;
refresh_q24h_start = 13;
refresh_q24h_end = 18;

overall_pos_start = min([no_refresh_start, refresh_q48h_start, refresh_q24h_start]);
overall_pos_end = max([no_refresh_end, refresh_q48h_end, refresh_q24h_end]);

%% Go through each position to make measurements
tic
% for pos = overall_pos_start:overall_pos_end
for pos = refresh_q24h_start:refresh_q24h_end
    
    close all
    position = num2str(pos);

    imstack0_length = 0;
    imstack1_length = 0;
    imstack2_length = 0;
    imstack3_length = 0;
    
    imstack0 = readStack([source_folder '\' expt_name '\' expt_name infix position suffixes]);
%     imstack1 = readStack([source_folder '\' expt_name '\' expt_name infix position '_1' suffixes]);
%     imstack2 = readStack([source_folder '\' expt_name '\' expt_name infix position '_2' suffixes]);
%     imstack3 = readStack([source_folder '\' expt_name '\' expt_name infix position '_3' suffixes]);
    
    [~,~,imstack0_length] = size(imstack0);
%     [~,~,imstack1_length] = size(imstack1);
%     [~,~,imstack2_length] = size(imstack2);
%     [~,~,imstack3_length] = size(imstack3);
%     
    imstack_complete_length = imstack0_length + imstack1_length + imstack2_length + imstack2_length;

    endframe = imstack_complete_length / 3;
    
    for  i = startframe:endframe
        disp(['Position ' position '. Segmenting frame ' num2str(i)]);
        
        if i <= imstack0_length/3
            raw_ch2 = imstack0(:,:,3*i-1);
            raw_ch3 = imstack0(:,:,3*i-0);
        elseif i <= (imstack0_length + imstack1_length)/3
            raw_ch2 = imstack1(:,:,3*(i-imstack0_length/3)-1);
            raw_ch3 = imstack1(:,:,3*(i-imstack0_length/3)-0);
        elseif i <= (imstack0_length + imstack1_length + imstack2_length)/3
            raw_ch2 = imstack2(:,:,3*(i-imstack0_length/3-imstack1_length/3)-1);
            raw_ch3 = imstack2(:,:,3*(i-imstack0_length/3-imstack1_length/3)-0);
        elseif i <= (imstack0_length + imstack1_length + imstack2_length + imstack3_length)/3
            raw_ch2 = imstack3(:,:,3*(i-imstack0_length/3-imstack1_length/3-imstack2_length/3)-1);
            raw_ch3 = imstack3(:,:,3*(i-imstack0_length/3-imstack1_length/3-imstack2_length/3)-0);
        end
        
        % Don't forget to change the order of colors if necessary. Look for this
        % comment text below.
        
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

for pos = overall_pos_start:overall_pos_end
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
    
    figure_folder = ['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\' expt_name];
    if ~exist(figure_folder,'dir')
        mkdir(figure_folder);
    end
    
    figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
        sg2_cells(startframe:endframe)./total_cells(startframe:endframe))
    if strcmp(expt_type, 'before')
        xlabel('Time since imaging start (h)')
    elseif pos >= dmso_pos_start && pos <= dmso_pos_end
        xlabel('Time since DMSO addition (h)')
    elseif pos >= palbo_pos_start && pos <= palbo_pos_end
        xlabel('Time since 60nM palbo addition (h)')
    end
    ylabel('Fraction of Geminin+ cells')   
    saveas(gcf, [figure_folder '\Pos' position '_FractionSG2.png'])
    
    figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
        total_cells(startframe:endframe))
    if strcmp(expt_type, 'before')
        xlabel('Time since imaging start (h)')
    elseif pos >= dmso_pos_start && pos <= dmso_pos_end
        xlabel('Time since DMSO addition (h)')
    elseif pos >= palbo_pos_start && pos <= palbo_pos_end
        xlabel('Time since 60nM palbo addition (h)')
    end
    ylabel('Number of cells')
    saveas(gcf, [figure_folder '\Pos' position '_NumberOfCells.png'])

    close all
end
%% Save data
    
% save([figure_folder '\' expt_name '.mat'], 'source_folder', 'expt_name', 'infix', 'suffixes','expt_type', 'framerate','startframe','endframe',...
%     'dmso_pos_start', 'dmso_pos_end', 'palbo_pos_start', 'palbo_pos_end', 'segmentation_threshold', 'max_area', 'geminin_threshold',...
%     'all_data')

save([figure_folder '\' expt_name '.mat'], 'source_folder', 'expt_name', 'infix', 'suffixes','expt_type', 'framerate','startframe','endframe',...
    'no_refresh_start', 'no_refresh_end', 'refresh_q48h_start', 'refresh_q48h_end', 'refresh_q24h_start', 'refresh_q24h_end', 'segmentation_threshold', 'max_area', 'geminin_threshold',...
    'all_data')

%% Plot all positions combined

% Combine data across positions
% for i = startframe:endframe
%     all_sg2_cells_dmso(i) = 0;
%     all_total_cells_dmso(i) = 0;
%     for pos = dmso_pos_start:dmso_pos_end
%         all_sg2_cells_dmso(i) = all_sg2_cells_dmso(i) + all_data(pos).sg2_cells(i);
%         all_total_cells_dmso(i) = all_total_cells_dmso(i) + all_data(pos).total_cells(i);
%     end
%     all_sg2_cells_palbo(i) = 0;
%     all_total_cells_palbo(i) = 0;
%     for pos = palbo_pos_start:palbo_pos_end
%         all_sg2_cells_palbo(i) = all_sg2_cells_palbo(i) + all_data(pos).sg2_cells(i);
%         all_total_cells_palbo(i) = all_total_cells_palbo(i) + all_data(pos).total_cells(i);
%     end
% end

% Combine data across positions
for i = startframe:endframe
    all_sg2_cells_no_refresh(i) = 0;
    all_total_cells_no_refresh(i) = 0;
    for pos = no_refresh_start:no_refresh_end
        all_sg2_cells_no_refresh(i) = all_sg2_cells_no_refresh(i) + all_data(pos).sg2_cells(i);
        all_total_cells_no_refresh(i) = all_total_cells_no_refresh(i) + all_data(pos).total_cells(i);
    end
    all_sg2_cells_refresh_q48h(i) = 0;
    all_total_cells_refresh_q48h(i) = 0;
    for pos = refresh_q48h_start:refresh_q48h_end
        all_sg2_cells_refresh_q48h(i) = all_sg2_cells_refresh_q48h(i) + all_data(pos).sg2_cells(i);
        all_total_cells_refresh_q48h(i) = all_total_cells_refresh_q48h(i) + all_data(pos).total_cells(i);
    end
    all_sg2_cells_refresh_q24h(i) = 0;
    all_total_cells_refresh_q24h(i) = 0;
    for pos = refresh_q24h_start:refresh_q24h_end
        all_sg2_cells_refresh_q24h(i) = all_sg2_cells_refresh_q24h(i) + all_data(pos).sg2_cells(i);
        all_total_cells_refresh_q24h(i) = all_total_cells_refresh_q24h(i) + all_data(pos).total_cells(i);
    end
end

% Plot
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_sg2_cells_dmso(startframe:endframe)./all_total_cells_dmso(startframe:endframe))
% xlabel('Time since DMSO addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Fraction of Geminin+ cells')
% saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])
% 
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_sg2_cells_palbo(startframe:endframe)./all_total_cells_palbo(startframe:endframe))
% xlabel('Time since 60nM palbo addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Fraction of Geminin+ cells')
% saveas(gcf, [figure_folder '\All_Palbo_positions_FractionSG2.png'])
% 
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_total_cells_dmso(startframe:endframe)./(dmso_pos_end - dmso_pos_start + 1))
% % Divide by number of corresponding positions to normalize per position
% xlabel('Time since DMSO addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Average number of cells per position')
% saveas(gcf, [figure_folder '\All_DMSO_positions_TotalCells.png'])
% 
% figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
%     all_total_cells_palbo(startframe:endframe)./(palbo_pos_end - palbo_pos_start + 1))
% xlabel('Time since 60nM palbo addition (h)')
% if strcmp(expt_type, 'before')
%     xlabel('Time since imaging start (h)')
% end
% ylabel('Average number of cells per position')
% saveas(gcf, [figure_folder '\All_Palbo_positions_TotalCells.png'])
   
% Plot
figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_sg2_cells_no_refresh(startframe:endframe)./all_total_cells_no_refresh(startframe:endframe))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title('No media refresh')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])

figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_sg2_cells_refresh_q48h(startframe:endframe)./all_total_cells_refresh_q48h(startframe:endframe))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title('Media refresh q48h')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])

figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_sg2_cells_refresh_q24h(startframe:endframe)./all_total_cells_refresh_q24h(startframe:endframe))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Fraction of Geminin+ cells')
title('Media refresh q24h')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])

figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_total_cells_no_refresh(startframe:endframe)./(no_refresh_end - no_refresh_start + 1))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title('No media refresh')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])

figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_total_cells_refresh_q48h(startframe:endframe)./(refresh_q48h_end - refresh_q48h_start + 1))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title('Media refresh q48h')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])

figure,plot([startframe*framerate : 1*framerate : endframe*framerate],...
    all_total_cells_refresh_q24h(startframe:endframe)./(refresh_q24h_end - refresh_q24h_start_start + 1))
xlabel('Time since DMSO addition (h)')
if strcmp(expt_type, 'before')
    xlabel('Time since imaging start (h)')
end
ylabel('Average number of cells per position')
title('Media refresh q24h')
saveas(gcf, [figure_folder '\All_DMSO_positions_FractionSG2.png'])
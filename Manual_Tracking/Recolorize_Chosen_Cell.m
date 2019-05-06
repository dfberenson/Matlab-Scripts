
clear all
close all

load('E:\Manually tracked measurements\DFB_180627_HMEC_1GFiii_palbo_2\clicking_Data.mat')
chosencell = 31;

chosencell_clicks = data(1).position(1).tracking_measurements.clicks(:,chosencell);

segmentation_prefix = 'F:\Manually tracked imaging experiments\DFB_180627_HMEC_1GFiii_palbo_2_Pos1\Segmentation\Segmented';
resegmentation_prefix = 'F:\Manually tracked imaging experiments\DFB_180627_HMEC_1GFiii_palbo_2_Pos1\Resegmentation\Resegmented';
old_trackedoutline_prefix = 'F:\Manually tracked imaging experiments\DFB_180627_HMEC_1GFiii_palbo_2_Pos1\DFB_180627_HMEC_1GFiii_palbo_2_Pos1_TrackedOutlined\DFB_180627_HMEC_1GFiii_palbo_2_Pos1_TrackedOutlined';
new_trackedoutline_prefix = 'F:\Manually tracked imaging experiments\DFB_180627_HMEC_1GFiii_palbo_2_Pos1\DFB_180627_HMEC_1GFiii_palbo_2_Pos1_ChosenCellTrackedOutlined\DFB_180627_HMEC_1GFiii_palbo_2_Pos1_ChosenCellTrackedOutlined';

for t = 144:233
    disp(['Recolorizing image ' num2str(t)])
    
    color_im_outlined = imread([old_trackedoutline_prefix '_' sprintf('%03d',t) '.tif']);
    
    if exist([resegmentation_prefix '_' sprintf('%03d',t) '.tif'])
        segmented_im = imread([resegmentation_prefix '_' sprintf('%03d',t) '.tif']);
    else
        segmented_im = imread([segmentation_prefix '_' sprintf('%03d',t) '.tif']);
    end
    
    % Recolor all outlines in white
    labels = bwlabel(segmented_im, 4);
    all_outlines = bwperim(labels);
    color_im_outlined = imoverlay_fast(color_im_outlined, all_outlines, 'white');
    
    % Recolor just the chosen cell in cyan
    click = chosencell_clicks{t};
    if length(click) == 2
        x = click(1);
        y = click(2);
        clicked_label = labels(y,x);
        
        thistrack_labels = bwlabel(segmented_im, 4) == clicked_label;
        thistrack_outline = bwperim(thistrack_labels);
        
        color_im_outlined = imoverlay_fast(color_im_outlined, thistrack_outline, 'cyan');
    end
    
    imwrite(color_im_outlined,[new_trackedoutline_prefix '_' sprintf('%03d',t) '.tif']);
end

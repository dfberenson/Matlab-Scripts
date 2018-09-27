

function [daughter1_id, daughter2_id] = find_daughters(s, cellnum);

daughter1_id = 0;
daughter2_id = 0;

thiscell_track_metadata = s.track_metadata(cellnum);
if isempty(thiscell_track_metadata.mitosis)
    return
end
t = thiscell_track_metadata.mitosis + 1;
daughter1_xy = thiscell_track_metadata.daughter1_xy;
daughter2_xy = thiscell_track_metadata.daughter2_xy;

segmentation_prefix = [s.expt_folder '\' s.expt_name '\'...
    'Segmentation\Segmented'];
resegmentation_prefix = [s.expt_folder '\' s.expt_name '\'...
    'Resegmentation\Resegmented'];

if exist([resegmentation_prefix '_' sprintf('%03d',t) '.tif']);
    segmented_im = imread([resegmentation_prefix '_' sprintf('%03d',t) '.tif']);
else
    segmented_im = imread([segmentation_prefix '_' sprintf('%03d',t) '.tif']);
end

[L,~] = bwlabel(segmented_im,4);

[Y,X] = size(L);
if daughter1_xy(1) > X || daughter1_xy(2) > Y || daughter1_xy(1) <=0 || daughter1_xy(2) <= 0
    daughter1_label = 0;
else
    daughter1_label = L(daughter1_xy(2), daughter1_xy(1));
end
if daughter2_xy(1) > X || daughter2_xy(2) > Y || daughter2_xy(1) <=0 || daughter2_xy(2) <= 0
    daughter2_label = 0;
else
    daughter2_label = L(daughter2_xy(2), daughter2_xy(1));
end

for n = s.all_tracknums
    click_table_size = size(s.clicks);
    if n <= click_table_size(2)
        potential_click = s.clicks{t,n};
        if ~isempty(potential_click)
            potential_label = L(potential_click(2), potential_click(1));
            if potential_label == daughter1_label
                daughter1_id = n;
            end
            if potential_label == daughter2_label && potential_label ~= daughter1_label
                daughter2_id = n;
            end
        end
    end
end
end

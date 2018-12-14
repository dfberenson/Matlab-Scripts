
clear all
close all

%% Initialize variables
im_folder = ['E:\Confocal'];
expt_name = '12-10-2018 Tetraspeck 4um';

positions_to_analyze = [2];
pos = 2;
% for pos = positions_to_analyze
expt_folder = [im_folder '\' expt_name];
cfc_fpath = [expt_folder '\' num2str(pos) '.tif'];

%% Prepare images
% Read images
cfc_stack = readStack(cfc_fpath);
[Y,X,num_images] = size(cfc_stack);
num_channels = 4;
assert(num_channels == 4);
channel_order = 'egtr'; %EF1a -- Geminin -- Transmitted -- Rb
% But in this case it's just the corresponding colors of the beads
cfc_info = imfinfo(cfc_fpath);
num_zslices = numel(cfc_info) / num_channels;
bitdepth = 2^(cfc_info(1).BitDepth) - 1;
cfc_hyperstack = reshape(cfc_stack,[Y,X,num_channels,num_zslices]);


%% Prepare images
for chan_num = 1:num_channels
    cfc_stack_thischan = cfc_hyperstack(:,:,chan_num,:);
    % Take mip along 4th dimension (i.e., z from order YXCZ)
    cfc_mips(:,:,chan_num) = max(cfc_stack_thischan,[],4);
end

main_channel_to_segment = 2;
gaussian_width = 2;
strel_shape = 'disk';
strel_size = 4;
se = strel(strel_shape,strel_size);
main_cfc_mip_threshold = 50;

% Segment based on confocal maximum intensity projection (mip)
main_cfc_mip = cfc_mips(:,:,main_channel_to_segment);
cfc_mip_gaussian_filtered = imgaussfilt(main_cfc_mip,gaussian_width);
% imtool(cfc_mip_gaussian_filtered)
cfc_mip_thresholded = cfc_mip_gaussian_filtered > main_cfc_mip_threshold;
% figure,imshow(cfc_mip_thresholded)
cfc_mip_opened = imopen(cfc_mip_thresholded,se);
% figure,imshow(cfc_mip_opened)
cfc_mip_closed = imclose(cfc_mip_opened,se);
figure,imshow(cfc_mip_closed)
cfc_mip_segmentation = cfc_mip_closed;
[cfc_mip_labels,cfc_mip_num_cells] = bwlabel(cfc_mip_segmentation,4);
cfc_mip_perim = bwperim(cfc_mip_segmentation);

main_cfc_zslice_threshold = 20;

main_cfc_zstack = squeeze(cfc_hyperstack(:,:,main_channel_to_segment,:));
zslices_to_examine = [round(num_zslices/3) round(num_zslices/2) round(num_zslices*2/3)];
for z = 1:num_zslices
    main_cfc_thiszslice = main_cfc_zstack(:,:,z);
    cfc_thiszslice_gaussian_filtered = imgaussfilt(main_cfc_thiszslice,gaussian_width);
    %     imtool(cfc_thiszslice_gaussian_filtered)
    cfc_thiszslice_thresholded = cfc_thiszslice_gaussian_filtered > main_cfc_zslice_threshold;
    %     figure,imshow(cfc_thiszslice_thresholded)
    cfc_thiszslice_opened = imopen(cfc_thiszslice_thresholded,se);
    %     figure,imshow(cfc_thiszslice_opened)
    cfc_thiszslice_closed = imclose(cfc_thiszslice_opened,se);
    if any(z == zslices_to_examine)
        figure,imshow(cfc_thiszslice_gaussian_filtered,[])
        figure,imshow(cfc_thiszslice_closed)
    end
    
    cfc_zstack_segmentation(:,:,z) = cfc_thiszslice_closed;
    [cfc_zslices_labels(:,:,z),cfc_zslices_num_cells(z)] = bwlabel(cfc_zstack_segmentation(:,:,z),4);
    cfc_zstacked_perims(:,:,z) = bwperim(cfc_zstack_segmentation(:,:,z));
end

writeSequence(cfc_zstack_segmentation*bitdepth, im_folder, [expt_name '_Pos' num2str(pos)], ['Confocal_Segmentation'], 1, num_zslices, 'binary');



% Display images with overlaid perimeters
flat_perim_to_overlay = cfc_mip_perim;
zstacked_cfc_mip_perims = repmat(cfc_mip_perim,1,1,num_zslices);
zstack_perim_to_overlay = cfc_zstacked_perims;

for chan_num = 1:num_channels
    thischan_overlaid(:,:,1) = main_cfc_mip;
    thischan_overlaid(:,:,2) = flat_perim_to_overlay*bitdepth;
    thischan_overlaid(:,:,3) = flat_perim_to_overlay*bitdepth;
    cfc_mip_stack_overlaid(:,:,:,chan_num) = thischan_overlaid;
    
    for z = 1:num_zslices
        thischan_thiszslice_overlaid(:,:,1) = cfc_hyperstack(:,:,chan_num,z);
        %             thischan_thiszslice_overlaid(:,:,2) = flat_perim_to_overlay*bitdepth;
        thischan_thiszslice_overlaid(:,:,2) = zstacked_cfc_mip_perims(:,:,z)*bitdepth;
        thischan_thiszslice_overlaid(:,:,3) = cfc_zstacked_perims(:,:,z)*bitdepth;
        cfc_stack_overlaid(:,:,:,chan_num,z) = thischan_thiszslice_overlaid;
    end
    writeSequence(squeeze(cfc_stack_overlaid(:,:,:,chan_num,:)), im_folder, [expt_name '_Pos' num2str(pos)], ['Confocal_Ch' num2str(chan_num)], 1, num_zslices, 'rgb');
end

%     implay(cfc_mip_stack_overlaid)
%     implay(squeeze(cfc_stack_overlaid(:,:,:,1,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,2,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,3,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,4,:)))

close all

%% Measure images

% Measure confocal mip and sliced images using mip segmentation
for cfc_cell = 1:cfc_mip_num_cells
    disp(['Measuring confocal cell ' num2str(cfc_cell)])
    thiscell_cfc_mip_mask = cfc_mip_labels == cfc_cell;
    props = regionprops(thiscell_cfc_mip_mask,'Area','BoundingBox');
    position(pos).cfc_mipsegmented_measurements(cfc_cell).area = props.Area;
    for chan = 'egr'
        chan_num = find(channel_order == chan);
        cfc_mip_thischannel = cfc_mips(:,:,chan_num);
        assert(mode(cfc_mip_thischannel(:)) == 0, 'Background mode is not 0. May need to consider background subtraction.');
        props = regionprops(thiscell_cfc_mip_mask,cfc_mip_thischannel,'MeanIntensity');
        thiscell_thischan_mip_meanintens = props.MeanIntensity;
        thiscell_thischan_zsliced_meanintens = zeros(num_zslices,1);
        for z = 1:num_zslices
            cfc_thischan_thiszslice = cfc_hyperstack(:,:,chan_num,z);
            assert(mode(cfc_thischan_thiszslice(:)) == 0, 'Background mode is not 0. May need to consider background subtraction.');
            props = regionprops(thiscell_cfc_mip_mask,cfc_thischan_thiszslice,'MeanIntensity');
            thiscell_thischan_zsliced_meanintens(z) = props.MeanIntensity;
        end
        
        switch chan
            case 'e'
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_mean = thiscell_thischan_mip_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_mean = thiscell_thischan_zsliced_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
            case 'g'
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_mean = thiscell_thischan_mip_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_mean = thiscell_thischan_zsliced_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
            case 'r'
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_mean = thiscell_thischan_mip_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_zsliced_mean = thiscell_thischan_zsliced_meanintens;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_zsliced_int_intens = position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_zsliced_mean * position(pos).cfc_mipsegmented_measurements(cfc_cell).area;
        end
    end
end

% Measure confocal sliced images using individual z-slice segmentation
for z = 1:num_zslices
    disp(['Measuring z slice ' num2str(z)])
    thiszslice_labels = cfc_zslices_labels(:,:,z);
    for thiszslice_cfc_cell = 1:cfc_zslices_num_cells(z)
        thiszslice_thiscell_mask = thiszslice_labels == thiszslice_cfc_cell;
        props = regionprops(thiszslice_thiscell_mask,'Area','BoundingBox');
        position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).area = props.Area;
        for chan = 'egr'
            chan_num = find(channel_order == chan);
            cfc_thischan_thiszslice = cfc_hyperstack(:,:,chan_num,z);
            assert(mode(cfc_thischan_thiszslice(:)) == 0, 'Background mode is not 0. May need to consider background subtraction.');
            props = regionprops(thiszslice_thiscell_mask,cfc_thischan_thiszslice,'MeanIntensity');
            switch chan
                case 'e'
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).ef1a_zsliced_mean = props.MeanIntensity;
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).ef1a_zsliced_int_intens = position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).ef1a_zsliced_mean * position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).area;
                case 'g'
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).geminin_zsliced_mean =  props.MeanIntensity;
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).geminin_zsliced_int_intens = position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).geminin_zsliced_mean * position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).area;
                case 'r'
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).rb_zsliced_mean =  props.MeanIntensity;
                    position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).rb_zsliced_int_intens = position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).rb_zsliced_mean * position(pos).cfc_zstacksegmented_measurements_unassigned(z,thiszslice_cfc_cell).area;
            end
        end
    end
end


% Use Hungarian algorithm to assign correspondence between confocal mip
% labels and labels from confocal z-slice segmentation
cfc_mip_to_cfc_allzslices_assignments_byoverlap = zeros(z,cfc_mip_num_cells);
cfc_mip_to_cfc_allzslices_assignments_bycentroid = zeros(z,cfc_mip_num_cells);
for z = 1:num_zslices
    thiszslice_label_overlap_matrix = zeros(cfc_mip_num_cells,cfc_zslices_num_cells(z));
    thiszslice_centroid_distance_matrix = zeros(cfc_mip_num_cells,cfc_zslices_num_cells(z));
    thiszslice_labels = cfc_zslices_labels(:,:,z);
    for cfc_mip_cell = 1:cfc_mip_num_cells
        thiscell_cfc_mip_mask = cfc_mip_labels == cfc_mip_cell;
        thiscell_cfc_mip_props = regionprops(thiscell_cfc_mip_mask,'Centroid');
        thiscell_cfc_mip_centroid = thiscell_cfc_mip_props.Centroid;
        for thiszslice_cfc_cell = 1:cfc_zslices_num_cells(z)
            thiszslice_thiscell_mask = thiszslice_labels == thiszslice_cfc_cell;
            label_overlap = thiscell_cfc_mip_mask & thiszslice_thiscell_mask;
            thiszslice_label_overlap_matrix(cfc_mip_cell,thiszslice_cfc_cell) = -sum(label_overlap(:));
            thiszslice_thiscell_props = regionprops(thiszslice_thiscell_mask,'Centroid');
            thiszslice_thiscell_centroid = thiszslice_thiscell_props.Centroid;
            thiszslice_centroid_distance_matrix(cfc_mip_cell,thiszslice_cfc_cell) = sum((thiscell_cfc_mip_centroid - thiszslice_thiscell_centroid).^2);
        end
    end
    % It is likely that thiszslice_label_overlap_matrix will not be square.
    % But that is okay because munkres will return a vector with length
    % equal to the number of rows in the cost matrix: i.e., length equal to
    % cfc_mip_num_cells
    cfc_mip_to_cfc_thiszslice_assignment_byoverlap = munkres(thiszslice_label_overlap_matrix);
    cfc_mip_to_cfc_allzslices_assignments_byoverlap(z,:) = cfc_mip_to_cfc_thiszslice_assignment_byoverlap;
    cfc_mip_to_cfc_thiszslice_assignment_bycentroid = munkres(thiszslice_centroid_distance_matrix);
    cfc_mip_to_cfc_allzslices_assignments_bycentroid(z,:) = cfc_mip_to_cfc_thiszslice_assignment_bycentroid;
end
if ~isequal(cfc_mip_to_cfc_allzslices_assignments_byoverlap,cfc_mip_to_cfc_allzslices_assignments_bycentroid)
    warning(['Overlap and centroid do not give same correspondence'])
end


% Put confocal slice-segmented measurements into a structure with one entry
% total per cell (with fields containing vectors of z-sliced measurements)
for z = 1:num_zslices
    for cfc_mip_cell = 1:cfc_mip_num_cells
        % cfc_thiscell_thiszslice = cfc_mip_to_cfc_allzslices_assignments_byoverlap(z,cfc_mip_cell);
        cfc_thiscell_thiszslice = cfc_mip_to_cfc_allzslices_assignments_bycentroid(z,cfc_mip_cell);
        if cfc_thiscell_thiszslice ~= 0
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).areas(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).area;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).ef1a_zsliced_means(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).ef1a_zsliced_mean;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).ef1a_zsliced_int_intens(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).ef1a_zsliced_int_intens;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).geminin_zsliced_means(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).geminin_zsliced_mean;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).geminin_zsliced_int_intens(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).geminin_zsliced_int_intens;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).rb_zsliced_means(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).rb_zsliced_mean;
            position(pos).cfc_zstacksegmented_measurements(cfc_mip_cell).rb_zsliced_int_intens(z) = position(pos).cfc_zstacksegmented_measurements_unassigned(z,cfc_thiscell_thiszslice).rb_zsliced_int_intens;
        end
    end
end

position(pos).cfc_mip_num_cells = cfc_mip_num_cells;

%% Collate data

cfc_mip_areas = [];
cfc_mip_ef1a = [];
cfc_mip_geminin = [];
cfc_mip_rb = [];
cfc_mipsegmented_ef1a_maxslice = [];
cfc_mipsegmented_geminin_maxslice = [];
cfc_mipsegmented_rb_maxslice = [];
cfc_mipsegmented_ef1a_sumslices = [];
cfc_mipsegmented_geminin_sumslices = [];
cfc_mipsegmented_rb_sumslices = [];
cfc_zstacksegmented_area_maxslice = [];
cfc_zstacksegmented_area_sumslices = [];
cfc_zstacksegmented_ef1a_maxslice = [];
cfc_zstacksegmented_ef1a_sumslices = [];
cfc_zstacksegmented_geminin_maxslice = [];
cfc_zstacksegmented_geminin_sumslices = [];
cfc_zstacksegmented_rb_maxslice = [];
cfc_zstacksegmented_rb_sumslices = [];
cfc_zstacksegmented_ef1a_maxslice_meanintens = [];
cfc_zstacksegmented_rb_maxslice_meanintens = [];
all_z_coords = [];
all_ch2_zsliced_means = [];
all_z_coords_traces = {};
all_ch2_zsliced_means_traces = {};

for cfc_cell = 1:position(pos).cfc_mip_num_cells
    if cfc_cell == 0
        continue
    end
    
    cfc_mip_areas = [cfc_mip_areas; position(pos).cfc_mipsegmented_measurements(cfc_cell).area];
    cfc_mip_ef1a = [cfc_mip_ef1a; position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_int_intens];
    cfc_mip_geminin = [cfc_mip_geminin; position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_int_intens];
    cfc_mip_rb = [cfc_mip_rb; position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_int_intens];
    
    cfc_mipsegmented_ef1a_maxslice = [cfc_mipsegmented_ef1a_maxslice;...
        max(position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_int_intens)];
    cfc_mipsegmented_geminin_maxslice = [cfc_mipsegmented_geminin_maxslice;
        max(position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    cfc_mipsegmented_rb_maxslice = [cfc_mipsegmented_rb_maxslice;...
        max(position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    
    cfc_mipsegmented_ef1a_sumslices = [cfc_mipsegmented_ef1a_sumslices;...
        sum(position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_int_intens)];
    cfc_mipsegmented_geminin_sumslices = [cfc_mipsegmented_geminin_sumslices;
        sum(position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    cfc_mipsegmented_rb_sumslices = [cfc_mipsegmented_rb_sumslices;...
        sum(position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    
    cfc_zstacksegmented_area_maxslice = [cfc_zstacksegmented_area_maxslice;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).areas)];
    cfc_zstacksegmented_ef1a_maxslice = [cfc_zstacksegmented_ef1a_maxslice;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_int_intens)];
    cfc_zstacksegmented_geminin_maxslice = [cfc_zstacksegmented_geminin_maxslice;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    cfc_zstacksegmented_rb_maxslice = [cfc_zstacksegmented_rb_maxslice;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).rb_zsliced_int_intens)];
    
    cfc_zstacksegmented_area_sumslices = [cfc_zstacksegmented_area_sumslices;...
        sum(position(pos).cfc_zstacksegmented_measurements(cfc_cell).areas)];
    cfc_zstacksegmented_ef1a_sumslices = [cfc_zstacksegmented_ef1a_sumslices;...
        sum(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_int_intens)];
    cfc_zstacksegmented_geminin_sumslices = [cfc_zstacksegmented_geminin_sumslices;...
        sum(position(pos).cfc_zstacksegmented_measurements(cfc_cell).geminin_zsliced_int_intens)];
    cfc_zstacksegmented_rb_sumslices = [cfc_zstacksegmented_rb_sumslices;...
        sum(position(pos).cfc_zstacksegmented_measurements(cfc_cell).rb_zsliced_int_intens)];
    
    cfc_zstacksegmented_ef1a_maxslice_meanintens = [cfc_zstacksegmented_ef1a_maxslice_meanintens;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means)];
    cfc_zstacksegmented_rb_maxslice_meanintens = [cfc_zstacksegmented_rb_maxslice_meanintens;...
        max(position(pos).cfc_zstacksegmented_measurements(cfc_cell).rb_zsliced_means)];
    
    all_z_coords = [all_z_coords; [1:length(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means)]'];
    all_ch2_zsliced_means = [all_ch2_zsliced_means; [position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means]'];
    
    all_z_coords_traces = {all_z_coords_traces{:}, [1:length(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means)]'};
    all_ch2_zsliced_means_traces = {all_ch2_zsliced_means_traces{:}, [position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means]'};
    
end

%% Plot mean versus z coordinate

figure
hold on
cmap = colormap('winter');
for trace = 1:length(all_z_coords_traces)
    plotcolor = cmap(trace*floor(64/length(all_z_coords_traces)),:);
    z_coords = all_z_coords_traces{trace};
    ef1a_zsliced_means = all_ch2_zsliced_means_traces{trace};
    nonzero_z_coords = z_coords(find(ef1a_zsliced_means));
    nonzero_ef1a_zsliced_means = ef1a_zsliced_means(find(ef1a_zsliced_means));
    max_z = nonzero_z_coords(nonzero_ef1a_zsliced_means == max(nonzero_ef1a_zsliced_means));
    middle_z = median(nonzero_z_coords);
%     plot(nonzero_z_coords - max_z, nonzero_ef1a_zsliced_means)
    plot(nonzero_z_coords - middle_z, nonzero_ef1a_zsliced_means,'Color',plotcolor)
end
xlabel('Z position')
ylabel('EF1a-mCherry mean pixel intensity')
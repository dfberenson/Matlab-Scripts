
clear all
close all

%% Initialze variables
im_folder = ['E:\Confocal'];
% expt_name = '08-30-2018 HMECs D5 confocal';
expt_name = '10-30-2018 HMECs D5 confocal';
plot_correlations = true;
plot_all_correlations_independently = false;

positions_to_analyze = [2 3 5 6 7];
% positions_to_analyze = [5];

for pos = positions_to_analyze
    expt_folder = [im_folder '\' expt_name];
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        epi_fpath = [expt_folder '\' num2str(pos) '\' num2str(pos) '_epi.czi'];
        cfc_fpath = [expt_folder '\' num2str(pos) '\' num2str(pos) '_confocal.tif'];
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        epi_fpath = [expt_folder '\' num2str(pos) '\' num2str(pos) '-epi.tif'];
        cfc_fpath = [expt_folder '\' num2str(pos) '\' num2str(pos) '-confocal.tif'];
    end
    
    
    %% Prepare images
    % Read images
    epi_stack = readStack(epi_fpath);
    cfc_stack = readStack(cfc_fpath);
    
    % Reshape image stacks
    [Y,X,num_channels] = size(epi_stack);
    assert(num_channels == 4);
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        channel_order = 'egtr'; %EF1a -- Geminin -- Transmitted -- Rb
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        channel_order = 'egrt'; %EF1a -- Geminin -- Rb -- Transmitted
    end
    cfc_info = imfinfo(cfc_fpath);
    num_zslices = numel(cfc_info) / num_channels;
    bitdepth = 2^(cfc_info(1).BitDepth) - 1;
    cfc_hyperstack = reshape(cfc_stack,[Y,X,num_channels,num_zslices]);
    
    % Get maximum intensity projections (mip) for confocal
    for chan_num = 1:num_channels
        cfc_stack_thischan = cfc_hyperstack(:,:,chan_num,:);
        % Take mip along 4th dimension (i.e., z from order YXCZ)
        cfc_mips(:,:,chan_num) = max(cfc_stack_thischan,[],4);
    end
    
    % Segment images
    main_channel_to_segment = find(channel_order == 'e');
    gaussian_width = 2;
    strel_shape = 'disk';
    strel_size = 4;
    se = strel(strel_shape,strel_size);
    
    %% Prepare images
    
    % Segment based on epifluorescence
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        main_epi_threshold = 15;
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        main_epi_threshold = 12;
%         main_epi_threshold = 20;
    end
    
    main_epi_im = epi_stack(:,:,main_channel_to_segment);
    epi_gaussian_filtered = imgaussfilt(main_epi_im,gaussian_width);
    % figure,imshow(epi_gaussian_filtered,[])
    epi_thresholded = epi_gaussian_filtered > main_epi_threshold;
    % figure,imshow(epi_thresholded)
    epi_im_opened = imopen(epi_thresholded,se);
    % figure,imshow(epi_im_opened)
    epi_im_closed = imclose(epi_im_opened,se);
    figure,imshow(epi_im_closed)
    epi_segmentation = epi_im_closed;
    [epi_labels,epi_num_cells] = bwlabel(epi_segmentation,4);
    epi_perim = bwperim(epi_segmentation);
    
    % Segment based on confocal maximum intensity projection (mip)
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        main_cfc_mip_threshold = 60;
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        main_cfc_mip_threshold = 3;
    end
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
    
    % Segmenting each confocal z-slice independently
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        main_cfc_zslice_threshold = 10;
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        main_cfc_zslice_threshold = 2;
    end
    
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
            figure,imshow(cfc_thiszslice_closed)
        cfc_zstack_segmentation(:,:,z) = cfc_thiszslice_closed;
        [cfc_zslices_labels(:,:,z),cfc_zslices_num_cells(z)] = bwlabel(cfc_zstack_segmentation(:,:,z),4);
        cfc_zstacked_perims(:,:,z) = bwperim(cfc_zstack_segmentation(:,:,z));
    end
    
    writeSequence(cfc_zstack_segmentation*bitdepth, im_folder, [expt_name '_Pos' num2str(pos)], ['Confocal_Segmentation'], 1, num_zslices, 'binary');
    
    % Display images with overlaid perimeters
    flat_perim_to_overlay = epi_perim;
    zstacked_epi_perims = repmat(epi_perim,1,1,num_zslices);
    zstacked_cfc_mip_perims = repmat(cfc_mip_perim,1,1,num_zslices);
    zstack_perim_to_overlay = cfc_zstacked_perims;
    
    for chan_num = 1:num_channels
        thischan_overlaid(:,:,1) = epi_stack(:,:,chan_num);
        thischan_overlaid(:,:,2) = flat_perim_to_overlay*bitdepth;
        thischan_overlaid(:,:,3) = flat_perim_to_overlay*bitdepth;
        epi_stack_overlaid(:,:,:,chan_num) = thischan_overlaid;
        
        for z = 1:num_zslices
            thischan_thiszslice_overlaid(:,:,1) = cfc_hyperstack(:,:,chan_num,z);
            %             thischan_thiszslice_overlaid(:,:,2) = flat_perim_to_overlay*bitdepth;
            thischan_thiszslice_overlaid(:,:,2) = zstacked_cfc_mip_perims(:,:,z)*bitdepth;
            thischan_thiszslice_overlaid(:,:,3) = cfc_zstacked_perims(:,:,z)*bitdepth;
            cfc_stack_overlaid(:,:,:,chan_num,z) = thischan_thiszslice_overlaid;
        end
        writeSequence(squeeze(cfc_stack_overlaid(:,:,:,chan_num,:)), im_folder, [expt_name '_Pos' num2str(pos)], ['Confocal_Ch' num2str(chan_num)], 1, num_zslices, 'rgb');
    end
%     implay(epi_stack_overlaid)
%     implay(squeeze(cfc_stack_overlaid(:,:,:,1,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,2,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,3,:)))
%     implay(squeeze(cfc_stack_overlaid(:,:,:,4,:)))

close all
    
    %% Measure images
    
    measure_images = true;
    if ~measure_images
        return
    end
    
    % Make sure to throw out segmented objects with EF1a below a threshold
    % (in the event that we are segmenting on a different channel)
    if strcmp(expt_name, '08-30-2018 HMECs D5 confocal')
        ef1a_threshold = 25;
    elseif strcmp(expt_name, '10-30-2018 HMECs D5 confocal')
        ef1a_threshold = 5;
    end
    
    % Measure epifluorescence images
    for epi_cell = 1:epi_num_cells
        disp(['Measuring epifluorescence cell ' num2str(epi_cell)])
        thiscell_epi_mask = epi_labels == epi_cell;
        props = regionprops(thiscell_epi_mask,'Area','BoundingBox');
        position(pos).epi_measurements(epi_cell).area = props.Area;
        for chan = 'egr'
            chan_num = find(channel_order == chan);
            epi_im_thischannel = epi_stack(:,:,chan_num);
            assert(mode(epi_im_thischannel(:)) == 0, 'Background mode is not 0. May need to consider background subtraction.');
            props = regionprops(thiscell_epi_mask,epi_im_thischannel,'MeanIntensity');
            thischan_meanintens = props.MeanIntensity;
            if chan == 'e' && thischan_meanintens < ef1a_threshold
                position(pos).epi_measurements(epi_cell).area = NaN;
                position(pos).epi_measurements(epi_cell).ef1a_mean = NaN;
                position(pos).epi_measurements(epi_cell).ef1a_int_intens = NaN;
                position(pos).epi_measurements(epi_cell).geminin_mean = NaN;
                position(pos).epi_measurements(epi_cell).geminin_int_intens = NaN;
                position(pos).epi_measurements(epi_cell).rb_mean = NaN;
                position(pos).epi_measurements(epi_cell).rb_int_intens = NaN;
            else
                switch chan
                    case 'e'
                        position(pos).epi_measurements(epi_cell).ef1a_mean = thischan_meanintens;
                        position(pos).epi_measurements(epi_cell).ef1a_int_intens = position(pos).epi_measurements(epi_cell).area * position(pos).epi_measurements(epi_cell).ef1a_mean;
                    case 'g'
                        position(pos).epi_measurements(epi_cell).geminin_mean = thischan_meanintens;
                        position(pos).epi_measurements(epi_cell).geminin_int_intens = position(pos).epi_measurements(epi_cell).area * position(pos).epi_measurements(epi_cell).geminin_mean;
                    case 'r'
                        position(pos).epi_measurements(epi_cell).rb_mean = thischan_meanintens;
                        position(pos).epi_measurements(epi_cell).rb_int_intens = position(pos).epi_measurements(epi_cell).area * position(pos).epi_measurements(epi_cell).rb_mean;
                end
            end
        end
    end
    
    
    
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
            if chan == 'e' && thischan_meanintens < ef1a_threshold
                position(pos).cfc_mipsegmented_measurements(cfc_cell).area = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_mip_int_intens = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).ef1a_zsliced_int_intens = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_mip_int_intens = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).geminin_zsliced_int_intens = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_mip_int_intens = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_zsliced_mean = NaN;
                position(pos).cfc_mipsegmented_measurements(cfc_cell).rb_zsliced_int_intens = NaN;
            else
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
    
    % Use Hungarian algorithm to assign correspondence between epifluorescence
    % labels and labels from confocal maximum intensity projection
    label_overlap_matrix = zeros(epi_num_cells,cfc_mip_num_cells);
    centroid_distance_matrix = zeros(epi_num_cells,cfc_mip_num_cells);
    for epi_cell = 1:epi_num_cells
        thiscell_epi_mask = epi_labels == epi_cell;
        thiscell_epi_props = regionprops(thiscell_epi_mask,'Centroid');
        thiscell_epi_centroid = thiscell_epi_props.Centroid;
        for cfc_mip_cell = 1:cfc_mip_num_cells
            thiscell_cfc_mip_mask = cfc_mip_labels == cfc_mip_cell;
            label_overlap = thiscell_epi_mask & thiscell_cfc_mip_mask;
            label_overlap_matrix(epi_cell,cfc_mip_cell) = -sum(label_overlap(:));
            thiscell_cfc_mip_props = regionprops(thiscell_cfc_mip_mask,'Centroid');
            thiscell_cfc_mip_centroid = thiscell_cfc_mip_props.Centroid;
            centroid_distance_matrix(epi_cell,cfc_mip_cell) = sum((thiscell_epi_centroid - thiscell_cfc_mip_centroid).^2);
        end
    end
    
    if epi_num_cells ~= cfc_mip_num_cells
        warning(['Position ' num2str(pos) ': Different numbers of cells are detected for epi and confocal'])
    end
    
    % After applying the Hungarian algorithm, epi_labels == epi_cell corresponds
    % to cfc_labels == assignment(epi_cell)
    epi_to_cfc_mip_assignment_byoverlap = munkres(label_overlap_matrix);
    epi_to_cfc_mip_assignment_bycentroid = munkres(centroid_distance_matrix);
    if ~isequal(epi_to_cfc_mip_assignment_byoverlap,epi_to_cfc_mip_assignment_bycentroid)
        warning(['Overlap and centroid do not give same correspondence'])
    end
    
    % Use Hungarian algorithm to assign correspondence between epifluorescence
    % labels and labels from confocal z-slice segmentation
    epi_to_cfc_allzslices_assignments_byoverlap = zeros(z,epi_num_cells);
    epi_to_cfc_allzslices_assignments_bycentroid = zeros(z,epi_num_cells);
    
    for z = 1:num_zslices
        thiszslice_label_overlap_matrix = zeros(epi_num_cells,cfc_zslices_num_cells(z));
        thiszslice_centroid_distance_matrix = zeros(epi_num_cells,cfc_zslices_num_cells(z));
        thiszslice_labels = cfc_zslices_labels(:,:,z);
        for epi_cell = 1:epi_num_cells
            thiscell_epi_mask = epi_labels == epi_cell;
            thiscell_epi_props = regionprops(thiscell_epi_mask,'Centroid');
            thiscell_epi_centroid = thiscell_epi_props.Centroid;
            for thiszslice_cfc_cell = 1:cfc_zslices_num_cells
                thiszslice_thiscell_mask = thiszslice_labels == thiszslice_cfc_cell;
                label_overlap = thiscell_epi_mask & thiszslice_thiscell_mask;
                thiszslice_label_overlap_matrix(epi_cell,thiszslice_cfc_cell) = -sum(label_overlap(:));
                thiszslice_thiscell_props = regionprops(thiszslice_thiscell_mask,'Centroid');
                thiszslice_thiscell_centroid = thiszslice_thiscell_props.Centroid;
                thiszslice_centroid_distance_matrix(epi_cell,thiszslice_cfc_cell) = sum((thiscell_epi_centroid - thiszslice_thiscell_centroid).^2);
            end
        end
        % It is likely that thiszslice_label_overlap_matrix will not be square.
        % But that is okay because munkres will return a vector with length
        % equal to the number of rows in the cost matrix: i.e., length equal to
        % epi_num_cells
        epi_to_cfc_thiszslice_assignment_byoverlap = munkres(thiszslice_label_overlap_matrix);
        epi_to_cfc_allzslices_assignments_byoverlap(z,:) = epi_to_cfc_thiszslice_assignment_byoverlap;
        epi_to_cfc_thiszslice_assignment_bycentroid = munkres(thiszslice_centroid_distance_matrix);
        epi_to_cfc_allzslices_assignments_bycentroid(z,:) = epi_to_cfc_thiszslice_assignment_bycentroid;
    end
    if ~isequal(epi_to_cfc_allzslices_assignments_byoverlap,epi_to_cfc_allzslices_assignments_bycentroid)
        warning(['Overlap and centroid do not give same correspondence'])
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
    
    position(pos).epi_num_cells = epi_num_cells;
    % position(pos).epi_to_cfc_mip_assignment = epi_to_cfc_mip_assignment_byoverlap;
    position(pos).epi_to_cfc_mip_assignment = epi_to_cfc_mip_assignment_bycentroid;
    
end

%% Collate data

epi_areas = [];
epi_ef1a = [];
epi_ef1a_mean = [];
epi_geminin = [];
epi_rb = [];
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
all_ef1a_zsliced_means = [];
all_z_coords_traces = {};
all_ef1a_zsliced_means_traces = {};

for pos = positions_to_analyze
    for epi_cell = 1:position(pos).epi_num_cells
        cfc_cell = position(pos).epi_to_cfc_mip_assignment(epi_cell);
        if cfc_cell == 0
            continue
        end
        epi_areas = [epi_areas; position(pos).epi_measurements(epi_cell).area];
        epi_ef1a = [epi_ef1a; position(pos).epi_measurements(epi_cell).ef1a_int_intens];
        epi_ef1a_mean = [epi_ef1a_mean; position(pos).epi_measurements(epi_cell).ef1a_mean];
        epi_geminin = [epi_geminin; position(pos).epi_measurements(epi_cell).geminin_int_intens];
        epi_rb = [epi_rb; position(pos).epi_measurements(epi_cell).rb_int_intens];
        
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
        all_ef1a_zsliced_means = [all_ef1a_zsliced_means; [position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means]'];
    
        all_z_coords_traces = {all_z_coords_traces{:}, [1:length(position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means)]'};
        all_ef1a_zsliced_means_traces = {all_ef1a_zsliced_means_traces{:}, [position(pos).cfc_zstacksegmented_measurements(cfc_cell).ef1a_zsliced_means]'};

    
    end
end

%% Plot mean versus z coordinate

figure
hold on
cmap = colormap('winter');
for trace = 1:length(all_z_coords_traces)
    plotcolor = cmap(trace*floor(64/length(all_z_coords_traces)),:);
    z_coords = all_z_coords_traces{trace};
    ef1a_zsliced_means = all_ef1a_zsliced_means_traces{trace};
    nonzero_z_coords = z_coords(find(ef1a_zsliced_means));
    nonzero_ef1a_zsliced_means = ef1a_zsliced_means(find(ef1a_zsliced_means));
    max_z = nonzero_z_coords(nonzero_ef1a_zsliced_means == max(nonzero_ef1a_zsliced_means));
    middle_z = median(nonzero_z_coords);
%     plot(nonzero_z_coords - max_z, nonzero_ef1a_zsliced_means)
    plot(nonzero_z_coords - middle_z, nonzero_ef1a_zsliced_means,'Color',plotcolor)
end
xlabel('Z position')
ylabel('EF1a-mCherry mean pixel intensity')

%% Plot correlations
if plot_correlations
figure_folder = ['C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\' expt_name];
if ~exist(figure_folder,'dir')
    mkdir(figure_folder)
end

analyze_rb = true;

% all_data_types_to_plot = {'Epi_area_vs_Epi_EF1a','Epi_EF1a_vs_Cfc_mip_EF1a',...
%     'Epi_EF1a_vs_Cfc_mipsegmented_EF1a_maxslice','Epi_EF1a_vs_Cfc_mipsegmented_EF1a_sumslices',...
%     'Epi_EF1a_vs_Cfc_zstacksegmented_EF1a_maxslice','Epi_EF1a_vs_Cfc_zstacksegmented_EF1a_sumslices',...
%     'Epi_EF1a_vs_Cfc_zstacksegmented_volume'};
% if analyze_rb
%     all_data_types_to_plot = {all_data_types_to_plot{:},'Epi_Rb_vs_Cfc_mip_Rb',
%         'Epi_Rb_vs_Cfc_mipsegmented_Rb_maxslice','Epi_Rb_vs_Cfc_mipsegmented_Rb_sumslices',...
%         'Epi_Rb_vs_Cfc_zstacksegmented_Rb_maxslice'};
% end

all_x_vars_to_plot = {'Epi_area','Epi_EF1a','Cfc_zstacksegmented_EF1a_maxslice',...
    'Cfc_zstacksegmented_EF1a_sumslices'};
all_y_vars_to_plot = {'Epi_EF1a','Cfc_mip_EF1a','Epi_EF1a_per_Epi_area','Cfc_mipsegmented_EF1a_maxslice',...
    'Cfc_mipsegmented_EF1a_sumslices','Cfc_zstacksegmented_EF1a_maxslice',...
    'Cfc_zstacksegmented_EF1a_sumslices','Cfc_zstacksegmented_EF1a_meanintensity',...
    'Cfc_zstacksegmented_volume','Epi_EF1a_per_Cfc_zstacksegmented_volume',...
    'Cfc_zstacksegmented_EF1a_sumslices_per_Cfc_zstacksegmented_volume'};
if analyze_rb
    all_x_vars_to_plot = {all_x_vars_to_plot{:},'Epi_Rb','Epi_Rb_per_Epi_EF1a'};
    all_y_vars_to_plot = {all_y_vars_to_plot{:},'Cfc_mip_Rb','Cfc_mipsegmented_Rb_maxslice',...
        'Cfc_mipsegmented_Rb_sumslices','Cfc_zstacksegmented_Rb_maxslice',...
        'Cfc_zstacksegmented_Rb_sumslices','Cfc_zstacksegmented_Rb_meanintensity'};
end

% complete_data_1 =[epi_areas, epi_ef1a, cfc_mip_ef1a, cfc_zstacksegmented_area_sumslices, cfc_zstacksegmented_ef1a_sumslices];
% var_names = {'Epi_area','Epi_EF1a','Cfc_mip_EF1a','Cfc_volume','Cfc_EF1a_sumslices'};
% figure,gplotmatrix(complete_data_1)
% text([.04 .24 .44 .64 .84], repmat(-.1,1,5), var_names, 'FontSize',14, 'Interpreter','none');
% text(repmat(-.12,1,5), [.84 .70 .48 .26 0], var_names, 'FontSize',12, 'Rotation',90, 'Interpreter','none');
%
% complete_data_2 =[epi_areas.^1.5, epi_ef1a, cfc_mip_ef1a, cfc_zstacksegmented_area_sumslices, cfc_zstacksegmented_ef1a_sumslices];
% var_names = {'Epi_volume','Epi_EF1a','Cfc_mip_EF1a','Cfc_volume','Cfc_EF1a_sumslices'};
% figure,gplotmatrix(complete_data_2)
% text([.04 .24 .44 .64 .84], repmat(-.1,1,5), var_names, 'FontSize',14, 'Interpreter','none');
% text(repmat(-.12,1,5), [.84 .70 .48 .26 0], var_names, 'FontSize',12, 'Rotation',90, 'Interpreter','none');
%
% complete_data_3 = [epi_ef1a, cfc_zstacksegmented_ef1a_sumslices, cfc_zstacksegmented_area_maxslice, cfc_zstacksegmented_ef1a_maxslice, cfc_zstacksegmented_ef1a_maxslice_meanintens];
% var_names = {'Epi_EF1a','Cfc_ef1a_sumslices','Cfc_area_maxslice','Cfc_EF1a_maxslice','Cfc_EF1a_maxslice_meanintensity'};
% figure,gplotmatrix(complete_data_3)
% text([.04 .24 .44 .64 .84], repmat(-.1,1,5), var_names, 'FontSize',14, 'Interpreter','none');
% text(repmat(-.12,1,5), [.88 .64 .42 .22 -.12], var_names, 'FontSize',12, 'Rotation',90, 'Interpreter','none');
%
% complete_data_4 = [epi_rb, epi_rb ./ (epi_areas .^ 1.5), epi_rb ./ epi_ef1a, cfc_zstacksegmented_rb_sumslices ./ cfc_zstacksegmented_area_sumslices, cfc_zstacksegmented_ef1a_maxslice_meanintens];
% var_names = {'Epi_Rb','Epi_Rb_per_epi_volume','Epi_Rb_per_epi_EF1a','Cfc_Rb_sumslices_per_cfc_volume','Cfc_Rb_maxslice_meanintensity'};
% figure,gplotmatrix(complete_data_4)
% text([.04 .24 .44 .62 .84], repmat(-.1,1,5), var_names, 'FontSize',14, 'Interpreter','none');
% text(repmat(-.12,1,5), [.88 .64 .42 .18 -.12], var_names, 'FontSize',12, 'Rotation',90, 'Interpreter','none');

heatmap_data_1 = [epi_ef1a, epi_areas .^ 1.5, cfc_zstacksegmented_ef1a_sumslices, cfc_zstacksegmented_ef1a_maxslice_meanintens,...
    cfc_zstacksegmented_area_sumslices];
heatmap_var_names_1 = {'Epi_EF1a_total','Epi_volume','Cfc_EF1a_sumtotal','Cfc_EF1a_mean','Cfc_volume'};
assert(size(heatmap_data_1,2) == length(heatmap_var_names_1))
figure
gplotmatrix_notex(heatmap_data_1,[],[],'k','.',[],'on','',heatmap_var_names_1)
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,[figure_folder '\All_size_correlations.png'])
for i = 1:length(heatmap_var_names_1)
    for j = 1:length(heatmap_var_names_1)
        lm = fitlm(heatmap_data_1(:,i),heatmap_data_1(:,j));
        r2_mat_1(i,j) = lm.Rsquared.Ordinary;
    end
end
figure
heatmap(heatmap_var_names_1,heatmap_var_names_1,r2_mat_1,'Colormap',cool)
title({'R^2 values for pairwise correlations'})
saveas(gcf,[figure_folder '\All_size_correlations_heatmap.png'])

heatmap_data_2 = [epi_rb, epi_areas .^ 1.5, cfc_zstacksegmented_rb_sumslices, cfc_zstacksegmented_rb_maxslice_meanintens,...
    cfc_zstacksegmented_area_sumslices];
heatmap_var_names_2 = {'Epi_Rb_total','Epi_volume','Cfc_Rb_sumtotal','Cfc_Rb_mean','Cfc_volume'};
assert(size(heatmap_data_2,2) == length(heatmap_var_names_2))
figure
gplotmatrix_notex(heatmap_data_2,[],[],'k','.',[],'on','',heatmap_var_names_2)
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,[figure_folder '\All_size_and_Rb_amt_correlations.png'])
for i = 1:length(heatmap_var_names_2)
    for j = 1:length(heatmap_var_names_2)
        lm = fitlm(heatmap_data_2(:,i),heatmap_data_2(:,j));
        r2_mat_2(i,j) = lm.Rsquared.Ordinary;
    end
end
figure
heatmap(heatmap_var_names_2,heatmap_var_names_2,r2_mat_2,'Colormap',cool)
title({'R^2 values for pairwise correlations'})
saveas(gcf,[figure_folder '\All_size_and_Rb_amt_correlations_heatmap.png'])


heatmap_data_3 = [epi_rb ./ epi_areas .^ 1.5, epi_rb ./ epi_ef1a, cfc_zstacksegmented_rb_sumslices ./ cfc_zstacksegmented_area_sumslices,...
    cfc_zstacksegmented_rb_sumslices ./ cfc_zstacksegmented_ef1a_sumslices, cfc_zstacksegmented_rb_maxslice_meanintens];
heatmap_var_names_3 = {'Epi_Rb_per_epi_volume','Epi_Rb_per_epi_EF1a','Cfc_Rb_per_cfc_volume','Cfc_Rb_per_cfc_EF1a','Cfc_Rb_mean'};
assert(size(heatmap_data_3,2) == length(heatmap_var_names_3))
figure
gplotmatrix_notex(heatmap_data_3,[],[],'k','.',[],'on','',heatmap_var_names_3)
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,[figure_folder '\All_Rb_concentration_correlations.png'])
for i = 1:length(heatmap_var_names_3)
    for j = 1:length(heatmap_var_names_3)
        lm = fitlm(heatmap_data_3(:,i),heatmap_data_3(:,j));
        r2_mat_3(i,j) = lm.Rsquared.Ordinary;
    end
end
figure
heatmap(heatmap_var_names_3,heatmap_var_names_3,r2_mat_3,'Colormap',cool)
title('R^2 values for pairwise correlations')
saveas(gcf,[figure_folder '\All_Rb_concentration_correlations_heatmap.png'])

heatmap_data_4 = [epi_rb ./ epi_areas .^ 1.5, epi_rb ./ epi_ef1a, cfc_zstacksegmented_rb_sumslices ./ cfc_zstacksegmented_area_sumslices,...
    cfc_zstacksegmented_rb_sumslices ./ cfc_zstacksegmented_ef1a_sumslices, cfc_zstacksegmented_rb_maxslice_meanintens,...
    epi_rb ./ cfc_zstacksegmented_area_sumslices, cfc_zstacksegmented_rb_sumslices ./ epi_areas .^ 1.5];
heatmap_var_names_4 = {'Epi_Rb_per_epi_volume','Epi_Rb_per_epi_EF1a','Cfc_Rb_per_cfc_volume','Cfc_Rb_per_cfc_EF1a','Cfc_Rb_mean',...
    'Epi_Rb_per_cfc_volume','Cfc_Rb_per_epi_volume'};
assert(size(heatmap_data_4,2) == length(heatmap_var_names_4))
figure
gplotmatrix_notex(heatmap_data_4,[],[],'k','.',[],'on','',heatmap_var_names_4)
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,[figure_folder '\All_even_more_Rb_concentration_correlations.png'])
for i  = 1:length(heatmap_var_names_4)
    for j = 1:length(heatmap_var_names_4)
        lm = fitlm(heatmap_data_4(:,i),heatmap_data_4(:,j));
        r2_mat_4(i,j) = lm.Rsquared.Ordinary;
    end
end
figure
heatmap(heatmap_var_names_4,heatmap_var_names_4,r2_mat_4,'Colormap',cool)
title({'R^2 values for pairwise correlations'})
saveas(gcf,[figure_folder '\All_even_more_Rb_concentration_correlations_heatmap.png'])

heatmap_data_5 = [epi_ef1a, epi_areas .^ 1.5, epi_ef1a_mean, cfc_zstacksegmented_ef1a_sumslices, cfc_zstacksegmented_ef1a_maxslice_meanintens,...
    cfc_zstacksegmented_area_sumslices, epi_ef1a ./ epi_areas .^ 1.5, cfc_zstacksegmented_ef1a_sumslices ./ cfc_zstacksegmented_area_sumslices];
heatmap_var_names_5 = {'Epi_EF1a_total','Epi_volume','Epi_EF1a_mean','Cfc_EF1a_sumtotal','Cfc_EF1a_mean',...
    'Cfc_volume','Epi_EF1a_per_epi_volume','Cfc_EF1a_per_cfc_volume'};
assert(size(heatmap_data_5,2) == length(heatmap_var_names_5))
figure
gplotmatrix_notex(heatmap_data_5,[],[],'k','.',[],'on','',heatmap_var_names_5)
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,[figure_folder '\All_EF1a_concentration_correlations.png'])
for i = 1:length(heatmap_var_names_5)
    for j = 1:length(heatmap_var_names_5)
        lm = fitlm(heatmap_data_5(:,i),heatmap_data_5(:,j));
        r2_mat_5(i,j) = lm.Rsquared.Ordinary;
    end
end
figure
heatmap(heatmap_var_names_5,heatmap_var_names_5,r2_mat_5,'Colormap',cool)
title({'R^2 values for pairwise correlations'})
saveas(gcf,[figure_folder '\All_EF1a_concentration_correlations_heatmap.png'])

if plot_all_correlations_independently
    plot_num = 0;
    for y_var_to_plot = all_y_vars_to_plot
        for x_var_to_plot = all_x_vars_to_plot
            plot_num = plot_num + 1;
            switch x_var_to_plot{1}
                case 'Epi_area'
                    data.x = epi_areas;
                    x_axis_label = 'Area from epifluorescence segmentation (px2)';
                case 'Epi_EF1a'
                    data.x = epi_ef1a;
                    x_axis_label = 'EF1a integrated intensity from epifluorescence (AU)';
                case 'Cfc_zstacksegmented_EF1a_maxslice'
                    data.x = cfc_zstacksegmented_ef1a_maxslice;
                    x_axis_label = [{'EF1a integrated intensity from single greatest confocal z-slice,'};...
                        {'segmented for each z-slice (AU)'}];
                case 'Cfc_zstacksegmented_EF1a_sumslices'
                    data.x = cfc_zstacksegmented_ef1a_sumslices;
                    x_axis_label = [{'EF1a integrated intensity from sum of all confocal z-slices,'};...
                        {'segmented for each z-slice (AU)'}];
                case 'Epi_Rb'
                    data.x = epi_rb;
                    x_axis_label = 'Rb integrated intensity from epifluorescence (AU)';
                case 'Epi_Rb_per_Epi_EF1a'
                    data.x = epi_rb ./ epi_ef1a;
                    x_axis_label = [{'Rb integrated intensity from epifluorescence'};...
                        {'per unit EF1a integrated intensity from epifluorescence (AU/AU)'}];
            end
            
            switch y_var_to_plot{1}
                case 'Epi_EF1a'
                    data.y = epi_ef1a;
                    y_axis_label = 'EF1a integrated intensity from epifluorescence (AU)';
                case 'Cfc_mip_EF1a'
                    data.y = cfc_mip_ef1a;
                    y_axis_label = 'EF1a integrated intensity from confocal max intensity projection (AU)';
                case 'Epi_EF1a_per_Epi_area'
                    data.y = epi_ef1a ./ epi_areas;
                    y_axis_label = 'EF1a integrated intensity from epifluorescence divided by area (AU/px2)';
                case 'Cfc_mipsegmented_EF1a_maxslice'
                    data.y = cfc_mipsegmented_ef1a_maxslice;
                    y_axis_label = [{'EF1a integrated intensity from single greatest confocal z-slice,'};...
                        {'segmented from max intensity projection (AU)'}];
                case 'Cfc_mipsegmented_EF1a_sumslices'
                    data.y = cfc_mipsegmented_ef1a_sumslices;
                    y_axis_label = [{'EF1a integrated intensity from sum of all confocal z-slices,'};...
                        {'segmented form max intensity projection (AU)'}];
                case 'Cfc_zstacksegmented_EF1a_maxslice'
                    data.y = cfc_zstacksegmented_ef1a_maxslice;
                    y_axis_label = [{'EF1a integrated intensity from single greatest confocal z-slice,'};...
                        {'segmented for each z-slice (AU)'}];
                case 'Cfc_zstacksegmented_EF1a_sumslices'
                    data.y = cfc_zstacksegmented_ef1a_sumslices;
                    y_axis_label = [{'EF1a integrated intensity from sum of all confocal z-slices,'};...
                        {'segmented for each z-slice (AU)'}];
                case 'Cfc_zstacksegmented_EF1a_meanintensity'
                    data.y = cfc_zstacksegmented_ef1a_maxslice_meanintens;
                    y_axis_label = [{'EF1a mean intensity from single greatest confocal z-slice,'};
                        {'segmented for that z-slice (AU/px2)'}];
                case 'Cfc_zstacksegmented_volume'
                    data.y = cfc_zstacksegmented_area_sumslices;
                    y_axis_label = 'Volume from confocal z-slice segmentation (px2*um)';
                case 'Epi_EF1a_per_Cfc_zstacksegmented_volume'
                    data.y = epi_ef1a ./ cfc_zstacksegmented_area_sumslices;
                    y_axis_label =[{'EF1a integrated intensity from epifluorescence,'};...
                        {'divided by confocal z-slice segmentation volume (AU/(px2*um))'}];
                case 'Cfc_zstacksegmented_EF1a_sumslices_per_Cfc_zstacksegmented_volume'
                    data.y = cfc_zstacksegmented_ef1a_sumslices ./ cfc_zstacksegmented_area_sumslices;
                    y_axis_label =[{'EF1a integrated intensity from sum of all confocal z-slices,'};...
                        {'divided by confocal z-slice segmentation volume (AU/(px2*um))'}];
                    
                case 'Cfc_mip_Rb'
                    data.y = cfc_mip_rb;
                    y_axis_label = 'Rb integrated intensity from confocal max intensity projection (AU)';
                case 'Cfc_mipsegmented_Rb_maxslice'
                    data.y = cfc_mipsegmented_rb_maxslice;
                    y_axis_label = [{'Rb integrated intensity from single greatest confocal z-slice,'};
                        {'segmented from max intensity projection (AU)'}];
                case 'Cfc_mipsegmented_Rb_sumslices'
                    data.y = cfc_mipsegmented_rb_sumslices;
                    y_axis_label = [{'Rb integrated intensity from sum of all confocal z-slices,'};
                        {'segmented from max intensity projection (AU)'}];
                case 'Cfc_zstacksegmented_Rb_maxslice'
                    data.y = cfc_zstacksegmented_rb_maxslice;
                    y_axis_label = [{'Rb integrated intensity from single greatest confocal z-slice,'};
                        {'segmented for each z-slice (AU)'}];
                case 'Cfc_zstacksegmented_Rb_sumslices'
                    data.y = cfc_zstacksegmented_rb_sumslices;
                    y_axis_label = [{'Rb integrated intensity from sum of all confocal z-slices,'};
                        {'segmented for each z-slice (AU)'}];
                case 'Cfc_zstacksegmented_Rb_meanintensity'
                    data.y = cfc_zstacksegmented_rb_maxslice_meanintens;
                    y_axis_label = [{'Rb mean intensity from single greatest confocal z-slice,'};
                        {'segmented for that z-slice (AU/px2)'}];
            end
            
            assert(length(data.x) == length(data.y));
            clean_data.x = [];
            clean_data.y = [];
            for i = 1:length(data.x)
                if ~isnan(data.x(i)) && ~isnan(data.y(i))
                    clean_data.x = [clean_data.x; data.x(i)];
                    clean_data.y = [clean_data.y; data.y(i)];
                end
            end
            
            assert(length(clean_data.x) == length(clean_data.y));
            figure
            plot_scatter_with_line(clean_data.x,clean_data.y);
            xlabel(gca,x_axis_label)
            ylabel(gca,y_axis_label)
            
            saveas(gcf,[figure_folder '\' x_var_to_plot{1} '_vs_' y_var_to_plot{1} '.png'])
            
            subplot(length(all_y_vars_to_plot),length(all_x_vars_to_plot),plot_num)
            subplot_scatter_with_line(clean_data.x,clean_data.y);
            xlabel(gca,x_axis_label)
            ylabel(gca,y_axis_label)
        end
    end
end
end

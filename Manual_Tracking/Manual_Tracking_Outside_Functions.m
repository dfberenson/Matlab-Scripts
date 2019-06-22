
clear all
close all

%% Initialize Variables

% Need to change backslashes to forward slashes in filenames on Mac

source_folder = 'H:\DFB_imaging_experiments_3';
destination_folder = 'H:\Manually tracked imaging experiments';
base_expt_name = 'DFB_181031_HMEC_1E+gem_palbo_1';
expt_source_folder = [source_folder '\' base_expt_name];
pos = 3;
order_of_colors = 'pgr';
full_expt_name = [base_expt_name '_Pos' num2str(pos)];
expt_destination_folder = [destination_folder '\' full_expt_name];

storage_type = 'stack';
max_n = 3;

% storage_type = 'sequence';
% num_images = 432;


%% Put images in correct folders


if ~exist(expt_destination_folder,'dir')
    mkdir(expt_destination_folder);
end
if ~exist([expt_destination_folder  '\' full_expt_name '_RawGray'],'dir')
    mkdir([expt_destination_folder  '\' full_expt_name '_RawGray']);
end
if ~exist([expt_destination_folder  '\' full_expt_name '_RawGreen'],'dir')
    mkdir([expt_destination_folder  '\' full_expt_name '_RawGreen']);
end
if ~exist([expt_destination_folder  '\' full_expt_name '_RawRed'],'dir')
    mkdir([expt_destination_folder  '\' full_expt_name '_RawRed']);
end

init_frame = 1;
current_frame = init_frame;

switch storage_type
    case 'stack'
        
        for n = 0:max_n
            if n == 0
                raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '.ome.tif']);
            else
                raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome.tif']);
            end
            size_raw_imstack = size(raw_imstack);
            for i = 1:size_raw_imstack(3)/3
                disp(['Writing image ' sprintf('%03d',current_frame)])
                if strcmp(order_of_colors,'pgr')
                    imwrite(raw_imstack(:,:,3*i-2),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                        full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                    imwrite(raw_imstack(:,:,3*i-1),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                        full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                    imwrite(raw_imstack(:,:,3*i-0),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                        full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                elseif strcmp(order_of_colors,'prg')
                    imwrite(raw_imstack(:,:,3*i-2),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                        full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                    imwrite(raw_imstack(:,:,3*i-1),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                        full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                    imwrite(raw_imstack(:,:,3*i-0),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                        full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                end
                current_frame = current_frame + 1;
            end
        end
        
    case 'sequence'
        for current_frame = 1:num_images
            for c = 0:length(order_of_colrs)-1
                disp(['Writing image ' sprintf('%03d',current_frame)])
                im = imread([expt_source_folder '\' base_expt_name '\Pos' num2str(pos) '\img_channel' sprintf('%03d',c) '_position' sprintf('%03d',pos)...
                    '_time' sprintf('%09d',current_frame-1) '_z000.tif']);
                if strcmp(order_of_colors,'pgr')
                    switch c
                        case 0
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                                full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                        case 1
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                                full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                        case 2
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                                full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                    end
                elseif strcmp(order_of_colors,'prg')
                    switch c
                        case 0
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                                full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                        case 1
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                                full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                        case 2
                            imwrite(im,[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                                full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                    end
                end
            end
        end
end



%% Segment programatically

% clear overlaid_movie


startframe = 1;
endframe = 432;
gaussian_width = 2;
threshold = 300;
% Threshold = 200 is good for tracking 500ms mCherry @ 5% in line 1G. 300
% is better for 1E.
% Threshold = 300 was used for automatically counting fraction Gem+.
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

if ~exist([expt_destination_folder  '\Segmentation'],'dir')
    mkdir([expt_destination_folder  '\Segmentation']);
end

fileID = fopen([expt_destination_folder '\Segmentation\Segmentation_Parameters.txt'],'w');
fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
fprintf(fileID,['Threshold > ' num2str(threshold) '\r\n']);
fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fclose(fileID);

for  i = startframe:endframe
    disp(['Segmenting frame ' num2str(i)]);
    raw_main = imread([expt_destination_folder  '\' full_expt_name '_RawRed\'...
        full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
    
    gaussian_filtered = imgaussfilt(raw_main,gaussian_width);
    %     figure,imshow(gaussian_filtered,[])
    thresholded = gaussian_filtered > threshold;
    % figure,imshow(thresholded)
    im_opened = imopen(thresholded,se);
    % figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    % figure,imshow(im_closed)
    
    imwrite(im_closed,[expt_destination_folder '\Segmentation\Segmented_' sprintf('%03d',i) '.tif']);
    
    %     im_overlaid = imoverlay_fast(raw_main*200, bwperim(im_closed));
    %     overlaid_movie(:,:,i+1-startframe) = im_overlaid;
end
% implay(overlaid_movie)

if ~exist([expt_destination_folder  '\Resegmentation\'],'dir')
    mkdir([expt_destination_folder  '\Resegmentation\']);
end


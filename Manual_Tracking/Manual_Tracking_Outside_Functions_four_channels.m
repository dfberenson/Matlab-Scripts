
clear all
close all

%% Initialize Variables

% Need to change backslashes to forward slashes in filenames on Mac

% folder = 'C:\Users\Skotheim Lab\Desktop\Manual_Tracking';
folder = 'F:\DFB_imaging_experiments_2';
base_expt_name = 'DFB_180803_HMEC_D5_1';
pos = 3;
full_expt_name = [base_expt_name '_Pos' num2str(pos)];
expt_folder = [folder '\' full_expt_name];
order_of_colors = 'pgrf';
% phase green red farred
max_n = 4;

%% Put images in correct folders


if ~exist(expt_folder,'dir')
    mkdir(expt_folder);
end
if ~exist([expt_folder  '\' full_expt_name '_RawGray'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawGray']);
end
if ~exist([expt_folder  '\' full_expt_name '_RawGreen'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawGreen']);
end
if ~exist([expt_folder  '\' full_expt_name '_RawRed'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawRed']);
end
if ~exist([expt_folder  '\' full_expt_name '_RawFarRed'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawFarRed']);
end

init_frame = 1;
current_frame = init_frame;
left_off_before = order_of_colors(end-3);

for n = 0:max_n
    if n == 0
        raw_imstack = readStack([expt_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '.ome.tif']);
    else
        raw_imstack = readStack([expt_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome.tif']);
    end
    [~,~,length_imstack] = size(raw_imstack);
    
    for i = 1 : length_imstack/4 + 1
        disp(['Writing image ' sprintf('%03d',current_frame)])
        if strcmp(order_of_colors,'pgrf')
            disp(['Stack ' num2str(n) ' images ' num2str(4*i-3) '-' num2str(4*i-0) ...
                ' is being written as frame ' num2str(current_frame) ' starting with color '...
                left_off_before])
            % Need to change the order depending on where left off since
            % number of frames per movie is not necessarily divisible by 4
            if left_off_before == 'p'
                if 4*i - 3 > length_imstack
                    left_off_before = order_of_colors(end-3);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-3),[expt_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 2 > length_imstack
                    left_off_before = order_of_colors(end-2);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-2),[expt_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 1 > length_imstack
                    left_off_before = order_of_colors(end-1);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-1),[expt_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 0 > length_imstack
                    left_off_before = order_of_colors(end-0);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-0),[expt_folder  '\' full_expt_name '_RawFarRed\'...
                    full_expt_name '_RawFarRed_' sprintf('%03d',current_frame) '.tif']);
                current_frame = current_frame + 1;
                
            elseif left_off_before == 'g'
                if 4*i - 3 > length_imstack
                    left_off_before = order_of_colors(end-2);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-3),[expt_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 2 > length_imstack
                    left_off_before = order_of_colors(end-1);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-2),[expt_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 1 > length_imstack
                    left_off_before = order_of_colors(end-0);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-1),[expt_folder  '\' full_expt_name '_RawFarRed\'...
                    full_expt_name '_RawFarRed_' sprintf('%03d',current_frame) '.tif']);
                current_frame = current_frame + 1;
                if 4*i - 0 > length_imstack
                    left_off_before = order_of_colors(end-3);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-0),[expt_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                
            elseif left_off_before == 'r'
                if 4*i - 3 > length_imstack
                    left_off_before = order_of_colors(end-1);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-3),[expt_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 2 > length_imstack
                    left_off_before = order_of_colors(end-0);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-2),[expt_folder  '\' full_expt_name '_RawFarRed\'...
                    full_expt_name '_RawFarRed_' sprintf('%03d',current_frame) '.tif']);
                current_frame = current_frame + 1;
                if 4*i - 1 > length_imstack
                    left_off_before = order_of_colors(end-3);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-1),[expt_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 0 > length_imstack
                    left_off_before = order_of_colors(end-2);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-0),[expt_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                
            elseif left_off_before == 'f'
                if 4*i - 3 > length_imstack
                    left_off_before = order_of_colors(end-0);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-3),[expt_folder  '\' full_expt_name '_RawFarRed\'...
                    full_expt_name '_RawFarRed_' sprintf('%03d',current_frame) '.tif']);
                current_frame = current_frame + 1;
                if 4*i - 2 > length_imstack
                    left_off_before = order_of_colors(end-3);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-2),[expt_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 1 > length_imstack
                    left_off_before = order_of_colors(end-2);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-1),[expt_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
                if 4*i - 0 > length_imstack
                    left_off_before = order_of_colors(end-1);
                    continue
                end
                imwrite(raw_imstack(:,:,4*i-0),[expt_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
            end
        end
    end
end

%% Segment programatically

% clear overlaid_movie

startframe = 1;
endframe = 432;
gaussian_width = 2;
threshold = 272;
strel_shape = 'disk';
strel_size = 3;
se = strel(strel_shape,strel_size);

if ~exist([expt_folder  '\Segmentation'],'dir')
    mkdir([expt_folder  '\Segmentation']);
end

fileID = fopen([expt_folder '\Segmentation\Segmentation_Parameters.txt'],'w');
fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
fprintf(fileID,['Threshold > ' num2str(threshold) '\r\n']);
fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
fclose(fileID);


for  i = startframe:endframe
    disp(['Segmenting frame ' num2str(i)]);
    raw_main = imread([expt_folder  '\' full_expt_name '_RawFarRed\'...
        full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']);
    
    gaussian_filtered = imgaussfilt(raw_main,gaussian_width);
    %     figure,imshow(gaussian_filtered,[])
    thresholded = gaussian_filtered > threshold;
    % figure,imshow(thresholded)
    im_opened = imopen(thresholded,se);
    % figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    % figure,imshow(im_closed)
    
    imwrite(im_closed,[expt_folder '\Segmentation\Segmented_' sprintf('%03d',i) '.tif']);
    
    %     im_overlaid = imoverlay_fast(raw_main*200, bwperim(im_closed));
    %     overlaid_movie(:,:,i+1-startframe) = im_overlaid;
end
% implay(overlaid_movie)

if ~exist([expt_folder  '\Resegmentation\'],'dir')
    mkdir([expt_folder  '\Resegmentation\']);
end

clear all

%% Initialize Variables

folder = 'E:\RealStack';
expt_name = 'DFB_170308_HMEC_1Giii_1_hyperstack_Pos1';
expt_folder = [folder '\' expt_name];
startframe = 1;
endframe = 129;



%% Put images in correct folders


if ~exist(expt_folder,'dir')
    mkdir(expt_folder);
end
if ~exist([expt_folder  '\' expt_name '_RawGray'],'dir')
    mkdir([expt_folder  '\' expt_name '_RawGray']);
end
if ~exist([expt_folder  '\' expt_name '_RawGreen'],'dir')
    mkdir([expt_folder  '\' expt_name '_RawGreen']);
end
if ~exist([expt_folder  '\' expt_name '_RawRed'],'dir')
    mkdir([expt_folder  '\' expt_name '_RawRed']);
end

init_frame = 1;
current_frame = init_frame;

for n = 0:5
    raw_imstack = readStack([folder '\' expt_name '_' num2str(n) '.tif']);
    size_raw_imstack = size(raw_imstack);
    for i = 1:size_raw_imstack(3)/3
        disp(['Writing image ' sprintf('%03d',current_frame)])
        imwrite(raw_imstack(:,:,3*i-2),[expt_folder  '\' expt_name '_RawGray\'...
            expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
        imwrite(raw_imstack(:,:,3*i-1),[expt_folder  '\' expt_name '_RawGreen\'...
            expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
        imwrite(raw_imstack(:,:,3*i-0),[expt_folder  '\' expt_name '_RawRed\'...
            expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
        current_frame = current_frame + 1;
    end
end

%% Segment programatically

% clear overlaid_movie


startframe = 1;
endframe = 720;
gaussian_width = 2;
threshold = 115;
strel_shape = 'disk';
strel_size = 1;
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
    raw_main = imread([expt_folder  '\' expt_name '_RawRed\'...
        expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
    
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


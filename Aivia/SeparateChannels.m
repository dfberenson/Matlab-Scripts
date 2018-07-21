
%% Load images

clear all

source_folder = 'F:\DFB_imaging_experiments';
expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
infix = '_MMStack_Pos';
position = num2str(14);
suffixes = '.ome.tif';
num_channels = 3;

imstack0 = readStack([source_folder '\' expt_name '\' expt_name infix position suffixes]);
imstack1 = readStack([source_folder '\' expt_name '\' expt_name infix position '_1' suffixes]);
imstack2 = readStack([source_folder '\' expt_name '\' expt_name infix position '_2' suffixes]);
imstack3 = readStack([source_folder '\' expt_name '\' expt_name infix position '_3' suffixes]);

[Y,X,imstack0_length] = size(imstack0);
[~,~,imstack1_length] = size(imstack1);
[~,~,imstack2_length] = size(imstack2);
[~,~,imstack3_length] = size(imstack3);

imstack0_length = imstack0_length / num_channels;
imstack1_length = imstack1_length / num_channels;
imstack2_length = imstack2_length / num_channels;
imstack3_length = imstack3_length / num_channels;

total_length = imstack0_length + imstack1_length + imstack2_length + imstack3_length;

%% Measure mode background

for i = 1:total_length
    disp(['Measuring image ' num2str(i)])
    if i <= imstack0_length
        j = i - 0;
        ch1_im = imstack0(:,:,3*j-2);
        ch2_im = imstack0(:,:,3*j-1);
        ch3_im = imstack0(:,:,3*j-0);
    elseif i <= imstack0_length + imstack1_length
        j = i - imstack0_length;
        ch1_im = imstack1(:,:,3*j-2);
        ch2_im = imstack1(:,:,3*j-1);
        ch3_im = imstack1(:,:,3*j-0);
    elseif i <= imstack0_length + imstack1_length + imstack2_length
        j = i - imstack0_length - imstack1_length;
        ch1_im = imstack2(:,:,3*j-2);
        ch2_im = imstack2(:,:,3*j-1);
        ch3_im = imstack2(:,:,3*j-0);
    elseif i <= imstack0_length + imstack1_length + imstack2_length + imstack3_length
        j = i - imstack0_length - imstack1_length - imstack2_length;
        ch1_im = imstack3(:,:,3*j-2);
        ch2_im = imstack3(:,:,3*j-1);
        ch3_im = imstack3(:,:,3*j-0);
    end
    
    gaussian_width = uint16(2);
    
    ch1_gaussian_filtered = imgaussfilt(ch1_im,gaussian_width);
    ch2_gaussian_filtered = imgaussfilt(ch2_im,gaussian_width);
    ch3_gaussian_filtered = imgaussfilt(ch3_im,gaussian_width);
    
%     histogram(ch2_gaussian_filtered(:));
    
    ch1_modes(i) = mode(ch1_gaussian_filtered(:));
    ch2_modes(i) = mode(ch2_gaussian_filtered(:));
    ch3_modes(i) = mode(ch3_gaussian_filtered(:));
end

destination_superfolder = 'E:\Aivia';
destination_subfolder = [destination_superfolder '\' expt_name '\'];
save([destination_subfolder 'Pos' position '_mode_intensities.mat'],...
    'ch1_modes', 'ch2_modes', 'ch3_modes');    
    

%% Write sequence

destination_superfolder = 'E:\Aivia';
destination_subfolder = [destination_superfolder '\' expt_name '\Image_Sequences\Pos' position '\'];
if ~exist(destination_subfolder,'dir')
    mkdir(destination_subfolder)
end

for i = 1:total_length
    disp(['Writing image ' num2str(i)])
    %     ch1_fpath = [destination_subfolder 'X' num2str(X) '_Y' num2str(Y) '_Z1_C1_T' sprintf('%03d',i) '_16bit.tif'];
    %     ch2_fpath = [destination_subfolder 'X' num2str(X) '_Y' num2str(Y) '_Z1_C2_T' sprintf('%03d',i) '_16bit.tif'];
    %     ch3_fpath = [destination_subfolder 'X' num2str(X) '_Y' num2str(Y) '_Z1_C3_T' sprintf('%03d',i) '_16bit.tif'];
    
%     ch1_fpath = [destination_subfolder 'C1_T' sprintf('%03d',i) '.tif'];
%     ch2_fpath = [destination_subfolder 'C2_T' sprintf('%03d',i) '.tif'];
%     ch3_fpath = [destination_subfolder 'C3_T' sprintf('%03d',i) '.tif'];

    ch1_fpath = [destination_subfolder 'C1_T' num2str(i) '.tif'];
    ch2_fpath = [destination_subfolder 'C2_T' num2str(i) '.tif'];
    ch3_fpath = [destination_subfolder 'C3_T' num2str(i) '.tif'];

    if i <= imstack0_length
        j = i - 0;
        imwrite(imstack0(:,:,3*j-2), ch1_fpath);
        imwrite(imstack0(:,:,3*j-1), ch2_fpath);
        imwrite(imstack0(:,:,3*j-0), ch3_fpath);
    elseif i <= imstack0_length + imstack1_length
        j = i - imstack0_length;
        imwrite(imstack1(:,:,3*j-2), ch1_fpath);
        imwrite(imstack1(:,:,3*j-1), ch2_fpath);
        imwrite(imstack1(:,:,3*j-0), ch3_fpath);
    elseif i <= imstack0_length + imstack1_length + imstack2_length
        j = i - imstack0_length - imstack1_length;
        imwrite(imstack2(:,:,3*j-2), ch1_fpath);
        imwrite(imstack2(:,:,3*j-1), ch2_fpath);
        imwrite(imstack2(:,:,3*j-0), ch3_fpath);
    elseif i <= imstack0_length + imstack1_length + imstack2_length + imstack3_length
        j = i - imstack0_length - imstack1_length - imstack2_length;
        imwrite(imstack3(:,:,3*j-2), ch1_fpath);
        imwrite(imstack3(:,:,3*j-1), ch2_fpath);
        imwrite(imstack3(:,:,3*j-0), ch3_fpath);
    end
end

%% Write single-channel TIF stacks
% 
% destination_folder = 'E:\Aivia';
% destination_fpath_ch1 = [destination_folder '\' expt_name '_Pos' position '_ch1.tif'];
% destination_fpath_ch2 = [destination_folder '\' expt_name '_Pos' position '_ch2.tif'];
% destination_fpath_ch3 = [destination_folder '\' expt_name '_Pos' position '_ch3.tif'];
% 
% for i = 1:imstack0_length
%     disp(['Writing image ' num2str(i)])
%     imwrite(imstack0(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
%     imwrite(imstack0(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
%     imwrite(imstack0(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
% end
% 
% for i = 1:imstack1_length
%     disp(['Writing image ' num2str(i + imstack0_length)])
%     imwrite(imstack1(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
%     imwrite(imstack1(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
%     imwrite(imstack1(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
% end
% 
% for i = 1:imstack2_length - 2
%     disp(['Writing image ' num2str(i + imstack1_length + imstack0_length)])
%     imwrite(imstack2(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
%     imwrite(imstack2(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
%     imwrite(imstack2(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
% end
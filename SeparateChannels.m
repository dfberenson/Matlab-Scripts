
clear all

source_folder = 'F:\DFB_imaging_experiments';
expt_name = 'DFB_180110_HMEC_1GFiii_palbo_After_2';
infix = '_MMStack_Pos';
position = num2str(2);
suffixes = '.ome.tif';

imstack0 = readStack([source_folder '\' expt_name '\' expt_name infix position suffixes]);
imstack1 = readStack([source_folder '\' expt_name '\' expt_name infix position '_1' suffixes]);
imstack2 = readStack([source_folder '\' expt_name '\' expt_name infix position '_2' suffixes]);
imstack3 = readStack([source_folder '\' expt_name '\' expt_name infix position '_3' suffixes]);

[~,~,imstack0_length] = size(imstack0);
[~,~,imstack1_length] = size(imstack1);
[~,~,imstack2_length] = size(imstack2);
[~,~,imstack3_length] = size(imstack3);

destination_folder = 'E:\Aivia';
destination_fpath_ch1 = [destination_folder '\' expt_name '_Pos' position '_ch1.tif'];
destination_fpath_ch2 = [destination_folder '\' expt_name '_Pos' position '_ch2.tif'];
destination_fpath_ch3 = [destination_folder '\' expt_name '_Pos' position '_ch3.tif'];

for i = 1:imstack0_length/3
    disp(['Writing image ' num2str(3*i)])
    imwrite(imstack0(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
    imwrite(imstack0(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
    imwrite(imstack0(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
end

for i = 1:imstack1_length/3
    disp(['Writing image ' num2str(3*i + imstack0_length)])
    imwrite(imstack1(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
    imwrite(imstack1(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
    imwrite(imstack1(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
end

for i = 1:imstack2_length/3 - 2
    disp(['Writing image ' num2str(3*i + imstack1_length + imstack0_length)])
    imwrite(imstack2(:,:,3*i-2), destination_fpath_ch1, 'writemode', 'append');
    imwrite(imstack2(:,:,3*i-1), destination_fpath_ch2, 'writemode', 'append');
    imwrite(imstack2(:,:,3*i-0), destination_fpath_ch3, 'writemode', 'append');
end
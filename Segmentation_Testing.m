
clear all


startframe = 1;
endframe = 421;
gaussian_width = 3;
threshold_1 = 270;
threshold_2 = 265;
threshold_3 = 275;
strel_shape = 'disk';
strel_size = 3;
se = strel(strel_shape,strel_size);

for i = 1 : 20 : 421

raw_main = imread(['F:\DFB_imaging_experiments_2\DFB_180803_HMEC_D5_1_Pos3\DFB_180803_HMEC_D5_1_Pos3_RawFarRed\DFB_180803_HMEC_D5_1_Pos3_RawFarRed_' sprintf('%03d',i) '.tif']);

% figure,imshow(raw_main,[0 500])
    gaussian_filtered = imgaussfilt(raw_main,gaussian_width);
%         figure,imshow(gaussian_filtered,[])
    thresholded = gaussian_filtered > threshold_1;
%     figure,imshow(thresholded)
    im_opened = imopen(thresholded,se);
%     figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    figure,imshow(im_closed)
    
        thresholded = gaussian_filtered > threshold_2;
%     figure,imshow(thresholded)
    im_opened = imopen(thresholded,se);
%     figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    figure,imshow(im_closed)
    
        thresholded = gaussian_filtered > threshold_3;
%     figure,imshow(thresholded)
    im_opened = imopen(thresholded,se);
%     figure,imshow(im_opened)
    im_closed = imclose(im_opened,se);
    figure,imshow(im_closed)
end
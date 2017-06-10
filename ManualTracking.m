
%This approach: show each image and ask user to type in the right number
%Can enter 0 to go back

cellnum = 6;

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';
fname_trackedimg = ['DFB_170308_HMEC_1Giii_1 images\Individual Cells\Cell'...
num2str(cellnum) 'granddaughters_labelUntracked'];
fpath_trackedimg = [foldername '/' fname_trackedimg '.tif'];
info = imfinfo(fpath_trackedimg);
num_images = numel(info);
h = info.Height;
w = info.Width;

imstack = zeros(h,w,3,num_images);

for i = 1:num_images
    A = imread(fpath_trackedimg, i, 'Info', info);
    imstack(:,:,:,i) = A;
end



imshow(uint8(imstack(:,:,:,1)))
cell = input('Number of cell to be tracked: ');
close()
track = zeros(num_images,1);

i = 1;
while i<=num_images
    %figure()
    imshow(uint8(imstack(:,:,:,i)))
    title(['Frame ' num2str(i)])
    newnum = input(['In frame ' num2str(i) ', original cell ' num2str(cell) ' is now number: ']);
    %close();
    if newnum == 0
        i = i-1;
        continue
    end
    track(i) = newnum;
    i = i+1;
end

outlinesOnly = true;

ancestorcellnum = 36;
n = 1;

foldername = 'E:/Image Analysis';
fname_grayimg = ['DFB_170308_HMEC_1Giii_1 images/Individual Cells/Cell'...
num2str(ancestorcellnum) 'granddaughters_labelUntrackedGray'];
fpath_grayimg = [foldername '/' fname_grayimg '.tif'];
fname_origimg = ['DFB_170308_HMEC_1Giii_1 images/Individual Cells/Cell'...
num2str(ancestorcellnum) 'granddaughters'];
fpath_origimg = [foldername '/' fname_origimg '.tif'];
fname_manualtracks = ['DFB_170308_HMEC_1Giii_1 analysis/Cell' num2str(ancestorcellnum) 'granddaughters_Segmented_ManuallyTracked'];
fpath_manualtracks = [foldername '/' fname_manualtracks '.xlsx'];

%Calls importManualTracks to get the list of frames and corresponding object labels

[trackedframes,track] = importManualTracks(fpath_grayimg , fpath_manualtracks , n);
firstframe = min(trackedframes);
lastframe = max(trackedframes);

%Load segmented gray image
info = imfinfo(fpath_grayimg);
num_images = numel(info);
h = info.Height;
w = info.Width;
grayimstack = zeros(h,w,num_images);
for i = 1:num_images
    A = imread(fpath_grayimg, i, 'Info', info);
    grayimstack(:,:,i) = A;
end

%Load red channel from original image
info = imfinfo(fpath_origimg);
numchannels = 3;
channeltodisplay = 3;
num_images = numel(info) / numchannels;
h = info.Height;
w = info.Width;
origimstack = zeros(h,w,num_images);
for i = 1:num_images
    origimg = imread(fpath_origimg,  numchannels*(i-1) + channeltodisplay, 'Info', info);
    origimstack(:,:,i) = origimg;
end

%Create new yellow overlay
overlayimstack = zeros(h,w,num_images);
rgboverlayimstack = zeros(h,w,3,num_images);


rgbimstack = zeros(h,w,3,num_images);

for i = 1:firstframe
    rgbimstack(:,:,1,i) = mat2gray(origimstack(:,:,i));
end

for i = lastframe:num_images
    rgbimstack(:,:,1,i) = mat2gray(origimstack(:,:,i));
end


if outlinesOnly
    for i = firstframe:lastframe
        disp(i);
        grayimg = grayimstack(:,:,i);
        goodlabelnums = track(trackedframes == i);
        alllabelsmatrix = grayimg ~= 0;
        goodlabelsmatrix = ismember(grayimg,goodlabelnums) & grayimg ~= 0;
        otherlabelsmatrix = logical(alllabelsmatrix - goodlabelsmatrix);
        
        goodlabelsmatrix_outlines = goodlabelsmatrix;
        otherlabelsmatrix_outlines = otherlabelsmatrix;
        
        for j = 2:h-1
            for k = 2:w-1
                if goodlabelsmatrix(j,k) == 1
                    if goodlabelsmatrix(j-1,k-1) == 1 & goodlabelsmatrix(j,k-1) == 1 & goodlabelsmatrix(j+1,k-1) == 1 &...
                            goodlabelsmatrix(j-1,k) == 1 & goodlabelsmatrix(j+1,k) == 1 &...
                            goodlabelsmatrix(j-1,k+1) == 1 & goodlabelsmatrix(j,k+1) == 1 & goodlabelsmatrix(j+1,k+1) == 1
                        goodlabelsmatrix_outlines(j,k) = 0;
                    end
                end
                if otherlabelsmatrix(j,k) == 1
                    if otherlabelsmatrix(j-1,k-1) == 1 & otherlabelsmatrix(j,k-1) == 1 & otherlabelsmatrix(j+1,k-1) == 1 &...
                            otherlabelsmatrix(j-1,k) == 1 & otherlabelsmatrix(j+1,k) == 1 &...
                            otherlabelsmatrix(j-1,k+1) == 1 & otherlabelsmatrix(j,k+1) == 1 & otherlabelsmatrix(j+1,k+1) == 1
                        otherlabelsmatrix_outlines(j,k) = 0;
                    end
                end
            end
        end
        
        rgbimstack(:,:,1,i) = mat2gray(origimstack(:,:,i));
        rgbimstack(:,:,2,i) = goodlabelsmatrix_outlines;
        rgbimstack(:,:,3,i) = otherlabelsmatrix_outlines;
    end
else
    for i = firstframe:lastframe
        grayimg = grayimstack(:,:,i);
        goodlabelnums = track(trackedframes == i);
        alllabelsmatrix = grayimg ~= 0;
        goodlabelsmatrix = ismember(grayimg,goodlabelnums) & grayimg ~= 0;
        otherlabelsmatrix = logical(alllabelsmatrix - goodlabelsmatrix);

        rgbimstack(:,:,1,i) = mat2gray(origimstack(:,:,i));
        rgbimstack(:,:,2,i) = goodlabelsmatrix * 0.5;
        rgbimstack(:,:,3,i) = otherlabelsmatrix * 0.3;   
    end
end
implay(rgbimstack)


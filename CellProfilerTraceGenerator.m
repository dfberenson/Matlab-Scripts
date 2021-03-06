% @dfberenson@gmail.com
% Next steps: convert steps to standalone functions


cellnum = 6;

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';
fname_trackedimg = ['DFB_170308_HMEC_1Giii_1 images\Individual Cells\Cell'...
num2str(cellnum) 'daughters_label'];
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

movie = implay(uint8(imstack));


% img = Tiff(fname_trackedimg,'r');
% offsets = img.getTag('SubIFD');
% img.setSubDirectory(offsets(1));
% subimg_1 = img.read();
% imagesc(subimg_1);

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';

fname_background = ['Cell' num2str(cellnum) 'daughters_Image'];
fpath_background = [foldername '/' fname_background '.csv'];
table_background = readtable(fpath_background);
imgMedians_Geminin = table2array(table_background(2:end,32));
imgMedians_mCherry = table2array(table_background(2:end,33));

fname_segmented = ['Cell' num2str(cellnum) 'daughters_Segmented'];
fpath_segmented = [foldername '/' fname_segmented '.csv'];
table_segmented = importdata(fpath_segmented,',',1);
headers_segmented = table_segmented.colheaders;
data_segmented = table_segmented.data;
index_Frames = find(strcmp(headers_segmented,'ImageNumber'));
index_Labels = find(strcmp(headers_segmented,'TrackObjects_Label_50'));
index_Areas = find(strcmp(headers_segmented,'AreaShape_Area'));
index_Geminin = find(strcmp(headers_segmented,'Intensity_IntegratedIntensity_Geminin'));
index_mCherry = find(strcmp(headers_segmented,'Intensity_IntegratedIntensity_mCherry'));

frames = data_segmented(:,index_Frames);
labels = data_segmented(:,index_Labels);
areas = data_segmented(:,index_Areas);
geminin = data_segmented(:,index_Geminin);
mCherry = data_segmented(:,index_mCherry);

numcells = length(unique(labels));
goodframes = cell(numcells,1);
rawtraces_Geminin = cell(numcells,1);
rawtraces_mCherry = cell(numcells,1);
smoothtraces_Geminin = cell(numcells,1);
smoothtraces_mCherry = cell(numcells,1);

frame_G1S = zeros(1,numcells);

%For each cell label
for i = 1:numcells
    thisframes = 1:max(frames);
    movie.show;
    thisframes = 1:input(strcat('Last good frame for cell ',num2str(i),': '));
    goodframes{i} = thisframes;
    rawtraces_Geminin{i} = zeros(length(thisframes),1);
    rawtraces_mCherry{i} = zeros(length(thisframes),1);
        
    %For each timepoint, combine all measurements with the given label
    %at this timepoint, then subtract (sum of areas)*imgmedian
    for j = 1:length(thisframes)
        rawtraces_Geminin{i}(j) = sum(geminin(labels == i & frames == j))...
            - sum(areas(labels == i & frames == j))*imgMedians_Geminin(j);
        rawtraces_mCherry{i}(j) = sum(mCherry(labels == i & frames == j))...
            - sum(areas(labels == i & frames == j))*imgMedians_mCherry(j);
    end
    
    smoothtraces_Geminin{i} = movavg(rawtraces_Geminin{i},5);
    smoothtraces_mCherry{i} = movavg(rawtraces_mCherry{i},5);    
    frame_G1S(i) = findG1S(smoothtraces_Geminin{i},10,15,'plot');
end

figure()
framerate = input('Framerate (min/frame): ');
geminin_scaler = 0.05;
legendInfo = cell(4*numcells,1);
colors = ['grcm'];
hold on
for i = 1:numcells
    plot(goodframes{i}*framerate,rawtraces_Geminin{i}(goodframes{i})*geminin_scaler , [colors(2*i-1) ':'])
    plot(goodframes{i}*framerate,rawtraces_mCherry{i}(goodframes{i}) , [colors(2*i) ':'])
    plot(goodframes{i}*framerate,smoothtraces_Geminin{i}(goodframes{i})*geminin_scaler , [colors(2*i-1) '-'])
    plot(goodframes{i}*framerate,smoothtraces_mCherry{i}(goodframes{i}) , [colors(2*i) '-'])
    legendInfo(4*i-3) = {['Cell ' num2str(cellnum) char(64+i) ', raw Geminin']};
    legendInfo(4*i-2) = {['Cell ' num2str(cellnum) char(64+i) ', raw mCherry']};
    legendInfo(4*i-1) = {['Cell ' num2str(cellnum) char(64+i) ', smooth Geminin']};
    legendInfo(4*i-0) = {['Cell ' num2str(cellnum) char(64+i) ', smooth mCherry']};
end
legend(legendInfo(:),'Location','SE')
xlabel('Time (min)')
ylabel('Fluorescence (AU)')
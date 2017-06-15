

ancestorcellnum = 1;
numcells = 4;

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';
fname_grayimg = ['DFB_170308_HMEC_1Giii_1 images\Individual Cells\Cell'...
num2str(ancestorcellnum) 'granddaughters_labelUntrackedGray'];
fpath_grayimg = [foldername '/' fname_grayimg '.tif'];
fname_manualtracks = ['Cell' num2str(ancestorcellnum) 'granddaughters_Segmented_ManuallyTracked'];
fpath_manualtracks = [foldername '/' fname_manualtracks '.xlsx'];

%Calls importManualTracks to get the list of frames and corresponding object labels

%Should store these values to a JSON?

%Using upper quartile of image as background to subtract since medians were
%often 0

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';

%For future reference: can read spreadsheets as table
fname_background = ['Cell' num2str(ancestorcellnum) 'granddaughters_Image'];
fpath_background = [foldername '/' fname_background '.csv'];
table_background = readtable(fpath_background);
imgMedians_Geminin = table2array(table_background(:,{'Intensity_MedianIntensity_Geminin'}));
imgMedians_mCherry = table2array(table_background(:,{'Intensity_MedianIntensity_mCherry'}));
imgUQs_Geminin = table2array(table_background(:,{'Intensity_UpperQuartileIntensity_Geminin'}));
imgUQs_mCherry = table2array(table_background(:,{'Intensity_UpperQuartileIntensity_mCherry'}));


%Or can read spreadsheets as data
fname_segmented = ['Cell' num2str(ancestorcellnum) 'granddaughters_Segmented'];
fpath_segmented = [foldername '/' fname_segmented '.csv'];
table_segmented = importdata(fpath_segmented,',',1);
headers_segmented = table_segmented.colheaders;
data_segmented = table_segmented.data;
index_Frames = find(strcmp(headers_segmented,'ImageNumber'));
index_ObjNums = find(strcmp(headers_segmented,'ObjectNumber'));
index_Labels = find(strcmp(headers_segmented,'TrackObjects_Label_50'));
index_Areas = find(strcmp(headers_segmented,'AreaShape_Area'));
index_Geminin = find(strcmp(headers_segmented,'Intensity_IntegratedIntensity_Geminin'));
index_mCherry = find(strcmp(headers_segmented,'Intensity_IntegratedIntensity_mCherry'));

frames = data_segmented(:,index_Frames);
objnums = data_segmented(:,index_ObjNums);
labels = data_segmented(:,index_Labels);
areas = data_segmented(:,index_Areas);
geminin = data_segmented(:,index_Geminin);
mCherry = data_segmented(:,index_mCherry);

allframenums = cell(numcells,1);
alltracks = cell(numcells,1);
firstframes = zeros(numcells,1);
lastframes = zeros(numcells,1);
goodframes = cell(numcells,1);
rawtraces_Geminin = cell(numcells,1);
rawtraces_mCherry = cell(numcells,1);
smoothtraces_Geminin = cell(numcells,1);
smoothtraces_mCherry = cell(numcells,1);

ancestorcellnum_array = zeros(1,numcells);
descendantcellnum_array = zeros(1,numcells);
frame_G1S = zeros(1,numcells);
sizes_birth = zeros(1,numcells);
sizes_G1S = zeros(1,numcells);
sizes_M = zeros(1,numcells);

%For each cell label
for n = 1:numcells
    
    ancestorcellnum_array(n) = ancestorcellnum;
    descendantcellnum_array(n) = n;
    
%     thisframes = 1:max(frames);
%     movie.show;
%     thisframes = 1:input(strcat('Last good frame for cell ',num2str(i),': '));
%     goodframes{i} = thisframes;

%     [trackedframes,track] = enterManualTracks(fpath_grayimg);
    [trackedframes,track] = importManualTracks(fpath_grayimg , fpath_manualtracks , n);
    allframenums{n} = trackedframes;
    alltracks{n} = track;
    goodframes{n} = unique(trackedframes);
    firstframes(n) = min(trackedframes);
    lastframes(n) = max(trackedframes);

    rawtraces_Geminin{n} = zeros(length(goodframes),1);
    rawtraces_mCherry{n} = zeros(length(goodframes),1);
        
    %For each timepoint, combine all measurements with the appropriate
    %object number at this timepoint, then subtract (sum of areas)*imgmedian
    for i = firstframes(n):lastframes(n)
        thisframe_trackedobjects = track(trackedframes == i);     
        
        %At each timepoint i, the measurements we want are those where
        %objnums matches the objects tracked in this frame
        %(thisframe_trackedobjects) and of course where frames == i
        rawtraces_Geminin{n}(i+1-firstframes(n)) = sum(geminin(ismember(objnums,thisframe_trackedobjects)...
            & frames == i)) - sum(areas(ismember(objnums,thisframe_trackedobjects)...
            & frames == i))*imgUQs_Geminin(i);
        rawtraces_mCherry{n}(i+1-firstframes(n)) = sum(mCherry(ismember(objnums,thisframe_trackedobjects)...
            & frames == i)) - sum(areas(ismember(objnums,thisframe_trackedobjects)...
            & frames == i))*imgUQs_mCherry(i);
    end
    
    smoothtraces_Geminin{n} = movavg(rawtraces_Geminin{n},5);
    smoothtraces_mCherry{n} = movavg(rawtraces_mCherry{n},5);    
    frame_G1S(n) = findG1S(smoothtraces_Geminin{n},10,15,'plot');
    sizes_birth(n) = smoothtraces_mCherry{n}(3);
    sizes_G1S(n) = smoothtraces_mCherry{n}(fix(frame_G1S(n)));
    sizes_M(n) = smoothtraces_mCherry{n}(end-2);
end

figure()
framerate = input('Framerate (min/frame): ');
geminin_scaler = 0.05;
legendInfo = cell(4*numcells,1);
colors = ['grcmbykk'];
hold on
for n = 1:numcells
    plot((goodframes{n}-firstframes(n))*framerate,rawtraces_Geminin{n}(find(goodframes{n}))*geminin_scaler ,...
        [colors(2*n-1) ':'])
    plot((goodframes{n}-firstframes(n))*framerate,rawtraces_mCherry{n}(find(goodframes{n})) ,...
        [colors(2*n) ':'])
    plot((goodframes{n}-firstframes(n))*framerate,smoothtraces_Geminin{n}(find(goodframes{n}))*geminin_scaler ,...
        [colors(2*n-1) '-'])
    plot((goodframes{n}-firstframes(n))*framerate,smoothtraces_mCherry{n}(find(goodframes{n})) ,...
        [colors(2*n) '-'])
    legendInfo(4*n-3) = {['Cell ' num2str(ancestorcellnum) '-' num2str(n) ', raw Geminin']};
    legendInfo(4*n-2) = {['Cell ' num2str(ancestorcellnum) '-' num2str(n) ', raw mCherry']};
    legendInfo(4*n-1) = {['Cell ' num2str(ancestorcellnum) '-' num2str(n) ', smooth Geminin']};
    legendInfo(4*n-0) = {['Cell ' num2str(ancestorcellnum) '-' num2str(n) ', smooth mCherry']};
end
legend(legendInfo(:),'Location','SE')
xlabel('Time (min)')
ylabel('Fluorescence (AU)')


fname_tosave = ['DFB_170308_HMEC_1Giii_1_analyzed'];
fpath_tosave = [foldername '/' fname_tosave '.mat'];

if exist(fpath_tosave,'file') == 2
   saveddata = load(fpath_tosave);  
end

%Need to go through each variable in saveddata and check if the current
%workspace is dealing with the same cells as it (i.e., matching
%ancestorcellnum_array and descendantcellnum_array). If matching, replace
%old data with new data. If not matching, append new data.

save(fpath_tosave , 'ancestorcellnum_array' , 'descendantcellnum_array' ,...
    'rawtraces_Geminin' , 'rawtraces_mCherry' , 'smoothtraces_Geminin' ,...
    'smoothtraces_mCherry' , 'frame_G1S' , 'sizes_birth', 'sizes_G1S');
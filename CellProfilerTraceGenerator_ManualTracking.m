

ancestorcellnum = 6;

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';
fname_grayimg = ['DFB_170308_HMEC_1Giii_1 images\Individual Cells\Cell'...
num2str(ancestorcellnum) 'granddaughters_labelUntrackedGray'];
fpath_grayimg = [foldername '/' fname_grayimg '.tif'];



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

numcells = 1;
allframenums = cell(numcells,1);
alltracks = cell(numcells,1);

goodframes = cell(numcells,1);
rawtraces_Geminin = cell(numcells,1);
rawtraces_mCherry = cell(numcells,1);
smoothtraces_Geminin = cell(numcells,1);
smoothtraces_mCherry = cell(numcells,1);

frame_G1S = zeros(1,numcells);

%For each cell label
for i = 1:numcells
%     thisframes = 1:max(frames);
%     movie.show;
%     thisframes = 1:input(strcat('Last good frame for cell ',num2str(i),': '));
%     goodframes{i} = thisframes;

    [trackedframes,track] = importManualTracks(fpath_grayimg);
    allframenums{i} = trackedframes;
    alltracks{i} = track;
    goodframes{i} = unique(trackedframes);
    maxframe = max(trackedframes);

    rawtraces_Geminin{i} = zeros(maxframe,1);
    rawtraces_mCherry{i} = zeros(maxframe,1);
        
    %For each timepoint, combine all measurements with the appropriate
    %object number at this timepoint, then subtract (sum of areas)*imgmedian
    for j = 1:maxframe
        thisframe_trackedobjects = track(trackedframes == j);     
        
        %At each timepoint j, the measurements we want are those where
        %objnums matches the objects tracked in this frame
        %(thisframe_trackedobjects) and of course where frames == j
        rawtraces_Geminin{i}(j) = sum(geminin(ismember(objnums,thisframe_trackedobjects)...
            & frames == j)) - sum(areas(ismember(objnums,thisframe_trackedobjects)...
            & frames == j))*imgUQs_Geminin(j);
        rawtraces_mCherry{i}(j) = sum(mCherry(ismember(objnums,thisframe_trackedobjects)...
            & frames == j)) - sum(areas(ismember(objnums,thisframe_trackedobjects)...
            & frames == j))*imgUQs_mCherry(j);
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
    legendInfo(4*i-3) = {['Cell ' num2str(ancestorcellnum) char(64+i) ', raw Geminin']};
    legendInfo(4*i-2) = {['Cell ' num2str(ancestorcellnum) char(64+i) ', raw mCherry']};
    legendInfo(4*i-1) = {['Cell ' num2str(ancestorcellnum) char(64+i) ', smooth Geminin']};
    legendInfo(4*i-0) = {['Cell ' num2str(ancestorcellnum) char(64+i) ', smooth mCherry']};
end
legend(legendInfo(:),'Location','SE')
xlabel('Time (min)')
ylabel('Fluorescence (AU)')
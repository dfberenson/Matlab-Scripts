

ancestorcellnum = 1;
numcells = 4;

foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';
fname_grayimg = ['DFB_170308_HMEC_1Giii_1 images/Individual Cells/Cell'...
num2str(ancestorcellnum) 'granddaughters_labelUntrackedGray'];
fpath_grayimg = [foldername '/' fname_grayimg '.tif'];
fname_manualtracks = ['DFB_170308_HMEC_1Giii_1 analysis/Cell' num2str(ancestorcellnum) 'granddaughters_Segmented_ManuallyTracked'];
fpath_manualtracks = [foldername '/' fname_manualtracks '.xlsx'];

%Calls importManualTracks to get the list of frames and corresponding object labels

%Should store these values to a JSON?

%Using upper quartile of image as background to subtract since medians were
%often 0

%foldername = 'C:/Users/Skotheim Lab/Desktop/Test images';

%For future reference: can read spreadsheets as table
fname_background = ['DFB_170308_HMEC_1Giii_1 analysis/Cell' num2str(ancestorcellnum) 'granddaughters_Image'];
fpath_background = [foldername '/' fname_background '.csv'];
table_background = readtable(fpath_background);
imgMedians_Geminin = table2array(table_background(:,{'Intensity_MedianIntensity_Geminin'}));
imgMedians_mCherry = table2array(table_background(:,{'Intensity_MedianIntensity_mCherry'}));
imgUQs_Geminin = table2array(table_background(:,{'Intensity_UpperQuartileIntensity_Geminin'}));
imgUQs_mCherry = table2array(table_background(:,{'Intensity_UpperQuartileIntensity_mCherry'}));


%Or can read spreadsheets as data
fname_segmented = ['DFB_170308_HMEC_1Giii_1 analysis/Cell' num2str(ancestorcellnum) 'granddaughters_Segmented'];
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

ancestorcellnum_array = zeros(numcells,1);
descendantcellnum_array = zeros(numcells,1);
frames_G1S = zeros(numcells,1);
aregood = false(numcells,1);
sizes_birthF20 = zeros(numcells,1);
sizes_G1S = zeros(numcells,1);
sizes_M = zeros(numcells,1);
sizes_birth_extrap = zeros(numcells,1);

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
    frames_G1S(n) = findG1S(smoothtraces_Geminin{n},10,35,'plot');
    aregood(n) = input('Enter 1 if trace looks good, else 0: ');
    sizes_birthF20(n) = smoothtraces_mCherry{n}(20);
    sizes_G1S(n) = smoothtraces_mCherry{n}(fix(frames_G1S(n)));
    sizes_M(n) = smoothtraces_mCherry{n}(end-10);
    
    frametostartextrap = 20;
    frametoendextrap = 80;
    if length(smoothtraces_mCherry{n}) > frametoendextrap
        extrapfit = fitlm(frametostartextrap:frametoendextrap,...
            smoothtraces_mCherry{n}(frametostartextrap:frametoendextrap));
        sizes_birth_extrap(n) = extrapfit.Coefficients.Estimate(1);
    else
        sizes_birth_extrap(n) = NaN;
    end
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

if exist(fpath_tosave,'file') == 2  %If file previously existed
   S = load(fpath_tosave);
   saveddata = S.SavedDataStruct;
   datatosave = saveddata;
   
    %Update previous measurements if they were already stored.
    %Only works when updating a whole lineage (i.e., 4 granddaughters)
    %simultaneously
    if any(saveddata.ancestorcellnum_array == ancestorcellnum)
       knowncells_indices = datatosave.ancestorcellnum_array == ancestorcellnum;
       datatosave.descendantcellnum_array(knowncells_indices) = descendantcellnum_array;
       datatosave.aregood(knowncells_indices) = aregood;
       datatosave.rawtraces_Geminin(knowncells_indices) = rawtraces_Geminin;
       datatosave.rawtraces_mCherry(knowncells_indices) = rawtraces_mCherry;
       datatosave.smoothtraces_Geminin(knowncells_indices) = smoothtraces_Geminin;
       datatosave.smoothtraces_mCherry(knowncells_indices) = smoothtraces_mCherry;
       datatosave.frames_G1S(knowncells_indices) = frames_G1S;
       datatosave.sizes_birthF20(knowncells_indices) = sizes_birthF20;
       datatosave.sizes_G1S(knowncells_indices) = sizes_G1S;
       datatosave.sizes_M(knowncells_indices) = sizes_M;
       datatosave.sizes_birth_extrap(knowncells_indices) = sizes_birth_extrap;
    
    else
        datatosave.ancestorcellnum_array = [datatosave.ancestorcellnum_array ; ancestorcellnum_array];
        datatosave.descendantcellnum_array = [datatosave.descendantcellnum_array ; descendantcellnum_array];
        datatosave.aregood = [datatosave.aregood ; aregood];
        datatosave.rawtraces_Geminin = [datatosave.rawtraces_Geminin ; rawtraces_Geminin];
        datatosave.rawtraces_mCherry = [datatosave.rawtraces_mCherry ; rawtraces_mCherry];
        datatosave.smoothtraces_Geminin = [datatosave.smoothtraces_Geminin ; smoothtraces_Geminin];
        datatosave.smoothtraces_mCherry = [datatosave.smoothtraces_mCherry ; smoothtraces_mCherry];
        datatosave.frames_G1S = [datatosave.frames_G1S ; frames_G1S];
        datatosave.sizes_birthF20 = [datatosave.sizes_birthF20 ; sizes_birthF20];
        datatosave.sizes_G1S = [datatosave.sizes_G1S ; sizes_G1S];
        datatosave.sizes_M = [datatosave.sizes_M ; sizes_M];
        datatosave.sizes_birth_extrap = [datatosave.sizes_birth_extrap ; sizes_birth_extrap];
    end    
else
    datatosave = struct('ancestorcellnum_array' , ancestorcellnum_array,...
    'descendantcellnum_array' , descendantcellnum_array,...
    'aregood' , aregood,...
    'rawtraces_Geminin' , {rawtraces_Geminin},...
    'rawtraces_mCherry' , {rawtraces_mCherry},...
    'smoothtraces_Geminin' , {smoothtraces_Geminin},...
    'smoothtraces_mCherry' , {smoothtraces_mCherry},...
    'frames_G1S' , frames_G1S,...
    'sizes_birthF20' , sizes_birthF20,...
    'sizes_G1S' , sizes_G1S,...
    'sizes_M' , sizes_M,...
    'sizes_birth_extrap' , sizes_birth_extrap);
end

SavedDataStruct = datatosave;
save(fpath_tosave , 'SavedDataStruct');

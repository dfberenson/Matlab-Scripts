
% This is the function version of TrackCells.m

function track_cells(folder, expt_name, startframe, endframe, reclass_status)

tic

%% Initialize variables and load images

expt_folder = [folder '\' expt_name];
results_folder = [expt_folder '\' expt_name '_TrackingResults'];
cmap = csvread('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv');

max_cluster_size = 20;
max_local_dist = 200;
max_dilation_dist = 150;

if ~exist(results_folder,'dir')
    mkdir(results_folder);
end
if ~exist([results_folder '\Tracked_Gray'],'dir')
    mkdir([results_folder '\Tracked_Gray']);
end
if ~exist([results_folder '\Tracked_RGB'],'dir')
    mkdir([results_folder '\Tracked_RGB']);
end
if ~exist([results_folder '\Untracked_Gray'],'dir')
    mkdir([results_folder '\Untracked_Gray']);
end
if ~exist([results_folder '\Untracked_RGB'],'dir')
    mkdir([results_folder '\Untracked_RGB']);
end
if ~exist([results_folder '\Tracked_RGB_chosencell'],'dir')
    mkdir([results_folder '\Tracked_RGB_chosencell']);
end

rawimstack = readSequence([expt_folder '\' expt_name '_Raw\'...
    expt_name '_Raw'],startframe,endframe,'gray');

if reclass_status == 'r'
    objimstack = readSequence([expt_folder '\' expt_name '_Object Reclassification\'...
        expt_name '_Object Reclassification'],startframe,endframe,'gray');
else
    objimstack = readSequence([expt_folder '\' expt_name '_Object Classification\'...
        expt_name '_Object Classification'],startframe,endframe,'gray');
end

%% Get ready to track

assert(isequal(size(objimstack),size(rawimstack)), 'Raw and segmented stacks must be the same size.');

[Y,X,T] = size(objimstack);
assert(startframe <= T && endframe <= T, 'Start and end frames must be within length of movie.');
t = startframe;

orig_labels = getLabelsFromObjects(rawimstack(:,:,startframe),objimstack(:,:,startframe));
upstream_untracked_labels = orig_labels;
upstream_tracked_labels = orig_labels;
orig_props = regionprops(orig_labels);
upstream_props = orig_props;

untrackedim_gray = uint16(orig_labels);
untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' sprintf('%03d',t) '.tif']);
imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' sprintf('%03d',t) '.tif']);

trackedim_gray = uint16(orig_labels);
trackedim_rgb = ind2rgb(trackedim_gray,cmap);
imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' sprintf('%03d',t) '.tif']);
imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' sprintf('%03d',t) '.tif']);

%% Track using localOptimumTrack in ascending frame order

for t = startframe+1:1:endframe
    disp(['Tracking time ' num2str(t)])
    thistime_untracked_labels = getLabelsFromObjects(rawimstack(:,:,t),objimstack(:,:,t));
    thistime_tracked_labels = localOptimumTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels,max_cluster_size,max_local_dist,max_dilation_dist);
    
    %     If want to also keep track of randomly colorized image:
    %     untrackedstack(:,:,t) = uint16(thistime_labels);
    %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
    %     imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
    %     If we want to store the stack in memory:
    %     trackedstack(:,:,t) = uint16(thistime_labels);
    
    untrackedim_gray = uint16(thistime_untracked_labels);
    untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
    imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' sprintf('%03d',t) '.tif']);
    imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' sprintf('%03d',t) '.tif']);
    
    trackedim_gray = uint16(thistime_tracked_labels);
    trackedim_rgb = ind2rgb(trackedim_gray,cmap);
    imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' sprintf('%03d',t) '.tif']);
    imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' sprintf('%03d',t) '.tif']);
    
    upstream_untracked_labels = thistime_untracked_labels;
    upstream_tracked_labels = thistime_tracked_labels;
end

toc

end
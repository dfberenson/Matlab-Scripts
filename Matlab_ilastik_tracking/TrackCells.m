%% Initialize parameters

tic

folder = 'E:\Image Analysis\Cell Counting';
expt = 'DFB_170907_HMEC_1GFiii_palbo_after_1';

max_pos = 18;
max_num = 0;
max_cluster_size = 6;
max_local_dist = 100;
pos = 1;

%% Load segmented images from ilastik into imstack

input_already_loaded = input('Input already loaded to imstack (y/n): ','s');
if input_already_loaded == 'n'
    imstack = [];
    
    for n = 0:max_num
        if n==0
            filename = ['C3-' expt '_MMStack_Pos' num2str(pos) '.ome_Object Predictions'];
        else
            filename = ['C3-' expt '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome_Object Predictions'];
        end
        fpath = [folder '\' filename '.tiff'];
        
        thisstack = readStack(fpath);
        imstack = cat(3,imstack,thisstack);
    end
    toc
end
% h = implay(imstack)
% h.Visual.ColorMap.UserRange = 1;
% h.Visual.ColorMap.UserRangeMin = min(imstack(:));
% h.Visual.ColorMap.UserRangeMax = max(imstack(:));

%% Get ready to track

strategy = input('Enter "s/o" for simple/optimum track: ', 's');
ascdesc = input('Enter "a/d" for ascending/descending track: ', 's');
startframe = input('Enter starting frame: ');
endframe = input('Enter ending frame: ');
[Y,X,T] = size(imstack);
assert(startframe <= T && endframe <= T, 'Start and end frames must be within length of movie.');

orig_labels = getLabelsFromObjects(imstack(:,:,startframe));
upstream_untracked_labels = orig_labels;
upstream_tracked_labels = orig_labels;
orig_props = regionprops(orig_labels);
upstream_props = orig_props;

cmap = rand(500,3);
cmap(1,:) = [0 0 0];
t = startframe;

untrackedim_gray = uint16(orig_labels);
untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
imwrite(untrackedim_gray, [folder '\Untracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);

trackedim_gray = uint16(orig_labels);
trackedim_rgb = ind2rgb(trackedim_gray,cmap);
imwrite(trackedim_gray, [folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
imwrite(trackedim_rgb, [folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);

%% Track

if (strategy == 's' && ascdesc == 'a')
    for t = startframe+1:1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = simpleTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [folder '\Untracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
    
elseif (strategy == 's' && ascdesc == 'd')
    for t = startframe-1:-1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = simpleTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
    
elseif (strategy == 'o' && ascdesc == 'a')
    for t = startframe+1:1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = localOptimumTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels,max_cluster_size,max_local_dist);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [folder '\Untracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);

        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
    
elseif (strategy == 'o' && ascdesc == 'd')
    for t = startframe-1:-1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = localOptimumTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels,max_cluster_size,max_local_dist);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [folder '\Untracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
end

%% Display results

% figure,imshow(untrackedstack(:,:,5),cmap)
% figure,imshow(untrackedstack(:,:,6),cmap)
%
% figure,imshow(trackedstack(:,:,5),cmap)
% figure,imshow(trackedstack(:,:,6),cmap)

% Must clear stacks because can only hold one in memory at a time

% clear trackedstack_rgb;
% clear trackedstack_gray;
% trackedstack_gray = readSequence([folder '\Tracked_Gray\Pos' num2str(pos)],startframe,endframe,'gray');
% gray = implay(trackedstack_gray)

toc

clear trackedstack_rgb;
clear trackedstack_gray;
trackedstack_rgb = readSequence([folder '\Tracked_RGB\Pos' num2str(pos)],startframe,endframe,'rgb');
rgb = implay(trackedstack_rgb)
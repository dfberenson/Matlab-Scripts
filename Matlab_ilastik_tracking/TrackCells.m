%% Initialize parameters

tic

folder = 'E:\Matlab ilastik';
expt_name = 'DivisionStack1';
expt_folder = [folder '\' expt_name];
results_folder = [expt_folder '\' expt_name '_TrackingResults'];
startframe = input('Enter starting frame: ');
endframe = input('Enter ending frame: ');

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

if(input('Input already loaded to imstack? (y/n) ','s') == 'n')
    if(input('Use reclassifications? (y/n) ','s') == 'y')
        imstack = readSequence([expt_folder '\' expt_name '_Object Reclassification\'...
            expt_name '_Object Reclassification'],startframe,endframe,'gray');
    else
        imstack = readSequence([expt_folder '\' expt_name '_Object Classification\'...
            expt_name '_Object Classification'],startframe,endframe,'gray');
    end
end

max_pos = 18;
max_num = 0;
max_cluster_size = 6;
max_local_dist = 100;
max_dilation_dist = 10;
pos = 1;

% Load colormap
if exist('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv','file') == 2
    cmap = csvread('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv');
else
    cmap = 0.2 + 0.8*rand(500,3);
    cmap(1,:) = [0 0 0];
end

%% Need to do this only if don't yet have a list of unique patterns
% tic 
% generateUniquePatterns(7);
% toc
%% Load segmented images from ilastik into imstack

input_already_loaded = input('Input already loaded to imstack? (y/n): ','s');
if input_already_loaded == 'n'
    imstack = [];
    
    for n = 0:max_num
        if n==0
            filename = ['C3-' expt_name '_MMStack_Pos' num2str(pos) '.ome_Object Predictions'];
        else
            filename = ['C3-' expt_name '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome_Object Predictions'];
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
[Y,X,T] = size(imstack);
assert(startframe <= T && endframe <= T, 'Start and end frames must be within length of movie.');
t = startframe;

orig_labels = getLabelsFromObjects(imstack(:,:,startframe));
upstream_untracked_labels = orig_labels;
upstream_tracked_labels = orig_labels;
orig_props = regionprops(orig_labels);
upstream_props = orig_props;

untrackedim_gray = uint16(orig_labels);
untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' num2str(t) '.tif']);
imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);

trackedim_gray = uint16(orig_labels);
trackedim_rgb = ind2rgb(trackedim_gray,cmap);
imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' num2str(t) '.tif']);
imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' num2str(t) '.tif']);

%% Track

if (strategy == 's' && ascdesc == 'a')
    for t = startframe+1:1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = simpleTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' num2str(t) '.tif']);
        
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
        %     imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' num2str(t) '.tif']);
        
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
    
elseif (strategy == 'o' && ascdesc == 'a')
    for t = startframe+1:1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = localOptimumTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels,max_cluster_size,max_local_dist,max_dilation_dist);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' num2str(t) '.tif']);
        
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
    
elseif (strategy == 'o' && ascdesc == 'd')
    for t = startframe-1:-1:endframe
        disp(['Tracking time ' num2str(t)])
        thistime_untracked_labels = getLabelsFromObjects(imstack(:,:,t));
        thistime_tracked_labels = localOptimumTrack(thistime_untracked_labels,upstream_untracked_labels,upstream_tracked_labels,max_cluster_size,max_local_dist,max_dilation_dist);
        
        %     If want to also keep track of randomly colorized image:
        %     untrackedstack(:,:,t) = uint16(thistime_labels);
        %     untrackedim_rgb = ind2rgb(thistime_labels,cmap);
        %     imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        %     If we want to store the stack in memory:
        %     trackedstack(:,:,t) = uint16(thistime_labels);
        
        untrackedim_gray = uint16(thistime_untracked_labels);
        untrackedim_rgb = ind2rgb(untrackedim_gray,cmap);
        imwrite(untrackedim_gray, [results_folder '\Untracked_Gray\Untracked_Gray_' num2str(t) '.tif']);
        imwrite(untrackedim_rgb, [results_folder '\Untracked_RGB\Untracked_RGB_' num2str(t) '.tif']);
        
        trackedim_gray = uint16(thistime_tracked_labels);
        trackedim_rgb = ind2rgb(trackedim_gray,cmap);
        imwrite(trackedim_gray, [results_folder '\Tracked_Gray\Tracked_Gray_' num2str(t) '.tif']);
        imwrite(trackedim_rgb, [results_folder '\Tracked_RGB\Tracked_RGB_' num2str(t) '.tif']);
        
        upstream_untracked_labels = thistime_untracked_labels;
        upstream_tracked_labels = thistime_tracked_labels;
    end
end

%% Display results

toc

% Must clear stacks because can only hold one in memory at a time

% clear trackedstack_rgb;
% clear trackedstack_gray;
% trackedstack_gray = readSequence([results_folder '\Tracked_Gray\Pos' num2str(pos)],startframe,endframe,'gray');
% gray = implay(trackedstack_gray)

% clear trackedstack_rgb;
% clear trackedstack_gray;
% trackedstack_rgb = readSequence([results_folder '\Tracked_RGB\Pos' num2str(pos)],startframe,endframe,'rgb');
% rgb = implay(trackedstack_rgb)

%% Display results with one cell highlighted on the RGB image
%
% chosen_cell = input('Choose a cell to highlight: ');
% clear trackedstack_rgb;
% clear trackedstack_gray;
% trackedstack_rgb = readSequence([results_folder '\Tracked_RGB\Pos' num2str(pos)],startframe,endframe,'rgb');
%
% for t = startframe:1:endframe
%     gray_img = imread([results_folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
%
%     perim = bwperim(gray_img == chosen_cell);
%     highlighted_im = imoverlay(trackedstack_rgb(:,:,:,t),perim,'w');
%     trackedstack_rgb(:,:,:,t) = highlighted_im;
% end
% implay(trackedstack_rgb)
%
% %% Save results with one cell highlighted on the RGB image
%
% for t = startframe:1:endframe
%     gray_img = imread([results_folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
%     rgb_img = imread([results_folder '\Tracked_RGB\Pos' num2str(pos) '_' num2str(t) '.tif']);
%     perim = bwperim(gray_img == chosen_cell);
%     highlighted_im = imoverlay(trackedstack_rgb(:,:,:,t),perim,'w');
%     imwrite(highlighted_im, [results_folder '\Tracked_RGB_chosencell\Pos' num2str(pos) '_Cell' num2str(chosen_cell) '_' num2str(t) '.tif']);
% end
%
% %% Display results with once cell highlighted on the Raw image
%
% clear trackedstack_rgb;
% clear trackedstack_gray;
% clear trackedstack_raw;
% clear trackedstack_raw_4d;
% trackedstack_raw = uint8(readStack('E:\Matlab ilastik\TestStack1.tif')/16);
%
% for t = startframe:1:endframe
%     gray_img = imread([results_folder '\Tracked_Gray\Pos' num2str(pos) '_' num2str(t) '.tif']);
%     perim = bwperim(gray_img == chosen_cell);
%     trackedstack_raw_4d(:,:,:,t) = imoverlay(trackedstack_raw(:,:,t),perim,'c');
%
% %     highlighted_im = trackedstack_raw(:,:,t);
% %     highlighted_im(perim) = 255;
% %     trackedstack_raw(:,:,t) = highlighted_im;
% end
% implay(trackedstack_raw_4d)
%
% % trackedstack_raw_4d(:,:,1,:) = trackedstack_raw;
% % movie = immovie(im2uint8(trackedstack_raw_4d),gray(256))
% % implay(movie)
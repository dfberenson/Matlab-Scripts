%Use ManualTracking tool from ImageJ to find (x,y) coordinates for each cell at each position.
%Save these lists of x- and y-coordinates.
%Script takes argument of filepath to grayscale image, filepath to
%spreadsheet containing coordinates, and which cell on the spreadsheet.
%Script uses that info to find the cell track and the corresponding frame
%numbers.



function [framenums,track] = importManualTracks(fpath_grayimg , fpath_manualtracks , n)

    info = imfinfo(fpath_grayimg);
    num_images = numel(info);
    h = info.Height;
    w = info.Width;

    imstack = zeros(h,w,num_images);

    for i = 1:num_images
        A = imread(fpath_grayimg, i, 'Info', info);
        imstack(:,:,i) = A;
    end

    trackingdata = readtable(fpath_manualtracks,'Sheet',n);
    xcoords = table2array(trackingdata(:,{'X'}));
    ycoords = table2array(trackingdata(:,{'Y'}));
    origframenums = table2array(trackingdata(:,{'Slice'}));
    allsplitcells = table2array(trackingdata(:,{'SplitLabel1','SplitLabel2','SplitLabel3'}));
    
    slice_increment = origframenums(2) - origframenums(1);
    origframenums = origframenums / slice_increment;
    
    tracklength = length(origframenums);
    firstframe = min(origframenums);
    lastframe = max(origframenums);
    origtrack = zeros(tracklength,1);
  
    for i = firstframe:lastframe
        x = xcoords(origframenums == i);
        y = ycoords(origframenums == i);
        origtrack(origframenums == i) = imstack(y,x,i);
        %If there is an error here involving unequal numbers of elements,
        %Check manual track spreadsheet to confirm no twice-recorded slices
    end

    framenums = origframenums;
    track = origtrack;
    needToFix = true;
    currframe = firstframe - 1;
    
    while needToFix
        currframe = currframe + 1;
        thissplitcells = allsplitcells(origframenums == currframe,:);
        if any(~isnan(thissplitcells))
            newlabels = thissplitcells(~isnan(thissplitcells));
            if any(newlabels == 0)
                track = track(framenums > currframe);
                framenums = framenums(framenums > currframe);
                continue;
            end
            if any(newlabels == -1)
                framenums = framenums(framenums < currframe);
                track = track(framenums < currframe);
                break;
            end
            oldlabels = track(framenums == currframe);
            labels_toadd = setdiff(newlabels,oldlabels).';
            frames_toadd = ones(length(labels_toadd),1)*currframe;
            index_toadd = find(framenums == currframe);
            
            framenums = [framenums(1:index_toadd); frames_toadd; framenums(index_toadd+1:end)];   
            track = [track(1:index_toadd); labels_toadd; track(index_toadd+1:end)];
        end
        if currframe == lastframe
            needToFix = false;
        end
    end   
end
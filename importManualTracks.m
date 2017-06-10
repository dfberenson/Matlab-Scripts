%Use ManualTracking tool from ImageJ to find (x,y) coordinates for each cell at each position.
%Enter these as lists of x- and y-coordinates.
%Script takes argument of filepath to grayscale image then asks for the coordinates.
%Gets corresponding object number for each point, stores as track, returns track.

function [framenums,track] = importManualTracks(fpath_grayimg)

    info = imfinfo(fpath_grayimg);
    num_images = numel(info);
    h = info.Height;
    w = info.Width;

    imstack = zeros(h,w,num_images);

    for i = 1:num_images
        A = imread(fpath_grayimg, i, 'Info', info);
        imstack(:,:,i) = A;
    end

    xcoords = input('Enter list of x-coordinates: ');
    ycoords = input('Enter list of y-coordinates: ');
    tracklength = length(xcoords);
    framenums = zeros(tracklength,1);
    track = zeros(tracklength,1);

    for i = 1:tracklength
        framenums(i) = i;
        x = xcoords(i);
        y = ycoords(i);
        track(i) = imstack(y,x,i);
    end

    frame_tofix = input('Enter frame number where tracked cell is erroneously split: ');
    while frame_tofix ~= 0
        disp(['At frame ' num2str(frame_tofix) ' we currently have cell labels: '...
            num2str(track(framenums == frame_tofix).')]);
        label_toadd = input('Enter a missing label: ');
        disp(['']);
        element_toadd = max(find(framenums == frame_tofix));
        
        framenums = [framenums(1:element_toadd); frame_tofix; framenums(element_toadd+1:end)];       
        track = [track(1:element_toadd);  label_toadd; track(element_toadd+1:end)];
        
        frame_tofix = input('Enter frame number where tracked cell is erroneously split: ');
    end
    
end
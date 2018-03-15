

function labels = simpleTrack(image, previous_props)

[labels,num_cells] = bwlabel(im2bw(image,0));
thistime_props = regionprops(labels);
for c = 1:num_cells
    disp(['Tracking cell ' num2str(c)])
    % For each cell in the current frame, find the closest cell from
    % the previous frame, and then reassign values in this frame to the
    % corresponding values from last frame (+ 10000 to avoid
    % repetition)
    centroid = thistime_props(c).Centroid;
    previous_cell = findClosestCentroid(centroid,previous_props);
    labels(labels == c) = previous_cell + 10000;
end
labels(find(labels)) = labels(find(labels)) - 10000;
end
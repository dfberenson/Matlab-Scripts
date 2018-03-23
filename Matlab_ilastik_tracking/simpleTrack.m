

function tracked_labels = simpleTrack(untracked_labels, upstream_untracked_labels, upstream_tracked_labels)

tracked_labels = untracked_labels;
thistime_props = regionprops(tracked_labels);
upstream_props = regionprops(upstream_untracked_labels);

for c = 1:length(thistime_props)
    %     disp(['Tracking cell ' num2str(c)]);
    % For each cell in the current frame, find the closest cell from
    % the previous frame, and then reassign values in this frame to the
    % corresponding values from last frame (+ 10000 to avoid
    % repetition)
    centroid = thistime_props(c).Centroid;
    upstreamcell_untracked_label = findClosestCentroid(centroid,upstream_props);
    upstreamcell_centroid = upstream_props(upstreamcell_untracked_label).Centroid;
    upstreamcell_x = round(upstreamcell_centroid(1));
    upstreamcell_y = round(upstreamcell_centroid(2));
    upstreamcell_tracked_label = upstream_tracked_labels(upstreamcell_y,upstreamcell_x);
    
    %     disp('Closest upstream centroid is ');
    %     disp(upstreamcell_centroid);
    %     disp(['Closest upstream cell is ' num2str(upstreamcell_tracked_label)]);
    
    tracked_labels(tracked_labels == c) = upstreamcell_tracked_label + 10000;
end
tracked_labels(find(tracked_labels)) = tracked_labels(find(tracked_labels)) - 10000;
end
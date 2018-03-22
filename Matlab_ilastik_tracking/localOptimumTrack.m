
function tracked_labels = localOptimumTrack(untracked_labels, upstream_untracked_labels, upstream_tracked_labels, maxX, max_local_dist, max_dilation_dist)
% Inputs: object_image = untracked label image, with each connected
% component assigned an arbitrary pixel intensity value.
% upstream_untracked_labels = randomly ordered connected components from
% upstream image. This is used as the source of upstream cells, because
% otherwise two separate cells with the same tracked label will have a
% merged regionprop (centroid between them, summed area).
% upstream_tracked_labels = correctly labeled cells from upstream image.
% maxX = number of cells to consider in local region. Start with 6.
% max_local_dist = maximum distance within which to consider local cluster.
% If a cell is outside this cluster, increment maxX down by one and try
% again.

debug = false;

tracked_labels = untracked_labels;
thistime_props = regionprops(tracked_labels);
upstream_props = regionprops(upstream_untracked_labels);

for c = 1:length(thistime_props)
    %     disp(['Tracking cell ' num2str(c)])
    
    %     X can't be greater than the total number of cells in this frame or the upstream frame
    centroid = thistime_props(c).Centroid;
    upstream_X = numCloseCentroids(centroid, upstream_props, maxX, max_local_dist, max_dilation_dist);
    current_X = numCloseCentroids(centroid, thistime_props, upstream_X, max_local_dist, max_dilation_dist);
    X = min(upstream_X, current_X);
    closest_current_centroids = findXClosestCentroids(centroid, thistime_props, X);
    closest_upstream_centroids = findXClosestCentroids(centroid, upstream_props, X);
    
    %     Create a matrix that stores each pairwise squared distance between
    %     cells in the local area
    dist2_matrix = zeros(X,X);
    for i = 1:X
        for j = 1:X
            current_centroid = thistime_props(closest_current_centroids(i)).Centroid;
            upstream_centroid = upstream_props(closest_upstream_centroids(j)).Centroid;
            dist2_matrix(i,j) = squaredDistance(current_centroid, upstream_centroid);
        end
    end
    
    %     Look at previously created list of unique patterns.
    %     Go through each and find which one has the lowest summed squared distances.
    all_unique_patterns = csvread(['C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\UniquePatterns_'...
        num2str(X) '.csv']);
    num_unique_patterns = length(all_unique_patterns);
    assert(num_unique_patterns == factorial(X));
    sums = NaN(1,num_unique_patterns);
    for n = 1:num_unique_patterns
        thistry_sum = 0;
        thispattern = all_unique_patterns(n,:);
        for m = 1:X
            thistry_sum = thistry_sum + dist2_matrix(m, thispattern(m));
        end
        sums(n) = thistry_sum;
    end
    [~,indices] = sort(sums);
    best_n = indices(1);
    best_pattern = all_unique_patterns(best_n,:);
    
    %     Get the matrix index for the current cell.
    %     Use the best_pattern to find the corresponding cell.
    thiscell_matrix_index = closest_current_centroids == c;
    upstreamcell_matrix_index = best_pattern(thiscell_matrix_index);
    upstreamcell_untracked_label = closest_upstream_centroids(upstreamcell_matrix_index);
    
    % Use the first pixel index of a cell within the upstream cell to find its tracked label
    upstreamcell_indices = find(upstream_untracked_labels == upstreamcell_untracked_label);
    upstreamcell_tracked_label = upstream_tracked_labels(upstreamcell_indices(1));
    
    tracked_labels(tracked_labels == c) = upstreamcell_tracked_label + 10000;
    
    if debug == true
        disp(['Cell ' num2str(c) ' has ' num2str(X) ' cells in its cluster.'])
        disp(['Cell ' num2str(c) ' has the following cells in its current cluster: '])
        disp(closest_current_centroids)
        disp(['Cell ' num2str(c) ' has the following cells in its upstream cluster: '])
        disp(closest_upstream_centroids)
        disp(['Cell ' num2str(c) ' has the following best pattern: '])
        disp(best_pattern')
        disp(['Cell ' num2str(c) ' is from untracked cell ' num2str(upstreamcell_untracked_label) '.'])
        disp(['Cell ' num2str(c) ' is from tracked cell ' num2str(upstreamcell_tracked_label) '.'])
    end
end

tracked_labels(tracked_labels > 0) = tracked_labels(tracked_labels > 0) - 10000;

end
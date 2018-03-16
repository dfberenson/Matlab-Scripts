

function tracked_labels = localOptimumTrack(untracked_labels, upstream_untracked_labels, upstream_tracked_labels, maxX, max_local_dist)
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

tracked_labels = untracked_labels;
thistime_props = regionprops(tracked_labels);
upstream_props = regionprops(upstream_tracked_labels);

for c = 1:length(thistime_props)
    %     disp(['Tracking cell ' num2str(c)])
    
    %     X can't be greater than the total number of cells in this frame or the upstream frame
    X = min([maxX, length(thistime_props), length(upstream_props)]);
    centroid = thistime_props(c).Centroid;
    X = min(X, numCloseCentroids(centroid, thistime_props, max_local_dist));
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
    
    %     Brute force method to search through all unique pairwise assignments
    %     of cells to parents in matrix follows.
    %     Create all possible vectors of length X where each element is in the range [1 X] inclusive.
    %     Ignore any that would have a non-unique assignment.
    %     Calculate the sum of the squared distances and store it, adjusting for Matlab 1-indexing.
    %     Find the lowest sum.
    
    %     Example for debugging purposes:
    %     c = 100;
    %     closest_current_centroids = [100 200 300];
    %     closest_upstream_centroids = [150 250 350];
    %     matrix = [[100 50 40];[10 30 90];[20 10 30]];
    %     dist2_matrix = matrix;
    
    sums = NaN(1,X^X);
    for k = 0:X^X-1
        pattern = getMatrixReadablePattern(convertToBaseX(k,X), X);
        thistry_sum = 0;
        
        if length(pattern) == length(unique(pattern))
            for m = 1:X
                thistry_sum = thistry_sum + dist2_matrix(m, pattern(m));
            end
            sums(k+1) = thistry_sum;
        end
    end
    [~,indices] = sort(sums);
    best_k = indices(1) - 1;
    best_pattern = getMatrixReadablePattern(convertToBaseX(best_k,X),X);
    
    %     Get the matrix index for the current cell.
    %     Use the best_pattern to find the corresponding cell.
    thiscell_matrix_index = find(closest_current_centroids == c);
    upstreamcell_matrix_index = best_pattern(thiscell_matrix_index);
    upstreamcell_untracked_label = closest_upstream_centroids(upstreamcell_matrix_index);
    upstreamcell_centroid = upstream_props(upstreamcell_untracked_label).Centroid;
    upstreamcell_x = round(upstreamcell_centroid(1));
    upstreamcell_y = round(upstreamcell_centroid(2));
    upstreamcell_tracked_label = upstream_tracked_labels(upstreamcell_y,upstreamcell_x);
    
    tracked_labels(tracked_labels == c) = upstreamcell_tracked_label + 10000;
    disp(['Cell ' num2str(upstreamcell_tracked_label) ' has ' num2str(X) ' cells in its cluster.'])
end

tracked_labels(find(tracked_labels)) = tracked_labels(find(tracked_labels)) - 10000;

end
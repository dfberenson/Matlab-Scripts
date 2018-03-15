% Need to work with fake labels not real labels

function labels = localOptimumTrack(image, previous_props, maxX, max_local_dist)
% Inputs: image = current image, previous_props properties data structure for previous image,
% maxX = number of cells to consider in local region. Start with 6.
% max_local_dist = maximum distance within which to consider local cluster.
% If a cell is outside this cluster, increment maxX down by one and try
% again.


[labels,num_cells] = bwlabel(im2bw(image,0));
thistime_props = regionprops(labels);

for c = 1:num_cells
%     disp(['Tracking cell ' num2str(c)])
    X = maxX;
    centroid = thistime_props(c).Centroid;
    closest_current_centroids = findXClosestCentroids(centroid, thistime_props, X);
    local_area_too_big = true;
    while local_area_too_big
        local_area_too_big = false;
        for candidate_toofar_centroid = closest_current_centroids
            if squaredDistance(centroid,thistime_props(candidate_toofar_centroid).Centroid) > max_local_dist^2
                X = X - 1;
                closest_current_centroids = findXClosestCentroids(centroid, thistime_props, X);
                local_area_too_big = true;
                break
            end
        end
    end

    closest_previous_centroids = findXClosestCentroids(centroid, previous_props, X);

%     Create a matrix that stores each pairwise squared distance between
%     cells in the local area
    dist2_matrix = zeros(X,X);
    for i = 1:X
        for j = 1:X
            current_centroid = thistime_props(closest_current_centroids(i)).Centroid;
            previous_centroid = previous_props(closest_previous_centroids(j)).Centroid;
            dist2_matrix(i,j) = squaredDistance(current_centroid, previous_centroid);
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
%     closest_previous_centroids = [150 250 350];
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
    correspondingcell_matrix_index = best_pattern(thiscell_matrix_index);
    correspondingcell = closest_previous_centroids(correspondingcell_matrix_index);
    
    labels(labels == c) = correspondingcell + 10000;
        disp(['Cell ' num2str(correspondingcell) ' has ' num2str(X) ' cells in its cluster.'])
end

labels(find(labels)) = labels(find(labels)) - 10000;

end
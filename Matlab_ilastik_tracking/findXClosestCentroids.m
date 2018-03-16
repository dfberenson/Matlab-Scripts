

function X_closest_centroids_indices = findXClosestCentroids(centroid, props, X)

for p = 1:length(props)
    other_centroid = props(p).Centroid;
    dist2(p) = squaredDistance(centroid, other_centroid);
end

[~,indices] = sort(dist2);
X_closest_centroids_indices = indices(1:X);
end
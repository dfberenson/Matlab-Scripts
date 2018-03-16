

function num = numCloseCentroids(centroid,props,max_local_dist)

for p = 1:length(props)
    other_centroid = props(p).Centroid;
    dist2(p) = squaredDistance(centroid, other_centroid);
end

s = sort(dist2);
num = length(s(s < max_local_dist^2));
end
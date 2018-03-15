
function idx = findClosestCentroid(centroid, props)

mindist2 = 1000000;
for p = 1:length(props)
    previous_centroid = props(p).Centroid;
    dist2 = squaredDistance(centroid, previous_centroid);
    if dist2 < mindist2
        mindist2 = dist2;
        idx = p;
    end
end
end


function final_X = numCloseCentroids(centroid, props, suggested_X, max_local_dist, max_dilation_dist)
% Create an ordered list of all nearby centroids.
% Find out how many are within max_local dist.
% Don't go beyond either that number or the suggested cluster size X.
% See if there are any other centroids lurking just beyond the border and include them too.

for p = 1:length(props)
    other_centroid = props(p).Centroid;
    dist2(p) = squaredDistance(centroid, other_centroid);
end

% s = sort(dist2);
% num = length(s(s < max_local_dist^2));
% num = max(num,1); % In case a cell appears far away from any possible upstream source
% final_X = min(num, suggested_X);
% % Need to account for the case where there is one more cell just beyond the last one that X would allow
% while (num < length(props)) && (s(num+1) - s(num) < max_dilation_dist^2)
%     num = num+1;
% end
% final_X = max(num, final_X);

s = sort(dist2);
num = length(s(s < max_local_dist^2));
num = max(num,1); % In case a cell appears far away from any possible upstream source
% Need to account for the case where there is one more cell just beyond the last one that X would allow
while (num < length(props)) && (s(num+1) - s(num) < max_dilation_dist^2)
    num = num+1;
end
final_X = num;

end
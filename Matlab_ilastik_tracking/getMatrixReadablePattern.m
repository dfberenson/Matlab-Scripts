
function pattern = getMatrixReadablePattern(arr, X)
% Takes array input like [2 4 5] and a square array size X (e.g., 5).
% Adds leading zeros up to size X: [0 0 2 4 5]
% Adds 1 to account for Matlab 1-indexing

pattern = zeros(X,1);
pattern(end - length(arr) + 1 : end) = arr;
pattern = pattern + 1;
end
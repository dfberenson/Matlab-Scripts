
function generateUniquePatterns(max_cluster_size)

path = 'C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\UniquePatterns_';
for X = 1:max_cluster_size
    tic
    disp(X)
    n = 1;
    num_unique_combinations = factorial(X);
    unique_patterns = zeros(num_unique_combinations, X);
   for k = 0:X^X-1
        pattern = getMatrixReadablePattern(convertToBaseX(k,X), X);        
        if length(pattern) == length(unique(pattern))
            unique_patterns(n,:) = pattern;
            n = n+1;
        end
   end  
   csvwrite([path num2str(X) '.csv'], unique_patterns)
   toc
end

% m = csvread([path num2str(6) '.csv']);
% sum(m,2)
end
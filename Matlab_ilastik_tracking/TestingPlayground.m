
%% Generate and save a list of unique patterns

path = 'C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\UniquePatterns_';
max_cluster_size = 8;
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


%% Messing around with image cross-correlation

% % Can we do something with image cross-correlation to improve tracking
% % within a cluster?
% 
% % trackedstack_gray = readSequence([folder '\Tracked_Gray\Pos' num2str(pos)],startframe,endframe,'gray');


% A = randi(9,2,3,2)
% 
% X = [true,false,false;false,true,true]
% 
% A(X(:,:,[1,1])) = 0


%% Messing around with splitting fused cells
% stack = readStack('E:\Test\TouchingCells3.tif');
% img = stack(:,:,1);
% touchingCells = img;
% touchingCells = uint8(img == 2);
% 
% 
% comp = ~touchingCells;
% basins = bwdist(comp);
% suppressed = -imhmin(basins,6.2);
% L = watershed(suppressed);
% 
% % Minimum watershed depth of 6.2 empirically works well for this image.
% % Perhaps can try starting with a high depth and incrementing to lower
% % depths while counting depths until reach a height so number of distinct
% % basins is equal to the cell label.
% 
% figure,imshow(comp,[])
% figure,imshow(basins,[])
% figure,imshow(suppressed,[])
% figure,imshow(L,[])
% 
% nontouchingCells = touchingCells;
% nontouchingCells(L == 0) = 0;
% 
% figure,imshow(touchingCells,[])
% figure,imshow(nontouchingCells,[])
% 
% A = bwdist(touchingCells);
% B = bwdist(~touchingCells);
% C = -bwdist(~touchingCells);
% L = watershed(C);
% 
% figure,imshow(A,[])
% figure,imshow(B,[])
% figure,imshow(C,[])
% figure,imshow(L,[])
% 
% nontouchingCells = touchingCells;
% nontouchingCells(L == 0) = 0;
% 
% figure,imshow(touchingCells,[])
% figure,imshow(nontouchingCells,[])
% 
% 

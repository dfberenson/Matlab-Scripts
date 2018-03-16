

% After (?) do regionprops, need to relabel connected cells
% Perhaps this method will be called by getLabelsFromObjects()

stack = readStack('E:\Test\TouchingCells3.tif');
img = stack(:,:,1);
touchingCells = img;
touchingCells = uint8(img == 2);

% 
% figure,imshow(img,[])
% figure,imshow(touchingCells,[])

comp = ~touchingCells;
basins = bwdist(comp);
suppressed = -imhmin(basins,6.2);
L = watershed(suppressed);

% Minimum watershed depth of 6.2 empirically works well for this image.
% Perhaps can try starting with a high depth and incrementing to lower
% depths while counting depths until reach a height so number of distinct
% basins is equal to the cell label.

figure,imshow(comp,[])
figure,imshow(basins,[])
figure,imshow(suppressed,[])
figure,imshow(L,[])

nontouchingCells = touchingCells;
nontouchingCells(L == 0) = 0;

figure,imshow(touchingCells,[])
figure,imshow(nontouchingCells,[])

A = bwdist(touchingCells);
B = bwdist(~touchingCells);
C = -bwdist(~touchingCells);
L = watershed(C);

figure,imshow(A,[])
figure,imshow(B,[])
figure,imshow(C,[])
figure,imshow(L,[])

nontouchingCells = touchingCells;
nontouchingCells(L == 0) = 0;

figure,imshow(touchingCells,[])
figure,imshow(nontouchingCells,[])

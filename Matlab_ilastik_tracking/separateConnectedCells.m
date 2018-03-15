

% After (?) do regionprops, need to relabel connected cells


stack = readStack('E:\Test\Test.tif');
img = stack(:,:,1);
[labels,numcells] = bwlabel(im2bw(img,0));
props = regionprops(labels)
imtool(labels)

newlabels = labels;
newlabels(newlabels == 5) = 2;
newprops = regionprops(newlabels);
imtool(newlabels)
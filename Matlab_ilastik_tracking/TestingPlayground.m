
stack = readStack('E:\Test\Test2.tif');
img = stack(:,:,1);
[labels,numcells] = bwlabel(im2bw(img,0));
props = regionprops(labels)


newlabels = labels;
newlabels(newlabels == 5) = 2;
newprops = regionprops(newlabels);


% imtool(labels)
% imtool(newlabels)


% Can we do something with image cross-correlation to improve tracking
% within a cluster?

% trackedstack_gray = readSequence([folder '\Tracked_Gray\Pos' num2str(pos)],startframe,endframe,'gray');



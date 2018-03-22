
%% Overwrite Pixels in RGB image

perim = bwperim(gray_img == chosen_cell);

%Manual code:
rgb_img = rgb_stack(:,:,:,t);
new_img = rgb_img;
new_img(perim(:,:,[1 1 1])) = 255;
rgb_stack(:,:,:,t) = new_img;

%In Matlab R2017b or later can do this instead:
rgb_img = rgb_stack(:,:,:,t);
new_img = imoverlay(rgb_img, perim, 'w')
rgb_stack(:,:,:,t) = new_img;

%% localOptimumTrack

%     The following method recalculates all possible unique assignments each time.
%         Brute force method to search through all unique pairwise assignments
%         of cells to parents in matrix follows.
%         Create all possible vectors of length X where each element is in the range [1 X] inclusive.
%         Ignore any that would have a non-unique assignment.
%         Calculate the sum of the squared distances and store it, adjusting for Matlab 1-indexing.
%         Find the lowest sum.

% Example for debugging purposes:
% c = 100;
% closest_current_centroids = [100 200 300];
% closest_upstream_centroids = [150 250 350];
% matrix = [[100 50 40];[10 30 90];[20 10 30]];
% dist2_matrix = matrix;

sums = NaN(1,X^X);
for k = 0:X^X-1
    pattern = getMatrixReadablePattern(convertToBaseX(k,X), X);
    thistry_sum = 0;
    
    if length(pattern) == length(unique(pattern))
        for m = 1:X
            thistry_sum = thistry_sum + dist2_matrix(m, pattern(m));
        end
        sums(k+1) = thistry_sum;
    end
end
[~,indices] = sort(sums);
best_k = indices(1) - 1;
best_pattern = getMatrixReadablePattern(convertToBaseX(best_k,X),X);


%     Relying on centroids can have strange behavior when centroids
%     are outside the cells.
upstreamcell_centroid = upstream_props(upstreamcell_untracked_label).Centroid;
upstreamcell_x = round(upstreamcell_centroid(1));
upstreamcell_y = round(upstreamcell_centroid(2));
assert(upstream_untracked_labels(upstreamcell_y,upstreamcell_x) == upstreamcell_untracked_label,...
    ['Untracked upstream cell ' num2str(upstreamcell_untracked_label) ' has an external centroid.'])
upstreamcell_tracked_label = upstream_tracked_labels(upstreamcell_y,upstreamcell_x);


%% getLabelsFromObjects

% Before accounted for up to 5 touching cells in a for loop
 
twoTouchingCells = (object_image == 2);
[twoTouchingCells_labels,twoTouchingCells_num] = bwlabel(twoTouchingCells);
twoTouchingCells_props = regionprops(twoTouchingCells_labels);

for c = 1:twoTouchingCells_num
    boundingBox_vals = twoTouchingCells_props(c).BoundingBox;
    x_min = uint16(boundingBox_vals(1));
    x_max = uint16(x_min + boundingBox_vals(3));
    y_min = uint16(boundingBox_vals(2));
    y_max = uint16(y_min + boundingBox_vals(4));
    object_image(y_min:y_max, x_min:x_max) = separateConnectedCells(object_image(y_min:y_max, x_min:x_max),2);
end


threeTouchingCells = (object_image == 3);
[threeTouchingCells_labels,threeTouchingCells_num] = bwlabel(threeTouchingCells);
threeTouchingCells_props = regionprops(threeTouchingCells_labels);

for c = 1:threeTouchingCells_num
    boundingBox_vals = threeTouchingCells_props(c).BoundingBox;
    x_min = uint16(boundingBox_vals(1));
    x_max = uint16(x_min + boundingBox_vals(3));
    y_min = uint16(boundingBox_vals(2));
    y_max = uint16(y_min + boundingBox_vals(4));
    object_image(y_min:y_max, x_min:x_max) = separateConnectedCells(object_image(y_min:y_max, x_min:x_max),3);
end
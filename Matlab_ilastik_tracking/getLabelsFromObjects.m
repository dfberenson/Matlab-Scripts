
function labels = getLabelsFromObjects(object_image)
% object_image is the ilastik object classification output,
% a uint8 matrix with single cells labeled as 1, doublets as 2, triplets 3

max_touching_objects = 5;
[Y,X] = size(object_image);

for n = 2:max_touching_objects
   n_touching_cells = (object_image == n);
   [n_touching_cells_labels, n_touching_cells_num] = bwlabel(n_touching_cells,4);
   n_touching_cells_props = regionprops(n_touching_cells_labels, 'Image','BoundingBox');
    
   for c = 1:n_touching_cells_num
       boundingBox_vals = n_touching_cells_props(c).BoundingBox;
       x_min = max(uint16(boundingBox_vals(1)),1);
       x_max = min(uint16(x_min + boundingBox_vals(3)),X)-1;
       y_min = max(uint16(boundingBox_vals(2)),1);
       y_max = min(uint16(y_min + boundingBox_vals(4)),Y)-1;
       bounding_box = object_image(y_min:y_max, x_min:x_max);
       
       % The bounding box could contain the corners of nearby cells, so
       % instead need to operate on only the pixels that are part of
       % connected object c.
       touching_cells_c = n_touching_cells_props(c).Image;
       untouching_cells_c = separateConnectedCells(touching_cells_c, n);
       
       bounding_box(touching_cells_c) = untouching_cells_c(touching_cells_c);
       object_image(y_min:y_max, x_min:x_max) = bounding_box;
   end
end

[labels,num_cells] = bwlabel(im2bw(object_image,0),4);

end

function labels = getLabelsFromObjects(object_image)

max_touching_objects = 5;
[Y,X] = size(object_image);

for n = 2:max_touching_objects
   n_touching_cells = (object_image == n);
   [n_touching_cells_labels, n_touching_cells_num] = bwlabel(n_touching_cells,4);
   n_touching_cells_props = regionprops(n_touching_cells_labels);
    
   for c = 1:n_touching_cells_num
       boundingBox_vals = n_touching_cells_props(c).BoundingBox;
       x_min = max(uint16(boundingBox_vals(1)),1);
       x_max = min(uint16(x_min + boundingBox_vals(3)),X);
       y_min = max(uint16(boundingBox_vals(2)),1);
       y_max = min(uint16(y_min + boundingBox_vals(4)),Y);
       object_image(y_min:y_max, x_min:x_max) = separateConnectedCells(object_image(y_min:y_max, x_min:x_max),n);
   end
end

[labels,num_cells] = bwlabel(im2bw(object_image,0),4);

end
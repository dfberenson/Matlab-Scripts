
function labels = getLabelsFromObjects(object_image)

max_touching_objects = 5;

for n = 2:max_touching_objects
   n_touching_cells = (object_image == n);
   [n_touching_cells_labels, n_touching_cells_num] = bwlabel(n_touching_cells);
   n_touching_cells_props = regionprops(n_touching_cells_labels);
    
   for c = 1:n_touching_cells_num
       boundingBox_vals = n_touching_cells_props(c).BoundingBox;
       x_min = uint16(boundingBox_vals(1));
       x_max = uint16(x_min + boundingBox_vals(3));
       y_min = uint16(boundingBox_vals(2));
       y_max = uint16(y_min + boundingBox_vals(4));
       object_image(y_min:y_max, x_min:x_max) = separateConnectedCells(object_image(y_min:y_max, x_min:x_max),n);
   end
end

[labels,num_cells] = bwlabel(im2bw(object_image,0));

end
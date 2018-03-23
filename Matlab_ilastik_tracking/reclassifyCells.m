
function im = reclassifyCells(im,x,y,reclassify_as)

% figure,imshow(im,[])

[labels,~] = bwlabel(im2bw(im,0));
props = regionprops(labels);
old_label = labels(y,x);
if old_label == 0
    return
end

% figure,imshow(labels,[])

boundingBox_vals = props(old_label).BoundingBox;
x_min = uint16(boundingBox_vals(1));
x_max = uint16(x_min + boundingBox_vals(3));
y_min = uint16(boundingBox_vals(2));
y_max = uint16(y_min + boundingBox_vals(4));

boxed_cell = im(y_min:y_max, x_min:x_max);
boxed_cell(boxed_cell > 0) = reclassify_as;
im(y_min:y_max, x_min:x_max) = boxed_cell;

% figure,imshow(im,[])
end
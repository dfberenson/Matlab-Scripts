
function labels = getLabelsFromObjects(object_image)

[labels,num_cells] = bwlabel(im2bw(object_image,0));

end
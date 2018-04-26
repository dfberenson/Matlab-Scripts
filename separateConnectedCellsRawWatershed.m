
function corrected_local_binary_image = separateConnectedCellsRawWatershed(local_raw_image, local_binary_image, disksize)
% Takes the local raw image and segmented image as inputs
% Uses a strel filter on the raw image to use as good watershed seed points
% Sets watershed ridge lines to 0 and returns binary image

just_raw_cells = imimposemin(local_raw_image, ~local_binary_image);
basins = single(just_raw_cells);
se = strel('disk',disksize);
basins_opened = imopen(basins,se);
shed = watershed(-basins_opened);

corrected_local_binary_image = local_binary_image;
corrected_local_binary_image(shed == 0) = 0;
corrected_local_binary_image(corrected_local_binary_image ~= 0) = 1;

end
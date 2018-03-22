
function correctedLocalImage = separateConnectedCells(localImage, correct_num)

minimum_watershed_depth = 10;
[~,num] = bwlabel(localImage);

while num < correct_num && minimum_watershed_depth >= 0
    basins = bwdist(~localImage);
    suppressed = -imhmin(basins,minimum_watershed_depth);
    shed = watershed(suppressed);
    correctedLocalImage = localImage;
    correctedLocalImage(shed == 0) = 0;
%     imshow(correctedLocalImage,[])
%     imtool(basins)
    [~,num] = bwlabel(correctedLocalImage);
    minimum_watershed_depth = minimum_watershed_depth - 0.5;
end
end


% minimum_watershed_depth_2 = 1;
% minimum_watershed_depth_3 = 6.2;
% % Minimum watershed depth of 6.2 empirically works well for this image.
% % Perhaps can try starting with a high depth and incrementing to lower
% % depths while counting depths until reach a height so number of distinct
% % basins is equal to the cell label.
% 
% if num == 2
%     basins = bwdist(~localImage);
%     suppressed = -imhmin(basins,minimum_watershed_depth_2);
%     shed = watershed(suppressed);
%     %     shed = watershed(-basins);
%     correctedLocalImage = localImage;
%     correctedLocalImage(shed == 0) = 0;
% %     imshow(correctedLocalImage,[])
% end
% 
% if num == 3
%     basins = bwdist(~localImage);
%     suppressed = -imhmin(basins,0);
%     shed = watershed(suppressed);
%     correctedLocalImage = localImage;
%     correctedLocalImage(shed == 0) = 0;
%     imshow(correctedLocalImage,[])
% end
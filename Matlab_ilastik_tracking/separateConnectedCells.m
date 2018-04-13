
function correctedLocalImage = separateConnectedCells(localImage, correct_num)
% Takes as input a binary image showing only the cell that needs to be
% split, and the number of cells to split it into.
% Returns an equally binary sized image with the cells split.

minimum_watershed_depth = 10;
[~,num] = bwlabel(localImage,4);
correctedLocalImage = localImage;

while num ~= correct_num && minimum_watershed_depth >= 0
    basins = bwdist(~localImage);
    suppressed = -imhmin(basins,minimum_watershed_depth);
    shed = watershed(suppressed);
    correctedLocalImage = localImage;
    correctedLocalImage(shed == 0) = 0;
    correctedLocalImage(correctedLocalImage ~= 0) = 1;
    %     imshow(correctedLocalImage,[])
    %     imtool(basins)
    [L,num] = bwlabel(correctedLocalImage,4);
    if num < correct_num
        minimum_watershed_depth = minimum_watershed_depth - 0.5;
    elseif num > correct_num    %If oversegmentation happened suddenly
        props = regionprops(L);
        for n = 1:num
            areas(n) = props(n).Area;
        end
        [~,label_nums] = sort(areas,'descend');
        good_cell_indices = label_nums(1:correct_num);
        bad_cell_indices = label_nums(correct_num+1:end);
        L(ismember(L,bad_cell_indices)) = 0;
        L(ismember(L,good_cell_indices)) = 1;
        correctedLocalImage = L;
        return
    end
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
function group = get_group_variable(cell_array)

%Takes a cell array of equal-length, mutually exclusive logical vectors as input.
%Combines them into a single integer vector with the integer corresponding
%to the cell_array index.

for i = 1:length(cell_array)
    arr = cell_array{i};
    for k = 1:length(arr)
        if arr(k) ~= 0
            group(k) = arr(k) * i;
        end
    end
end
end
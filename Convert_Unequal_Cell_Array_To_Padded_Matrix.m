
cell_array = data(1).good_smooth_geminin_traces;

max_column_height = 0;
matrix = [];

for i = 1:length(cell_array)
    thiscell_data = cell_array{i};
    if length(thiscell_data) > max_column_height
        max_column_height = length(thiscell_data);
    end
end

for i = 1:length(cell_array)
    thiscell_data = cell_array{i};
    thiscell_data(max_column_height) = 0;
    matrix(:,i) = thiscell_data;
%     figure,plot(thiscell_data)
end
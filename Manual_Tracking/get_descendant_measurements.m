function descendant_struct = get_descendant_measurements(descendant_struct, s, measurement_table, parent_cellnum)
% d is a structure with the measurement data for the lineage.
% s is the saved data struct from tracking
% measurement_table is the table of the chosen measurement

descendant_struct(parent_cellnum).measurements = measurement_table(:, parent_cellnum);
[d1,d2] = find_daughters(s, parent_cellnum);
if d1 == 0 && d2 == 0
    if s.track_metadata(parent_cellnum).mitosis > 0
        descendant_struct(parent_cellnum).divides = true;
    else
        descendant_struct(parent_cellnum).divides = false;
    return
else
    descendant_struct(parent_cellnum).divides = true;
    descendant_struct(parent_cellnum).d1_num = d1;
    descendant_struct(parent_cellnum).d2_num = d2;
    if d1 ~= 0
        descendant_struct = get_descendant_measurements(descendant_struct, s, measurement_table, d1);
    end
    if d2 ~= 0
        descendant_struct = get_descendant_measurements(descendant_struct, s, measurement_table, d2);
    end
end
end

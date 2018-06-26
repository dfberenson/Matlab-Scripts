

function display_descendant_lineage(s, parent_cellnum)

[d1,d2] = find_daughters(s, parent_cellnum);

if d1 == 0 && d2 == 0
    disp(['Cell ' num2str(parent_cellnum) ' does not divide.'])
    return
else
    disp(['Cell ' num2str(parent_cellnum) ' divides into cells ' num2str(d1) ' and ' num2str(d2) '.'])
    display_descendant_lineage(s, d1);
    display_descendant_lineage(s, d2);
end
end
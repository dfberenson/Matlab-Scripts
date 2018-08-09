
function tree = make_lineage_tree(lineage_table)

    tree = struct;
    
    assert(strcmp(lineage_table.Properties.DimensionNames{1},'Row'),...
        'The table is not organized into rows for each track');
    assert(strcmp(lineage_table.Properties.DimensionNames{2},'Variables'),...
        'The table is not organized into columns for each variable');
    assert(strcmp(lineage_table.Properties.VariableNames{1},'TrackLineages'),...
        'The first column is not TrackLineages');
    
    [num_rows,num_cols] = size(lineage_table);
    
    for c = 1:num_rows 
        assert(strcmp(lineage_table{c,'TrackLineages'}{1},['Track ' num2str(c)]),...
            'The track numbers and row numbers do not match');
        
        % Convert mother and daughter IDs to just the numbers
        tree(c).daughter1_id = str2num(lineage_table{c,'Daughter1'}{1}(7:end));
        tree(c).daughter2_id = str2num(lineage_table{c,'Daughter2'}{1}(7:end));
        tree(c).mother_id = str2num(lineage_table{c,'Mother'}{1}(7:end));
        tree(c).orig_ancestor_id = str2num(lineage_table{c,'Founder'}{1}(7:end));
    end
    
    % Double check that everything makes sense
    for c = 1:num_rows
%         if isempty(tree(c).mother_id) == lineage_table{c,'Newborn'}
%             disp('Newborn boolean does not make sense')
%         end
        
        assert((~isempty(tree(c).daughter1_id) && ~isempty(tree(c).daughter2_id)) == lineage_table{c,'Divides'})
        
        if ~isempty(tree(c).daughter1_id) && ~isempty(tree(c).daughter2_id)
            assert(lineage_table{c,'LastFrame'} + 1 == lineage_table{tree(c).daughter1_id,'FirstFrame'});
            assert(lineage_table{c,'LastFrame'} + 1 == lineage_table{tree(c).daughter2_id,'FirstFrame'});
        end
        
        if ~isempty(tree(c).mother_id)
            assert(lineage_table{c,'FirstFrame'} - 1 == lineage_table{tree(c).mother_id,'LastFrame'});
        end
    end
end
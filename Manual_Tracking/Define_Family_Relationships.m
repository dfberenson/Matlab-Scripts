
clear all

folder = 'E:\Manually tracked measurements';
expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
expt_folder = [folder '\' expt_name];
positions_list = [1 2 3 13 14 15];

for pos = positions_list
    position_folder = [expt_folder '\Pos' num2str(pos)];
    load([position_folder '\TrackingData.mat']);
    s = saved_data;
    s.expt_folder = 'F:\Manually tracked imaging experiments';
    s.expt_name = [expt_name '_Pos' num2str(pos)];
    
    tree = struct;
    for c = s.all_tracknums
        if ~isempty(s.track_metadata(c).mitosis)
            [tree(c).daughter1_id, tree(c).daughter2_id] = find_daughters(s,c);
            if ~(tree(c).daughter1_id > 0 && tree(c).daughter2_id > 0)
                disp(['Position ' num2str(pos) ' cell ' num2str(c)...
                    ' divides but does not have two found daughters.'])
            end
            if tree(c).daughter1_id > 0
                tree(tree(c).daughter1_id).mother_id = c;
            end
            if tree(c).daughter2_id > 0
                tree(tree(c).daughter2_id).mother_id = c;
            end
        end
    end
    
    save([position_folder '\Family_Relationships.mat'], 'tree');
    
end

% Count cells in an image
% First, use ilastik to pixel classify and object classify the image
% Save image as multipage tiff 'Object Predictions'
% With empty space coded as 0s, single cells as 1s, and doublets as 2s

folder = 'E:\Image Analysis\Cell Counting';
expt = 'DFB_170907_HMEC_1GFiii_palbo_after_1';
avg_birth_frame = 60;

max_pos = 18;
max_num = 2;

avg_obj_count_array = zeros(max_pos,max_num);
full_obj_count_array = cell(max_pos,max_num);
obj_count_at_avg_birth_frame = zeros(max_pos,1);

for pos = 1:max_pos
    pos
    for n = 0:max_num
        if n==0
            filename = ['C3-' expt '_MMStack_Pos' num2str(pos) '.ome_Object Predictions'];
        else
            filename = ['C3-' expt '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome_Object Predictions'];
        end
        
        fpath = [folder '\' filename '.tiff'];

        info = imfinfo(fpath);
        num_images = numel(info);
        stack_objects_list = [];
        stack_total_objects = 0;

        for i = 1:num_images
            imstack(:,:,i) = imread(fpath,i,'Info',info);
            [L1,num1] = bwlabel(imstack(:,:,i) == 1);
            [L2,num2] = bwlabel(imstack(:,:,i) == 2);
            [L3,num3] = bwlabel(imstack(:,:,i) == 3);
            sum_objects = num1 + 2*num2 + 3*num3;
            stack_objects_list = [stack_objects_list, sum_objects];
            stack_total_objects = stack_total_objects + sum_objects;
            
            if n*129 + i == avg_birth_frame
                obj_count_at_avg_birth_frame(pos) = sum_objects;
            end
            
        end
        
        full_obj_count_array{pos,n+1} = stack_objects_list;
        avg_obj_count_array(pos,n+1) = stack_total_objects / num_images;
    end
end
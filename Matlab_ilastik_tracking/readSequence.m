

function imstack = readSequence(filepath, start_num, end_num, color)

    if strcmp(color,'rgb')
        for i = start_num:end_num
            disp(['Reading image ' num2str(i)])
            imstack(:,:,:,i) = imread([filepath '_' num2str(i) '.tif']);
        end
    else
        for i = start_num:end_num
            disp(['Reading image ' num2str(i)])
            imstack(:,:,i) = imread([filepath '_' num2str(i) '.tif']);
        end
    end
end
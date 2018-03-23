

function imstack = readSequence(filepath, startframe, endframe, color)
% Filepath should be everything in the image names except for the
% final '_1.tif'

    if strcmp(color,'rgb')
        for i = startframe:endframe
            disp(['Reading image ' num2str(i)])
            imstack(:,:,:,i) = imread([filepath '_' num2str(i) '.tif']);
        end
    else
        for i = startframe:endframe
            disp(['Reading image ' num2str(i)])
            imstack(:,:,i) = imread([filepath '_' num2str(i) '.tif']);
        end
    end
end
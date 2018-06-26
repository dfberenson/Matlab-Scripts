

function imstack = readSequence(filepath, startframe, endframe, color)
% Filepath should be everything in the image names except for the
% final '_1.tif'

    if strcmp(color,'rgb')
        for i = startframe:endframe
            disp(['Reading image ' sprintf('%03d',i)])
            imstack(:,:,:,i) = imread([filepath '_' sprintf('%03d',i) '.tif']);
        end
    else
        for i = startframe:endframe
            disp(['Reading image ' sprintf('%03d',i)])
            imstack(:,:,i) = imread([filepath '_' sprintf('%03d',i) '.tif']);
        end
    end
end
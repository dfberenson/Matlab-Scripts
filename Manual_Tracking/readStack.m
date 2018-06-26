

function imstack = readStack(filepath)

    info = imfinfo(filepath);
    num_images = numel(info);
    for i = 1:num_images
        disp(['Reading image ' sprintf('%03d',i)])
        imstack(:,:,i) = imread(filepath,i,'Info',info);
    end
end
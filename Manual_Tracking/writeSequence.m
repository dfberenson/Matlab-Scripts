
function writeSequence(imstack,expt_folder,expt_name,img_name,startframe,endframe,color)

filepath = [expt_folder '\' expt_name '_' img_name];
if ~exist(filepath,'dir')
    mkdir(filepath)
end

if strcmp(color,'rgb')
        for i = startframe:endframe
            disp(['Writing image ' sprintf('%03d',i)])
            imwrite(imstack(:,:,:,i),[filepath  '\' expt_name '_' img_name '_' sprintf('%03d',i) '.tif']);
        end
else
    for i = startframe:endframe
            disp(['Writing image ' sprintf('%03d',i)])
            imwrite(imstack(:,:,i),[filepath  '\' expt_name '_' img_name '_' sprintf('%03d',i) '.tif']);
    end
end
end
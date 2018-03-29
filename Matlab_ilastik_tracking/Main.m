
%% Initalize variables

folder = 'E:\Matlab ilastik';
expt_name = 'DivisionStack1';
startframe = 1;
endframe = 40;

%TrackCells and ImageViewingGUI currently have the above values hard-coded.
%Should be shared instead (as arguments?)

%% Put images in correct folders

expt_folder = [folder '\' expt_name];

if ~exist(expt_folder,'dir')
    mkdir(expt_folder);
end

raw_imstack = readStack([folder '\' expt_name '.tif']);
writeSequence(raw_imstack,expt_folder,expt_name,'Raw',startframe,endframe,'gray');
clear raw_imstack;

obj_class_imstack = readStack([folder '\' expt_name '_Object Predictions.tiff']);
writeSequence(obj_class_imstack,expt_folder,expt_name,'Object Classification',startframe,endframe,'gray');
if ~exist([expt_folder '\' expt_name '_Object Reclassification\'],'dir')
    mkdir([expt_folder '\' expt_name '_Object Reclassification\'])
    writeSequence(obj_class_imstack,expt_folder,expt_name,'Object Reclassification',startframe,endframe,'gray');
end
clear obj_class_imstack;

%% Run tracking algorithm
TrackCells

%% Use GUI to adjust object classification
% Full camera images are too large to reclassify by hand. Allow zoom?
gui = ImageViewingGUI(folder,expt_name,startframe,endframe);
waitfor(gui);

if input('Write reclassifications over classifications? (y/n) ','s') == 'y'
    obj_reclass_imstack = readSequence([expt_folder '\' expt_name '_Object Reclassification\'...
        expt_name '_Object Reclassification'],1,60,'gray');
    writeSequence(obj_reclass_imstack,expt_folder,expt_name,'Object Classification',startframe,endframe,'gray');
    clear obj_reclass_imstack;
end

%% Rerun tracking algorithm
TrackCells
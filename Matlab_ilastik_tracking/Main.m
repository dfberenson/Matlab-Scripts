
%% Initalize variables

folder = 'E:\Matlab ilastik\PixelObjectClassification_3';
expt_name = 'DivisionStack1';
startframe = 1;
endframe = 40;

% Load colormap
if exist('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv','file') == 2
    cmap = csvread('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv');
else
    cmap = 0.2 + 0.8*rand(500,3);
    cmap(1,:) = [0 0 0];
    csvwrite('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv',cmap);
end

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
track_cells(folder,expt_name,startframe,endframe,'c');

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
track_cells(folder,expt_name,startframe,endframe,'r');
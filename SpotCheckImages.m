
%% For images sorted into Manually Tracked folders (may or may not actually have been manually tracked)


clear all
close all

% drive = 'F';
drive = 'H';
folder = 'Manually tracked imaging experiments';
% expt = 'DFB_180803_HMEC_D5_1';
% expt = 'DFB_180829_HMEC_D5_1';
expt = 'DFB_181108_HMEC_D5_palbo_1';
channel = 'RawFarRed';

positions = 13:24;
frames = 1:432;
frames = [10 60 110 170 230 290 350 410];

for pos = positions
    for frame = frames
        fpath = [drive ':\' folder '\' expt '_Pos' num2str(pos) '\' expt '_Pos' num2str(pos) '_' channel '\' expt '_Pos' num2str(pos) '_' channel '_' sprintf('%03d',frame) '.tif'];
        if exist(fpath)
            im = imread(fpath);
            figure,imshow(im,[])
            title(['Position ' num2str(pos) ', frame ' num2str(frame)])
        end
    end
end

%% For images not sorted into Manually Tracked folders
clear all
close all

drive = 'H';
folder = 'DFB_imaging_experiments_3';

% expt = 'DFB_190121_HMEC_D5_palbo_1';
% channel = 2;

expt = 'DFB_190212_HMEC_Rb-Clov_D5_1';
channel = 0;

% expt = 'DFB_190215_HMEC_BT45-Cdt1_D5_3';
% channel = 1;


positions = 1:36;
frames = 1:432;
frames = [10 60 110 170 230 290 350 410];

for pos = positions
    for frame = frames
        fpath = [drive ':\' folder '\' expt '\Pos' num2str(pos) '\img_channel' sprintf('%03d',channel) '_position' sprintf('%03d',pos) '_time' sprintf('%09d',frame) '_z000.tif'];
        if exist(fpath)
            im = imread(fpath);
            figure,imshow(im,[])
            title(['Position ' num2str(pos) ', frame ' num2str(frame)])
        end
    end
end


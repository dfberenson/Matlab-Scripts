
clear all
close all

folder = 'E:\QPM_Timelapse';
expt = 'DFB_180501_QPM_HMEC_1GFiii\Pos11';

if ~exist([folder '\' expt '\fluo1'])
    mkdir([folder '\' expt '\fluo1'])
end
if ~exist([folder '\' expt '\fluo2'])
    mkdir([folder '\' expt '\fluo2'])
end

for t = 0:561
    fluo1_fname = [folder '\' expt '\fluo\INT_img_channel000_position011_time' sprintf('%09d',t) '_z000fluo1_flat.tif'];
    fluo2_fname = [folder '\' expt '\fluo\INT_img_channel000_position011_time' sprintf('%09d',t) '_z000fluo2_flat.tif'];
    
    movefile(fluo1_fname,[folder '\' expt '\fluo1\INT_img_channel000_position011_time' sprintf('%09d',t) '_z000fluo1_flat.tif']);
    movefile(fluo2_fname,[folder '\' expt '\fluo2\INT_img_channel000_position011_time' sprintf('%09d',t) '_z000fluo2_flat.tif']);
end

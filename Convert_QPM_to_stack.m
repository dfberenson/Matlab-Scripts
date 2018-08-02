
%% For flattened images

position = 21;
folder = ['E:\QPM_Timelapse\DFB_180501_QPM_HMEC_1GFiii\Pos' num2str(position)];
phase_subfolder = [folder '\Phase\Flattened'];
fluorescence_subfolder = [folder '\Fluorescence\Flattened'];

phase_stack_name = 'Phase.tif';
fluo1_stack_name = 'GFP.tif';
fluo2_stack_name = 'mCherry.tif';


% for i = 0:504
for i = 1:504
    disp(['Writing frame ' num2str(i)])
    phase_name = ['PHA_img_channel000_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000_flat.tif'];
    fluo1_name = ['INT_img_channel000_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000fluo1_flat.tif'];
    fluo2_name = ['INT_img_channel000_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000fluo2_flat.tif'];
    
    phase_im = imread([phase_subfolder '\' phase_name]);
    fluo1_im = imread([fluorescence_subfolder '\' fluo1_name]);
    fluo2_im = imread([fluorescence_subfolder '\' fluo2_name]);
    
    if i == 0
        imwrite(phase_im, [phase_subfolder '\' phase_stack_name],'Compression','none');
        imwrite(fluo1_im, [fluorescence_subfolder '\' fluo1_stack_name],'Compression','none');
        imwrite(fluo2_im, [fluorescence_subfolder '\' fluo2_stack_name],'Compression','none');
        
    else
        imwrite(phase_im, [folder '\' phase_stack_name],'writemode','append','Compression','none');
        imwrite(fluo1_im, [folder '\' fluo1_stack_name],'writemode','append','Compression','none');
        imwrite(fluo2_im, [folder '\' fluo2_stack_name],'writemode','append','Compression','none');
    end
end

%% For unflattened images

position = 11;
folder = ['G:\DFB_imaging_experiments\DFB_180501_QPM_HMEC_1GFiii_4\Pos' num2str(position)];
phase_stack_name = 'Phase.tif';
GFP_stack_name = 'GFP.tif';
mCherry_stack_name = 'mCherry.tif';

for i = 1:504
    disp(['Writing frame ' num2str(i)])
    phase_name = ['img_channel001_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000.tif'];
    GFP_name = ['img_channel002_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000.tif'];
    mCherry_name = ['img_channel003_position' sprintf('%03d',position) '_time' sprintf('%09d',i) '_z000.tif'];
    
    phase_im = imread([folder '\' phase_name]);
    GFP_im = imread([folder '\' GFP_name]);
    mCherry_im = imread([folder '\' mCherry_name]);
    
    if i == 0
        imwrite(phase_im, [folder '\' phase_stack_name],'Compression','none');
        imwrite(GFP_im, [folder '\' GFP_stack_name],'Compression','none');
        imwrite(mCherry_im, [folder '\' mCherry_stack_name],'Compression','none');
    
    else
        imwrite(phase_im, [folder '\' phase_stack_name],'writemode','append','Compression','none');
        imwrite(GFP_im, [folder '\' GFP_stack_name],'writemode','append','Compression','none');
        imwrite(mCherry_im, [folder '\' mCherry_stack_name],'writemode','append','Compression','none');
    end
end
        
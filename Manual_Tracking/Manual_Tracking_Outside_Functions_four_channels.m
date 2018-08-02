
clear all
close all

%% Initialize Variables

% Need to change backslashes to forward slashes in filenames on Mac

folder = 'C:\Users\Skotheim Lab\Desktop\Manual_Tracking';
base_expt_name = 'DFB_180627_HMEC_1GFiii_palbo_2';
pos = 15;
full_expt_name = [base_expt_name '_Pos' num2str(pos)];
expt_folder = [folder '\' full_expt_name];
order_of_colors = 'pgrf';
% phase green red farred
max_n = 1;

%% Put images in correct folders


if ~exist(expt_folder,'dir')
    mkdir(expt_folder);
end
if ~exist([expt_folder  '\' full_expt_name '_RawGray'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawGray']);
end
if ~exist([expt_folder  '\' full_expt_name '_RawGreen'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawGreen']);
end
if ~exist([expt_folder  '\' full_expt_name '_RawRed'],'dir')
    mkdir([expt_folder  '\' full_expt_name '_RawRed']);
end

init_frame = 1;
current_frame = init_frame;

for n = 0:max_n
    if n == 0
        raw_imstack = readStack([expt_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '.ome.tif']);
    else
        raw_imstack = readStack([expt_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome.tif']);
    end
    size_raw_imstack = size(raw_imstack);
    for i = 1:size_raw_imstack(3)/3
        disp(['Writing image ' sprintf('%03d',current_frame)])
        if strcmp(order_of_colors,'gr')
            imwrite(raw_imstack(:,:,3*i-2),[expt_folder  '\' full_expt_name '_RawGray\'...
                full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
            imwrite(raw_imstack(:,:,3*i-1),[expt_folder  '\' full_expt_name '_RawGreen\'...
                full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
            imwrite(raw_imstack(:,:,3*i-0),[expt_folder  '\' full_expt_name '_RawRed\'...
                full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
        elseif strcmp(order_of_colors,'rg')
            imwrite(raw_imstack(:,:,3*i-2),[expt_folder  '\' full_expt_name '_RawGray\'...
                full_expt_name '_RawGray_' sprintf('%03d',current_frame) '.tif']);
            imwrite(raw_imstack(:,:,3*i-1),[expt_folder  '\' full_expt_name '_RawRed\'...
                full_expt_name '_RawRed_' sprintf('%03d',current_frame) '.tif']);
            imwrite(raw_imstack(:,:,3*i-0),[expt_folder  '\' full_expt_name '_RawGreen\'...
                full_expt_name '_RawGreen_' sprintf('%03d',current_frame) '.tif']);
        end
        current_frame = current_frame + 1;
    end
end
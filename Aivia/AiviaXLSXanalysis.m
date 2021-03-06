source_folder = 'E:\Aivia';
xlsx_fname = 'DFB_180110_HMEC_1GFiii_palbo_After_2_MMStack_Pos1_combined - PixelClassifierResults - All Channels - In Focus - Results_Tracks';

xlsx_fpath = [source_folder '\' xlsx_fname '.xlsx'];

[status,sheets] = xlsfinfo(xlsx_fpath);

areas_table = readtable(xlsx_fpath, 'Sheet', 'Area (�m�)');
ch1_mean_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - default');
ch2_mean_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - default (2)');
ch3_mean_table = readtable(xlsx_fpath, 'Sheet', 'Mean Intensity - default (3)');
ch1_total_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - default');
ch2_total_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - default (2)');
ch3_total_table = readtable(xlsx_fpath, 'Sheet', 'Total Intensity - default (3)');

% Interesting track gruops: 220, 450, 452; 179, 431, 433; 241, 494, 495


track = 241;

figure()
hold on
% plot(ch1_total_table{track,2:end})
plot(areas_table{track,2:end} * 1000, 'k')
plot(ch2_total_table{track,2:end}, 'g')
plot(ch3_total_table{track,2:end}, 'r')

figure()
hold on
% plot(ch1_total_table{track,2:end})
plot(areas_table{track,2:end}, 'k')
plot(ch2_mean_table{track,2:end}, 'g')
plot(ch3_mean_table{track,2:end}, 'r')


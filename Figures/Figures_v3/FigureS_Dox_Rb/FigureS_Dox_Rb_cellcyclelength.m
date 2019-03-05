
clear all
close all

xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190219_HMEC_BT45-Cdt1_Dox_Palbo_2.xlsx';

framerate = 1/6;

nodox_tracks = readtable(xlsx_fpath,'Sheet','0 dox');
nodox_g1_length = nodox_tracks.Cdt1MaxFrame - nodox_tracks.BirthFrame;

lowdox_tracks = readtable(xlsx_fpath,'Sheet','50 dox');
lowdox_g1_length = lowdox_tracks.Cdt1MaxFrame - lowdox_tracks.BirthFrame;

hidox_tracks = readtable(xlsx_fpath,'Sheet','500 dox');
hidox_g1_length = hidox_tracks.Cdt1MaxFrame - hidox_tracks.BirthFrame;
hidox_birth_rb = hidox_tracks.NetIntens;

figure
hold on
histogram(nodox_g1_length)
histogram(lowdox_g1_length)
histogram(hidox_g1_length)

nodox_med_g1_length = nanmedian(nodox_g1_length);
lowdox_med_g1_length = nanmedian(lowdox_g1_length);
hidox_med_g1_length = nanmedian(hidox_g1_length);

nodox_intens = readtable(xlsx_fpath,'Sheet','0 dox Rb intensity');
lowdox_intens = readtable(xlsx_fpath,'Sheet','50 dox Rb intensity');
hidox_intens = readtable(xlsx_fpath,'Sheet','500 dox Rb intensity');

nodox_med_rb = nanmedian(nodox_intens.RawIntDen(1:2:length(nodox_intens.RawIntDen)-1) - nodox_intens.RawIntDen(2:2:length(nodox_intens.RawIntDen)));
lowdox_med_rb = nanmedian(lowdox_intens.RawIntDen(1:2:length(lowdox_intens.RawIntDen)-1) - lowdox_intens.RawIntDen(2:2:length(lowdox_intens.RawIntDen)));
hidox_med_rb = nanmedian(hidox_intens.RawIntDen(1:2:length(hidox_intens.RawIntDen)-1) - hidox_intens.RawIntDen(2:2:length(hidox_intens.RawIntDen)));

disp(['0 dox has ' num2str(nodox_med_rb) ' expression and median G1 length of ' num2str(nodox_med_g1_length * framerate) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(nodox_g1_length,25)*framerate) ' to ' num2str(prctile(nodox_g1_length,75)*framerate) ' hours.'])
disp(['50 dox has ' num2str(lowdox_med_rb) ' expression and median G1 length of ' num2str(lowdox_med_g1_length * framerate) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(lowdox_g1_length,25)*framerate) ' to ' num2str(prctile(lowdox_g1_length,75)*framerate) ' hours.'])
disp(['500 dox has ' num2str(hidox_med_rb) ' expression and median G1 length of ' num2str(hidox_med_g1_length * framerate) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(hidox_g1_length,25)*framerate) ' to ' num2str(prctile(hidox_g1_length,75)*framerate) ' hours.'])

figure
scatter(hidox_birth_rb,hidox_g1_length*framerate)
xlabel('Rb amount at birth')
ylabel('G1 length (h)')

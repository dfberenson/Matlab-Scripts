
clear all
close all

xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190219_HMEC_BT45-Cdt1_Dox_Palbo_2.xlsx';

framerate = 1/6;

dox0_tracks = readtable(xlsx_fpath,'Sheet','0 dox');
dox0_g1_length = (dox0_tracks.Cdt1PeakFrame - dox0_tracks.BirthFrame) * framerate;

dox50_tracks = readtable(xlsx_fpath,'Sheet','50 dox');
dox50_g1_length = (dox50_tracks.Cdt1PeakFrame - dox50_tracks.BirthFrame) * framerate;

dox500_tracks = readtable(xlsx_fpath,'Sheet','500 dox');
dox500_g1_length = (dox500_tracks.Cdt1PeakFrame - dox500_tracks.BirthFrame) * framerate;
dox500_birth_rb = dox500_tracks.NetIntens;

figure
hold on
histogram(dox0_g1_length)
histogram(dox50_g1_length)
histogram(dox500_g1_length)

dox0_median_g1_length = nanmedian(dox0_g1_length);
dox50_median_g1_length = nanmedian(dox50_g1_length);
dox500_median_g1_length = nanmedian(dox500_g1_length);

dox0_stderr_g1_length = nanstd(dox0_g1_length) / sqrt(height(dox0_tracks));
dox50_stderr_g1_length = nanstd(dox50_g1_length) / sqrt(height(dox50_tracks));
dox500_stderr_g1_length = nanstd(dox500_g1_length) / sqrt(height(dox500_tracks));

dox0_intens = readtable(xlsx_fpath,'Sheet','0 dox Rb intensity');
dox50_intens = readtable(xlsx_fpath,'Sheet','50 dox Rb intensity');
dox500_intens = readtable(xlsx_fpath,'Sheet','500 dox Rb intensity');

dox0_med_rb = nanmedian(dox0_intens.RawIntDen(1:2:length(dox0_intens.RawIntDen)-1) - dox0_intens.RawIntDen(2:2:length(dox0_intens.RawIntDen)));
dox50_med_rb = nanmedian(dox50_intens.RawIntDen(1:2:length(dox50_intens.RawIntDen)-1) - dox50_intens.RawIntDen(2:2:length(dox50_intens.RawIntDen)));
dox500_med_rb = nanmedian(dox500_intens.RawIntDen(1:2:length(dox500_intens.RawIntDen)-1) - dox500_intens.RawIntDen(2:2:length(dox500_intens.RawIntDen)));

dox0_stderr_rb = std(dox0_intens.RawIntDen(1:2:length(dox0_intens.RawIntDen)-1) - dox0_intens.RawIntDen(2:2:length(dox0_intens.RawIntDen))) / sqrt(height(dox0_intens)/2);
dox50_stderr_rb = std(dox50_intens.RawIntDen(1:2:length(dox50_intens.RawIntDen)-1) - dox50_intens.RawIntDen(2:2:length(dox50_intens.RawIntDen))) / sqrt(height(dox50_intens)/2);
dox500_stderr_rb = std(dox500_intens.RawIntDen(1:2:length(dox500_intens.RawIntDen)-1) - dox500_intens.RawIntDen(2:2:length(dox500_intens.RawIntDen))) / sqrt(height(dox500_intens)/2);

disp(['0 dox has ' num2str(dox0_med_rb) ' expression and median G1 length of ' num2str(dox0_median_g1_length) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(dox0_g1_length,25)) ' to ' num2str(prctile(dox0_g1_length,75)) ' hours.'])
disp(['50 dox has ' num2str(dox50_med_rb) ' expression and median G1 length of ' num2str(dox50_median_g1_length) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(dox50_g1_length,25)) ' to ' num2str(prctile(dox50_g1_length,75)) ' hours.'])
disp(['500 dox has ' num2str(dox500_med_rb) ' expression and median G1 length of ' num2str(dox500_median_g1_length) ' hours.'])
disp(['The interquartile range of G1 length is ' num2str(prctile(dox500_g1_length,25)) ' to ' num2str(prctile(dox500_g1_length,75)) ' hours.'])

figure
hold on
box on
[bar,err] = barwitherr([dox0_stderr_g1_length dox50_stderr_g1_length dox500_stderr_g1_length],[dox0_median_g1_length dox50_median_g1_length dox500_median_g1_length],'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 inf],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'0 ng/mL dox','50 ng/mL dox','500 ng/mL dox'})
ylabel('G1 length (h)')
hold off

figure
hold on
box on
[bar,err] = barwitherr([dox0_stderr_rb dox50_stderr_rb dox500_stderr_rb],[dox0_med_rb dox50_med_rb dox500_med_rb],'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 inf],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'0 ng/mL dox','50 ng/mL dox','500 ng/mL dox'})
ylabel('Rb amount at movie start')
hold off


figure
scatter(dox500_birth_rb,dox500_g1_length)
xlabel('Rb amount at birth')
ylabel('G1 length (h)')

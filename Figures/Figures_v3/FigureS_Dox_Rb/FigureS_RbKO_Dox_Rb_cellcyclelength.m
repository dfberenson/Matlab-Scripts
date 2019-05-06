
clear all
close all

framerate = 1/6;
% 
% % Pre-treated with Dox 60 h
% fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190416_HMEC_Rb-KO_Cdt1_Dox_palbo.xlsx';

% Not pre-treated with Dox
fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\DFB_190429_HMEC_RbKO_BT45_palbo.xlsx';


dox0_table = readtable(fpath,'Sheet','0 dox');
dox20_table = readtable(fpath,'Sheet','20 dox');
dox500_table = readtable(fpath,'Sheet','500 dox');

dox0_birth_nucarea = dox0_table.NucAreaBirth;
dox0_birth_rb = dox0_table.RbNetBirth;
dox0_g1s_rb = dox0_table.RbNetG1S;
dox0_g1_length = (dox0_table.Cdt1PeakFrame - dox0_table.BirthFrame) * framerate;
dox0_sg2_length = (dox0_table.G2MFrame - dox0_table.Cdt1PeakFrame) * framerate;
dox0_fullcycle_length = (dox0_table.CytoFrame - dox0_table.BirthFrame) * framerate;

dox20_birth_nucarea = dox20_table.NucAreaBirth;
dox20_birth_rb = dox20_table.RbNetBirth;
dox20_g1s_rb = dox20_table.RbNetG1S;
dox20_g1_length = (dox20_table.Cdt1PeakFrame - dox20_table.BirthFrame) * framerate;
dox20_sg2_length = (dox20_table.G2MFrame - dox20_table.Cdt1PeakFrame) * framerate;
dox20_fullcycle_length = (dox20_table.CytoFrame - dox20_table.BirthFrame) * framerate;

dox500_birth_nucarea = dox500_table.NucAreaBirth;
dox500_birth_rb = dox500_table.RbNetBirth;
dox500_g1s_rb = dox500_table.RbNetG1S;
dox500_g1_length = (dox500_table.Cdt1PeakFrame - dox500_table.BirthFrame) * framerate;
dox500_sg2_length = (dox500_table.G2MFrame - dox500_table.Cdt1PeakFrame) * framerate;
dox500_fullcycle_length = (dox500_table.CytoFrame - dox500_table.BirthFrame) * framerate;

dox0_median_birth_rb = median(dox0_birth_rb);
dox0_stderr_birth_rb = std(dox0_birth_rb) / sqrt(height(dox0_table));
dox0_median_g1s_rb = median(dox0_g1s_rb);
dox0_stderr_g1s_rb = std(dox0_g1s_rb) / sqrt(height(dox0_table));
dox0_median_g1_length = median(dox0_g1_length);
dox0_stderr_g1_length = std(dox0_g1_length) / sqrt(height(dox0_table));

dox20_median_birth_rb = median(dox20_birth_rb);
dox20_stderr_birth_rb = std(dox20_birth_rb) / sqrt(height(dox20_table));
dox20_median_g1s_rb = median(dox20_g1s_rb);
dox20_stderr_g1s_rb = std(dox20_g1s_rb) / sqrt(height(dox20_table));
dox20_median_g1_length = median(dox20_g1_length);
dox20_stderr_g1_length = std(dox20_g1_length) / sqrt(height(dox20_table));

dox500_median_birth_rb = median(dox500_birth_rb);
dox500_stderr_birth_rb = std(dox500_birth_rb) / sqrt(height(dox500_table));
dox500_median_g1s_rb = median(dox500_g1s_rb);
dox500_stderr_g1s_rb = std(dox500_g1s_rb) / sqrt(height(dox500_table));
dox500_median_g1_length = median(dox500_g1_length);
dox500_stderr_g1_length = std(dox500_g1_length) / sqrt(height(dox500_table));

all_birth_rb_unnormalized = [dox0_birth_rb; dox20_birth_rb; dox500_birth_rb];
all_g1s_rb_unnormalized = [dox0_g1s_rb; dox20_g1s_rb; dox500_g1s_rb];
all_g1_length = [dox0_g1_length; dox20_g1_length; dox500_g1_length];

all_birth_rb = all_birth_rb_unnormalized / median(all_birth_rb_unnormalized);
all_g1s_rb = all_g1s_rb_unnormalized / median(all_birth_rb_unnormalized);

% figure
% hold on
% histogram(dox0_birth_nucarea)
% histogram(dox20_birth_nucarea)
% histogram(dox500_birth_nucarea)
% title('Nuclear area at birth')
% legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
% 
% figure
% hold on
% histogram(dox0_birth_rb)
% histogram(dox20_birth_rb)
% histogram(dox500_birth_rb)
% title('Rb amount at birth')
% legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
% 
% figure
% hold on
% histogram(dox0_g1s_rb)
% histogram(dox20_g1s_rb)
% histogram(dox500_g1s_rb)
% title('Rb amount at G1/S')
% legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
% 
% figure
% hold on
% histogram(dox0_g1_length)
% histogram(dox20_g1_length)
% histogram(dox500_g1_length)
% title('G1 length (h)')
% legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})

figure
hold on
box on
[bar,err] = barwitherr([dox0_stderr_birth_rb dox20_stderr_birth_rb dox500_stderr_birth_rb] / median(all_birth_rb_unnormalized),[dox0_median_birth_rb dox20_median_birth_rb dox500_median_birth_rb] / median(all_birth_rb_unnormalized),'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 inf],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
ylabel('Rb amount at birth')
hold off

figure
hold on
box on
[bar,err] = barwitherr([dox0_stderr_g1s_rb dox20_stderr_g1s_rb dox500_stderr_g1s_rb] / median(all_birth_rb_unnormalized),[dox0_median_g1s_rb dox20_median_g1s_rb dox500_median_g1s_rb] / median(all_birth_rb_unnormalized),'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 inf],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
ylabel('Rb amount at G1/S')
hold off

figure
hold on
box on
[bar,err] = barwitherr([dox0_stderr_g1_length dox20_stderr_g1_length dox500_stderr_g1_length],[dox0_median_g1_length dox20_median_g1_length dox500_median_g1_length],'k');
bar.FaceColor = 'k';
err.LineWidth = 2;
err.CapSize = 40;
axis([0.5 3.5 0 inf],'square')
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
ylabel('G1 length (h)')
hold off

fitlm(all_birth_rb, all_g1_length)
fitlm(all_g1s_rb,all_g1_length)

polyfit_birth_g1 = polyfit(all_birth_rb, all_g1_length,1);
polyfit_g1s_g1 = polyfit(all_g1s_rb, all_g1_length,1);

% figure
% box on
% hold on
% scatter(all_birth_rb, all_g1_length)
% xlabel('Rb at birth')
% ylabel('G1 length (h)')
% 
% figure
% box on
% hold on
% scatter(all_g1s_rb, all_g1_length, '.k')
% xlabel('Rb at G1/S')
% ylabel('G1 length (h)')

figure
box on
hold on
scatter(dox0_birth_rb / median(all_birth_rb_unnormalized), dox0_g1_length, 100, '.b')
scatter(dox20_birth_rb / median(all_birth_rb_unnormalized), dox20_g1_length, 100, '.c')
scatter(dox500_birth_rb / median(all_birth_rb_unnormalized), dox500_g1_length, 100, '.g')
plot(0:0.1:60,polyval(polyfit_birth_g1, 0:0.1:60),'k')
xlabel('Rb at birth')
ylabel('G1 length (h)')
legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
axis([0 60 0 60],'square')

figure
box on
hold on
scatter(dox0_g1s_rb / median(all_birth_rb_unnormalized), dox0_g1_length, 100, '.b')
scatter(dox20_g1s_rb / median(all_birth_rb_unnormalized), dox20_g1_length, 100,'.c')
scatter(dox500_g1s_rb / median(all_birth_rb_unnormalized), dox500_g1_length, 100, '.g')
plot(0:0.1:200,polyval(polyfit_g1s_g1, 0:0.1:200),'k')
xlabel('Rb at G1/S')
ylabel('G1 length (h)')
legend({'0 ng/mL dox','20 ng/mL dox','500 ng/mL dox'})
axis([0 200 0 60],'square')

[g1s_binnedmeans, g1s_stdevs, g1s_stderrs, g1s_Ns] = bindata(all_g1s_rb, all_g1_length, 0:20:100);

figure
box on
hold on
shadedErrorBar(0:20:100,g1s_binnedmeans,g1s_stderrs)
scatter(dox0_g1s_rb / median(all_birth_rb_unnormalized), dox0_g1_length, 100, '.b')
scatter(dox20_g1s_rb / median(all_birth_rb_unnormalized), dox20_g1_length, 100,'.c')
scatter(dox500_g1s_rb / median(all_birth_rb_unnormalized), dox500_g1_length, 100, '.g')
xlabel('Rb at G1/S')
ylabel('G1 length (h)')
axis([0 200 0 60],'square')


% all_with_dox_birth_rb = [dox20_birth_rb; dox500_birth_rb];
% all_with_dox_g1s_rb = [dox20_g1s_rb; dox500_g1s_rb];
% all_with_dox_g1_length = [dox20_g1_length; dox500_g1_length];
% 
% figure
% scatter(all_with_dox_birth_rb, all_with_dox_g1_length)
% xlabel('Rb at birth')
% ylabel('G1 length (h)')
% title('20 and 500 ng/mL dox only')
% 
% figure
% scatter(all_with_dox_g1s_rb, all_with_dox_g1_length)
% xlabel('Rb at G1/S')
% ylabel('G1 length (h)')
% title('20 and 500 ng/mL dox only')
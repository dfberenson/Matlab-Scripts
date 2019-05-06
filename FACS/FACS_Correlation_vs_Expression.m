
clear all
close all

num_lines = 10;

fsc_r2 = nan(num_lines,1);
fsc_int = nan(num_lines,1);
mdians = nan(num_lines,1);

fsc_r2(1) = 0.64;
fsc_r2(2) = 0.56;
fsc_r2(3) = 0.60;
fsc_r2(4) = 0.54;
fsc_r2(5) = 0.57;
fsc_r2(6) = 0.55;
fsc_r2(7) = 0.41;
fsc_r2(8) = 0.35;
fsc_r2(9) = 0.45;
fsc_r2(10) = 0.51;

fsc_int(1) = -0.32;
fsc_int(2) = -0.34;
fsc_int(3) = -0.26;
fsc_int(4) = -0.30;
fsc_int(5) = -0.55;
fsc_int(6) = -0.41;
fsc_int(7) = -0.11;
fsc_int(8) = -0.23;
fsc_int(9) = -0.22;
fsc_int(10) = -0.34;

mdians(1) = 222;
mdians(2) = 103;
mdians(3) = 205;
mdians(4) = 81;
mdians(5) = 129;
mdians(6) = 181;
mdians(7) = 134;
mdians(8) = 78;
mdians(9) = 51;
mdians(10) = 121;

figure
scatter(mdians,fsc_r2)
xlabel('Median expression')
ylabel('FSC R^2')
fitlm(mdians,fsc_r2)

figure
scatter(mdians,fsc_int)
xlabel('Median expression')
ylabel('FSC y-int')
fitlm(mdians,fsc_int)

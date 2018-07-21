
clear all
close all

xlsx_fpath = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Phasics\DFB_180501_manual_measurements.xlsx';

framerate = 1/12;

T1 = readtable(xlsx_fpath,'Sheet','1');
T2 = readtable(xlsx_fpath,'Sheet','2');
T3 = readtable(xlsx_fpath,'Sheet','3');

raw_int_densities1 = table2array(T1(:,{'RawIntDen'}));
raw_int_densities2 = table2array(T2(:,{'RawIntDen'}));
raw_int_densities3 = table2array(T3(:,{'RawIntDen'}));

num_measurements_per_timepoint = 6;

[len1,~] = size(T1);
[len2,~] = size(T2);
[len3,~] = size(T3);

total_len = len1 + max(len2,len3);

total_frames = total_len / num_measurements_per_timepoint;

timepoints = 0 : framerate : framerate * (total_frames-1);

phase_fore1 = zeros(total_frames,1);
phase_back1 = zeros(total_frames,1);
gfp_fore1 = zeros(total_frames,1);
gfp_back1 = zeros(total_frames,1);
mcherry_fore1 = zeros(total_frames,1);
mcherry_back1 = zeros(total_frames,1);
phase_fore2 = zeros(total_frames,1);
phase_back2 = zeros(total_frames,1);
gfp_fore2 = zeros(total_frames,1);
gfp_back2 = zeros(total_frames,1);
mcherry_fore2 = zeros(total_frames,1);
mcherry_back2 = zeros(total_frames,1);
phase_fore3 = zeros(total_frames,1);
phase_back3 = zeros(total_frames,1);
gfp_fore3 = zeros(total_frames,1);
gfp_back3 = zeros(total_frames,1);
mcherry_fore3 = zeros(total_frames,1);
mcherry_back3 = zeros(total_frames,1);

smooth_phase_fore1 = zeros(total_frames,1);
smooth_phase_back1 = zeros(total_frames,1);
smooth_gfp_fore1 = zeros(total_frames,1);
smooth_gfp_back1 = zeros(total_frames,1);
smooth_mcherry_fore1 = zeros(total_frames,1);
smooth_mcherry_back1 = zeros(total_frames,1);
smooth_phase_fore2 = zeros(total_frames,1);
smooth_phase_back2 = zeros(total_frames,1);
smooth_gfp_fore2 = zeros(total_frames,1);
smooth_gfp_back2 = zeros(total_frames,1);
smooth_mcherry_fore2 = zeros(total_frames,1);
smooth_mcherry_back2 = zeros(total_frames,1);
smooth_phase_fore3 = zeros(total_frames,1);
smooth_phase_back3 = zeros(total_frames,1);
smooth_gfp_fore3 = zeros(total_frames,1);
smooth_gfp_back3 = zeros(total_frames,1);
smooth_mcherry_fore3 = zeros(total_frames,1);
smooth_mcherry_back3 = zeros(total_frames,1);


for i = 1:total_frames
    
    if i <= len1 / num_measurements_per_timepoint
        phase_fore1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 5);
        phase_back1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 4);
        gfp_fore1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 3);
        mcherry_fore1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 2);
        gfp_back1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 1);
        mcherry_back1(i) = raw_int_densities1(num_measurements_per_timepoint*i - 0);
    else
        j = i - len1 / num_measurements_per_timepoint;
        
        if j <= len2 / num_measurements_per_timepoint
            phase_fore2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 5);
            phase_back2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 4);
            gfp_fore2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 3);
            mcherry_fore2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 2);
            gfp_back2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 1);
            mcherry_back2(i) = raw_int_densities2(num_measurements_per_timepoint*j - 0);
        end
        if j <= len3 / num_measurements_per_timepoint
            phase_fore3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 5);
            phase_back3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 4);
            gfp_fore3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 3);
            mcherry_fore3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 2);
            gfp_back3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 1);
            mcherry_back3(i) = raw_int_densities3(num_measurements_per_timepoint*j - 0);
        end
    end
end

figure()
hold on
plot(timepoints,phase_fore1,'--k')
plot(timepoints,gfp_fore1,'--g')
plot(timepoints,mcherry_fore1,'--r')
plot(timepoints,phase_fore2,'-k')
plot(timepoints,gfp_fore2,'-g')
plot(timepoints,mcherry_fore2,'-r')
plot(timepoints,phase_fore3,':k')
plot(timepoints,gfp_fore3,':g')
plot(timepoints,mcherry_fore3,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Raw phase','Raw GFP','Raw mCherry')
hold off

figure()
hold on
plot(timepoints,phase_fore1 - phase_back1,'--k')
plot(timepoints,gfp_fore1 - gfp_back1,'--g')
plot(timepoints,mcherry_fore1 - mcherry_back1,'--r')
plot(timepoints,phase_fore2 - phase_back2,'-k')
plot(timepoints,gfp_fore2 - gfp_back2,'-g')
plot(timepoints,mcherry_fore2 - mcherry_back2,'-r')
plot(timepoints,phase_fore3 - phase_back3,':k')
plot(timepoints,gfp_fore3 - gfp_back3,':g')
plot(timepoints,mcherry_fore3 - mcherry_back3,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Corrected phase','Corrected GFP','Corrected mCherry')
hold off

figure()
hold on
plot(timepoints,phase_fore1 - phase_back1,'--k')
plot(timepoints,gfp_fore1 - gfp_back1,'--g')
plot(timepoints,(mcherry_fore1 - mcherry_back1)*2,'--r')
plot(timepoints,phase_fore2 - phase_back2,'-k')
plot(timepoints,gfp_fore2 - gfp_back2,'-g')
plot(timepoints,(mcherry_fore2 - mcherry_back2)*2,'-r')
plot(timepoints,phase_fore3 - phase_back3,':k')
plot(timepoints,gfp_fore3 - gfp_back3,':g')
plot(timepoints,(mcherry_fore3 - mcherry_back3)*2,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Corrected phase','Corrected GFP','Corrected mCherry * 2')
hold off


smooth_num = 13;

smooth_phase_fore1(phase_fore1 > 0) = movmedian(phase_fore1(phase_fore1 > 0),smooth_num);
smooth_phase_back1(phase_back1 > 0) = movmedian(phase_back1(phase_back1 > 0),smooth_num);
smooth_gfp_fore1(gfp_fore1 > 0) = movmedian(gfp_fore1(gfp_fore1 > 0),smooth_num);
smooth_gfp_back1(gfp_fore1 > 0) = movmedian(gfp_back1(gfp_fore1 > 0),smooth_num);
smooth_mcherry_fore1(mcherry_fore1 > 0) = movmedian(mcherry_fore1(mcherry_fore1 > 0),smooth_num);
smooth_mcherry_back1(mcherry_fore1 > 0) = movmedian(mcherry_back1(mcherry_fore1 > 0),smooth_num);

smooth_phase_fore2(phase_fore2 > 0) = movmedian(phase_fore2(phase_fore2 > 0),smooth_num);
smooth_phase_back2(phase_back2 > 0) = movmedian(phase_back2(phase_back2 > 0),smooth_num);
smooth_gfp_fore2(gfp_fore2 > 0) = movmedian(gfp_fore2(gfp_fore2 > 0),smooth_num);
smooth_gfp_back2(gfp_back2 > 0) = movmedian(gfp_back2(gfp_back2 > 0),smooth_num);
smooth_mcherry_fore2(mcherry_fore2 > 0) = movmedian(mcherry_fore2(mcherry_fore2 > 0),smooth_num);
smooth_mcherry_back2(mcherry_back2 > 0) = movmedian(mcherry_back2(mcherry_back2 > 0),smooth_num);

smooth_phase_fore3(phase_fore3 > 0) = movmedian(phase_fore3(phase_fore3 > 0),smooth_num);
smooth_phase_back3(phase_back3 > 0) = movmedian(phase_back3(phase_back3 > 0),smooth_num);
smooth_gfp_fore3(gfp_fore3 > 0) = movmedian(gfp_fore3(gfp_fore3 > 0),smooth_num);
smooth_gfp_back3(gfp_back3 > 0) = movmedian(gfp_back3(gfp_back3 > 0),smooth_num);
smooth_mcherry_fore3(mcherry_fore3 > 0) = movmedian(mcherry_fore3(mcherry_fore3 > 0),smooth_num);
smooth_mcherry_back3(mcherry_back3 > 0) = movmedian(mcherry_back3(mcherry_back3 > 0),smooth_num);

figure()
hold on
plot(timepoints,smooth_phase_fore1,'--k')
plot(timepoints,smooth_gfp_fore1,'--g')
plot(timepoints,smooth_mcherry_fore1,'--r')
plot(timepoints,smooth_phase_fore2,'-k')
plot(timepoints,smooth_gfp_fore2,'-g')
plot(timepoints,smooth_mcherry_fore2,'-r')
plot(timepoints,smooth_phase_fore3,':k')
plot(timepoints,smooth_gfp_fore3,':g')
plot(timepoints,smooth_mcherry_fore3,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Raw phase','Raw GFP','Raw mCherry')
hold off

figure()
hold on
plot(timepoints,smooth_phase_fore1 - smooth_phase_back1,'--k')
plot(timepoints,smooth_gfp_fore1 - smooth_gfp_back1,'--g')
plot(timepoints,smooth_mcherry_fore1 - smooth_mcherry_back1,'--r')
plot(timepoints,smooth_phase_fore2 - smooth_phase_back2,'-k')
plot(timepoints,smooth_gfp_fore2 - smooth_gfp_back2,'-g')
plot(timepoints,smooth_mcherry_fore2 - smooth_mcherry_back2,'-r')
plot(timepoints,smooth_phase_fore3 - smooth_phase_back3,':k')
plot(timepoints,smooth_gfp_fore3 - smooth_gfp_back3,':g')
plot(timepoints,smooth_mcherry_fore3 - smooth_mcherry_back3,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Corrected phase','Corrected GFP','Corrected mCherry')
hold off

figure()
hold on
plot(timepoints,smooth_phase_fore1 - smooth_phase_back1,'--k')
plot(timepoints,smooth_gfp_fore1 - smooth_gfp_back1,'--g')
plot(timepoints,(smooth_mcherry_fore1 - smooth_mcherry_back1)*2,'--r')
plot(timepoints,smooth_phase_fore2 - smooth_phase_back2,'-k')
plot(timepoints,smooth_gfp_fore2 - smooth_gfp_back2,'-g')
plot(timepoints,(smooth_mcherry_fore2 - smooth_mcherry_back2)*2,'-r')
plot(timepoints,smooth_phase_fore3 - smooth_phase_back3,':k')
plot(timepoints,smooth_gfp_fore3 - smooth_gfp_back3,':g')
plot(timepoints,(smooth_mcherry_fore3 - smooth_mcherry_back3)*2,':r')
xlabel('Time (h)')
ylabel('Integrated intensity (AU)')
legend('Corrected phase','Corrected GFP','Corrected mCherry * 2')
hold off

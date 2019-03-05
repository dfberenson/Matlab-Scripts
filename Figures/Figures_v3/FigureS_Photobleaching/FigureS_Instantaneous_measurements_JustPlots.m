
clear all
close all

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\mCherry_slopes_over_time.mat')

figure
box on
hold on
shadedErrorBar((5:length(slopes_by_age)+4)*framerate, movmedian(slopes_by_age,13),movmedian(slope_errors_by_age,13))
axis([0 inf 0 inf],'square')
xlabel('Cell age (h)')
ylabel('Slope of prEF1-mCherry-NLS vs nuclear volume')
fitlm(1:length(slopes_by_age),slopes_by_age,'Weights',num_cells_by_age)

figure
box on
hold on
shadedErrorBar((5:length(r2_vals_by_age)+4)*framerate,movmedian(r2_vals_by_age,13),movmedian(r2_errors_by_age,13))
axis([0 inf 0 1],'square')
xlabel('Cell age (h)')
ylabel('R^2 value for prEF1a-mCherry-NLS vs nuclear volume')
fitlm(1:length(r2_vals_by_age),r2_vals_by_age,'Weights',num_cells_by_age)

load('C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\mCrimson_slopes_over_time.mat')

figure
box on
hold on
shadedErrorBar((5:length(slopes_by_age)+4)*framerate, movmedian(slopes_by_age,13),movmedian(slope_errors_by_age,13))
axis([0 inf -inf inf],'square')
xlabel('Cell age (h)')
ylabel('Slope of prEF1-mCrimson-NLS vs nuclear volume')
fitlm(1:length(slopes_by_age),slopes_by_age,'Weights',num_cells_by_age)

figure
box on
hold on
shadedErrorBar((5:length(r2_vals_by_age)+4)*framerate,movmedian(r2_vals_by_age,13),movmedian(r2_errors_by_age,13))
axis([0 inf 0 1],'square')
xlabel('Cell age (h)')
ylabel('R^2 value for prEF1a-mCrimson-NLS vs nuclear volume')
fitlm(1:length(r2_vals_by_age),r2_vals_by_age,'Weights',num_cells_by_age)

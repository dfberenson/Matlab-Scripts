
clear all
close all

folder = "C:\Users\Skotheim Lab\Box Sync\Daniel Berenson's Files\Data\Coulter";
fname = 'DFB_181021_HMEC_1GFiii';
fpath = strcat(folder, "\", fname, "\", fname, ".xlsx");
T = readtable(fpath);

var_names = T.Properties.VariableNames;
diam_cutoff = 12;

for var = var_names
    
    switch var{1}
        case 'Bin_Diam'
            bin_diams = T.Bin_Diam;
        case 'Incubator_0h'
            sizes_incubator_0h = convert_CoulterData(bin_diams, T.Incubator_0h, diam_cutoff);
            mean_incubator_0h = mean(sizes_incubator_0h);
            median_incubator_0h = median(sizes_incubator_0h);
            first_quartile_incubator_0h = quantile(sizes_incubator_0h, 0.25);
            third_quartile_incubator_0h = quantile(sizes_incubator_0h, 0.75);
            stdevs_incubator_0h = std(sizes_incubator_0h);
            stderrs_incubator_0h = stdevs_incubator_0h / sqrt(length(sizes_incubator_0h));
        case 'Incubator_48h'
            sizes_incubator_48h = convert_CoulterData(bin_diams, T.Incubator_48h, diam_cutoff);
            mean_incubator_48h = mean(sizes_incubator_48h);
            median_incubator_48h = median(sizes_incubator_48h);
            first_quartile_incubator_48h = quantile(sizes_incubator_48h, 0.25);
            third_quartile_incubator_48h = quantile(sizes_incubator_48h, 0.75);
            stdevs_incubator_48h = std(sizes_incubator_48h);
            stderrs_incubator_48h = stdevs_incubator_48h / sqrt(length(sizes_incubator_48h));
        case 'Microscope_ConstantIllumination'
            sizes_constantillumination = convert_CoulterData(bin_diams, T.Microscope_ConstantIllumination, diam_cutoff);
            mean_constantillumination = mean(sizes_constantillumination);
            median_constantillumination = median(sizes_constantillumination);
            first_quartile_constantillumination = quantile(sizes_constantillumination, 0.25);
            third_quartile_constantillumination = quantile(sizes_constantillumination, 0.75);
            stdevs_constantillumination = std(sizes_constantillumination);
            stderrs_constantillumination = stdevs_constantillumination / sqrt(length(sizes_constantillumination));
        case 'Microscope_IntermittentIllumination'
            sizes_intermittentillumination = convert_CoulterData(bin_diams, T.Microscope_IntermittentIllumination, diam_cutoff);
            mean_intermittentillumination = mean(sizes_intermittentillumination);
            median_intermittentillumination = median(sizes_intermittentillumination);
            first_quartile_intermittentillumination = quantile(sizes_intermittentillumination, 0.25);
            third_quartile_intermittentillumination = quantile(sizes_intermittentillumination, 0.75);
            stdevs_intermittentillumination = std(sizes_intermittentillumination);
            stderrs_intermittentillumination = stdevs_intermittentillumination / sqrt(length(sizes_intermittentillumination));
        case 'Microscope_NoIllumination'
            sizes_noillumination = convert_CoulterData(bin_diams, T.Microscope_NoIllumination, diam_cutoff);
            mean_noillumination = mean(sizes_noillumination);
            median_noillumination = median(sizes_noillumination);
            first_quartile_noillumination = quantile(sizes_noillumination, 0.25);
            third_quartile_noillumination = quantile(sizes_noillumination, 0.75);
            stdevs_noillumination = std(sizes_noillumination);
            stderrs_noillumination = stdevs_noillumination / sqrt(length(sizes_noillumination));
    end
end

disp(['Percent decrease in median size after incubator: ' num2str(1 - median_incubator_48h / median_incubator_0h)])
disp(['Percent decrease in median size after constant exposure on microscope: ' num2str(1 - median_constantillumination / median_incubator_0h)])
disp(['Percent decrease in median size after intermittent exposure on microscope: ' num2str(1 - median_intermittentillumination / median_incubator_0h)])
disp(['Percent decrease in median size after no exposure on microscope: ' num2str(1 - median_noillumination / median_incubator_0h)])


figure
hold on
cdfplot(sizes_incubator_0h)
cdfplot(sizes_incubator_48h)
cdfplot(sizes_constantillumination)
cdfplot(sizes_intermittentillumination)
cdfplot(sizes_noillumination)
legend({'Incubator_0h','Incubator_48h','Microscope_Constant','Microscope_Intermittent','Microscope_Dark'},'Interpreter','none')
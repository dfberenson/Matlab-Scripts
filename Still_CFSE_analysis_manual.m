
folder = 'E:\DFB_imaging_experiments';
base_expt_name = 'DFB_180903_HMEC_1G_CFSE_2';
expt_folder = [folder '\' base_expt_name];
xlsx_fpath = [expt_folder '\Manual_Measurements.xlsx'];

tabl = readtable(xlsx_fpath);

areas = tabl{:,'Area'};
int_den = tabl{:,'IntDen'};

num_cells = length(areas)/4;

for i = 1:num_cells
    cfse_areas(i) = areas(i*4-3);
    mcherry_areas(i) = areas(i*4-1);
    
    cfse_int_den(i) = int_den(i*4-3) - int_den(i*4-2);
    mcherry_int_den(i) = int_den(i*4-1) - int_den(i*4-0);
end

plot_scatter_with_line(mcherry_int_den,cfse_int_den);
plot_scatter_with_line(mcherry_areas,cfse_int_den);

plot_scatter_with_line(mcherry_int_den,cfse_int_den,'no_intercept');
plot_scatter_with_line(mcherry_areas,cfse_int_den,'no_intercept');
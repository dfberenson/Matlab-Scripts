
folder = 'E:\DFB_imaging_experiments';
base_expt_name = 'DFB_180903_HMEC_1G_CFSE_2';
base_expt_name = 'DFB_180905_HMEC_1G_CFSE_1';
expt_folder = [folder '\' base_expt_name];
xlsx_fpath = [expt_folder '\Manual_Measurements.xlsx'];

positions_list = [3 4];
for pos = positions_list
    tabl = readtable(xlsx_fpath, 'Sheet', ['Pos' num2str(pos)]);
    
    areas = tabl{:,'Area'};
    int_den = tabl{:,'IntDen'};
    
    num_cells = length(areas)/4;
    
    for i = 1:num_cells
        data(pos).cfse_areas(i) = areas(i*4-3);
        data(pos).mcherry_areas(i) = areas(i*4-1);
        
        data(pos).cfse_int_den(i) = int_den(i*4-3) - int_den(i*4-2);
        data(pos).mcherry_int_den(i) = int_den(i*4-1) - int_den(i*4-0);
    end
end

all_cfse_areas = [];
all_mcherry_areas = [];
all_cfse_int_den = [];
all_mcherry_int_den = [];

for pos = positions_list
    all_cfse_areas = [all_cfse_areas, data(pos).cfse_areas];
    all_mcherry_areas = [all_mcherry_areas, data(pos).mcherry_areas];
    all_cfse_int_den = [all_cfse_int_den, data(pos).cfse_int_den];
    all_mcherry_int_den = [all_mcherry_int_den, data(pos).mcherry_int_den];
end


plot_scatter_with_line(all_mcherry_int_den,all_cfse_int_den);
xlabel('mCherry integrated density (AU)')
ylabel('CFSE integrated density (AU')
title('Any intercept')
plot_scatter_with_line(all_mcherry_areas,all_cfse_int_den);
xlabel('Nuclear area (px2)')
ylabel('CFSE integrated density (AU)')
title('Any intercept')


plot_scatter_with_line(all_mcherry_int_den,all_cfse_int_den,'no_intercept');
xlabel('mCherry integrated density (AU)')
ylabel('CFSE integrated density (AU)')
title('Enforced intercept = 0')

plot_scatter_with_line(all_mcherry_areas,all_cfse_int_den,'no_intercept');
xlabel('Nuclear area (px2)')
ylabel('CFSE integrated density (AU)')
title('Enforced intercept = 0')


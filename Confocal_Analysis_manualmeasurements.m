
clear all
close all

%% Initialze variables
im_folder = ['E:\Confocal'];
% expt_name = '08-30-2018 HMECs D5 confocal';
expt_name = '10-30-2018 HMECs D5 confocal';
plot_all_correlations_independently = false;

positions_to_analyze = [2 3 5 6 7];
alphabet = 'abcdefghijklmnopqrstuvwxyz';

for pos = positions_to_analyze
    switch pos
        case 2
            num_cells_to_analyze = 3;
        case 3
num_cells_to_analyze = 4;
        case 5
num_cells_to_analyze = 7;
        case 6
num_cells_to_analyze = 5;
        case 7
num_cells_to_analyze = 5;
            
    end
    for cell = 1:num_cells_to_analyze
        cell_letter = alphabet(cell);
        epi_table = readtable([im_folder '\' expt_name '\ManualMeasurements.xlsx'],'Sheet',[num2str(pos) cell_letter '-epi']);
        cfc_table = readtable([im_folder '\' expt_name '\ManualMeasurements.xlsx'],'Sheet',[num2str(pos) cell_letter '-confocal']);
        
        position(pos).epi_measurements(cell).area = epi_table.Area(1);
        position(pos).epi_measurements(cell).ef1a_mean = epi_table.Mean(1) - epi_table.Mean(4);
        position(pos).epi_measurements(cell).ef1a_int_intens = position(pos).epi_measurements(cell).area * position(pos).epi_measurements(cell).ef1a_mean;
        position(pos).epi_measurements(cell).geminin_mean = epi_table.Mean(2) - epi_table.Mean(5);
        position(pos).epi_measurements(cell).geminin_int_intens = position(pos).epi_measurements(cell).area * position(pos).epi_measurements(cell).geminin_mean;
        position(pos).epi_measurements(cell).rb_mean = epi_table.Mean(3) - epi_table.Mean(5);
        position(pos).epi_measurements(cell).rb_int_intens = position(pos).epi_measurements(cell).area * position(pos).epi_measurements(cell).rb_mean;
        
    end
end

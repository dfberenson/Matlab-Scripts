
clear all
close all

% expt = 1;
% load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')
% all_conditions = [1 2];

% expt = 2;
% load('E:\Aivia\DFB_180829_HMEC_D5_1\aivia_Data.mat')
% all_conditions = [1 2 3];

% expt = 3;
% load('E:\Aivia\DFB_181108_HMEC_D5_palbo_1\aivia_Data.mat')
% all_conditions = [1 2];


for cond = all_conditions
    
    clear logdata
    
    if cond == 1
        if exist('C:\Users\Skotheim Lab\Desktop\Tables\LogData_PBS.mat')
            load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_PBS.mat')
        end
    elseif cond == 2 || cond == 3
        if (expt == 1 || expt == 2) && cond == 2
            if exist('C:\Users\Skotheim Lab\Desktop\Tables\LogData_40-50nM_palbo.mat')
                load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_40-50nM_palbo.mat');
            end
        else
            
            if exist('C:\Users\Skotheim Lab\Desktop\Tables\LogData_100nM_palbo.mat')
                load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_100nM_palbo.mat')
            end
        end
    end
    
    % Save full traces for cells that pass G1/S
    logdata(expt).all_frame_indices_full_wrt_trace_start = data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_trace_start;
    logdata(expt).all_frame_indices_full_wrt_g1s = data(cond).all_individual_pass_g1s_traces_frame_indices_wrt_g1s;
    logdata(expt).all_geminins_full = data(cond).all_individual_pass_g1s_traces_geminin;
    logdata(expt).all_sizes_full = data(cond).all_individual_pass_g1s_traces_sizes;
    logdata(expt).all_volumes_full = data(cond).all_individual_pass_g1s_traces_volumes;
    logdata(expt).all_rb_amts_full = data(cond).all_individual_pass_g1s_traces_protein_amts;
    logdata(expt).all_rb_per_size_full = data(cond).all_individual_pass_g1s_traces_protein_per_size;
    logdata(expt).all_rb_per_volume_full = data(cond).all_individual_pass_g1s_traces_protein_per_volume;
    
    
    % Save data up to G1/S for cells that pass G1/S
    logdata(expt).all_frame_indices_up_to_g1s_wrt_g1s = data(cond).all_frame_indices_wrt_g1s_thisframe;
    logdata(expt).all_areas_up_to_g1s = data(cond).all_areas_up_to_g1s_thisframe;
    logdata(expt).all_sizes_up_to_g1s = data(cond).all_sizes_up_to_g1s_thisframe;
    logdata(expt).all_volumes_up_to_g1s = data(cond).all_volumes_up_to_g1s_thisframe;
    logdata(expt).all_geminins_up_to_g1s = data(cond).all_geminins_up_to_g1s_thisframe;
    logdata(expt).all_rb_amts_up_to_g1s = data(cond).all_protein_amts_up_to_g1s_thisframe;
    logdata(expt).all_rb_up_to_g1s = data(cond).all_protein_amts_up_to_g1s_thisframe;
    logdata(expt).all_rb_per_area_up_to_g1s = data(cond).all_protein_per_area_up_to_g1s_thisframe;
    logdata(expt).all_rb_per_size_up_to_g1s = data(cond).all_protein_per_size_up_to_g1s_thisframe;
    logdata(expt).all_rb_per_volume_up_to_g1s = data(cond).all_protein_per_volume_up_to_g1s_thisframe;
    logdata(expt).all_g1s_happens_here = data(cond).all_g1s_happens_here_thisframe;
    
    % Save data up to G1/S for cells that are born and pass G1/S
    logdata(expt).all_ages_in_hours_up_to_g1s_for_born_cells = data(cond).all_ages_in_hours_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_g1s_happens_here_for_born_cells = data(cond).all_g1s_happens_here_for_born_cells_thisframe;
    logdata(expt).all_areas_up_to_g1s_for_born_cells = data(cond).all_areas_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_sizes_up_to_g1s_for_born_cells =  data(cond).all_sizes_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_volumes_up_to_g1s_for_born_cells = data(cond).all_volumes_up_to_g1s_for_born_cells_thisframe;
    % logdata(expt).all_rb_amts_up_to_g1s_for_born_cells = data(cond).all_protein_amts_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_rb_per_area_up_to_g1s_for_born_cells = data(cond).all_protein_per_area_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_rb_per_size_up_to_g1s_for_born_cells = data(cond).all_protein_per_size_up_to_g1s_for_born_cells_thisframe;
    logdata(expt).all_rb_per_volume_up_to_g1s_for_born_cells = data(cond).all_protein_per_volume_up_to_g1s_for_born_cells_thisframe;
    
    % Frame indices up to G1/S wrt G1/S were not previously recorded for born cells,
    % so have to calculate them here.
    logdata(expt).all_frame_indices_up_to_g1s_wrt_g1s_for_born_cells = zeros(length(logdata(expt).all_ages_in_hours_up_to_g1s_for_born_cells),1);
    relative_frame_index = 0;
    for i = length(logdata(expt).all_g1s_happens_here_for_born_cells) : -1 : 1
        if logdata(expt).all_g1s_happens_here_for_born_cells(i) == 1
            relative_frame_index = 0;
        else
            relative_frame_index = relative_frame_index - 1;
        end
        logdata(expt).all_frame_indices_up_to_g1s_wrt_g1s_for_born_cells(i) = relative_frame_index;
    end
    
    if cond == 1
        save('C:\Users\Skotheim Lab\Desktop\Tables\LogData_PBS.mat','logdata')
    elseif cond == 2 || cond == 3
        if (expt == 1 || expt == 2) && cond == 2
            save('C:\Users\Skotheim Lab\Desktop\Tables\LogData_40-50nM_palbo.mat','logdata')
        else
            save('C:\Users\Skotheim Lab\Desktop\Tables\LogData_100nM_palbo.mat','logdata')
        end
    end
        
end
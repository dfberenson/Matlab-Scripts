
%USES SAVEDDATASTRUCT TO ORGANIZE DATA - MAKE SURE FROM SAME EXPT

foldername = 'F:\DFB_imaging_experiments\DFB_170907_HMEC_1GFiii_palbo_after_1\DFB_170907_HMEC_1GFiii_palbo_after Analysis';
fname_manualbirthsizes = ['DFB_170907_HMEC_1GFiii_palbo_After manually measured Frame10'];
fname_manualG1Ssizes = ['DFB_170907_HMEC_1GFiii_palbo_After manually measured FrameG1S'];
fname_manualMsizes = ['DFB_170907_HMEC_1GFiii_palbo_After manually measured FrameM'];
fpath_manualbirthsizes = [foldername '/' fname_manualbirthsizes '.xlsx'];
fpath_manualG1Ssizes = [foldername '/' fname_manualG1Ssizes '.xlsx'];
fpath_manualMsizes = [foldername '/' fname_manualMsizes '.xlsx'];

%Use the commented code, or copy-paste AncestorCells and DescendantCells
%from spreadsheet into the variable names
% struct = SavedDataStruct;
% ancestorcells = struct.ancestorcellnum_array;
% descendantcells = struct.descendantcellnum_array;

manualbirthsizes = zeros(length(ancestorcells),1);
manualbirthareas = zeros(length(ancestorcells),1);
manualG1Ssizes = zeros(length(ancestorcells),1);
manualG1Sareas = zeros(length(ancestorcells),1);
manualMsizes = zeros(length(ancestorcells),1);
manualMareas = zeros(length(ancestorcells),1);

for i = 1:length(ancestorcells)
    sheetname = [num2str(ancestorcells(i)) '-' num2str(descendantcells(i))];
    
    birth_table = readtable(fpath_manualbirthsizes, 'Sheet', sheetname, 'ReadVariableNames' , false);
    if (size(birth_table) ~= [0 0])
        img_fluor = (birth_table{1,10} + birth_table{3,10} + birth_table{5,10})/3;
        img_bckgd = (birth_table{2,10} + birth_table{4,10} + birth_table{6,10})/3;
        img_net = img_fluor - img_bckgd;
        manualbirthsizes(i) = img_net;
        manualbirthareas(i) = (birth_table{1,2} + birth_table{3,2} + birth_table{5,2})/3;
        if manualbirthareas(i) > 1
            manualbirthareas(i) = manualbirthareas(i) * 0.00000233^2;
            %Convert image scale from 1 um to 0.00000233 um
        end
    end
    
    G1S_table = readtable(fpath_manualG1Ssizes, 'Sheet', sheetname, 'ReadVariableNames' , false);
    if (size(G1S_table) ~= [0 0])
        img_fluor = (G1S_table{1,10} + G1S_table{3,10} + G1S_table{5,10})/3;
        img_bckgd = (G1S_table{2,10} + G1S_table{4,10} + G1S_table{6,10})/3;
        img_net = img_fluor - img_bckgd;
        manualG1Ssizes(i) = img_net;
        manualG1Sareas(i) = (G1S_table{1,2} + G1S_table{3,2} + G1S_table{5,2})/3;
        if manualG1Sareas(i) > 1
            manualG1Sareas(i) = manualG1Sareas(i) * 0.00000233^2;
            %Convert image scale from 1 um to 0.00000233 um
        end
    end
    
    M_table = readtable(fpath_manualMsizes, 'Sheet', sheetname, 'ReadVariableNames' , false);
    if (size(M_table) ~= [0 0])
        img_fluor = (M_table{1,10} + M_table{3,10} + M_table{5,10})/3;
        img_bckgd = (M_table{2,10} + M_table{4,10} + M_table{6,10})/3;
        img_net = img_fluor - img_bckgd;
        manualMsizes(i) = img_net;
        manualMareas(i) = (M_table{1,2} + M_table{3,2} + M_table{5,2})/3;
        if manualMareas(i) > 1
            manualMareas(i) = manualMareas(i) * 0.00000233^2;
            %Convert image scale from 1 um to 0.00000233 um
        end
    end
end
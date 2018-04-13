
close all

folder = "C:\Users\Skotheim Lab\Box Sync\Daniel Berenson's Files\Data\Coulter";
fname = "DFB_1803-04_HMEC_1GFiii_all";

fpath = strcat(folder, "\", fname, ".xlsx");

tab = readtable(fpath);

date{1} = '180316';
date{2} = '180326';
date{3} = '180405';

cond_name{1} = 'MinusEGF_MinusPalbo';
cond_name{2} = 'MinusEGF_PlusPalbo';
cond_name{3} = 'PlusEGF_MinusPalbo';
cond_name{4} = 'PlusEGF_PlusPalbo';

unique_dates = 3;
unique_conditions = 4;

for i = 1:unique_dates
    binsizes = tab{:,['Bins_' date{i}]};
    for j = 1:unique_conditions
        expt(i,j).Date = date{i};
        expt(i,j).Condition = cond_name{j};
        expt(i,j).Binsizes = binsizes;
        expt(i,j).Counts = tab{:,['Counts_' date{i} '_' cond_name{j}]};
        expt(i,j).FullData = convert_CoulterData(expt(i,j).Binsizes, expt(i,j).Counts);
        %         figure,histogram(expt(run).FullData);
    end
end

for i = 1:unique_dates
    figure('Name',['Expt_' date{i}])
    hold on
    for j = 1:unique_conditions
        cdfplot(expt(i,j).FullData);
    end
    legend({cond_name{:}}, 'Interpreter','none','Location','SE')
    xlabel('Size (fL)')
    ylabel('Cumulative probability')
    hold off
    
    
    figure('Name',['Expt_' date{i}])
    hold on
    for j = 1:unique_conditions
        histogram(expt(i,j).FullData);
    end
    legend({cond_name{:}}, 'Interpreter','none','Location','SE')
    xlabel('Size (fL)')
    ylabel('Count')
    hold off
    
end
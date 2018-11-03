
clear all
close all

folder = "C:\Users\Skotheim Lab\Box Sync\Daniel Berenson's Files\Data\Coulter";
% fname = "DFB_1803-04_HMEC_1GFiii_all";
% 
% fpath = strcat(folder, "\", fname, ".xlsx");
% 
% tab = readtable(fpath);
% 
% date{1} = '180316';
% date{2} = '180326';
% date{3} = '180405';
% 
% cond_name{1} = 'MinusEGF_MinusPalbo';
% cond_name{2} = 'MinusEGF_PlusPalbo';
% cond_name{3} = 'PlusEGF_MinusPalbo';
% cond_name{4} = 'PlusEGF_PlusPalbo';

fname = 'DFB_160509_T98G_timecourse';
fpath = strcat(folder, "\", fname, ".xlsx");
tab = readtable(fpath);
date{1} = 'Volumes_pL';

cond_name{1} = 'Starved_2days';
cond_name{2} = 'Asynchronous';
cond_name{3} = 'Released_0hr';
cond_name{4} = 'Released_3hr';
cond_name{5} = 'Released_6hr';
cond_name{6} = 'Released_8hr';
cond_name{7} = 'Released_10hr';
cond_name{8} = 'Released_12hr';
cond_name{9} = 'Released_16hr';
cond_name{10} = 'Released_24hr';
timepoints = [0 3 6 8 10 12 16 24];

unique_dates = 1;
unique_conditions = 10;

for i = 1:unique_dates
    binsizes = tab{:,['Bins_' date{i}]};
    for j = 1:unique_conditions
        expt(i,j).Date = date{i};
        expt(i,j).Condition = cond_name{j};
        expt(i,j).Binsizes = binsizes;
        %         expt(i,j).Counts = tab{:,['Counts_' date{i} '_' cond_name{j}]};
        expt(i,j).Counts = tab{:,['Counts_' cond_name{j}]};
        expt(i,j).FullData = convert_CoulterData(expt(i,j).Binsizes, expt(i,j).Counts, 0.9);
        %         figure,histogram(expt(run).FullData);
        means(i,j) = mean(expt(i,j).FullData);
        medians(i,j) = median(expt(i,j).FullData);
        first_quartile(i,j) = quantile(expt(i,j).FullData, 0.25);
        third_quartile(i,j) = quantile(expt(i,j).FullData, 0.75);
        stdevs(i,j) = std(expt(i,j).FullData);
        stderrs(i,j) = stdevs(i,j) / length(expt(i,j).FullData);
    end

end

for i = 1:unique_dates
    figure('Name',['Expt_' date{i}])
    hold on
    for j = 1:unique_conditions
        cdfplot(expt(i,j).FullData);
    end
    legend({cond_name{:}}, 'Interpreter','none','Location','SE')
    xlabel('Size (pL)')
    ylabel('Cumulative probability')
    hold off
    
    
    figure('Name',['Expt_' date{i}])
    hold on
    for j = 1:unique_conditions
        histogram(expt(i,j).FullData);
    end
    legend({cond_name{:}}, 'Interpreter','none','Location','SE')
    xlabel('Size (pL)')
    ylabel('Count')
    hold off
     
end

figure()
hold on
errorbar(timepoints,medians(3:10),medians(3:10)-first_quartile(3:10),third_quartile(3:10)-medians(3:10),...
    '-k','LineWidth',2)
ln = line([-1 25],[medians(2) medians(2)],'LineWidth',third_quartile(2)-first_quartile(2),'Color',[0 0 0 0.5]);
dim = [.2 .2 .3 .3];
str = 'Asynchronous';
text(0, 60, str)
axis([-1 25 -inf inf])
xlabel('Time since serum addition (h)')
ylabel('Cell size (pL)')
title('Median and quartile cell size, meausured by Coulter counter')
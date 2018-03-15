

folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\Plots\DFB_170308_HMEC_1Giii_1';
file = '170308_Single cell traces';

tbl = readtable([folder '/' file '.xlsx'], 'Sheet', 'AllCells');

num_mothers = 4;
framerate_per_hour = 12;

hold on

for i = 1:num_mothers
    for d = ['A','B']
        mCherry = table2array(tbl(:,['Cell' num2str(i) d 'Red']));
        mCherry = mCherry(mCherry > -1000000);
        plot([1/framerate_per_hour:1/framerate_per_hour:length(mCherry)/framerate_per_hour], mCherry)        
    end
end

xlabel('Cell age (h)')
ylabel('mCherry size reporter')

clear all
close all

load('E:\Manually tracked measurements\DFB_180803_HMEC_D5_1\clicking_Data.mat')


for cond = 1:2
%     
    birth_sizes_born_and_pass_g1s = data(cond).birth_sizes_cells_born_and_pass_g1s;
    g1_lengths_born_and_pass_g1s = data(cond).g1_lengths_cells_born_and_pass_g1s;
    g1s_sizes_born_and_pass_g1s = data(cond).g1s_sizes_cells_born_and_pass_g1s;
%     
%             birth_sizes_born_and_pass_g1s = data(cond).half_of_mother_premitotic_size;
%             g1_lengths_born_and_pass_g1s = data(cond).g1_lengths_cells_born_and_pass_g1s_and_have_calculated_half_of_mother_premitotic_size;
%             g1s_sizes_born_and_pass_g1s = data(cond).g1s_sizes_cells_born_and_pass_g1s_and_have_calculated_half_of_mother_premitotic_size;
%     
    g1_growths_born_and_pass_g1s = g1s_sizes_born_and_pass_g1s - birth_sizes_born_and_pass_g1s;
    
    g1s_sizes_divide = data(cond).g1s_sizes_for_cells_that_divide;
    g2m_sizes_divide = data(cond).g2m_sizes_for_cells_that_divide;
    sg2_lengths_divide = data(cond).sg2_lengths_for_cells_that_divide;
    sg2_growths_divide = g2m_sizes_divide - g1s_sizes_divide;
    
    birth_sizes_bins = linspace(min(birth_sizes_born_and_pass_g1s),max(birth_sizes_born_and_pass_g1s),10);
    g1s_sizes_bins = linspace(min(g1s_sizes_divide), max(g1s_sizes_divide), 10);
    
    % figure
    % hold on
    % scatter(birth_sizes_born_and_pass_g1s, g1_lengths_born_and_pass_g1s,5,'k','MarkerFaceColor','k')
    % [means,stdevs,~] = bindata(birth_sizes_born_and_pass_g1s, g1_lengths_born_and_pass_g1s, birth_sizes_bins);
    % errorbar(birth_sizes_bins,means,stdevs,'k','LineWidth',2)
    % xlabel('prEF1a-mCrimson-NLS at birth')
    % ylabel('G1 length (h)')
    % legend('G1 length','Location','NE')
    % hold off
    
    figure
    hold on
    scatter(birth_sizes_born_and_pass_g1s, g1s_sizes_born_and_pass_g1s,5,'k','MarkerFaceColor','k')
    scatter(birth_sizes_born_and_pass_g1s, g1_growths_born_and_pass_g1s,5,'r','MarkerFaceColor','r')
    [means,stdevs,stderrs] = bindata(birth_sizes_born_and_pass_g1s, g1s_sizes_born_and_pass_g1s, birth_sizes_bins);
%         errorbar(birth_sizes_bins,means,stdevs,'k','LineWidth',2)
    errorbar(birth_sizes_bins,means,stderrs,'k','LineWidth',2)
    [means,stdevs,stderrs] = bindata(birth_sizes_born_and_pass_g1s, g1_growths_born_and_pass_g1s, birth_sizes_bins);
%         errorbar(birth_sizes_bins,means,stdevs,'r','LineWidth',2)
    errorbar(birth_sizes_bins,means,stderrs,'r','LineWidth',2)
    xlabel('prEF1a-mCrimson-NLS at birth')
    ylabel('prEF1a-mCrimson-NLS')
    legend('Size at G1/S','Growth during G1','Location','NE')
    title(data(cond).treatment)
    hold off
    
    figure
    hold on
    scatter(g1s_sizes_divide, g2m_sizes_divide,5,'k','MarkerFaceColor','k')
    scatter(g1s_sizes_divide, sg2_growths_divide,5,'r','MarkerFaceColor','r')
    [means,stdevs,stderrs] = bindata(g1s_sizes_divide, g2m_sizes_divide, g1s_sizes_bins);
%         errorbar(g1s_sizes_bins,means,stdevs,'k','LineWidth',2)
    errorbar(g1s_sizes_bins,means,stderrs,'k','LineWidth',2)
    [means,stdevs,stderrs] = bindata(g1s_sizes_divide, sg2_growths_divide, g1s_sizes_bins);
%         errorbar(g1s_sizes_bins,means,stdevs,'r','LineWidth',2)
    errorbar(g1s_sizes_bins,means,stderrs,'r','LineWidth',2)
    xlabel('prEF1a-mCrimson-NLS at G1/S')
    ylabel('prEF1a-mCrimson-NLS')
    legend('Size at G2/M','Growth during SG2','Location','NW')
    title(data(cond).treatment)
    hold off
    
    figure
    hold on
    scatter(birth_sizes_born_and_pass_g1s, g1_lengths_born_and_pass_g1s,5,'r','MarkerFaceColor','r')
    scatter(g1s_sizes_divide, sg2_lengths_divide,5,'g','MarkerFaceColor','g')
    fitlm(birth_sizes_born_and_pass_g1s, g1_lengths_born_and_pass_g1s)
    fitlm(g1s_sizes_divide, sg2_lengths_divide)
    [means,stdevs,stderrs] = bindata(birth_sizes_born_and_pass_g1s, g1_lengths_born_and_pass_g1s, birth_sizes_bins);
    errorbar(birth_sizes_bins,means,stderrs,'r','LineWidth',2)
    [means,stdevs,stderrs] = bindata(g1s_sizes_divide, sg2_lengths_divide, g1s_sizes_bins);
    errorbar(g1s_sizes_bins,means,stderrs,'g','LineWidth',2)
    axis([0 inf 0 35])
    xlabel('prEF1a-mCrimson-NLS at phase start')
    ylabel('Time (h)')
    legend('G1','SG2')
    title(data(cond).treatment)
    hold off
    
end
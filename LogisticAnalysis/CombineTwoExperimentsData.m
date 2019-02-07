

close all
clear all

% load('C:\Users\Skotheim Lab\Desktop\Tables\LogData.mat')
% load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_PBS.mat')
load('C:\Users\Skotheim Lab\Desktop\Tables\LogData_100nM_palbo.mat')


exptnums = 1:2;
hours_to_check = 2;

for hours = hours_to_check
    %     figure(4*hours-3)
    %     hold on
    %     box on
    %     figure(4*hours-2)
    %     hold on
    %     box on
    %     figure(4*hours-1)
    %     hold on
    %     box on
    
    for expt = exptnums
        if hours == 0
            sizes{hours,expt} = logdata(expt).all_sizes_up_to_g1s_thisframe;
            rb_per_size{hours,expt} = logdata(expt).all_rb_per_size_up_to_g1s_thisrame;
            g1s_happens_here{hours,expt} = logdata(expt).all_g1s_happens_here_thisframe;
        elseif hours == 1
            sizes{hours,expt} = logdata(expt).all_sizes_up_to_g1s_1hrs_ahead;
            rb_per_size{hours,expt} = logdata(expt).all_rb_per_size_up_to_g1s_1hrs_ahead;
            g1s_happens_here{hours,expt} = logdata(expt).all_g1s_happens_here_1hrs_ahead;
        elseif hours == 2
            sizes{hours,expt} = logdata(expt).all_sizes_up_to_g1s_2hrs_ahead;
            rb_per_size{hours,expt} = logdata(expt).all_rb_per_size_up_to_g1s_2hrs_ahead;
            g1s_happens_here{hours,expt} = logdata(expt).all_g1s_happens_here_2hrs_ahead;
        elseif hours == 3
            sizes{hours,expt} = logdata(expt).all_sizes_up_to_g1s_3hrs_ahead;
            rb_per_size{hours,expt} = logdata(expt).all_rb_per_size_up_to_g1s_3hrs_ahead;
            g1s_happens_here{hours,expt} = logdata(expt).all_g1s_happens_here_3hrs_ahead;
        end
        %         figure(4*hours-3)
        %         histogram(sizes{expt})
        %         figure(4*hours-2)
        %         histogram(rb_per_size{expt})
    end
end

numbins = 25;

for hours = hours_to_check
    collated_sizes{hours} = [];
    collated_rb_per_size{hours} = [];
    collated_g1s_happens_here{hours} = [];
    for expt = exptnums
        
        % Do not adjust for each expt's mean
        mean_sizes(hours,expt) = 1;
        mean_rb_per_size(hours,expt) = 1;
        
        %         % Adjust for each expt's mean
        %         mean_sizes(hours,expt) = nanmean(sizes{hours,expt});
        %         mean_rb_per_size(hours,expt) = nanmean(rb_per_size{hours,expt});
        
        collated_sizes{hours} = [collated_sizes{hours}; sizes{hours,expt}/mean_sizes(hours,expt)];
        collated_rb_per_size{hours} = [collated_rb_per_size{hours}; rb_per_size{hours,expt}/mean_rb_per_size(hours,expt)];
        collated_g1s_happens_here{hours} = [collated_g1s_happens_here{hours}; g1s_happens_here{hours,expt}];
    end
    
    max_size = 400000 / mean(mean_sizes(:));
    
    collated_rb_per_size{hours} = collated_rb_per_size{hours}(collated_sizes{hours} < max_size);
    collated_g1s_happens_here{hours} = collated_g1s_happens_here{hours}(collated_sizes{hours} < max_size);
    collated_sizes{hours} = collated_sizes{hours}(collated_sizes{hours} < max_size);
    
    if hours == 2
        
        disp('Linear fit to raw data for size')
        fitlm(collated_sizes{hours},collated_g1s_happens_here{hours})
        
        disp('Linear fit to raw data for [Rb]')
        fitlm(collated_rb_per_size{hours},collated_g1s_happens_here{hours})
        
        [size_b,size_dev,size_stats] = glmfit(collated_sizes{hours},collated_g1s_happens_here{hours},'binomial');
        [rb_b,rb_dev,rb_stats] = glmfit(collated_rb_per_size{hours},collated_g1s_happens_here{hours},'binomial');
        
        size_stats.p
        rb_stats.p
        
        bin_discrete_outcomes_with_logit(collated_sizes{hours},collated_g1s_happens_here{hours});
        xlabel('prEF1-mCrimson')
        ylabel('G1/S probability')
        bin_discrete_outcomes_with_logit(collated_rb_per_size{hours},collated_g1s_happens_here{hours});
        xlabel('Rb per prEF1-mCrimson')
        ylabel('G1/S probability')
        
        
        binsizes = linspace(min(collated_sizes{hours}) , max(collated_sizes{hours}) , numbins + 1);
        %Delete the first bin since it will contain zero observations
        binsizes(1) = [];
        [means,error_below,error_above,Ns] = bootstrap(collated_sizes{hours},collated_g1s_happens_here{hours},binsizes);
        disp('Weighted linear fit to sizes')
        fitlm(binsizes,means,'Weights',Ns)
        figure();
        shadedErrorBar(binsizes,means,[error_above, error_below]');
        xlabel('prEF1-mCrimson')
        ylabel('G1/S probability')
        
        binsizes = linspace(min(collated_rb_per_size{hours}) , max(collated_rb_per_size{hours}) , numbins + 1);
        %Delete the first bin since it will contain zero observations
        binsizes(1) = [];
        [means,error_below,error_above,Ns] = bootstrap(collated_rb_per_size{hours},collated_g1s_happens_here{hours},binsizes);
        disp('Weighted linear fit to [Rb]')
        fitlm(binsizes,means,'Weights',Ns)
        figure();
        shadedErrorBar(binsizes,means,[error_above, error_below]');
        xlabel('Rb per prEF1-mCrimson')
        ylabel('G1/S probability')
        
        figure()
        subplot(5,5,[1 2 3 4 5])
        histogram(collated_sizes{hours}(collated_g1s_happens_here{hours} == 1))
        
        subplot(5,5,[21 22 23 24 25])
        histogram(collated_sizes{hours}(collated_g1s_happens_here{hours} == 0))
        
        subplot(5,5,6:20)
        binsizes = linspace(min(collated_sizes{hours}) , max(collated_sizes{hours}) , numbins + 1);
        %Delete the first bin since it will contain zero observations
        binsizes(1) = [];
        [means,error_below,error_above,Ns] = bootstrap(collated_sizes{hours},collated_g1s_happens_here{hours},binsizes);
        disp('Weighted linear fit to sizes')
        fitlm(binsizes,means,'Weights',Ns)
        shadedErrorBar(binsizes,means,[error_above, error_below]');
        xlabel('prEF1-mCrimson')
        ylabel('G1/S probability')
        
        
        figure()
        subplot(5,5,[1 2 3 4 5])
        histogram(collated_rb_per_size{hours}(collated_g1s_happens_here{hours} == 1))
        axis([0 5 0 inf])
        
        subplot(5,5,[21 22 23 24 25])
        histogram(collated_rb_per_size{hours}(collated_g1s_happens_here{hours} == 0))
        axis([0 5 0 inf])
        
        
        subplot(5,5,6:20)
        binsizes = linspace(min(collated_rb_per_size{hours}) , max(collated_rb_per_size{hours}) , numbins + 1);
        %Delete the first bin since it will contain zero observations
        binsizes(1) = [];
        [means,error_below,error_above,Ns] = bootstrap(collated_rb_per_size{hours},collated_g1s_happens_here{hours},binsizes);
        disp('Weighted linear fit to [Rb]')
        fitlm(binsizes,means,'Weights',Ns)
        shadedErrorBar(binsizes,means,[error_above, error_below]');
        axis([0 5 0 inf])
        xlabel('Rb per prEF1-mCrimson')
        ylabel('G1/S probability')
        
        
    end
end




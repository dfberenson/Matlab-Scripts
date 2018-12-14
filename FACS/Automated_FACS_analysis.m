
clear all
close all

folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\180802_HMEC_Rb-Clov_Gem-mCherry_EF1a-Crimson\FlowJo CSVs';
specimen_prefix = ['export_Specimen_001'];
specimens = [{'1GFiii_006'},{'B4_005'},{'D2+Hoechst_002'},{'D2-no_Hoechst_001'},{'D5+Hoechst_004'},{'D5-no_Hoechst_003'}];
% Don't forget to adjust which samples use which color for size below
specimen_subpopulations = [{'Single Cells - Confirmed'},{'G1'},{'SG2'},{'High-FSC_Low-SSC'},{'Low-FSC_High-SSC'}];

% folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\181023_HMEC_NewClones\FlowJo CSVs';
% specimen_prefix = ['Specimen_001'];
% specimens = [{'1E_002'},{'1E+CFSE_006'},{'1F_003'},{'1F+CFSE_007'},{'WT_001'},{'WT+CFSE_005'},{'D5_004'}];
% % Don't forget to adjust which samples use which color for size below
% specimen_subpopulations = [{'Single Cells - Confirmed'}];

for spec = specimens
    for subpop = specimen_subpopulations
        
        specimen_name = spec{1};
        subpop_name = subpop{1};
        
        if isempty(specimen_prefix)
            data_fpath = [folder '\' specimen_name '_' subpop_name '.csv'];
        else
            data_fpath = [folder '\' specimen_prefix '_' specimen_name '_' subpop_name '.csv'];
        end
        
        if ~exist(data_fpath,'file')
            continue
        end
        
        table = readtable(data_fpath);
        
        for plot_type = [{'FSC'},{'SSC'},{'CFSE'},{'FSC_vs_CFSE'},{'SSC_vs_CFSE'}]
            
            plot_name = plot_type{1};
            
            if strcmp(plot_name, 'FSC')
                X = table.FSC_A;
                x_axis_label = 'FSC';
            elseif strcmp(plot_name, 'SSC')
                X = table.SSC_A;
                x_axis_label = 'SSC';
            elseif strcmp(plot_name, 'CFSE')
                if ~(strcmp(specimen_name,'1E+CFSE_006') || strcmp(specimen_name,'1F+CFSE_007'))
                    continue
                else
                    X = table.Comp_B525_A;
                    x_axis_label = 'CFSE';
                end
            elseif strcmp(plot_name, 'FSC_vs_CFSE')
                if ~(strcmp(specimen_name, 'WT+CFSE_005') || strcmp(specimen_name,'1E+CFSE_006') || strcmp(specimen_name,'1F+CFSE_007'))
                    continue
                else
                    X = table.FSC_A;
                    x_axis_label = 'FSC';
                    if strcmp(specimen_name,'WT+CFSE_005')
                        Y = table.B525_A;
                    else
                        Y = table.Comp_B525_A;
                    end
                    y_axis_label = 'CFSE';
                end
            elseif strcmp(plot_name, 'SSC_vs_CFSE')
                if ~(strcmp(specimen_name, 'WT+CFSE_005') || strcmp(specimen_name,'1E+CFSE_006') || strcmp(specimen_name,'1F+CFSE_007'))
                    continue
                else
                    X = table.SSC_A;
                    x_axis_label = 'SSC';
                    if strcmp(specimen_name,'WT+CFSE_005')
                        Y = table.B525_A;
                    else
                        Y = table.Comp_B525_A;
                    end
                    y_axis_label = 'CFSE';
                end
            end
            
            specimen_label = strrep(specimen_name(1:end-4), '_', '__');
            subpop_label = strrep(subpop_name, '_', '__');
            
            %Label figure
            figTitle = [{['Specimen: ' specimen_label]},...
                {['Subpopulation: ' subpop_label]}];
            
            % Don't forget to adjust here which samples use which color for size
            if strcmp(plot_name,'FSC') || strcmp(plot_name,'SSC') || strcmp(plot_name,'CFSE')
                if strcmp(specimen_name,'1E_002') || strcmp(specimen_name,'1F_003')
                    Y = table.Y610_A;
                    y_axis_label = 'mCherry';
                elseif  strcmp(specimen_name,'1E+CFSE_006') || strcmp(specimen_name,'1F+CFSE_007')
                    Y = table.Comp_Y610_A;
                    y_axis_label = 'mCherry';
                elseif strcmp(specimen_name,'D5_004')
                    Y = table.R670_A;
                    y_axis_label = 'Crimson';
                elseif strcmp(specimen_name,'WT_001') || strcmp(specimen_name,'WT+CFSE_005')
                    continue
                end
            end
            
            [numcells,one] = size(X);
            
            %Create a vector with 'numbins' equally spaced bins
            numbins = 100;
            binsizes = linspace(min(X) , max(X) , numbins + 1);
            %Delete the first bin since it will contain zero observations
            binsizes(1) = [];
            
            %Sort X and then keep data in Y properly paired with it
            [X,index] = sort(X);
            Y = Y(index);
            
            %Create an index for all the data (m)
            %And an empty cell array to contain the data
            m = 1;
            binneddataY = cell(1,numbins);
            
            %Go through each bin
            for n = 1 : numbins
                %Assign data in Y to the appropriate bin
                while X(m) < binsizes (n)
                    binneddataY{n} = [binneddataY{n} ; Y(m)];
                    m = m+1;
                end
            end
            
            %Calculate statistics for each bin
            allBinsAvgY = [];
            allBinsStdDevY = [];
            allBinsStdErrorY = [];
            %Determine which is the last bin with at least 'minFullBinObs' observations
            minFullBinObs = 1;
            lastFullBin = 1;
            
            %Go through each bin
            for n = 1 : numbins
                %Calculate statistics for this bin and append to list
                thisbin = binneddataY{n};
                avg = mean(thisbin);
                allBinsAvgY = [allBinsAvgY , avg];
                allBinsStdDevY = [allBinsStdDevY, std(thisbin)];
                stderror = std(thisbin) / sqrt(length(thisbin));
                allBinsStdErrorY = [allBinsStdErrorY, stderror];
                %Record if this bin has at least 'minFullBinObs' observations
                if length(thisbin) >= minFullBinObs
                    lastFullBin = n;
                end
            end
            
            for fittype = [{'Intercept'},{'No_Intercept'}]
                switch fittype{1}
                    case 'Intercept'
                        
                        %Linear fit to data in region up until bins are no longer fairly full
                        %This fit is plottable
                        fit1 = polyfit(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)) , 1);
                        ndensitybins = [200 200];
                        density = hist3([X,Y],ndensitybins) / numcells;
                        
                        %A new linear fit
                        %This fit provides statistics like R^2
                        linearfit = fitlm(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)))
                        linearfit_r2 = linearfit.Rsquared.Ordinary;
                        linearfit_pValue = linearfit.Coefficients.pValue(2);
                        linearfit_slope = linearfit.Coefficients.Estimate(2);
                        disp(sprintf('\n'));
                        
                    case 'No_Intercept'
                        linearfit = fitlm(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)),'Intercept',false)
                        disp(sprintf('\n'));
                        linearfit_r2 = linearfit.Rsquared.Ordinary;
                        linearfit_pValue = linearfit.Coefficients.pValue(1);
                        linearfit_slope = linearfit.Coefficients.Estimate(1);
                        fit1 = [linearfit_slope 0];
                end
                
                
                %Plot data and linear fit
                
                dimTopLeft = [0.15 0.8 0.1 0.1];
                
                figure ('Name','Data')
                hold on
                %contour (density);
                %plot (binsizes,allbinsavgY)
                title(figTitle)
                xlabel(x_axis_label)
                ylabel(y_axis_label)
                
                shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
                scatter (X,Y,0.1,'r')
                shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'g-')
                plot(0:max(X),polyval(fit1,0:max(X)))
                axis([0 inf 0 inf])
                hold off
                
                str1 = ['Fittype = ' fittype{1} newline...
                    'R^2 =  ' num2str(linearfit_r2) newline 'p-Value =  ' num2str(linearfit_pValue) newline 'slope = ' num2str(linearfit_slope)...
                    newline x_axis_label ' mean = ' num2str(mean(X)) newline x_axis_label ' stdev = ' num2str(std(X))...
                    newline y_axis_label ' mean = ' num2str(mean(Y)) newline y_axis_label ' stdev = ' num2str(std(Y))];
                annotation('textbox',dimTopLeft,'String',str1,'FitBoxToText','on');
                
                saveas(gcf, [folder '\' specimen_name '_' subpop_name '_' plot_name '_' fittype{1} '.png']);
                
            end
        end
    end
end
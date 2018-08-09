
clear all
close all

folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\180802_HMEC_Rb-Clov_Gem-mCherry_EF1a-Crimson\FlowJo CSVs';
specimen_prefix = ['export_Specimen_001'];
specimens = [{'1GFiii_006'},{'B4_005'},{'D2+Hoechst_002'},{'D2-no_Hoechst_001'},{'D5+Hoechst_004'},{'D5-no_Hoechst_003'}];
% Don't forget to adjust which samples use which color for size below
specimen_subpopulations = [{'Single Cells - Confirmed'},{'G1'},{'SG2'},{'High-FSC_Low-SSC'},{'Low-FSC_High-SSC'}];

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
        
        for plot_type = [{'FSC'},{'SSC'}]
            
            plot_name = plot_type{1};
            
            if strcmp(plot_name, 'FSC')
                X = table.FSC_A;
            elseif strcmp(plot_name, 'SSC')
                X = table.SSC_A;
            end
            
            specimen_label = strrep(specimen_name(1:end-4), '_', '__');
            subpop_label = strrep(subpop_name, '_', '__');
            
            %Label figure
            figTitle = [{['Specimen: ' specimen_label]},...
                {['Subpopulation: ' subpop_label]}];
            xAxis = plot_name;
            
            % Don't forget to adjust here which samples use which color for size
            if strcmp(specimen_name,'1GFiii_006')
                Y = table.Comp_Y610_A;
                yAxis = 'mCherry';
            else
                Y = table.Comp_R670_A;
                yAxis = 'Crimson';
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
            
            %Linear fit to data in region up until bins are no longer fairly full
            %This fit is plottable
            fit1 = polyfit(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)) , 1);
            ndensitybins = [200 200];
            density = hist3([X,Y],ndensitybins) / numcells;
            
            %A new linear fit
            %This fit provides statistics like R^2
            linearfit = fitlm(X(X < binsizes(lastFullBin)) , Y(X < binsizes(lastFullBin)))
            disp(sprintf('\n'));
            
            
            %Plot data and linear fit
            
            dimTopLeft = [0.15 0.8 0.1 0.1];
            
            figure ('Name','Data')
            hold on
            %contour (density);
            %plot (binsizes,allbinsavgY)
            title(figTitle)
            xlabel(xAxis)
            ylabel(yAxis)
            
            shadedErrorBar(binsizes,allBinsAvgY,allBinsStdDevY,'m-',1)
            scatter (X,Y,0.1,'r')
            shadedErrorBar(binsizes,allBinsAvgY,allBinsStdErrorY,'g-')
            plot(0:max(X),polyval(fit1,0:max(X)))
            axis([0 inf 0 inf])
            hold off
            
            linearfit_r2 = linearfit.Rsquared.Ordinary;
            linearfit_pValue = linearfit.Coefficients.pValue(2);
            linearfit_slope = linearfit.Coefficients.Estimate(2);
            
            
            str1 = ['R^2 =  ' num2str(linearfit_r2) newline 'p-Value =  ' num2str(linearfit_pValue) newline 'slope = ' num2str(linearfit_slope)...
                newline xAxis ' mean = ' num2str(mean(X)) newline xAxis ' stdev = ' num2str(std(X))...
                newline yAxis ' mean = ' num2str(mean(Y)) newline yAxis ' stdev = ' num2str(std(Y))];
            annotation('textbox',dimTopLeft,'String',str1,'FitBoxToText','on');
            
            saveas(gcf, [folder '\' specimen_name '_' subpop_name '_' plot_name '.png']);
            
        end
    end
end
clear all

folder = 'C:\Users\Skotheim Lab\Box Sync\Daniel Berenson''s Files\Data\FACS\180316_HMEC_size-sensors_EGF_Palbo\GatedAndCompensated';

s(1).Name = 'MinusEGF-MinusPalbo';
s(2).Name = 'MinusEGF-PlusPalbo';
s(3).Name = 'PlusEGF-MinusPalbo';
s(4).Name = 'PlusEGF-PlusPalbo';

for i = 1:4
    T = readtable([folder '\' s(i).Name '.csv']);
    s(i).FSC = T.FSC_A;
    s(i).mCherry = T.mCherry_A;
    FSC_mins(i) = min(s(i).FSC);
    FSC_maxes(i) = max(s(i).FSC);
end

FSC_global_min = min(FSC_mins);
FSC_global_max = max(FSC_maxes);

%Create a vector with 'numbins' equally spaced bins
%Delete the first bin since it will contain zero observations
numbins = 100;
binsizes = linspace(FSC_global_min, FSC_global_max, numbins + 1);
binsizes(1) = [];

for i = 1:4
    X = s(i).FSC;
    Y = s(i).mCherry;
    
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
        while m <= length(X) && X(m) < binsizes (n)
            binneddataY{n} = [binneddataY{n} ; Y(m)];
            m = m+1;
        end
    end
    
    %Calculate statistics for each bin
    allBinsAvgY = [];
    allBinsStdDevY = [];
    allBinsStdErrorY = [];
    %Determine which is the last bin with at least 'minFullBinObs' observations
    minFullBinObs = 50;
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
    s(i).binned_mCherry_mean = allBinsAvgY;
    s(i).binned_mCherry_StdDev = allBinsStdDevY;
    s(i).binned_mCherry_StdError = allBinsStdErrorY;
end

figure()
hold on
title('mCherry vs FSC')
xlabel('FSC')
ylabel('mCherry')
plot(binsizes,s(1).binned_mCherry_mean,'r');
plot(binsizes,s(2).binned_mCherry_mean,'m');
plot(binsizes,s(3).binned_mCherry_mean,'b');
plot(binsizes,s(4).binned_mCherry_mean,'c');
lgd_lines = legend(s(:).Name,'Location','Northwest')
hold off

figure()
hold on
title('mCherry vs FSC')
xlabel('FSC')
ylabel('mCherry')
shadedErrorBar(binsizes,s(1).binned_mCherry_mean,s(1).binned_mCherry_StdDev,'r-',1);
shadedErrorBar(binsizes,s(2).binned_mCherry_mean,s(2).binned_mCherry_StdDev,'m-',1);
shadedErrorBar(binsizes,s(3).binned_mCherry_mean,s(3).binned_mCherry_StdDev,'b-',1);
shadedErrorBar(binsizes,s(4).binned_mCherry_mean,s(4).binned_mCherry_StdDev,'c-',1);
% Have to divorce the legend from the actual plots because legend gets
% confused working with shadedErrorBar
h(1) = plot(NaN,NaN,'r-');
h(2) = plot(NaN,NaN,'m-');
h(3) = plot(NaN,NaN,'b-');
h(4) = plot(NaN,NaN,'c-');
legend(h,s.Name,'Location','Northwest')
hold off


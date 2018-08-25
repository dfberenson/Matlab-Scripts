
function fig = bin_discrete_outcomes(X,Y)

assert(length(X) == length(Y));

%Create a vector with 'numbins' equally spaced bins
numbins = 25;

% Insist that each bin have at least half the number of data points it
% should if all data were evenly distributed
min_num_cells_in_bin = length(X) / numbins / 2;

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
good_bin_indices = [];
%Go through each bin
for n = 1 : numbins
    %Assign data in Y to the appropriate bin
    while X(m) < binsizes (n)
        binneddataY{n} = [binneddataY{n} ; Y(m)];
        m = m+1;
    end
    
    % Now bin n has some number of data points in it, which
    % will be 0s or 1s if it is discrete binary data.
    num_cells_in_bin = length(binneddataY{n});
    num_yes_cells_in_bin = sum(binneddataY{n});
    binneddataY_fraction(n) = num_yes_cells_in_bin / num_cells_in_bin;
    
    if num_cells_in_bin >= min_num_cells_in_bin
        good_bin_indices = [good_bin_indices, n];
    end
end

fig = figure();
hold on
yyaxis left
ylabel('Binary outcome')
scatter(X,Y)
yyaxis right
scatter(binsizes(good_bin_indices), binneddataY_fraction(good_bin_indices))
ylabel('Probability')
axis([-inf inf 0 0.2])

binned_lm = fitlm(binsizes(good_bin_indices), binneddataY_fraction(good_bin_indices));
lm_r2 = binned_lm.Rsquared.Ordinary;
lm_pValue = binned_lm.Coefficients.pValue(2);
lm_slope = binned_lm.Coefficients.Estimate(2);
str = ['R^2 =  ' num2str(lm_r2) sprintf('\n') 'p-Value =  ' num2str(lm_pValue) sprintf('\n') 'slope = ' num2str(lm_slope)];
if (binned_lm.Coefficients.Estimate(2) > 0)
    dim = [0.15 0.82 0.1 0.1];
else
    dim = [0.15 0.15 0.1 0.1];
end
annotation('textbox',dim,'String',str,'FitBoxToText','on');
hold off

end
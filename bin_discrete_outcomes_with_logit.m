
function fig = bin_discrete_outcomes_with_logit(X,Y)

if ~iscolumn(X)
    X = X';
end
if ~iscolumn(Y)
    Y = Y';
end

assert(size(X,2) == 1 && size(Y,2) == 1);

nans = isnan(X) | isnan(Y);
X = X(~nans);
Y = Y(~nans);
assert(length(X) == length(Y));

%Create a vector with 'numbins' equally spaced bins
numbins = 25;

% Insist that each bin have at least one twentieth the number of data points it
% should if all data were evenly distributed
min_num_cells_in_bin = length(X) / numbins / 20;
min_num_cells_in_bin = 1;

binsizes = linspace(min(X) , max(X) , numbins + 1);
%Delete the first bin since it will contain zero observations
binsizes(1) = [];

%Sort X and then keep data in Y properly paired with it
[X,index] = sort(X);
Y = Y(index);

%Create an index for all the data (m)
%And an empty cell array to contain the data
i = 1;
binneddataY = cell(1,numbins);
good_bin_indices = [];
%Go through each bin
for bin = 1 : numbins
    %Assign data in Y to the appropriate bin
    while X(i) < binsizes (bin)
        binneddataY{bin} = [binneddataY{bin} ; Y(i)];
        i = i+1;
    end
    
    % Now bin n has some number of data points in it, which
    % will be 0s or 1s if it is discrete binary data.
    num_cells_in_bin = length(binneddataY{bin});
    num_yes_cells_in_bin = sum(binneddataY{bin});
    binneddataY_fraction(bin) = num_yes_cells_in_bin / num_cells_in_bin;
    
    if num_cells_in_bin >= min_num_cells_in_bin
        good_bin_indices = [good_bin_indices, bin];
    end
end


% Calculate logistic regression
main_fit = glmfit(X,Y,'binomial');
domain_granularity = 50;
domain = linspace(min(X),max(X),domain_granularity)';
main_fitted_vals = glmval(main_fit, domain, 'logit');

% Bootstrap for logistic regression
times_to_bootstrap = 1000;
data = [X,Y];
k = size(data,1);
all_bootstrapped_vals = zeros(domain_granularity,times_to_bootstrap);
for b = 1:times_to_bootstrap
    resampled = datasample(data,k);
    this_bootstrap_fit = glmfit(resampled(:,1), resampled(:,2), 'binomial');
    this_bootstrapped_vals = glmval(this_bootstrap_fit, domain, 'logit');
    all_bootstrapped_vals(:,b) = this_bootstrapped_vals;
end

sorted_bootstrapped_vals = sort(all_bootstrapped_vals,2);
fifth_percentile_bootstrapped_vals = sorted_bootstrapped_vals(:,times_to_bootstrap*0.05);
ninetyfifth_percentile_bootstrapped_vals = sorted_bootstrapped_vals(:,times_to_bootstrap*0.95);

error_bars_to_fifth_percentile = main_fitted_vals - fifth_percentile_bootstrapped_vals;
error_bars_to_ninetyfifth_percentile = ninetyfifth_percentile_bootstrapped_vals - main_fitted_vals;

fig = figure();
hold on
yyaxis right
% Can't do shadedErrorBar on second yyaxis - have to do it first
shadedErrorBar(domain,main_fitted_vals,[error_bars_to_fifth_percentile, error_bars_to_ninetyfifth_percentile])
plot(binsizes(good_bin_indices), binneddataY_fraction(good_bin_indices))
ylabel('Probability')
axis([-inf inf 0 0.2])
yyaxis left
ylabel('Binary outcome')
scatter(X,Y)
% Go back to yyaxis right before returning so outside labels go there
yyaxis right
plot(X,polyval(polyfit(X,Y,1),X))


end
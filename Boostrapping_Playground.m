

a = rand(10000,1);
b = rand(10000,1);

for i = 1:10000
    a(i) = a(i) + i*rand();
    b(i) = b(i) - i*rand();
end

c = [zeros(1,5000),ones(1,5000)];

two_variable_binning(a,b,c,0,100,0,100)








% X = (1:20)';
% Y = logical([0 0 0 1 0 0 1 1 0 0 1 0 0 1 1 1 1 1 1 1 ])';
% 
% main_fit = glmfit(X,Y,'binomial');
% domain_granularity = 50;
% domain = linspace(min(X),max(X),domain_granularity)';
% main_fitted_vals = glmval(main_fit, domain, 'logit');
% 
% figure()
% hold on
% scatter(X,Y)
% plot(domain, main_fitted_vals)
% hold off
% 
% 
% bin_discrete_outcomes_with_logit(X,Y)
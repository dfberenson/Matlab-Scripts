

x = rand(1000,1);
y = rand(1000,1);
scatter(x,y)
f1 = fitlm(x,y,'Intercept',true);
disp(['The R2 value for unforced fit is ' num2str(f1.Rsquared.Ordinary)])
f2 = fitlm(x,y,'Intercept',false);
disp(['The R2 value for forced fit is ' num2str(f2.Rsquared.Ordinary)])



% expt_length = 1000000
% 
% dredge = zeros(expt_length,1);
% rip = zeros(expt_length,1);
% 
% dredge(1) = 100;
% 
% for t = 2:expt_length
%     d_dredge = -0.1*rip(t-1)/(rip(t-1)+100);
%     d_rip = 0.1*dredge(t-1)/(dredge(t-1)+100);
%     dredge(t) = dredge(t-1) + d_dredge;
%     rip(t) = rip(t-1) + d_rip;
% end
% 
% yyaxis left
% plot(dredge)
% yyaxis right
% plot(rip)
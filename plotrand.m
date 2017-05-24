n=100;
r=rand(n,1);
plot(r);
m=mean(r);
hold on
plot([0,n],[m,m])
hold off
title('mean')



x = 0:0.01:1;
y = 1 - (x-0.5).^2;

figure
hold on
box off
plot(x,y,'-r')
axis('square')
xticks([])
yticks([])
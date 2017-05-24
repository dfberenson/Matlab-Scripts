%data = input('Enter the data within square brackets: ');
data = CompCSFEA;
figure()
hold on
xlabel(input('x-axis label: ' , 's'));
ylabel('Count');
str = ['CoV = ' num2str(std(data)/mean(data))]
dimTopRight = [0.65 0.82 0.1 0.1];
annotation('textbox',dimTopRight,'String',str,'FitBoxToText','on');
hist(data,200);
axis([0 inf 0 inf])
hold off
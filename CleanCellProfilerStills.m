minsize = 0.05;

p1c3t1 = p1c3t1(p1c3t1 > minsize);
p1c3t2 = p1c3t2(p1c3t2 > minsize);
p1c3t3 = p1c3t3(p1c3t3 > minsize);
p1c3t4 = p1c3t4(p1c3t4 > minsize);
p1c3t5 = p1c3t5(p1c3t5 > minsize);
p1c3t6 = p1c3t6(p1c3t6 > minsize);
p2c3t1 = p2c3t1(p2c3t1 > minsize);
p2c3t2 = p2c3t2(p2c3t2 > minsize);
p2c3t3 = p2c3t3(p2c3t3 > minsize);
p2c3t4 = p2c3t4(p2c3t4 > minsize);
p2c3t5 = p2c3t5(p2c3t5 > minsize);
p2c3t6 = p2c3t6(p2c3t6 > minsize);
p3c3t1 = p3c3t1(p3c3t1 > minsize);
p3c3t2 = p3c3t2(p3c3t2 > minsize);
p3c3t3 = p3c3t3(p3c3t3 > minsize);
p3c3t4 = p3c3t4(p3c3t4 > minsize);
p3c3t5 = p3c3t5(p3c3t5 > minsize);
p3c3t6 = p3c3t6(p3c3t6 > minsize);
p4c3t1 = p4c3t1(p4c3t1 > minsize);
p4c3t2 = p4c3t2(p4c3t2 > minsize);
p4c3t3 = p4c3t3(p4c3t3 > minsize);
p4c3t4 = p4c3t4(p4c3t4 > minsize);
p4c3t5 = p4c3t5(p4c3t5 > minsize);
p4c3t6 = p4c3t6(p4c3t6 > minsize);
p5c3t1 = p5c3t1(p5c3t1 > minsize);
p5c3t2 = p5c3t2(p5c3t2 > minsize);
p5c3t3 = p5c3t3(p5c3t3 > minsize);
p5c3t4 = p5c3t4(p5c3t4 > minsize);
p5c3t5 = p5c3t5(p5c3t5 > minsize);
p5c3t6 = p5c3t6(p5c3t6 > minsize);
p6c3t1 = p6c3t1(p6c3t1 > minsize);
p6c3t2 = p6c3t2(p6c3t2 > minsize);
p6c3t3 = p6c3t3(p6c3t3 > minsize);
p6c3t4 = p6c3t4(p6c3t4 > minsize);
p6c3t5 = p6c3t5(p6c3t5 > minsize);
p6c3t6 = p6c3t6(p6c3t6 > minsize);


hold on

p1t1 = cdfplot(p1c3t1)
p1t1.Color = 'b';
p1t1.LineStyle = '-';
p1t1.LineWidth = 1;
p1t2 = cdfplot(p1c3t2)
p1t2.Color = 'b';
p1t2.LineStyle = '--';
p1t2.LineWidth = 1;
p1t3 = cdfplot(p1c3t3)
p1t3.Color = 'b';
p1t3.LineStyle = '-.';
p1t3.LineWidth = 1;
p1t4 = cdfplot(p1c3t4)
p1t4.Color = 'b';
p1t4.LineStyle = ':';
p1t4.LineWidth = 1;
p1t5 = cdfplot(p1c3t5)
p1t5.Color = 'b';
p1t5.LineStyle = '-';
p1t5.LineWidth = 0.5;
p1t6 = cdfplot(p1c3t6)
p1t6.Color = 'b';
p1t6.LineStyle = '--';
p1t6.LineWidth = 0.5;

p2t1 = cdfplot(p2c3t1)
p2t1.Color = 'r';
p2t1.LineStyle = '-';
p2t1.LineWidth = 1;
p2t2 = cdfplot(p2c3t2)
p2t2.Color = 'r';
p2t2.LineStyle = '--';
p2t2.LineWidth = 1;
p2t3 = cdfplot(p2c3t3)
p2t3.Color = 'r';
p2t3.LineStyle = '-.';
p2t3.LineWidth = 1;
p2t4 = cdfplot(p2c3t4)
p2t4.Color = 'r';
p2t4.LineStyle = ':';
p2t4.LineWidth = 1;
p2t5 = cdfplot(p2c3t5)
p2t5.Color = 'r';
p2t5.LineStyle = '-';
p2t5.LineWidth = 0.5;
p2t6 = cdfplot(p2c3t6)
p2t6.Color = 'r';
p2t6.LineStyle = '--';
p2t6.LineWidth = 0.5;

p3t1 = cdfplot(p3c3t1)
p3t1.Color = 'g';
p3t1.LineStyle = '-';
p3t1.LineWidth = 1;
p3t2 = cdfplot(p3c3t2)
p3t2.Color = 'g';
p3t2.LineStyle = '--';
p3t2.LineWidth = 1;
p3t3 = cdfplot(p3c3t3)
p3t3.Color = 'g';
p3t3.LineStyle = '-.';
p3t3.LineWidth = 1;
p3t4 = cdfplot(p3c3t4)
p3t4.Color = 'g';
p3t4.LineStyle = ':';
p3t4.LineWidth = 1;
p3t5 = cdfplot(p3c3t5)
p3t5.Color = 'g';
p3t5.LineStyle = '-';
p3t5.LineWidth = 0.5;
p3t6 = cdfplot(p3c3t6)
p3t6.Color = 'g';
p3t6.LineStyle = '--';
p3t6.LineWidth = 0.5;

p4t1 = cdfplot(p4c3t1)
p4t1.Color = 'k';
p4t1.LineStyle = '-';
p4t1.LineWidth = 1;
p4t2 = cdfplot(p4c3t2)
p4t2.Color = 'k';
p4t2.LineStyle = '--';
p4t2.LineWidth = 1;
p4t3 = cdfplot(p4c3t3)
p4t3.Color = 'k';
p4t3.LineStyle = '-.';
p4t3.LineWidth = 1;
p4t4 = cdfplot(p4c3t4)
p4t4.Color = 'k';
p4t4.LineStyle = ':';
p4t4.LineWidth = 1;
p4t5 = cdfplot(p4c3t5)
p4t5.Color = 'k';
p4t5.LineStyle = '-';
p4t5.LineWidth = 0.5;
p4t6 = cdfplot(p4c3t6)
p4t6.Color = 'k';
p4t6.LineStyle = '--';
p4t6.LineWidth = 0.5;

p5t1 = cdfplot(p5c3t1)
p5t1.Color = 'm';
p5t1.LineStyle = '-';
p5t1.LineWidth = 1;
p5t2 = cdfplot(p5c3t2)
p5t2.Color = 'm';
p5t2.LineStyle = '--';
p5t2.LineWidth = 1;
p5t3 = cdfplot(p5c3t3)
p5t3.Color = 'm';
p5t3.LineStyle = '-.';
p5t3.LineWidth = 1;
p5t4 = cdfplot(p5c3t4)
p5t4.Color = 'm';
p5t4.LineStyle = ':';
p5t4.LineWidth = 1;
p5t5 = cdfplot(p5c3t5)
p5t5.Color = 'm';
p5t5.LineStyle = '-';
p5t5.LineWidth = 0.5;
p5t6 = cdfplot(p5c3t6)
p5t6.Color = 'm';
p5t6.LineStyle = '--';
p5t6.LineWidth = 0.5;

p6t1 = cdfplot(p6c3t1)
p6t1.Color = 'c';
p6t1.LineStyle = '-';
p6t1.LineWidth = 1;
p6t2 = cdfplot(p6c3t2)
p6t2.Color = 'c';
p6t2.LineStyle = '--';
p6t2.LineWidth = 1;
p6t3 = cdfplot(p6c3t3)
p6t3.Color = 'c';
p6t3.LineStyle = '-.';
p6t3.LineWidth = 1;
p6t4 = cdfplot(p6c3t4)
p6t4.Color = 'c';
p6t4.LineStyle = ':';
p6t4.LineWidth = 1;
p6t5 = cdfplot(p6c3t5)
p6t5.Color = 'c';
p6t5.LineStyle = '-';
p6t5.LineWidth = 0.5;
p6t6 = cdfplot(p6c3t6)
p6t6.Color = 'c';
p6t6.LineStyle = '--';
p6t6.LineWidth = 0.5;

ylabel('Cumulative probability');
xlabel('Integrated mCherry');
legend('Pos1 time1','Pos1 time2','Pos1 time3','Pos1 time4','Pos1 time5','Pos1 time6', ...
    'Pos2 time1','Pos2 time2','Pos2 time3','Pos2 time4','Pos2 time5','Pos2 time6', ...
    'Pos3 time1','Pos3 time2','Pos3 time3','Pos3 time4','Pos3 time5','Pos3 time6', ...
    'Pos4 time1','Pos4 time2','Pos4 time3','Pos4 time4','Pos4 time5','Pos4 time6', ...
    'Pos5 time1','Pos5 time2','Pos5 time3','Pos5 time4','Pos5 time5','Pos5 time6', ...
    'Pos6 time1','Pos6 time2','Pos6 time3','Pos6 time4','Pos6 time5','Pos6 time6', ...
    'Location','SE')


dim = [0.15 0.82 0.1 0.1];
str = ['Time elapsed between images = ' input('Time elapsed between images = ' , 's')...
    sprintf('\n') 'Observations smaller than ' num2str(minsize) ' excluded'];
annotation('textbox',dim,'String',str,'FitBoxToText','on');
hold off
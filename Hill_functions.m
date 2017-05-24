xvec=linspace(0,1,100);
    %number of elements in xvec cannot equal number of values of n or else
    %plot function will plot the columns instead of the rows
    
Y=[];

for n=1:10;
    yvec=xvec.^n./(0.5^n+xvec.^n);
    Y=[Y;yvec];
end

plot (xvec,Y);
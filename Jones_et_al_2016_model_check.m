% NON SIZE DEPENDENT
% g=0.018;
% d=0.5;
% Tdiv=2200;
% CDK=0;
% pCDK=57.14;
% size =30;
% t=1;
% sizedist(t)=size;
% 
% for i = 1:6
%     while CDK < Tdiv
%             size = size * (1+g);
%             CDK = CDK + pCDK;
%             t=t+1;
%             sizedist(t)=size;
%     end
%     size = size * d;
%     CDK=0;
%  end
% plot (sizedist)

%SIZE DEPENDENT
g=0.018;
d=0.5;
Tdiv=2200;
CDK=0;
pCDK=2;
size =30;
t=1;
sizedist(t)=size;
divsizedist(1)=0;

for i = 1:10
    while CDK < Tdiv
            size = size * (1+g);
            CDK = CDK + size * pCDK;
            t=t+1;
            sizedist(t)=size;
    end
    divsizedist(i)=size;
    size = size * d;
    CDK=0;
end
hold on
plot (sizedist)
% plot ([1,t],[divsizedist(i),divsizedist(i)])

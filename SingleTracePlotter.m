

mother_red = input('Mother cell red: ');
mother_green = input('Mother cell green: ');
daughterA_red = input('Daughter A red: ');
daughterA_green = input('Daughter A green: ');
daughterB_red = input('Daughter B red: ');
daughterB_green = input('Daughter B green: ');

mother_red = mother_red(mother_red > -1000000);
mother_green = mother_green(mother_green > -1000000);
daughterA_red = daughterA_red(daughterA_red > -1000000);
daughterA_green = daughterA_green(daughterA_green > -1000000);
daughterB_red = daughterB_red(daughterB_red > -1000000);
daughterB_green = daughterB_green(daughterB_green > -1000000);

green_scaler = 0.1;

hold on
plot([mother_red;daughterA_red] , 'r')
plot([mother_red;daughterB_red] , 'm')
plot([mother_green;daughterA_green] * green_scaler , 'g')
plot([mother_green;daughterB_green] * green_scaler , 'c')
plot(mother_red , 'y')
plot(mother_green * green_scaler , 'b')

legend('Daughter A size','Daughter B size','Daughter A geminin','Daughter B geminin',...
    'Mother size','Mother geminin','Location','SW')
xlabel('Frames (q30min)')
ylabel('Fluorescence (AU)')

figure()
hold on
times = 1:length(daughterA_green);
times = times.';
ftype = fittype('max(a,b*x+c)');
maxfit = fit(times,daughterA_green,ftype)
plot(times,daughterA_green)
plot(maxfit)

G1Stransition = (maxfit.a - maxfit.c)/maxfit.b

% generations = input('How many generations? ');
% trace = [];
% 
% if generations == 1
%     nametrace1 = input('Trace name: ');
%     trace = nametrace1(nametrace1 > -1000000);
% end
% 
% if generations == 2
%     nametrace1 = input('Trace 1 name: ');
%     nametrace2 = input('Trace 2 name: ');
%     trace = [nametrace1(nametrace1 > -1000000) ; nametrace2(nametrace2 > -1000000)];
% end
% 
% 
% color = input('Choose a Matlab color: ');
% scale = input('Choose a multiplier to scale data (5 is good for mCherry vs Geminin): ');
% hold on
% plot(trace*scale, color)
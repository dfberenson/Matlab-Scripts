%Import data as a CSV with the first row as the cell name.
%Data should take the form of: [channel1; channel2; blank; blank]
%Choose option: Import as column vectors
%Make sure each column has data type: number
%(Matlab might try to interpret scientific notation as text)

numchannels = input('How many channels? ');
generations = input('How many generations? ');
CellX = input('Parent cell name: ');



if numchannels == 1
    CellX_generations = [];
    
for n = 1:length(CellX)
    if CellX(n) > 0 || CellX(n) <= 0 %Eliminate blank rows (NaN)
        CellX_generations = [CellX_generations ; CellX(n)];
    end
end

if generations > 1
    CellXA = input('Daughter cell name: ');
    for n = 1:length(CellXA)
        if CellXA(n) > 0  || CellXA(n) <= 0
           CellX_generations = [CellX_generations ; CellXA(n)];
        end
    end
end

if generations > 2
CellXAA = input('Granddaughter cell name: ');
for n = 1:length(CellXAA)
    if CellXAA(n) > 0 || CellXAA(n) <= 0
        CellX_generations = [CellX_generations ; CellXAA(n)];
    end
end
end

color = input('Choose a Matlab color: ');
hold on
plot(CellX_generations, color)
hold off
end

if numchannels == 2
    CellX_generations_channel1 = [];
    CellX_generations_channel2 = [];
%     channelname1 = input('Channel 1: ');
%     channelname2 = input('Channel 2: ');
    
    for n = 2:2:length(CellX)
     if CellX(n) > 0 || CellX(n) <= 0
            CellX_generations_channel1 = [CellX_generations_channel1 ; CellX(n-1)];
            CellX_generations_channel2 = [CellX_generations_channel2 ; CellX(n)];
     end
    end

if generations > 1
    CellXA = input('Daughter cell name: ');
    for n = 2:2:length(CellXA)
        if CellXA(n) > 0 || CellXA(n) <= 0
            CellX_generations_channel1 = [CellX_generations_channel1 ; CellXA(n-1)];
            CellX_generations_channel2 = [CellX_generations_channel2 ; CellXA(n)];
        end
    end
end

if generations > 2
CellXAA = input('Granddaughter cell name: ');
for n = 2:2:length(CellXAA)
    if CellXAA(n) > 0 || CellXAA(n) <= 0
            CellX_generations_channel1 = [CellX_generations_channel1 ; CellXAA(n-1)];
            CellX_generations_channel2 = [CellX_generations_channel2 ; CellXAA(n)];
    end
end
end
color1 = input('Choose a Matlab color for channel 1: ');
color2 = input('Choose a Matlab color for channel 2: ');
scale1 = input('Choose a multiplier to scale channel 1: ');
scale2 = input('Choose a multiplier to scale channel 2: ');
hold on
plot(CellX_generations_channel1 * scale1, color1)
plot(CellX_generations_channel2 * scale2, color2)
hold off
% legend(channelname1,channelname2)
end
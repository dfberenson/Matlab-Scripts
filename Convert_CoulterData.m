%Import list of bin sizes and equally long list of bin counts

binsizes = Celldiambin;
bincounts = Totalbincount;

totaldata = [];
for i = 1:length(binsizes)
    for j = 1:bincounts(i)
        totaldata = [totaldata , binsizes(i)];
    end
end

%Eliminate debris peak
totaldata = totaldata(totaldata > 12);

%Convert linear to volumetric
totalvoldata = totaldata.^3;

function cleanvoldata = convert_CoulterData(binsizes, bincounts, cutoff)

%Take list of bin sizes (diameter in um) and equally long list of bin counts
%Return list of measurements after trimming left half at cutoff (often 12um
%or 0.9 pL)

totaldata = [];
typical_cutoff_binnum = length(binsizes(binsizes < cutoff));

for i = 1:length(binsizes)-2 % Go through each bin,except last two bins because they are weird
    thisbinsize = binsizes(i);
    thisbincount = bincounts(i);
    data_to_add = ones(thisbincount,1) * thisbinsize;
    totaldata = [totaldata ; data_to_add];
end

%Check if there's a local minimum a bit past the typical_cutoff
minbinnum = typical_cutoff_binnum;
minbincount = bincounts(typical_cutoff_binnum);
for j = typical_cutoff_binnum :  typical_cutoff_binnum*2
    thisbincount = bincounts(j);
    if thisbincount < minbincount
        minbinnum = j;
        minbincount = thisbincount;
    end
end

bottom_cutoff = binsizes(minbinnum);
cleandata = totaldata(totaldata > bottom_cutoff);

%Convert linear to volumetric
cleanvoldata = (4/3)*pi*(cleandata/2).^3;

end
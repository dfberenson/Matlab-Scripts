function I = imoverlay_fast(I,bw,color)
% Written 4/27/2018 by DFB.

sz_I = size(I);
assert(isa(I,'uint8') || isa(I,'uint16'), "Image must be uint8 or uint16");

if isa(I,'uint8')
    max = 255;
elseif isa(I,'uint16')
    max = 65535;
end

sz_bw = size(bw);
assert(length(sz_bw) == 2, "BW must be a 2D array");
assert(islogical(bw), "BW must be a logical array");

assert(sz_I(1) == sz_bw(1) && sz_I(2) == sz_bw(2), "I and bw must have the same 2D size");

if length(sz_I) == 2
    I(bw) = max;
elseif length(sz_I) == 3
    assert(sz_I(3) == 3, "Image must be a 3D RGB stack");
    
    
    I_red = I(:,:,1);
    I_green = I(:,:,2);
    I_blue = I(:,:,3);
    
    if strcmp(color,'w') || strcmp(color,'white')
        I_red(bw) = max;
        I_green(bw) = max;
        I_blue(bw) = max;
    end
    if strcmp(color,'y') || strcmp(color,'yellow')
        I_red(bw) = max;
        I_green(bw) = max;
        I_blue(bw) = 0;
    end
    if strcmp(color,'c') || strcmp(color,'cyan')
        I_red(bw) = 0;
        I_green(bw) = max;
        I_blue(bw) = max;
    end
    if strcmp(color,'m') || strcmp(color,'magenta')
        I_red(bw) = max;
        I_green(bw) = 0;
        I_blue(bw) = max;
    end

    I = cat(3,I_red,I_green,I_blue);
end
end
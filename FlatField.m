%function FlatField (uniform , darkfield)


uniform = imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif');
% darkfield = Darkfield5ug10ms;
darkfield = 106;,
aboveDark = uniform - darkfield;
new_image = aboveDark;
filter = double(aboveDark);

sz = size(aboveDark);
rows = sz(1);
cols = sz(2);

X = zeros(rows*cols,1);
Y = zeros(rows*cols,1);
Z = zeros(rows*cols,1);
D = zeros(rows*cols,1);
n = 1;
for (i = 1:rows)
    for (j = 1:cols)
        X(n) = j;
        Y(n) = i;
        Z(n) = aboveDark(i,j);
        D(n) = sqrt((X(n) - 1280)^2 + (Y(n) - 1080)^2);
        n = n+1;
    end
end
        

fpoly = fit([X,Y],Z,'poly55');
gaussian2d = 'A*exp(-(((x-x0)/(2*s1))^2 + ((y-y0)/(2*s2))^2)) + B';
fgauss = fit([X,Y],Z,gaussian2d);

flin = fitlm(D(D<1500),Z(D<1500));

hold on
mesh(aboveDark)
plot(fpoly)
hold off


for (i = 1:rows)
    for (j = 1:cols)
        x = j;
        y = i;
        z = double(aboveDark(i,j));
        pxfilter = 1/fpoly(x,y);
        filter(i,j) = pxfilter;
        new_image(i,j) = z*pxfilter;
    end
end

%return filter;
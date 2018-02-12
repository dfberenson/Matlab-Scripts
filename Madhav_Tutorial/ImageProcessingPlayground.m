CurrentDir = 'C:\Users\Skotheim Lab\Desktop\Matlab Scripts\Madhav_Tutorial';
[filename,path] = uigetfile('*.stk','Choose stack: ');

%Load the stack
if(filename)
    [stk,stacklength] = stkread([path filename]);
end

for i = 1:stacklength
    imstack(:,:,i) = stk(i).data;
end

im_base = imstack(:,:,2);

for i = 3:stacklength
    corr_matrix = normxcorr2(im_base, imstack(:,:,i));
    corr_matrices(:,:,i-2) = corr_matrix;
end

im1 = imread('cells1.tif');
im2 = imread('cells2.tif');

figure,imshow(im1)
figure,imshow(im2)

blank = zeros(size(im1));
cim = cat(3, mat2gray(im1), mat2gray(im2), blank);
figure,imshow(cim,[])

b = normxcorr2(im1,im2);
figure,mesh(b)

[y,x] = find(b == max(b(:)));
[yc,xc] = size(im2);
yoff = abs(yc - y);
xoff = abs(xc - x);

cim2 = zeros(yc + yoff, xc + xoff, 3);
cim2 (yoff:(yc+yoff-1), xoff:(xc+xoff-1), 1) = mat2gray(im1);
cim2(1:yc, 1:xc, 2) = mat2gray(im2);
figure,imshow(cim2)


% 
% CurrentDir = 'C:\Users\Skotheim Lab\Desktop\Matlab Scripts\Madhav_Tutorial';
% [filename,path] = uigetfile('*.stk','Choose stack: ');
% 
% %Load the stack
% if(filename)
%     [stk,stacklength] = stkread([path filename]);
% end
% 
% for i = 1:stacklength
%     imstack(:,:,i) = stk(i).data;
% end
% 
% sz = size(stk(1).data);
% maxintensproj = zeros(sz(1),sz(2));
% 
% for j = 1:sz(1)
%     j
%     for k = 1:sz(2)
%         maxintensproj(j,k) = max(imstack(j,k,:));
%     end
% end
% 
% mat2gray(maxintensproj)
% figure,imtool(maxintensproj)

%guide

% im = imread('dic_cell.tif')
% im = mat2gray(im);
% 
% imtool(im)
% imhist(im)
% 
% canny = edge(im,'canny',[0.2 0.6],1);
% figure,imshow(canny)
% 
% close all
% 
% im = mat2gray(imread('quantumdots.tif'));
% im1 = im(:,:,1);
% figure,imshow(im1)
% 
% imbw = im2bw(im1,0.5);
% figure,imshow(imbw)
% 
% so = strel('square',2);
% imo = imopen(imbw,so);
% figure,imshow(imo)
% 
% sc = strel('square',2);
% imc = imclose(imo,sc);
% figure,imshow(imc)
% 
% [L,N] = bwlabel(imc);
% figure,imshow(mat2gray(L))
% 
% D = regionprops(L,im1,'area','meanintensity');
% 
% for i = 1:N
%     D(i).integratedintensity = D(i).Area * D(i).MeanIntensity
% end


clear all
close all

blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));

cmap = cool(1000);

figure,imshow(blank_field/mean(blank_field(:)),'Colormap',cmap)
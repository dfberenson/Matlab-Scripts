
clear all
close all

beads = readStack('C:\Users\Skotheim Lab\Desktop\Uneven illumination\Beads.tif');
[Y,X,C] = size(beads);
green_beads = beads(:,:,2);
figure,imshow(green_beads,[])

distance_bins = 0:200:1400;

area_threshold = 100;
gaussian_width = 2;
strel_shape = 'disk';
strel_size = 1;
se = strel(strel_shape,strel_size);

thresholded_beads = green_beads > 200;
% figure,imshow(thresholded_ef1a)
im_opened_beads = imopen(thresholded_beads,se);
% figure,imshow(im_opened_ef1a)
im_closed_beads = imclose(im_opened_beads,se);
segmented_beads = im_closed_beads;
%     subplot(1,2,2)
imshow(segmented_beads)
%     figure()
%     imshow(imoverlay_fast(im_ef1a*100, bwperim(segmented_ef1a), 'm'),[])
[beads_labels,num_objects_beads] = bwlabel(segmented_beads,4);


blank_field = double(imread('C:\Users\Skotheim Lab\Desktop\blank-field.tif'));
blank_field_mean = mean(blank_field(:));

raw_beads_props = regionprops(beads_labels,green_beads,'Area','MeanIntensity','Centroid','BoundingBox');

for i = 1:num_objects_beads
    if raw_beads_props(i).Area > area_threshold
        raw_int_intens(i) = NaN;
        raw_distance_from_center(i) = NaN;
    else
        raw_int_intens(i) = raw_beads_props(i).Area * raw_beads_props(i).MeanIntensity;
        raw_distance_from_center(i) = sqrt((X/2 - raw_beads_props(i).Centroid(1))^2 + (Y/2 - raw_beads_props(i).Centroid(2))^2);
    end
end

%     figure
%     box on
%     scatter(raw_distance_from_center,raw_int_intens,'.k')
%     axis('square')

[means,stdevs,stderrs,Ns] = bindata(raw_distance_from_center,raw_int_intens/nanmean(raw_int_intens),distance_bins);
figure
shadedErrorBar(distance_bins,means,stderrs)
axis([0 inf 0 inf],'square')
xlabel('Distance from image center (px)')
xticks([0 400 800 1200])
ylabel('Bead total intensity')

fitlm(raw_distance_from_center,raw_int_intens)

flatfielded_beads = double(green_beads - mode(green_beads(:))) * blank_field_mean ./ blank_field;

flat_beads_props = regionprops(beads_labels,flatfielded_beads,'Area','MeanIntensity','Centroid','BoundingBox');

for i = 1:num_objects_beads
    if flat_beads_props(i).Area > area_threshold
        flat_int_intens(i) = NaN;
        flat_distance_from_center(i) = NaN;
    else
        flat_int_intens(i) = flat_beads_props(i).Area * flat_beads_props(i).MeanIntensity;
        flat_distance_from_center(i) = sqrt((X/2 - flat_beads_props(i).Centroid(1))^2 + (Y/2 - flat_beads_props(i).Centroid(2))^2);
    end
end

%     figure
%     box on
%     scatter(flat_distance_from_center,flat_int_intens,'.k')
%     axis('square')

[means,stdevs,stderrs,Ns] = bindata(flat_distance_from_center,flat_int_intens/nanmean(flat_int_intens),distance_bins);
figure
shadedErrorBar(distance_bins,means,stderrs)
axis([0 inf 0 inf],'square')
xlabel('Distance from image center (px)')
xticks([0 400 800 1200])
ylabel('Bead total intensity')

fitlm(flat_distance_from_center,flat_int_intens)
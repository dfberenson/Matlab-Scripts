
clear all
close all

for pos = [1:10]
    
    %% Initialize Variables
    
    % Need to change backslashes to forward slashes in filenames on Mac
    
    % folder = 'C:\Users\Skotheim Lab\Desktop\Manual_Tracking';
    source_folder = 'H:\DFB_imaging_experiments_3';
    base_expt_name = 'DFB_181031_HMEC_1E+gem_palbo_1';
    expt_source_folder = [source_folder '\' base_expt_name];
    % pos = 2;
    max_pos = 36;
    startframe = 1;
    endframe = 432;
    destination_folder = 'H:\Manually tracked imaging experiments';
    full_expt_name = [base_expt_name '_Pos' num2str(pos)];
    expt_destination_folder = [destination_folder '\' full_expt_name];
    num_colors = 4;
    order_of_colors = 'pgrf';
    % phase green red farred
    max_n = 4;
    assert(length(order_of_colors) == num_colors);
    assert(pos < max_pos);
    
    does_something_weird_happen = false;
    
    does_something_weird_happen = true;
    something_weird_happens_at_frame = 84;
    weird_thing_that_happens = 'channel_f_is_in_next_position';
    
    %% Break up stacks
    
    if ~exist(expt_destination_folder,'dir')
        mkdir(expt_destination_folder);
    end
    if ~exist([expt_destination_folder  '\' full_expt_name '_RawGray'],'dir')
        mkdir([expt_destination_folder  '\' full_expt_name '_RawGray']);
    end
    if ~exist([expt_destination_folder  '\' full_expt_name '_RawGreen'],'dir')
        mkdir([expt_destination_folder  '\' full_expt_name '_RawGreen']);
    end
    if ~exist([expt_destination_folder  '\' full_expt_name '_RawRed'],'dir')
        mkdir([expt_destination_folder  '\' full_expt_name '_RawRed']);
    end
    if num_colors == 4
        if ~exist([expt_destination_folder  '\' full_expt_name '_RawFarRed'],'dir')
            mkdir([expt_destination_folder  '\' full_expt_name '_RawFarRed']);
        end
    end
    
    complete_raw_imstack = [];
    complete_raw_imstack_nextpos = [];
    
    for n = 0:max_n
        if n == 0
            raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '.ome.tif']);
        else
            raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos) '_' num2str(n) '.ome.tif']);
        end
        
        complete_raw_imstack = cat(3,complete_raw_imstack,raw_imstack);
    end
    
    if does_something_weird_happen
        for n = 0:max_n
            if n == 0
                raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos+1) '.ome.tif']);
            else
                raw_imstack = readStack([expt_source_folder '\' base_expt_name '_MMStack_Pos' num2str(pos+1) '_' num2str(n) '.ome.tif']);
            end
            
            complete_raw_imstack_nextpos = cat(3,complete_raw_imstack_nextpos,raw_imstack);
        end
    end
    
    [Y,X,T] = size(complete_raw_imstack);
    assert(T / num_colors == endframe);
    
    if ~does_something_weird_happen
        if strcmp(order_of_colors,'prg')
            for i = startframe:endframe
                disp(['Writing image ' sprintf('%03d',i)])
                imwrite(complete_raw_imstack(:,:,num_colors*i-2),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',i) '.tif']);
                imwrite(complete_raw_imstack(:,:,num_colors*i-1),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
                imwrite(complete_raw_imstack(:,:,num_colors*i-0),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']);
            end
        elseif strcmp(order_of_colors,'pgrf')
            for i = startframe:endframe
                disp(['Writing image ' sprintf('%03d',i)])
                imwrite(complete_raw_imstack(:,:,num_colors*i-3),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                    full_expt_name '_RawGray_' sprintf('%03d',i) '.tif']);
                imwrite(complete_raw_imstack(:,:,num_colors*i-2),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                    full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']);
                imwrite(complete_raw_imstack(:,:,num_colors*i-1),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                    full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
                imwrite(complete_raw_imstack(:,:,num_colors*i-0),[expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
                    full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']);
            end
        end
        
    elseif does_something_weird_happen
        if strcmp(order_of_colors,'pgrf')
            for i = startframe:endframe
                if i < something_weird_happens_at_frame
                    disp(['Writing image ' sprintf('%03d',i)])
                    imwrite(complete_raw_imstack(:,:,num_colors*i-3),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                        full_expt_name '_RawGray_' sprintf('%03d',i) '.tif']);
                    imwrite(complete_raw_imstack(:,:,num_colors*i-2),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                        full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']);
                    imwrite(complete_raw_imstack(:,:,num_colors*i-1),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                        full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
                    imwrite(complete_raw_imstack(:,:,num_colors*i-0),[expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
                        full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']);
                else
                    if strcmp(weird_thing_that_happens,'channel_f_is_in_next_position')
                        disp(['Writing image ' sprintf('%03d',i)])
                        % There is an insertion of a frame at PosX_0 frame 333,
                        % so the gray channel starts at 334.
                        imwrite(complete_raw_imstack(:,:,num_colors*i-2),[expt_destination_folder  '\' full_expt_name '_RawGray\'...
                            full_expt_name '_RawGray_' sprintf('%03d',i) '.tif']);
                        imwrite(complete_raw_imstack(:,:,num_colors*i-1),[expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                            full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']);
                        imwrite(complete_raw_imstack(:,:,num_colors*i-0),[expt_destination_folder  '\' full_expt_name '_RawRed\'...
                            full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']);
                        imwrite(complete_raw_imstack_nextpos(:,:,num_colors*i-3),[expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
                            full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']);
                        
                        % This needs to be checked by examining the full
                        % concatenated image stack in FIJI to see what's really
                        % going on.
                    end
                end
                
                %             if mod(i,48) == 0
                %                 im_red = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawRed\'...
                %                     full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']));
                %                 im_green = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawGreen\'...
                %                     full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']));
                %                 im_blue = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
                %                     full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']));
                %                 im_composite = cat(3, im_red * 200, im_green * 100, im_blue * 200);
                %
                %                 figure()
                %                 subplot(2,2,1)
                %                 imshow(im_red * 200)
                %                 subplot(2,2,2)
                %                 imshow(im_green * 100)
                %                 subplot(2,2,3)
                %                 imshow(im_blue * 200)
                %                 subplot(2,2,4)
                %                 imshow(im_composite)
                %             end
            end
        end
    end
    
    %% Segment
    
    
    % clear overlaid_movie
    
    startframe = 1;
    endframe = 432;
    gaussian_width = 2;
    threshold = 272;
    strel_shape = 'disk';
    strel_size = 3;
    se = strel(strel_shape,strel_size);
    
    if ~exist([expt_destination_folder  '\Segmentation'],'dir')
        mkdir([expt_destination_folder  '\Segmentation']);
    end
    
    fileID = fopen([expt_destination_folder '\Segmentation\Segmentation_Parameters.txt'],'w');
    fprintf(fileID,['Gaussian filter width: ' num2str(gaussian_width) '\r\n']);
    fprintf(fileID,['Threshold > ' num2str(threshold) '\r\n']);
    fprintf(fileID,['imopen with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
    fprintf(fileID,['imclose with strel: ' strel_shape ' with size ' num2str(strel_size) '\r\n']);
    fclose(fileID);
    
    
    for  i = startframe:endframe
        disp(['Segmenting frame ' num2str(i)]);
        raw_main = imread([expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
            full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']);
        
        gaussian_filtered = imgaussfilt(raw_main,gaussian_width);
        %     figure,imshow(gaussian_filtered,[])
        thresholded = gaussian_filtered > threshold;
        % figure,imshow(thresholded)
        im_opened = imopen(thresholded,se);
        % figure,imshow(im_opened)
        im_closed = imclose(im_opened,se);
        % figure,imshow(im_closed)
        
        imwrite(im_closed,[expt_destination_folder '\Segmentation\Segmented_' sprintf('%03d',i) '.tif']);
        
        %     im_overlaid = imoverlay_fast(raw_main*200, bwperim(im_closed));
        %     overlaid_movie(:,:,i+1-startframe) = im_overlaid;
    end
    % implay(overlaid_movie)
    
    
    if mod(i,48) == 0
        im_red = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawRed\'...
            full_expt_name '_RawRed_' sprintf('%03d',i) '.tif']));
        im_green = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawGreen\'...
            full_expt_name '_RawGreen_' sprintf('%03d',i) '.tif']));
        im_blue = uint16(imread([expt_destination_folder  '\' full_expt_name '_RawFarRed\'...
            full_expt_name '_RawFarRed_' sprintf('%03d',i) '.tif']));
        im_composite = cat(3, im_red * 200, im_green * 100, im_blue * 200);
        
        figure()
        subplot(3,2,1)
        imshow(im_red * 200)
        subplot(3,2,2)
        imshow(im_green * 100)
        subplot(3,2,3)
        imshow(im_blue * 200)
        subplot(3,2,4)
        imshow(im_composite)
        subplot(3,2,5)
        imshow(im_closed,[])
        subplot(3,2,6)
        imshow(imoverlay_fast(im_composite, bwperim(im_closed), 'w'))
    end
    
    if ~exist([expt_destination_folder  '\Resegmentation\'],'dir')
        mkdir([expt_destination_folder  '\Resegmentation\']);
    end
    
end


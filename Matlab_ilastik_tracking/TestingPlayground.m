
%%

cellnum = 15;
firstframe = 249;
lastframe = 362;

s.track_metadata(cellnum).firstframe = firstframe;
s.track_metadata(cellnum).lastframe = lastframe;




%% Tiff class

clear all

fname_base = 'F:\DFB_imaging_experiments\DFB_180110_HMEC_1GFiii_palbo_After_2\DFB_180110_HMEC_1GFiii_palbo_After_2_MMStack_Pos1';
suffixes = '.ome.tif';

imstack0 = readStack([fname_base suffixes]);
imstack1 = readStack([fname_base '_1' suffixes]);
imstack2 = readStack([fname_base '_2' suffixes]);
imstack3 = readStack([fname_base '_3' suffixes]);

[~,~,imstack0_length] = size(imstack0);
[~,~,imstack1_length] = size(imstack1);
[~,~,imstack2_length] = size(imstack2);
[~,~,imstack3_length] = size(imstack3);

destination_fpath = 'E:\TestWriteStack.tif';

for i = 1:imstack0_length
    disp(['Writing image ' num2str(i)])
    imwrite(imstack0(:,:,i), destination_fpath, 'writemode', 'append');
end

for i = 1:imstack1_length
    disp(['Writing image ' num2str(i)])
    imwrite(imstack1(:,:,i), destination_fpath, 'writemode', 'append');
end

for i = 1:imstack2_length
    disp(['Writing image ' num2str(i)])
    imwrite(imstack2(:,:,i), destination_fpath, 'writemode', 'append');
end

for i = 1:imstack3_length
    disp(['Writing image ' num2str(i)])
    imwrite(imstack3(:,:,i), destination_fpath, 'writemode', 'append');
end


% fname = 'E:\Aivia\BigStack1.tif';

t = Tiff(fname);
t2 = Tiff(fname);

% imstack = readStack(fname);
% 
% destination_fpath = 'E:\TestWriteStack.tif';
% destination_fpath2 = 'E:\TestWriteStack2.tif';
% 
% imwrite(imstack(:,:,1),destination_fpath)
% imwrite(imstack(:,:,2),destination_fpath,'writemode', 'append')
% 
% for i = 1:124
%     disp(['Writing image ' num2str(i)])
%     imwrite(imstack(:,:,i),destination_fpath2,'writemode','append')
% end

%% Images

% for t = 300:400
%     disp(t)
%     imread([raw_red_prefix_e '_' sprintf('%03d',t) '.tif']);
% end
% toc
% 



%% Drawing
% a = rand(200);
% b = a > 0.5;
% imwrite(b,'E:/b.tif')


% 
% f = figure();
% ax = axes();
% M = magic(500);
% im = imshow(M,[],'Parent',ax);


% toc
% red_im = imread([handles.raw_red_prefix '_' sprintf('%03d',t) '.tif'])*handles.red_balance;
% green_im = imread([handles.raw_red_prefix '_' sprintf('%03d',t) '.tif'])*handles.green_balance;
% blue_im = imread([handles.raw_red_prefix '_' sprintf('%03d',t) '.tif'])*handles.blue_balance;
% 
% white_outlines = imread([handles.outlines_prefix '_white_' sprintf('%03d',t') '.tif']);
% yellow_outlines = imread([handles.outlines_prefix '_yellow_' sprintf('%03d',t') '.tif']);
% magenta_outlines = imread([handles.outlines_prefix '_magenta_' sprintf('%03d',t') '.tif']);
% toc
% red_im(white_outlines) = 65535;
% green_im(white_outlines) = 65535;
% blue_im(white_outlines) = 65535;
% red_im(yellow_outlines) = 65535;
% green_im(yellow_outlines) = 65535;
% blue_im(yellow_outlines) = 0;
% red_im(magenta_outlines) = 65535;
% green_im(magenta_outlines) = 0;
% blue_im(magenta_outlines) = 65535;
% color_im_outlined = cat(3, red_im, green_im, blue_im);
% 
% toc


%% Compare Hungarian algorithm to brute force

% tic
% 
% X = 9;
% M = rand(X);
% 
% testPossibleAssignments(M)
% 
% toc
% 
% munkres(M)
% 
% toc

%
%% Formatting text
% for i = 1:20
%     disp(['Writing image ' num2str(i)])
%     ['Hello ' sprintf('%03d',i)]
% end
%
%
%
%% Separating connected cells when it's hard to get the right number
% %

% raw_im = Cell_cluster_2;
% segmented = raw_im > 800;
% sep = separateConnectedCellsRawWatershed(raw_im, segmented);
% figure,imshow(raw_im,[])
% figure,imshow(segmented,[])
% figure,imshow(sep,[])

% close all
% figure,imshow(raw_im,[]),title('Raw image')
% segmented = raw_im > 800;
% figure,imshow(segmented),title('Segmented image')
% [L,n] = bwlabel(segmented);
% figure,imshow(L),title('Labeled image')
% cell_to_examine = 3;
% just_touching_cells_mask = L == cell_to_examine;
% figure,imshow(just_touching_cells_mask),title(['Just cell number ' num2str(cell_to_examine)])
% just_touching_cells_raw = imimposemin(raw_im,~just_touching_cells_mask);
% figure,imshow(just_touching_cells_raw,[]),title(['Just cell number ' num2str(cell_to_examine)])
% 
% % To try it on the whole image:
% % just_touching_cells_mask = L > 0;
% % just_touching_cells_raw = imimposemin(raw_im, ~just_touching_cells_mask)
% 
% basins_whole_raw_im = single(raw_im);
% figure,imshow(basins_whole_raw_im,[]),title('Whole raw image as basins')
% shed_whole_raw = watershed(-basins_whole_raw_im);
% figure,imshow(shed_whole_raw,[]),title('Whole raw image watershed')
% 
% basins_mask = bwdist(~just_touching_cells_mask);
% figure,imshow(basins_mask,[]),title('Bwdist image as basins')
% shed_mask = watershed(-basins_mask);
% figure,imshow(shed_mask,[]),title('Bwdist image watershed')
% 
% basins_raw = single(just_touching_cells_raw);
% figure,imshow(basins_raw,[]),title('Raw image as basins')
% shed_raw = watershed(-basins_raw);
% figure,imshow(shed_raw,[]),title('Raw image watershed')
% 
% suppressed = imhmin(basins_raw,3000);
% shed_raw = watershed(-suppressed);
% figure,imshow(shed_raw,[]),title('Raw image watershed, suppressed < 3000')
% overlaid_shed_raw = imoverlay(just_touching_cells_raw*16, shed_raw == 0, 'y');
% figure,imshow(overlaid_shed_raw,[]),title('Raw image watershed, suppressed < 3000, overlaid')
% 
% se = strel('disk', 3);
% io_raw = imopen(single(just_touching_cells_raw), se);
% figure,imshow(io_raw,[]),title('Raw image opened')
% shed_raw_opened = watershed(-io_raw);
% figure,imshow(shed_raw_opened,[]),title('Raw image opened watershed')
% overlaid_shed_raw_opened = imoverlay(just_touching_cells_raw*16, shed_raw_opened == 0, 'y');
% figure,imshow(overlaid_shed_raw_opened,[]),title('Raw image opened watershed, overlaid')
% 
% 
% se = strel('disk', 1);
% io_mask = imopen(basins_mask,se);
% figure,imshow(io_mask,[])
% shed_mask_strel = watershed(-io_mask);
% figure,imshow(shed_mask_strel)


% im = localImage;
% for d = 1:1000
%     basins = bwdist(~localImage);
%     suppressed = -imhmin(basins,7.61577+d/100000000);
%     shed = watershed(suppressed);
%     correctedLocalImage = localImage;
%     correctedLocalImage(shed == 0) = 0;
%     %     imshow(correctedLocalImage,[])
%     %     imtool(basins)
%     [~,num(d)] = bwlabel(correctedLocalImage);
% 
% end
% plot(num)


%%

% imstack = readStack('E:\Matlab ilastik\TestStack1_Object Predictions.tiff');

%% Messing around with GUI

% c = [[0 0 0];[1 0 0];[0 1 0];[0 0 1]];
%
% title(['\fontsize{16}black {\color{magenta}magenta '...
% '\color[rgb]{0 .5 .5}teal \color{red}red} black again'])

%     %code
%     line
%     set(gca,'ButtonDownFcn','disp(''axis callback'')')
%     %Now, click the axes, you will get: axis callback
%     %plot new object
%     plot(0:10)
%     %Now, click the axes, nothing happend. This is the problem!!!
%     %We change NextPlot to new to solve the problem
%     set(gca,'NextPlot','replacechildren')
%     %register callback function
%     set(gca,'ButtonDownFcn','disp(''axis callback'')')
%     plot(0:10)
%     %now, click the axes, you will get: axis callback
%     %erase previous objects [optional]
%     cla(gca)
%     %draw new object
%     line
%     %now, click the axes, you also get: axis callback


%
% f = figure
% ax1 = axes
% ax1_pos = ax1.Position;
% ax1.XColor = 'r';
% ax1.YColor = 'r';
% ax1.XLim = [0 10];
% ax1.YLim = [0 10];
% ax2 = axes('Position',ax1_pos,'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none');
% ax2.XLim = [0 10];
% ax2.YLim = [0 10];
%
% im = imshow(magic(10),[],'Parent',ax2)
%
% ax1
% ax2

% im = imshow(magic(500),[],'Parent',ax)


%
% function pickHit
% f = figure;
% ax = axes;
% p = patch(rand(1,3),rand(1,3),'g');
% l = line([1 0],[0 1]);
% set(f,'ButtonDownFcn',@(~,~)disp('figure'),...
%    'HitTest','off')
% set(ax,'ButtonDownFcn',@(~,~)disp('axes'),...
%    'HitTest','on')
% set(p,'ButtonDownFcn',@(~,~)disp('patch'),...
%    'PickableParts','all','FaceColor','none')
% set(l,'ButtonDownFcn',@(~,~)disp('line'),...
%    'HitTest','on')
% l2 = line([0 1],[0 1])
% set(l2,'HitTest','off')
% im = imshow(magic(100),[],'Parent',ax)
% set(im,'HitTest','off')
% set(ax,'HitTest','on')
% set(ax,'ButtonDownFcn',@(~,~)disp('axes'),...
%    'HitTest','on')
% end



%% Generate and save a list of unique patterns
%
% path = 'C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\UniquePatterns_';
% max_cluster_size = 8;
% for X = 1:max_cluster_size
%     tic
%     disp(X)
%     n = 1;
%     num_unique_combinations = factorial(X);
%     unique_patterns = zeros(num_unique_combinations, X);
%    for k = 0:X^X-1
%         pattern = getMatrixReadablePattern(convertToBaseX(k,X), X);
%         if length(pattern) == length(unique(pattern))
%             unique_patterns(n,:) = pattern;
%             n = n+1;
%         end
%    end
%    csvwrite([path num2str(X) '.csv'], unique_patterns)
%    toc
% end

% m = csvread([path num2str(6) '.csv']);
% sum(m,2)


%% Messing around with image cross-correlation

% % Can we do something with image cross-correlation to improve tracking
% % within a cluster?
%
% % trackedstack_gray = readSequence([folder '\Tracked_Gray\Pos' num2str(pos)],startframe,endframe,'gray');


% A = randi(9,2,3,2)
%
% X = [true,false,false;false,true,true]
%
% A(X(:,:,[1,1])) = 0


%% Messing around with splitting fused cells
% stack = readStack('E:\Test\TouchingCells3.tif');
% img = stack(:,:,1);
% touchingCells = img;
% touchingCells = uint8(img == 2);
%
%
% comp = ~touchingCells;
% basins = bwdist(comp);
% suppressed = -imhmin(basins,6.2);
% L = watershed(suppressed);
%
% % Minimum watershed depth of 6.2 empirically works well for this image.
% % Perhaps can try starting with a high depth and incrementing to lower
% % depths while counting depths until reach a height so number of distinct
% % basins is equal to the cell label.
%
% figure,imshow(comp,[])
% figure,imshow(basins,[])
% figure,imshow(suppressed,[])
% figure,imshow(L,[])
%
% nontouchingCells = touchingCells;
% nontouchingCells(L == 0) = 0;
%
% figure,imshow(touchingCells,[])
% figure,imshow(nontouchingCells,[])
%
% A = bwdist(touchingCells);
% B = bwdist(~touchingCells);
% C = -bwdist(~touchingCells);
% L = watershed(C);
%
% figure,imshow(A,[])
% figure,imshow(B,[])
% figure,imshow(C,[])
% figure,imshow(L,[])
%
% nontouchingCells = touchingCells;
% nontouchingCells(L == 0) = 0;
%
% figure,imshow(touchingCells,[])
% figure,imshow(nontouchingCells,[])
%
%


f = figure();
ax = axes();
M = magic(500);
im = imshow(M,[],'Parent',ax);



%% Compare Hungarian algorithm to brute force

tic

X = 9;
M = rand(X);

testPossibleAssignments(M)

toc

munkres(M)

toc

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
%
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

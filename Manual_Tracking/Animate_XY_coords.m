%% Initialize variables

close all
clear all

expt_folder = 'E:\RealStack';
expt_name = 'DFB_170308_HMEC_1Giii_1_hyperstack_Pos1';

X = 2560;
Y = 2160;
buffer_space = 50;

load([expt_folder '\' expt_name '\TrackingData.mat']);
s = saved_data;

make_gif = false;
gif_filepath = 'E:/animation.gif';

%% Show what happens to a cell

cellnum = 6;

first_full_click = -1;
last_full_click = -1;

click_table_size = size(s.clicks);
if cellnum <= click_table_size(2)
    
    thistrack_metadata = s.track_metadata(cellnum);
    firstframe = thistrack_metadata.firstframe;
    lastframe = thistrack_metadata.lastframe;
    mitosis = thistrack_metadata.mitosis;
    daughter1_xy = thistrack_metadata.daughter1_xy;
    daughter2_xy = thistrack_metadata.daughter2_xy;
    
    for t = s.startframe:s.endframe
        thisclick = s.clicks{t,cellnum};
        if ~isempty(thisclick)
            x_coords(t,1) = thisclick(1);
            y_coords(t,1) = thisclick(2);
            if first_full_click == -1
                first_full_click = t;
            end
            last_full_click = t;
        end
    end
end


for fig = 1:2
    figure(fig)
    hold on
    title(['Trajectory of cell ' num2str(cellnum)])
    xlabel('X coordinate')
    ylabel('Y coordinate')
    if fig == 1
        axis([1 X 1 Y])
    elseif fig == 2
        axis([min(nonzeros(x_coords))-buffer_space max(nonzeros(x_coords))+buffer_space...
            min(nonzeros(y_coords))-buffer_space max(nonzeros(y_coords))+buffer_space])
    end
    an = animatedline;
    for t = first_full_click:last_full_click
        addpoints(an, x_coords(t), y_coords(t))
        pause(0.005)
        drawnow
        if t == firstframe
            scatter(x_coords(t),y_coords(t), 'r*')
        end
        if t == lastframe
            scatter(x_coords(t),y_coords(t), 'g*')
        end
        if t == mitosis
            scatter(x_coords(t),y_coords(t), 'b*')
            scatter(daughter1_xy(1),daughter1_xy(2), 'c*')
            scatter(daughter2_xy(1),daughter2_xy(2), 'c*')
        end
        
        
        if make_gif == true
            figure_frame = getframe(gcf);
            figure_frame_img =  frame2im(figure_frame);
            [figure_frame_img,cmap] = rgb2ind(figure_frame_img,256);
            if t == first_full_click
                imwrite(figure_frame_img,cmap,gif_filepath,'gif','LoopCount',Inf,'DelayTime',0.1);
            else
                imwrite(figure_frame_img,cmap,gif_filepath,'gif','WriteMode','append','DelayTime',0.1);
            end
        end
        
    end
    hold off
end

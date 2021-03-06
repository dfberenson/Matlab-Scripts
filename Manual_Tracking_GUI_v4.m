function varargout = Manual_Tracking_GUI_v4(varargin)
% MANUAL_TRACKING_GUI_V4 MATLAB code for Manual_Tracking_GUI_v4.fig
%      MANUAL_TRACKING_GUI_V4, by itself, creates a new MANUAL_TRACKING_GUI_V4 or raises the existing
%      singleton*.
%
%      H = MANUAL_TRACKING_GUI_V4 returns the handle to a new MANUAL_TRACKING_GUI_V4 or the handle to
%      the existing singleton*.
%
%      MANUAL_TRACKING_GUI_V4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_TRACKING_GUI_V4.M with the given input arguments.
%
%      MANUAL_TRACKING_GUI_V4('Property','Value',...) creates a new MANUAL_TRACKING_GUI_V4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Manual_Tracking_GUI_v4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Manual_Tracking_GUI_v4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Manual_Tracking_GUI_v4

% Last Modified by GUIDE v2.5 02-May-2018 13:39:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Manual_Tracking_GUI_v4_OpeningFcn, ...
    'gui_OutputFcn',  @Manual_Tracking_GUI_v4_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Manual_Tracking_GUI_v4 is made visible.
function Manual_Tracking_GUI_v4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Manual_Tracking_GUI_v4 (see VARARGIN)

% Choose default command line output for Manual_Tracking_GUI_v4
handles.output = hObject;

% Update handles structure
handles.stacks_loaded = false;
handles.currently_tracking = false;
handles.current_track_start = -1;
handles.current_track_end = -1;
handles.current_track_divides = false;
handles.resegmentation_undoable = false;

handles.segmentation_thresh = 0;
handles.red_balance = 20;
handles.green_balance = 0;
handles.blue_balance = 0;

%The following default values will be overwritten when GUI is called
%with arguments
handles.expt_folder = 'E:\';
handles.expt_name = 'BigStack1';
handles.startframe = 1;
handles.endframe = 124;

%Overwrite default values when GUI is called with arguments
if length(varargin) >= 4
    handles.expt_folder = varargin{1};
    handles.expt_name = varargin{2};
    handles.startframe = varargin{3};
    handles.endframe = varargin{4};
end

handles.current_tracknum = 0;
handles.trackorsplit_status = 1;

handles.s = struct;
handles.s.all_tracknums = [];
handles.s.startframe = handles.startframe;
handles.s.endframe = handles.endframe;
handles.s.clicks = cell(0,0);
% handles.s.clicks will have an (x,y) click in each cell. The cells are
% indexed with time as a row and tracknum as a column.
handles.s.track_metadata = struct;
% handles.s.track_metadata will keep track of births and divisions, as
% well as any other information. This structure is indexed by cellnum.
handles.s.resegmentation_clicks = [];

handles.raw_red_prefix = [handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Raw\' handles.expt_name '_Raw'];
handles.raw_green_prefix = [handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Raw\' handles.expt_name '_Raw'];
handles.main_raw_prefix = handles.raw_red_prefix;
handles.reclass_prefix = [handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Object Reclassification\' handles.expt_name...
    '_Object Reclassification'];
handles.class_prefix = [handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Object Classification\' handles.expt_name...
    '_Object Classification'];
handles.trackedoutlined_prefix = [handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined'];
if ~exist([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_TrackedOutlined'],'dir')
    mkdir([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_TrackedOutlined']);
end

guidata(hObject, handles);

% UIWAIT makes Manual_Tracking_GUI_v4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Manual_Tracking_GUI_v4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = displayImage(hObject, eventdata, handles)
% Why I need to return handles here and in update_t is not clear to me.
if  ~handles.stacks_loaded
    return
end
t = handles.t;
color_im_outlined = imread([handles.trackedoutlined_prefix '_'...
    sprintf('%03d',t) '.tif']);
ax = handles.axes1;
set(ax,'NextPlot','replacechildren')
display = imshow(color_im_outlined,'Parent',ax);
set(display,'HitTest','off')
drawnow
% Have to use drawnow or it will wait until the end of the click callback,
% which takes a little while to write the outlined image.
guidata(hObject,handles)

function handles = update_t(hObject, eventdata, handles, new_t)
% Why I need to return handles here and in displayImage is not clear to me.
if new_t < 1
    handles.t = 1;
elseif new_t > handles.T
    handles.t = handles.T;
else
    handles.t = new_t;
end
set(handles.frame_slider,'Value',handles.t);
set(handles.frame_string_textbox,'String',['Frame ' num2str(handles.t) '/' num2str(handles.T)])

handles = displayImage(hObject,eventdata,handles);
guidata(hObject,handles)

% --- Executes on button press in LoadSegmentation_btn.
function LoadSegmentation_btn_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSegmentation_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.t = handles.startframe;

if exist([handles.reclass_prefix '_' sprintf('%03d',handles.t) '.tif'])
            segmented_im = imread([handles.reclass_prefix '_' sprintf('%03d',handles.t) '.tif']);
        else
            segmented_im = imread([handles.class_prefix '_' sprintf('%03d',handles.t) '.tif']);
        end
[handles.Y,handles.X] = size(segmented_im);
handles.T = handles.endframe - handles.startframe + 1;

handles.s.clicks = cell(handles.T,1);

set(handles.frame_slider,'Enable','on');
set(handles.frame_slider,'Value',1);
set(handles.frame_slider,'min',1);
set(handles.frame_slider,'max',handles.T);
set(handles.frame_slider,'SliderStep',[1/handles.T 1/handles.T]);

set(handles.axes1,'XLim',[1,handles.X]);
set(handles.axes1,'YLim',[1,handles.Y]);
set(handles.axes1,'YDir','reverse');

for t = 1:handles.T
    if ~exist([handles.trackedoutlined_prefix '_'...
            sprintf('%03d',t) '.tif'])
        disp(['Outlining image ' num2str(t) ' in white.'])
        raw_im_red = imread([handles.raw_red_prefix '_' sprintf('%03d',t) '.tif']);
        raw_im_green = imread([handles.raw_green_prefix '_' sprintf('%03d',t) '.tif']);
        if exist([handles.reclass_prefix '_' sprintf('%03d',t) '.tif'])
            segmented_im = imread([handles.reclass_prefix '_' sprintf('%03d',t) '.tif']);
        else
            segmented_im = imread([handles.class_prefix '_' sprintf('%03d',t) '.tif']);
        end
        
        color_im(:,:,1) = raw_im_red*handles.red_balance;
        color_im(:,:,2) = raw_im_green*handles.green_balance;
        color_im(:,:,3) = uint16(segmented_im)*handles.blue_balance;
        outlines = bwperim(segmented_im);
        color_im_outlined = imoverlay_fast(color_im, outlines,'white');
        imwrite(color_im_outlined,[handles.trackedoutlined_prefix '_'...
            sprintf('%03d',t) '.tif']);        
    end
end

response = questdlg('Continue a previous tracking session?');
if strcmp(response,'Yes')
    if exist([handles.expt_folder '\' handles.expt_name '\TrackingData.mat'])
        previous_session = load([handles.expt_folder '\' handles.expt_name '\TrackingData.mat']);
        handles.s = previous_session.saved_data;
        assert(handles.s.startframe == handles.startframe && handles.s.endframe == handles.endframe);
        handles.current_tracknum = handles.s.last_tracknum;
        set(handles.currentcell_textbox,'String',['Currently tracking cell ' num2str(handles.current_tracknum)]);
    end
end

handles.stacks_loaded = true;
handles = displayImage(hObject,eventdata,handles);
guidata(hObject,handles)


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.stacks_loaded == false
    return
end
value = round(get(hObject,'Value'));
handles = update_t(hObject, eventdata, handles, value);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in zoom_toggle.
function zoom_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoom_toggle
val = get(hObject,'Value');
if val == 1
    zoom on
else
    zoom off
end


% --- Executes on button press in pan_toggle.
function pan_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to pan_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pan_toggle
val = get(hObject,'Value');
if val == 1
    pan on
else
    pan off
end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if handles.stacks_loaded == false
    return
end
if strcmp(eventdata.Key, 'leftarrow') || strcmp(eventdata.Key, 'a')
    handles = update_t(hObject,eventdata,handles,handles.t - 1);
end
if strcmp(eventdata.Key, 'rightarrow') || strcmp(eventdata.Key, 'd')
    handles = update_t(hObject,eventdata,handles,handles.t + 1);
end
if strcmp(eventdata.Key,'1')
    set(handles.uibuttongroup1,'SelectedObject',handles.radiobtn_1);
    handles.trackorsplit_status = 1;
end
if strcmp(eventdata.Key,'2')
    set(handles.uibuttongroup1,'SelectedObject',handles.radiobtn_2);
    handles.trackorsplit_status = 2;
end
if strcmp(eventdata.Key,'3')
    set(handles.uibuttongroup1,'SelectedObject',handles.radiobtn_3);
    handles.trackorsplit_status = 3;
end
if strcmp(eventdata.Key,'4')
    set(handles.uibuttongroup1,'SelectedObject',handles.radiobtn_4);
    handles.trackorsplit_status = 4;
end
if strcmp(eventdata.Key,'space')
    pan on
end
if strcmp(eventdata.Key,'shift')
    zoom on
end

guidata(hObject,handles)

% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
if handles.stacks_loaded == false
    return
end
if eventdata.VerticalScrollCount == -1
    handles = update_t(hObject,eventdata,handles,handles.t - 1);
end
if eventdata.VerticalScrollCount == 1
    handles = update_t(hObject,eventdata,handles,handles.t + 1);
end
guidata(hObject,handles)


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('You touched the figure')
guidata(hObject,handles)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = round(eventdata.IntersectionPoint(1));
y = round(eventdata.IntersectionPoint(2));
disp(['You touched the axes at ' num2str(x) ' ' num2str(y)])
if handles.currently_tracking
    t = handles.t;
    if exist([handles.reclass_prefix '_' sprintf('%03d',t) '.tif'])
        segmented_im = imread([handles.reclass_prefix '_' sprintf('%03d',t) '.tif']);
    else
        segmented_im = imread([handles.class_prefix '_' sprintf('%03d',t) '.tif']);
    end
    color_im_outlined = imread([handles.trackedoutlined_prefix '_'...
        sprintf('%03d',handles.t) '.tif']);
    segmented_im = segmented_im > handles.segmentation_thresh;
    handles.resegmentation_undoable = false;
    handles.old_color_im_outlined = color_im_outlined; % Save this in case need to undo.
    handles.old_segmented_im = segmented_im; % Save this in case need to undo.
    labels = bwlabel(segmented_im, 4);
    clicked_label = labels(y,x);
    disp(['The clicked label was ' num2str(clicked_label)]);
    if clicked_label ~= 0
        if handles.trackorsplit_status == 1
            if handles.current_track_start == -1
                handles.current_track_start = handles.t;
            end
            handles.s.clicks{t, handles.current_tracknum} = [x,y];
            thistrack_labels = bwlabel(segmented_im, 4) == clicked_label;
            thistrack_outline = bwperim(thistrack_labels);
            % Recolor and write the image *after* loading the next one
            handles = update_t(hObject,eventdata,handles,handles.t + 1);
            color_im_outlined = imoverlay_fast(color_im_outlined, thistrack_outline, 'magenta');
            imwrite(color_im_outlined,[handles.trackedoutlined_prefix '_'...
                sprintf('%03d',t) '.tif']);
            if handles.t == handles.T
                % If it's the last frame, show the new version of the
                % image.
                handles = update_t(hObject,eventdata,handles,handles.t);
            end
        elseif handles.trackorsplit_status == 4
            if handles.current_track_end == -1
                handles.current_track_end = handles.t;
            end
            handles.current_track_divides = true;
            handles.s.track_metadata(handles.current_tracknum).mitosis = handles.t;
            handles = update_t(hObject,eventdata,handles,handles.t + 1);
            [daughters_x,daughters_y] = ginput_white(2);
            handles.s.track_metadata(handles.current_tracknum).daughter1_xy...
                = [daughters_x(1) daughters_y(1)];
            handles.s.track_metadata(handles.current_tracknum).daughter2_xy...
                = [daughters_x(2) daughters_y(2)];
        else
            props = regionprops(labels,'Image','BoundingBox');
            boundingBox_vals = props(clicked_label).BoundingBox;
            x_min = max(uint16(boundingBox_vals(1)),1);
            x_max = min(uint16(x_min + boundingBox_vals(3)),handles.X)-1;
            y_min = max(uint16(boundingBox_vals(2)),1);
            y_max = min(uint16(y_min + boundingBox_vals(4)),handles.Y)-1;
            segmented_bounding_box = segmented_im(y_min:y_max, x_min:x_max);
            raw_im = imread([handles.main_raw_prefix '_' sprintf('%03d',t) '.tif']);
            raw_bounding_box = raw_im(y_min:y_max, x_min:x_max);
            touching_cells = props(clicked_label).Image;
            separated_cells = separateConnectedCellsRawWatershed(raw_bounding_box,...
                touching_cells, 10, handles.trackorsplit_status);
            segmented_bounding_box(touching_cells) = separated_cells(touching_cells);
            segmented_im(y_min:y_max, x_min:x_max) = segmented_bounding_box;
            
            % Save the new segmentation as a reclassified image
            imwrite(segmented_im, [handles.reclass_prefix '_' sprintf('%03d',t) '.tif']);
            
            % Save the new cell boundaries
            newperim = bwperim(separated_cells);
            newperim_bigimage = logical(zeros(handles.Y,handles.X));
            newperim_bigimage(y_min:y_max, x_min:x_max) = newperim;
            color_im_outlined = imoverlay_fast(color_im_outlined, newperim_bigimage, 'white');
            imwrite(color_im_outlined,[handles.trackedoutlined_prefix '_'...
                sprintf('%03d',t) '.tif']);
            
            handles = update_t(hObject,eventdata,handles,handles.t);
            handles.s.resegmentation_clicks = [handles.resegmentation_clicks; {[handles.trackorsplit_status,x,y]}];
            handles.resegmentation_undoable = true;
        end
    end
end
guidata(hObject, handles);


% --- Executes on button press in new_track_btn.
function new_track_btn_Callback(hObject, eventdata, handles)
% hObject    handle to new_track_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.stacks_loaded
    return
end

if handles.currently_tracking && ~handles.current_track_divides
    response = questdlg('You have not marked a division for the current cell. Terminate track after this frame anyways?');
    if strcmp(response,'Yes')
        handles.current_track_end = handles.t;
    else
        return
    end
end

% First, go through and color yellow all cells already tracked.
tic
recolorize_start = 1;
recolorize_end = handles.T;

if handles.current_track_start ~= -1 && handles.current_track_end ~= -1
    recolorize_start = handles.current_track_start;
    recolorize_end = handles.current_track_end;
end

for t = recolorize_start:recolorize_end
    disp(['Outlining image ' num2str(t) ' in yellow.'])
        if exist([handles.reclass_prefix '_' sprintf('%03d',t) '.tif'])
            segmented_im = imread([handles.reclass_prefix '_' sprintf('%03d',t) '.tif']);
        else
            segmented_im = imread([handles.class_prefix '_' sprintf('%03d',t) '.tif']);
        end
    segmented_im = segmented_im > handles.segmentation_thresh;
    labels = bwlabel(segmented_im, 4);
    potential_clicks_thisframe = handles.s.clicks(t,:);
    real_clicks_thisframe = potential_clicks_thisframe(~cellfun('isempty',potential_clicks_thisframe));      
    all_tracked_cell_label_nums_thisframe = [];
    for i = 1:length(real_clicks_thisframe)
        thisclick = real_clicks_thisframe{i};
        all_tracked_cell_label_nums_thisframe(i) = nonzeros(labels(thisclick(2),thisclick(1)));
    end
    if ~isempty(all_tracked_cell_label_nums_thisframe)
        tracked_labels = ismember(bwlabel(segmented_im, 4), all_tracked_cell_label_nums_thisframe);
        tracked_outlines = bwperim(tracked_labels);
        color_im_outlined = imread([handles.trackedoutlined_prefix '_'...
            sprintf('%03d',t) '.tif']);
        color_im_outlined = imoverlay_fast(color_im_outlined, tracked_outlines, 'yellow');
        imwrite(color_im_outlined,[handles.trackedoutlined_prefix '_'...
            sprintf('%03d',t) '.tif']);
    end
end
toc

% Reset radio button group to track mode
buttongroup = handles.uibuttongroup1;
radiobutton_1 = handles.radiobtn_1;
set(handles.uibuttongroup1,'SelectedObject',handles.radiobtn_1);
handles.trackorsplit_status = 1;

handles.current_tracknum = handles.current_tracknum + 1;
set(handles.currentcell_textbox,'String',['Currently tracking cell ' num2str(handles.current_tracknum)]);
handles.s.all_tracknums = sort(unique([handles.s.all_tracknums, handles.current_tracknum]));
handles.currently_tracking = true;
handles.current_track_start = -1;
handles.current_track_end = -1;
handles.current_track_divides = false;
handles = update_t(hObject,eventdata,handles,handles.t);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in save_results_btn.
function save_results_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_results_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disp(handles.s)
% disp(handles.s.clicks)
% response = questdlg('Save the data to a .mat file? This will overwrite the previous data.');

handles.s.last_tracknum = handles.current_tracknum;
saved_data = handles.s;

if exist([handles.expt_folder '\' handles.expt_name '\TrackingData.mat'])
    response = questdlg('There is already a saved file. Overwrite?');
    if strcmp(response,'Yes')
        save([handles.expt_folder '\' handles.expt_name '\TrackingData.mat'],'saved_data');
        msgbox('Saved!');
    end
else
    save([handles.expt_folder '\' handles.expt_name '\TrackingData.mat'],'saved_data');
    msgbox('Saved!');
end

% --- Executes on button press in clearcolors_btn.
function clearcolors_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clearcolors_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.stacks_loaded
    return
end
for t = 1:handles.T
        disp(['Outlining image ' num2str(t) ' in white.'])
        raw_im_red = imread([handles.raw_red_prefix '_' sprintf('%03d',t) '.tif']);
        raw_im_green = imread([handles.raw_green_prefix '_' sprintf('%03d',t) '.tif']);
        if exist([handles.reclass_prefix '_' sprintf('%03d',t) '.tif'])
            segmented_im = imread([handles.reclass_prefix '_' sprintf('%03d',t) '.tif']);
        else
            segmented_im = imread([handles.class_prefix '_' sprintf('%03d',t) '.tif']);
        end
        
        color_im(:,:,1) = raw_im_red*handles.red_balance;
        color_im(:,:,2) = raw_im_green*handles.green_balance;
        color_im(:,:,3) = uint16(segmented_im)*handles.blue_balance;
        outlines = bwperim(segmented_im);
        color_im_outlined = imoverlay_fast(color_im, outlines,'white');
        imwrite(color_im_outlined,[handles.trackedoutlined_prefix '_'...
            sprintf('%03d',t) '.tif']);
end
handles = update_t(hObject,eventdata,handles,1);


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if eventdata.NewValue == handles.radiobtn_1
    handles.trackorsplit_status = 1;
elseif eventdata.NewValue == handles.radiobtn_2
    handles.trackorsplit_status = 2;
elseif eventdata.NewValue == handles.radiobtn_3
    handles.trackorsplit_status = 3;
elseif eventdata.NewValue == handles.radiobtn_4
    handles.trackorsplit_status = 4;
end
guidata(hObject,handles)


% --- Executes on button press in undosplit_btn.
function undosplit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to undosplit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.resegmentation_undoable
    return
end
imwrite(handles.old_segmented_im, [handles.reclass_prefix '_' sprintf('%03d',handles.t) '.tif']);
imwrite(handles.old_color_im_outlined, [handles.trackedoutlined_prefix '_' sprintf('%03d',handles.t) '.tif']);
handles = update_t(hObject,eventdata,handles,handles.t);
handles.s.resegmentation_clicks = handles.s.resegmentation_clicks(1:end-1);
handles.resegmentation_undoable = false;
guidata(hObject,handles)


% --- Executes on button press in display_current_track_btn.
function display_current_track_btn_Callback(hObject, eventdata, handles)
% hObject    handle to display_current_track_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.stacks_loaded
    return
end
if handles.current_tracknum == 0
    return
end
size_click_matrix = size(handles.s.clicks);
if handles.current_tracknum > size_click_matrix(2)
    return
end
for t = handles.startframe:handles.endframe
    disp(['Tracked click at frame ' num2str(t) ': ' num2str(handles.s.clicks{t,handles.current_tracknum})])
end
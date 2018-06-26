function varargout = Manual_Tracking_GUI_v2(varargin)
% MANUAL_TRACKING_GUI_V2 MATLAB code for Manual_Tracking_GUI_v2.fig
%      MANUAL_TRACKING_GUI_V2, by itself, creates a new MANUAL_TRACKING_GUI_V2 or raises the existing
%      singleton*.
%
%      H = MANUAL_TRACKING_GUI_V2 returns the handle to a new MANUAL_TRACKING_GUI_V2 or the handle to
%      the existing singleton*.
%
%      MANUAL_TRACKING_GUI_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_TRACKING_GUI_V2.M with the given input arguments.
%
%      MANUAL_TRACKING_GUI_V2('Property','Value',...) creates a new MANUAL_TRACKING_GUI_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Manual_Tracking_GUI_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Manual_Tracking_GUI_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Manual_Tracking_GUI_v2

% Last Modified by GUIDE v2.5 25-Apr-2018 19:46:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Manual_Tracking_GUI_v2_OpeningFcn, ...
    'gui_OutputFcn',  @Manual_Tracking_GUI_v2_OutputFcn, ...
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


% --- Executes just before Manual_Tracking_GUI_v2 is made visible.
function Manual_Tracking_GUI_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Manual_Tracking_GUI_v2 (see VARARGIN)

% Choose default command line output for Manual_Tracking_GUI_v2
handles.output = hObject;



% Update handles structure
handles.raw_stacks_loaded = false;
handles.segmentation_loaded = false;
handles.stacks_loaded = false;
handles.currently_tracking = false;
handles.some_tracked = false;

handles.red_balance = 20;
handles.green_balance = 0;
handles.blue_balance = 0;

handles.segmented_im = [];
handles.current_tracknum = 0;
handles.s = struct;
handles.s.all_tracknums = [];
handles.s.tracks = zeros();

%The following default values will be overwritten when GUI is called
%with arguments
handles.expt_folder = 'E:\Matlab ilastik';
handles.expt_name = 'BigStack1';
handles.startframe = 1;
handles.endframe = 10;
if ~exist([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_TrackedOutlined'],'dir')
    mkdir([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_TrackedOutlined']);
end

%Overwrite default values when GUI is called with arguments
if length(varargin) >= 4
    handles.image_folder = varargin{1};
    handles.expt_name = varargin{2};
    handles.startframe = varargin{3};
    handles.endframe = varargin{4};
end
guidata(hObject, handles);

% UIWAIT makes Manual_Tracking_GUI_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Manual_Tracking_GUI_v2_OutputFcn(hObject, eventdata, handles)
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

% raw_im_red = handles.rawimstack_red(:,:,t);
% raw_im_green = handles.rawimstack_green(:,:,t);
% segmented_im = handles.segmentationstack(:,:,t);

handles.color_im_outlined = imread([handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
    sprintf('%03d',t) '.tif']);
segmented_im = imread([handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Object Classification\' handles.expt_name...
    '_Object Classification_' sprintf('%03d',t) '.tif']);
segmented_im = segmented_im > 0;
handles.segmented_im = segmented_im;

% if ~exist([handles.expt_folder '\' handles.expt_name '\'...
%         handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
%         sprintf('%03d',t) '.tif'])
%     
%     raw_im_red = imread([handles.expt_folder '\' handles.expt_name '\'...
%         handles.expt_name '_Raw\' handles.expt_name '_Raw_' sprintf('%03d',t) '.tif']);
%     raw_im_green = imread([handles.expt_folder '\' handles.expt_name '\'...
%         handles.expt_name '_Raw\' handles.expt_name '_Raw_' sprintf('%03d',t) '.tif']);
%     
%     color_im(:,:,1) = raw_im_red*handles.red_balance;
%     color_im(:,:,2) = raw_im_green*handles.green_balance;
%     color_im(:,:,3) = uint16(segmented_im)*handles.blue_balance;
%     handles.color_im = color_im;
%     outlines = bwperim(segmented_im);
%     color_im_outlined = imoverlay(color_im, outlines,'white');
%     imwrite(color_im_outlined,[handles.expt_folder '\' handles.expt_name '\'...
%         handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
%         sprintf('%03d',t) '.tif']);
% else
%     color_im_outlined = imread([handles.expt_folder '\' handles.expt_name '\'...
%         handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
%         sprintf('%03d',t) '.tif']);
% end
% toc
% if handles.some_tracked
%     all_tracked_cell_label_nums_thisframe = nonzeros(handles.s.tracks(t,:));
%     if ~isempty(all_tracked_cell_label_nums_thisframe)
%         tracked_labels = ismember(bwlabel(segmented_im), all_tracked_cell_label_nums_thisframe);
%         tracked_outlines = bwperim(tracked_labels);
%         color_im_outlined = imoverlay(color_im_outlined, tracked_outlines, 'yellow');
%     end
% end
% if handles.currently_tracking
%     this_tracked_cell_label_nums_thisframe = nonzeros(handles.s.tracks(t,handles.current_tracknum));
%     if ~isempty(this_tracked_cell_label_nums_thisframe)
%         foundthiscell = true;
%         thistrack_labels = ismember(bwlabel(segmented_im), this_tracked_cell_label_nums_thisframe);
%         thistrack_outline = bwperim(thistrack_labels);
%         color_im_outlined = imoverlay(color_im_outlined, thistrack_outline, 'magenta');
%     end
% end
ax = handles.axes1;
set(ax,'NextPlot','replacechildren')
display = imshow(handles.color_im_outlined,'Parent',ax);
set(display,'HitTest','off')
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

% --- Executes on button press in LoadRawStack_btn.
function LoadRawStack_btn_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRawStack_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% rawimstack_red = readSequence([handles.expt_folder '\' handles.expt_name '\'...
%     handles.expt_name '_Raw\' handles.expt_name '_Raw'],handles.startframe,handles.endframe,'gray');
% rawimstack_green = readSequence([handles.expt_folder '\' handles.expt_name '\'...
%     handles.expt_name '_Raw\' handles.expt_name '_Raw'],handles.startframe,handles.endframe,'gray');
% 
% handles.rawimstack_red = rawimstack_red;
% handles.rawimstack_green = rawimstack_green;
% 
% [handles.Y,handles.X,handles.T] = size(rawimstack_red);
% 
% handles.t = 1;
% 
% set(handles.frame_slider,'Enable','on')
% set(handles.frame_slider,'Value',1);
% set(handles.frame_slider,'min',1);
% set(handles.frame_slider,'max',handles.T);
% set(handles.frame_slider,'SliderStep',[1/handles.T 1/handles.T])
% 
% set(handles.axes1,'XLim',[1,handles.X]);
% set(handles.axes1,'YLim',[1,handles.Y]);
% set(handles.axes1,'YDir','reverse')
% 
% handles.raw_stacks_loaded = true;
% if handles.segmentation_loaded
%     handles.stacks_loaded = true;
% end
% displayImage(hObject,eventdata,handles)
guidata(hObject,handles) %Don't forget to store the updated variables


% --- Executes on button press in LoadSegmentation_btn.
function LoadSegmentation_btn_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSegmentation_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

segmentationstack = readSequence([handles.expt_folder '\' handles.expt_name '\'...
    handles.expt_name '_Object Classification\' handles.expt_name '_Object Classification'],handles.startframe,handles.endframe,'gray');
handles.segmentationstack = segmentationstack > 0;

[handles.Y,handles.X,handles.T] = size(segmentationstack);
handles.s.tracks = zeros(handles.T,1);
handles.t = 1;

set(handles.frame_slider,'Enable','on')
set(handles.frame_slider,'Value',1);
set(handles.frame_slider,'min',1);
set(handles.frame_slider,'max',handles.T);
set(handles.frame_slider,'SliderStep',[1/handles.T 1/handles.T])

set(handles.axes1,'XLim',[1,handles.X]);
set(handles.axes1,'YLim',[1,handles.Y]);
set(handles.axes1,'YDir','reverse')

for t = 1:handles.T
    disp(['Outlining image ' num2str(t)])
    raw_im_red = imread([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_Raw\' handles.expt_name '_Raw_' sprintf('%03d',t) '.tif']);
    raw_im_green = imread([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_Raw\' handles.expt_name '_Raw_' sprintf('%03d',t) '.tif']);
    segmented_im = imread([handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_Object Classification\' handles.expt_name...
        '_Object Classification_' sprintf('%03d',t) '.tif']);
    
    color_im(:,:,1) = raw_im_red*handles.red_balance;
    color_im(:,:,2) = raw_im_green*handles.green_balance;
    color_im(:,:,3) = uint16(segmented_im)*handles.blue_balance;
    outlines = bwperim(segmented_im);
    color_im_outlined = imoverlay(color_im, outlines,'white');
    imwrite(color_im_outlined,[handles.expt_folder '\' handles.expt_name '\'...
        handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
        sprintf('%03d',t) '.tif']);
end

    handles.stacks_loaded = true;
displayImage(hObject,eventdata,handles)
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
% if strcmp(eventdata.Key,'0') || strcmp(eventdata.Key,'1') || strcmp(eventdata.Key,'2')...
%         || strcmp(eventdata.Key,'3') || strcmp(eventdata.Key,'4')...
%         || strcmp(eventdata.Key,'5') || strcmp(eventdata.Key,'6')
%     handles.reclassify_as = str2num(eventdata.Key);
% end

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
    labels = bwlabel(handles.segmented_im > 0);
    clicked_label = labels(y,x);
    disp(['The clicked label was ' num2str(clicked_label)]);
    if clicked_label ~= 0
        handles.s.tracks(t, handles.current_tracknum) = clicked_label;
        segmented_im = handles.segmented_im;
        thistrack_labels = bwlabel(segmented_im) == clicked_label;
        thistrack_outline = bwperim(thistrack_labels);
        color_im_outlined = handles.color_im_outlined;
        handles = update_t(hObject,eventdata,handles,handles.t + 1);
        % Recolor and write the image after loading the next one
        color_im_outlined = imoverlay(color_im_outlined, thistrack_outline, 'magenta');
        imwrite(color_im_outlined,[handles.expt_folder '\' handles.expt_name '\'...
            handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
            sprintf('%03d',t) '.tif']);
    end
end
guidata(hObject, handles);


% --- Executes on button press in new_track_btn.
function new_track_btn_Callback(hObject, eventdata, handles)
% hObject    handle to new_track_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First, go through and color yellow all cells already tracked.
for t = 1:handles.T
    disp(['Outlining image ' num2str(t)])
    all_tracked_cell_label_nums_thisframe = nonzeros(handles.s.tracks(t,:));
    if ~isempty(all_tracked_cell_label_nums_thisframe)
        segmented_im = imread([handles.expt_folder '\' handles.expt_name '\'...
            handles.expt_name '_Object Classification\' handles.expt_name...
            '_Object Classification_' sprintf('%03d',t) '.tif']);
        segmented_im = segmented_im > 0;
        tracked_labels = ismember(bwlabel(segmented_im), all_tracked_cell_label_nums_thisframe);
        tracked_outlines = bwperim(tracked_labels);
        color_im_outlined = imread([handles.expt_folder '\' handles.expt_name '\'...
            handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
            sprintf('%03d',t) '.tif']);
        color_im_outlined = imoverlay(color_im_outlined, tracked_outlines, 'yellow');
        imwrite(color_im_outlined,[handles.expt_folder '\' handles.expt_name '\'...
            handles.expt_name '_TrackedOutlined\' handles.expt_name '_TrackedOutlined_'...
            sprintf('%03d',t) '.tif']);
    end
end
handles.current_tracknum = handles.current_tracknum + 1;
handles.s.all_tracknums = sort(unique([handles.s.all_tracknums, handles.current_tracknum]));
handles.s.tracks(handles.T, handles.current_tracknum) = 0; %Expand table as far as necessary
handles.some_tracked = true;
handles.currently_tracking = true;
handles = update_t(hObject,eventdata,handles,1);
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


% --- Executes on button press in display_results_btn.
function display_results_btn_Callback(hObject, eventdata, handles)
% hObject    handle to display_results_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(handles.s)
disp(handles.s.tracks)

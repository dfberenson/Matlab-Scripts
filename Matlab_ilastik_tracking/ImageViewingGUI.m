
function varargout = ImageViewingGUI(varargin)
% IMAGEVIEWINGGUI MATLAB code for ImageViewingGUI.fig
%      IMAGEVIEWINGGUI, by itself, creates a new IMAGEVIEWINGGUI or raises the existing
%      singleton*.
%
%      H = IMAGEVIEWINGGUI returns the handle to a new IMAGEVIEWINGGUI or the handle to
%      the existing singleton*.
%
%      IMAGEVIEWINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEVIEWINGGUI.M with the given input arguments.
%
%      IMAGEVIEWINGGUI('Property','Value',...) creates a new IMAGEVIEWINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageViewingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageViewingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageViewingGUI

% Last Modified by GUIDE v2.5 23-Mar-2018 14:23:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImageViewingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ImageViewingGUI_OutputFcn, ...
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


% --- Executes just before ImageViewingGUI is made visible.
function ImageViewingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageViewingGUI (see VARARGIN)

% Choose default command line output for ImageViewingGUI
handles.output = hObject;

% Update handles structure
handles.stacks_loaded = false;
handles.image_folder = 'E:\Matlab ilastik';
handles.expt_name = 'BigStack1';
handles.startframe = 1;
handles.endframe = 124;
 if nargin > 4
     handles.image_folder = varargin{1};
     handles.expt_name = varargin{2};
     handles.startframe = varargin{3};
     handles.endframe = varargin{4};
 end

handles.obj_class_cmap = [[0 0 0];[1 0 0];[0 1 0];[0 0 1];[1 1 0];[1 0 1];[0 1 1]];
handles.reclassify_as = 1;
handles.expt_folder = [handles.image_folder '\' handles.expt_name];

ax = handles.ObjectClassificationAxes;
title(ax,'Previous Object Classification')
ylabel(ax,['\fontsize{16}0 {\color{red}1 \color{green}2 \color{blue}3 '...
    '\color{yellow}4} \color{cyan}5 \color{magenta}6'])
ax = handles.ObjectReclassificationAxes;
title(ax,'Object Reclassification')
ylabel(ax,['\fontsize{16}0 {\color{red}1 \color{green}2 \color{blue}3 '...
    '\color{yellow}4} \color{cyan}5 \color{magenta}6'])
ax = handles.RawImageAxes;
title(ax,'Raw Image')
ax = handles.TrackedAxes;
title(ax,'Tracked Image')

guidata(hObject, handles);

% UIWAIT makes ImageViewingGUI wait for user response (see UIRESUME)
% uiwait(handles.ObjectReclassificationFigure);


% --- Outputs from this function are returned to the command line.
function varargout = ImageViewingGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_Stack_btn.
function Load_Stack_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Stack_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.raw_image_stack = readStack([handles.image_folder '\' handles.expt_name '.tif']);
% handles.object_classification_stack = readStack([handles.image_folder '\' handles.expt_name '_Object Predictions.tiff']);
% handles.tracked_stack = readSequence([handles.image_folder '\' handles.expt_name '_TrackingResults\Tracked_RGB\Tracked_RGB'],1,60,'rgb');
% handles.object_reclassification_stack = handles.object_classification_stack;

handles.raw_image_stack = readSequence([handles.expt_folder '\'...
    handles.expt_name '_Raw\' handles.expt_name '_Raw'],handles.startframe,handles.endframe,'gray');
handles.object_classification_stack = readSequence([handles.expt_folder '\'...
    handles.expt_name '_Object Classification\' handles.expt_name '_Object Classification'],handles.startframe,handles.endframe,'gray');
handles.tracked_stack = readSequence([handles.expt_folder '\'...
    handles.expt_name '_TrackingResults\Tracked_RGB\Tracked_RGB'],handles.startframe,handles.endframe,'rgb');
handles.object_reclassification_stack = readSequence([handles.expt_folder '\'...
    handles.expt_name '_Object Reclassification\' handles.expt_name '_Object Reclassification'],handles.startframe,handles.endframe,'gray');

[raw_Y,raw_X,raw_T] = size(handles.raw_image_stack);
[obj_class_Y,obj_class_X,obj_class_T] = size(handles.object_classification_stack);

assert(raw_X == obj_class_X && raw_Y == obj_class_Y && raw_T == obj_class_T);
handles.X = raw_X;
handles.Y = raw_Y;
handles.T = raw_T;

handles.t = 1;

set(handles.frame_slider,'Enable','on')
set(handles.frame_slider,'Value',1);
set(handles.frame_slider,'min',1);
set(handles.frame_slider,'max',handles.T);
set(handles.frame_slider,'SliderStep',[1/handles.T 1/handles.T])

set(handles.ObjectClassificationAxes,'XLim',[1,handles.X]);
set(handles.ObjectClassificationAxes,'YLim',[1,handles.Y]);
set(handles.ObjectClassificationAxes,'YDir','reverse')
set(handles.ObjectReclassificationAxes,'XLim',[1,handles.X]);
set(handles.ObjectReclassificationAxes,'YLim',[1,handles.Y]);
set(handles.ObjectReclassificationAxes,'YDir','reverse')
set(handles.RawImageAxes,'XLim',[1,handles.X]);
set(handles.RawImageAxes,'YLim',[1,handles.Y]);
set(handles.RawImageAxes,'YDir','reverse')
set(handles.TrackedAxes,'XLim',[1,handles.X]);
set(handles.TrackedAxes,'YLim',[1,handles.Y]);
set(handles.TrackedAxes,'YDir','reverse')

handles.stacks_loaded = true;
displayImage(hObject,eventdata,handles)
guidata(hObject,handles) %Don't forget to store the updated variables



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
set(hObject,'Value',value);
handles.t = value;
displayImage(hObject,eventdata,handles)
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


% --- Executes during object creation, after setting all properties.
function frame_string_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_string_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on mouse press over axes background.
function ObjectClassificationAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ObjectClassificationAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = round(eventdata.IntersectionPoint(1));
y = round(eventdata.IntersectionPoint(2));

disp(['You touched the Classification axes at ' num2str(x) ' ' num2str(y)])
% disp(eventdata.IntersectionPoint(1))
% disp(eventdata.IntersectionPoint(2))
guidata(hObject, handles);


% --- Executes on mouse press over figure background.
function ObjectReclassificationFigure_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ObjectReclassificationFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('You touched the figure')


function displayImage(hObject, eventdata, handles)
t = handles.t;
set(handles.frame_string_textbox,'String',['Frame ' num2str(handles.t) '/' num2str(handles.T)])

object_classification_im = handles.object_classification_stack(:,:,handles.t);
object_classification_axes = handles.ObjectClassificationAxes;
set(object_classification_axes,'NextPlot','replacechildren')
object_classification_im_display = imshow(object_classification_im,handles.obj_class_cmap,...
    'Parent',object_classification_axes);
set(object_classification_im_display,'HitTest','off')

object_reclassification_im = handles.object_reclassification_stack(:,:,handles.t);
object_reclassification_axes = handles.ObjectReclassificationAxes;
set(object_reclassification_axes,'NextPlot','replacechildren')
object_reclassification_im_display = imshow(object_reclassification_im,handles.obj_class_cmap,...
    'Parent',object_reclassification_axes);
set(object_reclassification_im_display,'HitTest','off')

raw_im = handles.raw_image_stack(:,:,handles.t);
raw_axes = handles.RawImageAxes;
set(raw_axes,'NextPlot','replacechildren')
raw_im_display = imshow(raw_im,[],'Parent',raw_axes);
set(raw_im_display,'HitTest','off')

tracked_im = handles.tracked_stack(:,:,:,handles.t);
tracked_axes = handles.TrackedAxes;
set(tracked_axes,'NextPlot','replacechildren')
tracked_im_display = imshow(tracked_im,[],'Parent',tracked_axes);
set(tracked_im_display,'HitTest','off')

%  set(ax,'HitTest','on')
%  set(ax,'PickableParts','all')
guidata(hObject,handles)


% --- Executes on key press with focus on ObjectReclassificationFigure or any of its controls.
function ObjectReclassificationFigure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ObjectReclassificationFigure (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if handles.stacks_loaded == false
    return
end
if strcmp(eventdata.Key, 'leftarrow') || strcmp(eventdata.Key, 'a')
    handles.t = max(1, handles.t - 1);
    set(handles.frame_slider,'Value',handles.t);
end
if strcmp(eventdata.Key, 'rightarrow') || strcmp(eventdata.Key, 'd')
    handles.t = min(handles.T, handles.t+1);
    set(handles.frame_slider,'Value',handles.t);
end
if strcmp(eventdata.Key,'0') || strcmp(eventdata.Key,'1') || strcmp(eventdata.Key,'2')...
        || strcmp(eventdata.Key,'3') || strcmp(eventdata.Key,'4')...
        || strcmp(eventdata.Key,'5') || strcmp(eventdata.Key,'6')
    handles.reclassify_as = str2num(eventdata.Key);
end
displayImage(hObject,eventdata,handles)
guidata(hObject,handles)


% --- Executes on scroll wheel click while the figure is in focus.
function ObjectReclassificationFigure_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to ObjectReclassificationFigure (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
if handles.stacks_loaded == false
    return
end
if eventdata.VerticalScrollCount == -1
    handles.t = max(1, handles.t - 1);
end
if eventdata.VerticalScrollCount == 1
    handles.t = min(handles.T, handles.t+1);
end
set(handles.frame_slider,'Value',handles.t);
displayImage(hObject,eventdata,handles)
guidata(hObject,handles)


% --- Executes on mouse press over axes background.
function ObjectReclassificationAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ObjectReclassificationAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = round(eventdata.IntersectionPoint(1));
y = round(eventdata.IntersectionPoint(2));
disp(['You touched the Reclassification axes at ' num2str(x) ' ' num2str(y)])
if handles.stacks_loaded == false
    return
end
disp(['The previous classification was ' num2str(handles.object_reclassification_stack(y,x,handles.t))])
disp(['The new classification is ' num2str(handles.reclassify_as)])
handles.object_reclassification_stack(:,:,handles.t) =...
    reclassifyCells(handles.object_reclassification_stack(:,:,handles.t),x,y,handles.reclassify_as);
displayImage(hObject,eventdata,handles)
guidata(hObject, handles);


% --- Executes on button press in save_reclassifications_btn.
function save_reclassifications_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_reclassifications_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 writeSequence(handles.object_reclassification_stack,handles.expt_folder,handles.expt_name,...
     'Object Reclassification',handles.startframe,handles.endframe,'gray');

% When I display an image on to my Axes using imshow, I lose the ability to access the callback function for the underlying Axes. I have adjusted the HitTest and PickableParts already. My code is below. Thanks!


function varargout = MinimalGUI_2(varargin)
% MINIMALGUI_2 MATLAB code for MinimalGUI_2.fig
%      MINIMALGUI_2, by itself, creates a new MINIMALGUI_2 or raises the existing
%      singleton*.
%
%      H = MINIMALGUI_2 returns the handle to a new MINIMALGUI_2 or the handle to
%      the existing singleton*.
%
%      MINIMALGUI_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINIMALGUI_2.M with the given input arguments.
%
%      MINIMALGUI_2('Property','Value',...) creates a new MINIMALGUI_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MinimalGUI_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MinimalGUI_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MinimalGUI_2

% Last Modified by GUIDE v2.5 22-Mar-2018 17:49:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MinimalGUI_2_OpeningFcn, ...
                   'gui_OutputFcn',  @MinimalGUI_2_OutputFcn, ...
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


% --- Executes just before MinimalGUI_2 is made visible.
function MinimalGUI_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MinimalGUI_2 (see VARARGIN)

% Choose default command line output for MinimalGUI_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MinimalGUI_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MinimalGUI_2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ax = handles.axes1;
set(ax,'NextPlot','replacechildren')
im = imshow(magic(10),[],'Parent',ax);
set(im,'HitTest','off')
set(im,'PickableParts','none')
set(ax,'HitTest','on')
set(ax,'PickableParts','all')
guidata(hObject,handles)


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('You touched the Axes')


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('You touched the Figure')


% --- Executes on button press in info.
function info_Callback(hObject, eventdata, handles)
% hObject    handle to info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gca
ax = handles.axes1;
gca == ax
i = allchild(ax);
fprintf(['Axes hit test is ' num2str(get(ax,'HitTest')) '\n'])
fprintf(['Axes pickable parts is ' num2str(get(ax,'PickableParts')) '\n'])
fprintf(['Image hit test is ' num2str(get(i,'HitTest')) '\n'])
fprintf(['Image pickable parts is ' num2str(get(i,'PickableParts')) '\n'])

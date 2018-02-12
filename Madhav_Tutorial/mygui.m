function varargout = mygui(varargin)
% MYGUI MATLAB code for mygui.fig
%      MYGUI, by itself, creates a new MYGUI or raises the existing
%      singleton*.
%
%      H = MYGUI returns the handle to a new MYGUI or the handle to
%      the existing singleton*.
%
%      MYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYGUI.M with the given input arguments.
%
%      MYGUI('Property','Value',...) creates a new MYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mygui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mygui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mygui

% Last Modified by GUIDE v2.5 03-Feb-2018 16:56:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mygui_OpeningFcn, ...
                   'gui_OutputFcn',  @mygui_OutputFcn, ...
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


% --- Executes just before mygui is made visible.
function mygui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mygui (see VARARGIN)

% Choose default command line output for mygui
handles.output = hObject;
handles.loaded = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mygui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mygui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadstack.
function loadstack_Callback(hObject, eventdata, handles)
% hObject    handle to loadstack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentDir = 'C:\Users\Skotheim Lab\Desktop\Matlab Scripts\Madhav_Tutorial';
[filename,path] = uigetfile('*.stk','Choose stack: ');

%Load the stack
if(filename)
    [stk,stacklength] = stkread([path filename]);
    handles.stk = stk;
    handles.loaded = 1;
else
    cd(CurrentDir);
    return
end
set(handles.planeslider,'Min',1,'Max',stacklength);
figure(1);
imshow(stk(1).data,[]);
guidata(hObject,handles);


% --- Executes on slider movement.
function planeslider_Callback(hObject, eventdata, handles)
% hObject    handle to planeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if(handles.loaded == 1)
    slideval = get(handles.planeslider,'Value');
    plane = round(slideval);
    im = handles.stk(plane).data;
    imin = min(min(im));
    imax = max(max(im));
%     imin
%     imax
%     handles.stk(plane).data;
    figure(1)
    imagesc(handles.stk(plane).data,[imin imax]);
%     figure(2)
%     imshow(handles.stk(plane))
    colormap('gray');
%     children = get(gca,'children');
%     delete(children(end));
    xlabel(['plane' num2str(plane)]);
end



% --- Executes during object creation, after setting all properties.
function planeslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to planeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in kymo.
function kymo_Callback(hObject, eventdata, handles)
% hObject    handle to kymo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stk = handles.stk;
imshow(stk(2).data,[])
[y,x,p] = impixel;

kymo = [];
for i = 1:length(stk)
    im = im2double(stk(i).data);
    c = improfile(im,x,y);
    kymo = [kymo c];
end
%kymo = kymo';
figure(2)
imagesc(kymo,[min(min(kymo)),max(max(kymo))])

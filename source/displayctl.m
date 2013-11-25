function varargout = displayctl(varargin)
%DISPLAYCTL M-file for displayctl.fig
%      DISPLAYCTL, by itself, creates a new DISPLAYCTL or raises the existing
%      singleton*.
%
%      H = DISPLAYCTL returns the handle to a new DISPLAYCTL or the handle to
%      the existing singleton*.
%
%      DISPLAYCTL('Property','Value',...) creates a new DISPLAYCTL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to displayctl_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DISPLAYCTL('CALLBACK') and DISPLAYCTL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DISPLAYCTL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help displayctl

% Last Modified by GUIDE v2.5 28-Jun-2007 17:23:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @displayctl_OpeningFcn, ...
                   'gui_OutputFcn',  @displayctl_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before displayctl is made visible.
function displayctl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for displayctl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes displayctl wait for user response (see UIRESUME)
% uiwait(handles.figure1);
displayctl_channel_Callback(hObject, eventdata, handles); %force update for selected channels


% --- Outputs from this function are returned to the command line.
function varargout = displayctl_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


function displayctl_redisplay_Callback(hObject, eventdata, handles)
global DISPCTL
er;
% does nothing else at the moment...


function displayctl_reset_Callback(hObject, eventdata, handles)
global DISPCTL
DISPCTL = [];
initdispctl; % create the default data set
update_channels(hObject); % and take it to the window.

% callbacks to handle the individual items in the display

function displayctl_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayctl_ymax as text
%        str2double(get(hObject,'String')) returns contents of displayctl_ymax as a double
global DISPCTL
ymax=get(hObject, 'String');
ichan = getthischannel;
DISPCTL.ymax(ichan) = str2num(ymax);


% --- Executes during object creation, after setting all properties.
function displayctl_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displayctl_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayctl_ymin as text
%        str2double(get(hObject,'String')) returns contents of displayctl_ymin as a double
global DISPCTL
ymin=get(hObject, 'String');
ichan = getthischannel;
DISPCTL.ymin(ichan) = str2num(ymin);


% --- Executes during object creation, after setting all properties.
function displayctl_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in displayctl_channel.
function displayctl_channel_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns displayctl_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from displayctl_channel
update_channels(hObject);

% --- Executes during object creation, after setting all properties.
function displayctl_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displayctl_ysize_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_ysize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayctl_ysize as text
%        str2double(get(hObject,'String')) returns contents of displayctl_ysize as a double
global DISPCTL
ichan = getthischannel;
DISPCTL.ysizes(ichan) = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function displayctl_ysize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_ysize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global DISPCTL
ichan = getthischannel;
DISPCTL.ysizes(ichan) = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function displayctl_grid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_ysize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global DISPCTL
ichan = getthischannel;
DISPCTL.grid(ichan) = str2num(get(hObject, 'Value'));

% --- Executes on button press in displayctl_grid.
function displayctl_grid_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_grid
global DISPCTL
ichan=getthischannel;
DISPCTL.grid(ichan) = get(hObject, 'Value');


% --- Executes on selection change in displayctl_units.
function displayctl_units_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns displayctl_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from displayctl_units
global DISPCTL
ichan = getthischannel;
ichoice = get(hObject, 'Value');
is = get(hObject, 'String');
DISPCTL.unit{ichan} = char(is(ichoice));

% --- Executes during object creation, after setting all properties.
function displayctl_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayctl_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displayctl_minmax.
function displayctl_minmax_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_minmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_minmax
global DISPCTL
ichan = getthischannel;
DISPCTL.ymin(ichan) = -DISPCTL.ymax(ichan);
hc = findobj('tag', 'displayctl_ymin');
set(hc, 'String', sprintf('%d', DISPCTL.ymin(ichan)));

% --- Executes on button press in displayctl_sel1.
function displayctl_sel1_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel1
global DISPCTL
this = 1;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;

% --- Executes on button press in displayctl_sel2.
function displayctl_sel2_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel2
global DISPCTL
this = 2;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;



% --- Executes on button press in displayctl_sel3.
function displayctl_sel3_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel3
global DISPCTL
this = 3;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel4.
function displayctl_sel4_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel4
global DISPCTL
this = 4;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel5.
function displayctl_sel5_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel5
global DISPCTL
this = 5;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel6.
function displayctl_sel6_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel6
global DISPCTL
this = 6;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel7.
function displayctl_sel7_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel7
global DISPCTL
this = 7;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel8.
function displayctl_sel8_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel8
global DISPCTL
this = 8;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel9.
function displayctl_sel9_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DISPCTL
this = 9;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;
% Hint: get(hObject,'Value') returns toggle state of displayctl_sel9


% --- Executes on button press in displayctl_sel10.
function displayctl_sel10_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel10
global DISPCTL
this = 10;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel11.
function displayctl_sel11_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel11
global DISPCTL
this = 11;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel12.
function displayctl_sel12_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel12
global DISPCTL
this = 12;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel13.
function displayctl_sel13_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel13
global DISPCTL
this = 13;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel14.
function displayctl_sel14_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel14
global DISPCTL
this = 14;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel15.
function displayctl_sel15_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel15
global DISPCTL
this = 15;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_sel16.
function displayctl_sel16_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_sel16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_sel16
global DISPCTL
this = 16;
if(get(hObject, 'Value'))
    DISPCTL.enable(this) = 1;
else
    DISPCTL.enable(this) = 0;
end;


% --- Executes on button press in displayctl_utility.
function displayctl_utility_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_utility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_utility
global DISPCTL

DISPCTL.utility=get(hObject, 'Value');


% --- Executes on button press in displayctl_online.
function displayctl_online_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_online (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayctl_online
global DISPCTL

DISPCTL.online = get(hObject, 'Value');


%%
%--------------------------------------------------------------------
% My routines are added here.
function [ichan] = getthischannel()
% function to find out the current channel selection... 
hc = findobj('tag', 'displayctl_channel');
ichan = get(hc, 'value');

function update_channels(hObject)
% function to update the display contorl window for the selected channel
% when the channel selection is changed
%
global DISPCTL
ichan = getthischannel;
hymin = findobj('tag', 'displayctl_ymin');
set(hymin, 'string', sprintf('%g', DISPCTL.ymin(ichan)));
%displayctl_ymin_Callback(hymin, [], []);
hymax = findobj('tag', 'displayctl_ymax');
set(hymax, 'string', sprintf('%g', DISPCTL.ymax(ichan)));
%displayctl_ymax_Callback(hymax, [], []);
hysize = findobj('tag', 'displayctl_ysize');
set(hysize, 'string', sprintf('%g', DISPCTL.ysizes(ichan)));
%displayctl_ysize_Callback(hysize, [], []);
hygrid = findobj('tag', 'displayctl_grid');
set(hygrid, 'Value', DISPCTL.grid(ichan));
%displayctl_grid_Callback(hygrid, [], []);
hyunits = findobj('tag', 'displayctl_units');
%displayctl_units_Callback(hyunits, [], []);
ichoice = get(hyunits, 'Value');
is = get(hyunits, 'String');
% DISPCTL.unit{ichan} = is(ichoice);
im = strmatch(DISPCTL.unit{ichan}, is);
set(hyunits, 'Value', im);
hol = findobj('tag', 'displayctl_online');
set(hol, 'Value', DISPCTL.online);
hu = findobj('tag', 'displayctl_utility');
set(hu, 'Value', DISPCTL.utility);
if(~isfield(DISPCTL, 'enable'))
    DISPCTL.enable = zeros(1,16);
end;
for i = 1:16 % for all the "enable" channels
    senable = sprintf('displayctl_sel%d', i);
    hen = findobj('tag', senable);
    set(hen, 'Value', DISPCTL.enable(i));
end;


% --- Executes on button press in displayctl_close.
function displayctl_close_Callback(hObject, eventdata, handles)
% hObject    handle to displayctl_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=gcf;
close(h);



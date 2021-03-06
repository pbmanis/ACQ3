function varargout = header(varargin)
% HEADER M-file for header.fig
%      HEADER, by itself, creates a new HEADER or raises the existing
%      singleton*.
%
%      H = HEADER returns the handle to a new HEADER or the handle to
%      the existing singleton*.
%
%      HEADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEADER.M with the given input arguments.
%
%      HEADER('Property','Value',...) creates a new HEADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before header_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to header_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help header

% Last Modified by GUIDE v2.5 26-Aug-2008 11:35:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @header_OpeningFcn, ...
                   'gui_OutputFcn',  @header_OutputFcn, ...
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


% --- Executes just before header is made visible.
function header_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to header (see VARARGIN)

% Choose default command line output for header
handles.output = hObject;
global HFILE
hf = findobj('tag', 'Header_experiment');
set(hf, 'String', HFILE.Experiment);
hf = findobj('tag', 'Header_age');
set(hf, 'String', HFILE.Age);
hf = findobj('tag', 'Header_species');
set(hf, 'String', HFILE.Species);
hf = findobj('tag', 'Header_sex');
set(hf, 'String', HFILE.Sex);
hf = findobj('tag', 'Header_weight');
set(hf, 'String', HFILE.Weight);
hf = findobj('tag', 'Header_DIV');
set(hf, 'String', HFILE.DIV);
hf = findobj('tag', 'Header_signature');
set(hf, 'String', HFILE.Signature);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes header wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = header_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if(~isempty(handles))
    varargout{1} = handles.output;
end;

% --- Executes on button press in Header_Cancel.
function Header_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Header_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isempty(handles))
    varargout{1} = 0;
end;

% --- Executes on button press in Header_OK.
function Header_OK_Callback(hObject, eventdata, handles)
% hObject    handle to Header_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HFILE
hf = findobj('tag', 'Header_experiment');
HFILE.Experiment = get(hf, 'String');
hf = findobj('tag', 'Header_age');
HFILE.Age = get(hf, 'String');
hf = findobj('tag', 'Header_species');
HFILE.species = get(hf, 'String');
hf = findobj('tag', 'Header_sex');
HFILE.Sex = get(hf, 'String');
hf = findobj('tag', 'Header_weight');
HFILE.Weight = get(hf, 'String');
hf = findobj('tag', 'Header_DIV');
HFILE.DIV = get(hf, 'String');
hf = findobj('tag', 'Header_signature');
HFILE.Signature = get(hf, 'String');
if(~isempty(handles))
    varargout{1} = 1;
end;

function Header_experiment_Callback(hObject, eventdata, handles)
% hObject    handle to Header_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_experiment as text
%        str2double(get(hObject,'String')) returns contents of Header_experiment as a double


% --- Executes during object creation, after setting all properties.
function Header_experiment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Header_species_Callback(hObject, eventdata, handles)
% hObject    handle to Header_species (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_species as text
%        str2double(get(hObject,'String')) returns contents of Header_species as a double


% --- Executes during object creation, after setting all properties.
function Header_species_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_species (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Header_sex_Callback(hObject, eventdata, handles)
% hObject    handle to Header_sex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_sex as text
%        str2double(get(hObject,'String')) returns contents of Header_sex as a double


% --- Executes during object creation, after setting all properties.
function Header_sex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_sex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Header_weight_Callback(hObject, eventdata, handles)
% hObject    handle to Header_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_weight as text
%        str2double(get(hObject,'String')) returns contents of Header_weight as a double


% --- Executes during object creation, after setting all properties.
function Header_weight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Header_DIV_Callback(hObject, eventdata, handles)
% hObject    handle to Header_DIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_DIV as text
%        str2double(get(hObject,'String')) returns contents of Header_DIV as a double


% --- Executes during object creation, after setting all properties.
function Header_DIV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_DIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Header_signature_Callback(hObject, eventdata, handles)
% hObject    handle to Header_signature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_signature as text
%        str2double(get(hObject,'String')) returns contents of Header_signature as a double


% --- Executes during object creation, after setting all properties.
function Header_signature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_signature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



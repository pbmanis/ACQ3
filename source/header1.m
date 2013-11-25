function varargout = header(varargin)
% HEADER M-file for header.fig
%      HEADER by itself, creates a new HEADER or raises the
%      existing singleton*.
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

% Last Modified by GUIDE v2.5 26-Aug-2008 11:10:38

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


% Choose default command line output for header
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
% load dialogicons.mat
% 
%IconData=questIconData;
%questIconMap(256,:) = get(handles.figure1, 'Color');
%IconCMap=questIconMap;

%Img=image(IconData, 'Parent', handles.axes1);
%set(handles.figure1, 'Colormap', IconCMap);

%set(handles.axes1, ...
%    'Visible', 'off', ...
%    'YDir'   , 'reverse'       , ...
%    'XLim'   , get(Img,'XData'), ...
%    'YLim'   , get(Img,'YData')  ...
%    );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes header wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = header_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in Header_cancel.
function Header_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Header_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in Header_ok.
function Header_ok_Callback(hObject, eventdata, handles)
% hObject    handle to Header_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.output = get(hObject,'String');
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

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Header_species.
function Header_species_Callback(hObject, eventdata, handles)
% hObject    handle to Header_species (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Header_species contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Header_species



function Header_age_Callback(hObject, eventdata, handles)
% hObject    handle to Header_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Header_age as text
%        str2double(get(hObject,'String')) returns contents of Header_age as a double


% --- Executes during object creation, after setting all properties.
function Header_age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Header_age (see GCBO)
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



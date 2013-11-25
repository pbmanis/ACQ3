function varargout = profile_mgr(varargin)
% PROFILE_MGR M-file for profile_mgr.fig
%      PROFILE_MGR, by itself, creates a new PROFILE_MGR or raises the existing
%      singleton*.
%
%      H = PROFILE_MGR returns the handle to a new PROFILE_MGR or the handle to
%      the existing singleton*.
%
%      PROFILE_MGR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROFILE_MGR.M with the given input arguments.
%
%      PROFILE_MGR('Property','Value',...) creates a new PROFILE_MGR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before profile_mgr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to profile_mgr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help profile_mgr

% Last Modified by GUIDE v2.5 20-Aug-2008 17:20:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @profile_mgr_OpeningFcn, ...
                   'gui_OutputFcn',  @profile_mgr_OutputFcn, ...
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


% --- Executes just before profile_mgr is made visible.
function profile_mgr_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to profile_mgr (see VARARGIN)
global BASEPATH

% Choose default command line output for profile_mgr
if(~isempty(handles))
    handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
end;
cfgs = dir(slash4OS([BASEPATH '/configurations/' '*.ini']));    % find all the initialization configuration files.
hp = findobj('Tag', 'ProfileMgr_List');
if(isempty(hp))
       fprintf(1, 'ProfileMgr: unable to find menu (in create)\n');
    return;
end;
cfgl = {cfgs.name};
cfgl = sort(cfgl);
list = cell(length(cfgl), 1);
for i = 1:length(cfgl)
    [p f] = fileparts(cfgl{i});
    list{i} = f;
end;

set(hp, 'String', list);
set(hp, 'Max', length(cfgl));
set(hp, 'Min', 0);
set(hp, 'Value', 1);
return;
% UIWAIT makes profile_mgr wait for user response (see UIRESUME)
% uiwait(handles.ProfileMgr);


% --- Outputs from this function are returned to the command line.
function varargout = profile_mgr_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if(~isempty(handles))
    varargout{1} = handles.output;
end;

% --- Executes on selection change in ProfileMgr_List.
function ProfileMgr_List_Callback(hObject, eventdata, handles)
% hObject    handle to ProfileMgr_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ProfileMgr_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ProfileMgr_List



% --- Executes during object creation, after setting all properties.
function ProfileMgr_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfileMgr_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ProfileMgr_Select.
function ProfileMgr_Select_Callback(hObject, eventdata, handles)
% hObject    handle to ProfileMgr_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hlist = findobj('tag', 'ProfileMgr_List');
contents = get(hlist,'String'); % returns ProfileMgr_List contents as cell array
cfgfile = contents{get(hlist,'Value')}; % returns selected item from ProfileMgr_List
hp = findobj('Tag', 'ProfileMgr'); % close the window
delete(hp);
gc(cfgfile); % load the configuration file
err = acq3('run'); % callback to set it up.
if(err)
    acq3('exit');
end;
        

% --- Executes on button press in ProfileMgr_Cancel.
function ProfileMgr_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to ProfileMgr_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
thisfig = findobj('tag', 'ProfileMgr');
delete(thisfig);
return;


% --- Executes on mouse press over figure background.
function ProfileMgr_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ProfileMgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



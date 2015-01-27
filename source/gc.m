function [varargout] = gc(cname)
% gc: get configuration file from disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     gc [filename] <nodisplay> gets a configuration file from disk
%     If no filename is specified, a browser window is provided to select a file.

% 8/15/2000 - get a configuration file from disk.
% Paul B. Manis   pmanis@med.unc.edu
% returns the configuration file structure CONFIG in global variable CONFIG.
% If you call without a filename on the command line, then
% this routine will use uigetfile to do the file access
% 3/19/2008 - Modified to read configuration from a text file
% text files are expected to have an extension of ".ini".
% also extended to allow override of SensorRange values from Configuration
% directly to simplify the handling of acquisition protocols
% Because the configuration is a text file, it is edited as a text file
% outside of the program (with notepad or textedit)

global CONFIG BASEPATH ACQ_PATH

% load a protocol from the disk

% definitions
SGL = 0; %#ok<NASGU>
MULT = 1; %#ok<NASGU>

if(nargout > 0)
    varargout{1} = 0; % clear error return;
end;

% edit_dis = 1;
% if(nargin == 2)
%     edit_dis = 0; % turn it off.
% end;
if(nargin == 0)
    [cname, cpath] = uigetfile('configurations/*.ini','Load Initial Configuration File');
    if(cname == 0)
        return;
    end;
    cname=fullfile(cpath, cname);
end;
[path file ext] = fileparts(cname); % if filename still missing extension, add the default
if(isempty(ext))
    cname = [cname '.ini'];
end;
cname2 = cname;
if(isempty(path))
    cname2 = slash4OS([BASEPATH 'configurations/' cname2]);
end;
fid = fopen(cname2, 'r');
if(fid == -1)
    QueMessage(sprintf('File %s not found? ', cname2), 1);
    return;
end;
fclose(fid);
a = scriptread(cname2); % read from a script

cf=a.CONFIG; % get the "CONFIG" structure
fn = fieldnames(cf);
val = cell(1, length(fn));
for i = 1:length(fn) % build a data structure with create_element
    val{i} = eval(sprintf('cf.%s', fn{i}));
    a = number_arg(val{i});
    if(ischar(a))
        if(any(strcmpi(fn{i}, {'title', 'NAME', 'callback', 'fhandles', 'frame', 'comment', 'start', 'end'}))); % direct to structure
            cmd = sprintf('CONFIG.%s = ''%s'';',fn{i}, val{i});
        else  % make a valued structure format
            cmd = sprintf('CONFIG.%s = create_element(''%s'', SGL, 4, ''%s'', %s);',fn{i}, val{i}, fn{i}, '''%c''');
        end;
        eval(cmd);
    else
        la = length(val);
        if(la == 1)
            cmd = sprintf('CONFIG.%s = create_element(%d, SGL, 4, ''%g'', %s);', fn{i}, number_arg(val{i}), fn{i}, '''%s''');
            %disp 'numeric, single'
        else
            cmd = sprintf('CONFIG.%s = create_element(%d, MULT, 4, ''%g'', %s);', fn{i}, number_arg(val{i}), fn{i}, '''%s''');
            %disp 'numeric, multiple'
        end;
        eval(cmd);
    end;
end

%CONFIG
if(strcmpi(CONFIG.BasePath.v, 'default'))
    CONFIG.BasePath.v = BASEPATH;
end;

cpath=CONFIG.BasePath.v(find(~isspace(CONFIG.BasePath.v), length(CONFIG.BasePath.v), 'first'));
CONFIG.BasePath.v = cpath;
cpath=CONFIG.StmPath.v(find(~isspace(CONFIG.StmPath.v), length(CONFIG.StmPath.v), 'first'));
cpath2 = slash4OS([CONFIG.BasePath.v '/' cpath]);
if(exist(cpath2, 'dir') ~= 7)
    QueMessage('gc: Stim file path does not exist, creating', 1);
    mkdir(cpath2);
    QueMessage(sprintf('Created: %s', cpath2));
end;
CONFIG.StmPath.v = cpath;
cpath=CONFIG.AcqPath.v(find(~isspace(CONFIG.AcqPath.v), length(CONFIG.AcqPath.v), 'first'));
CONFIG.AcqPath.v = cpath;
cpath2 = slash4OS([CONFIG.BasePath.v '/' cpath]);
if(exist(cpath2, 'dir') ~= 7)
    QueMessage('gc: Acq file path does not exist, creating', 1);
    mkdir(cpath2);
    QueMessage(sprintf('Created: %s', cpath2));
end;
cpath=CONFIG.DataPath.v(find(~isspace(CONFIG.DataPath.v), length(CONFIG.DataPath.v), 'first'));
CONFIG.DataPath.v = cpath;
if strcmp(cpath(2:3), ':\')
    cpath2 = cpath;
else
    cpath2 = slash4OS([CONFIG.BasePath.v '/' cpath]);
end
if(exist(cpath2, 'dir') ~= 7)
    QueMessage('gc: Data file path does not exist, creating', 1);
    mkdir(cpath2);
    QueMessage(sprintf('Created: %s', cpath2));
end;
update_macros;

cpath=CONFIG.MacroPath.v(find(~isspace(CONFIG.MacroPath.v), length(CONFIG.MacroPath.v), 'first'));
CONFIG.MacroPath.v = cpath;
cpath2 = slash4OS([CONFIG.BasePath.v '/' cpath]);
if(exist(cpath2, 'dir') ~= 7)
    QueMessage('gc: Macro file path does not exist, creating', 1);
    mkdir(cpath2);
    QueMessage(sprintf('Created: %s', cpath2));
end;

if(~isempty(CONFIG.BasePath.v))
    if(exist(CONFIG.BasePath.v, 'dir') == 7) % must exist as a path
        cd(CONFIG.BasePath.v); % change the working directory first...
    else
        QueMessage(sprintf('gc: Base Path %s not found?', CONFIG.BasePath.v), 1);
        QueMessage(sprintf(' Using Current path'));
        CONFIG.BasePath.v = BASEPATH;
        cd(CONFIG.BasePath.v);
    end;
end;

show_configuration;
err = acq3('connectamplifier'); % if we change the config, make sure amp is updated
if(err)
    QueMessage('gc: Failed to make amplifier connection\n');
    if(nargout > 0)
        varargout{1} = 1;
    end;
    return;
else
    if(nargout > 0)
        varargout{1} = 0;
    end;
end;
if strcmp(CONFIG.DataPath.v(2:3), ':\')
    cpath = CONFIG.BasePath.v;
else
    cpath = slash4OS([CONFIG.BasePath.v '/' CONFIG.DataPath.v]);
end;
if(exist(cpath, 'dir') ~= 7)
    QueMessage('gc: Data file path does not exist', 1);
    mkdir(cpath);
    QueMessage(sprintf('Created: %s', cpath));
end;
ACQ_PATH = cpath; % full path to data files.


QueMessage(sprintf('     Configuration Params loaded from %s', cname), 1);
h = findobj('Tag', 'Acq');
set(h, 'Name', sprintf('ACQ: Data Acquisition [configuration: %s]', CONFIG.Config.v));
return;

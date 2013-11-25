function aopen(filename)
% aopen: Open a new acquisition file.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     If no filename is given, the next available filename using the default
%     structure is used, e.g., 01jan01a.mat.
%     If a filename is given, then that is used instead of the default.

%
% 17 Jul 2000
% Paul B. Manis
% pmanis@med.unc.edu
%
% Open a file for acquisition.
% file naming is automatic (DATAC naming convention).
% This routine opens the file, requests information for the header block
% (comment, user, etc), then writes the first entry to the file (header block)
% and closes the file. We also create the index file that will be appended to the
% end of the data file when the close is called.
% Data files are maintained closed during acquisition and are only open when
% data is being written or appended to the file.
%
global ACQ_FILENAME % this is null if there is no file in use; otherwise it holds the filename
global ACQ_PATH % default path to the data
global CONFIG

% FIRST, stop all acquisition. This is to keep us from getting confused when returning if already in scope mode
acq_stop;

% first make sure we are not already in a file
if(~isempty(ACQ_FILENAME))
    answer = lower(questdlg(sprintf('File %s already open. Close ?', ACQ_FILENAME),...
        'Previous file close','Yes','No','Help','No'));
    %   ans = lower(inputdlg (sprintf('File %s already open. Close (y,n, [n])?', ACQ_FILENAME), 'Previous file', 1, {'n'}));
    if(isempty(answer))
        answer = 'y';
    end;
    if(strmatch(lower(answer), {'y', 'yes'}))
        ac; % call the file close routine.
    else
        QueMessage('File not closed; continuing', 1);
        h = findobj('Tag', 'DispFilename');
        if(isempty(h))
            fprintf(2, 'aopen: Unable to display filename');
            return;
        end;
        set(h, 'String', ACQ_FILENAME);
        h = findobj('Tag', 'Acq');
        if(ishandle(h))
            set(h, 'Name', sprintf('ACQ: Data Acquisition [%s] - File: %s', ...
                CONFIG.Config.v, ACQ_FILENAME));
        end;
        disp_rec;
        return;
    end;
end;

% ok, now we can open a file. First see if there's a name on the command line
if(nargin > 0) % we will try to use the name on the command line
    fullname = fullfile(ACQ_PATH, filename);
    if(exist(fullname, 'file')) % a file by this name already exists - no option to overwrite
        fprintf(2, 'aopen.m ERROR - file %s exists - choose another filename\n', fullname);
        ACQ_FILENAME = [];
    else
        create_file(fullname, []);
    end;
else % no name on the command line - find the latest filename in the series
    [filename, hf] = nextname(ACQ_PATH); % find the next name
    if(isempty(filename)) % its an error? bad path or something. Error listed by nextname
        ACQ_FILENAME = [];
    else
        fullname = fullfile(ACQ_PATH, filename);
        create_file(fullname, hf);
    end;
end;
return;

% --------------------------
function create_file(filename, hf)
% function to create the file.
% we fill in some fields in the HFILE structure (header)
% we also ask via dialog for some general information regarding the
% experiment; to be filled in by the user. This should
% adequately describe the experiment.
% We then write this header to the file, and create the index file.
% if hf is not empty, or missing, we will assume its a header type
% and will fill the defaults for the initial data screen from that.
% nextname returns the PREVIOUS hfile (if it exists) to provide this data
%
global HFILE CONFIG FILEFORMAT
global ACQ_FILENAME FILE_STATUS GAPFREE_CTR
global ACQVERSION

fp = [];
%fprintf('Creating file %s\n', filename);
[pa, fp, ext, ver] = fileparts(filename);
ACQ_FILENAME = fp;
HFILE.filename = fp;
HFILE.ext = ext;
HFILE.Version = ACQVERSION;
%HFILE.path = [BASEPATH pa];
HFILE.path = pa;
if(~isempty(hf))
    HFILE.Experiment.v = hf.Experiment.v;
    HFILE.Species.v = hf.Species.v;
    HFILE.Age.v = hf.Age.v;
    HFILE.Weight.v = hf.Weight.v;
    HFILE.Sex.v = hf.Sex.v;
    HFILE.DIV.v = hf.DIV.v;
    HFILE.Signature.v = hf.Signature.v;
else
    HFILE.Experiment.v = '';
    HFILE.Species.v = '';
    HFILE.Sex.v = '';
    HFILE.Age.v = '';
    HFILE.Weight.v = '';
    HFILE.DIV.v = '';
    HFILE.Signature.v = '';
end;


% generate the fields to fill in
prompt   = {'Experiment','Species', 'Age', 'Sex', 'Weight', 'Days In Vitro', 'Signatures'};
title    = sprintf('File_%s', fp);
lines = [10,80; 1,40; 1,20; 1,20; 1,20; 1,20; 1,60];
if(nargin > 1 && ~isempty(hf))
  def = {char(hf.Experiment.v), char(hf.Species.v), char(hf.Age.v), char(hf.Sex.v), ...
        char(hf.Weight.v), char(hf.DIV.v), char(hf.Signature.v)};
else
  def     = {'','Rattus','10', 'U', '26', '1', CONFIG.Owner.v};
end;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

answer   = inputdlg(prompt, title, lines, def, options);

% header;

if(isempty(answer)) % we canceled out of the dialog...
    fprintf(2, 'aopen ERROR: File not opened...\n');
    ACQ_FILENAME = [];
    return;
end;
HFILE.Experiment.v = answer{1};
HFILE.Species.v = answer{2};
HFILE.Age.v = answer{3};
HFILE.Sex.v = answer{4};
HFILE.Weight.v = answer{5};
HFILE.DIV.v = answer{6};
HFILE.Signature.v = answer{7};
FILE_STATUS.Record = 1; % initialize internal file information counters
FILE_STATUS.Block = 1;
FILE_STATUS.NoteCount = 1;
GAPFREE_CTR = 0; % set the gapfree mode counter....
if(~isempty(FILEFORMAT))
    save(filename,'HFILE', FILEFORMAT); % this saves the header
else
    save(filename, 'HFILE');
end;
% now we need to create and initialize the INDEX file
index_file('new', 'HFILE');

%
% update the display information

h = findobj('Tag', 'DispFilename');
if(isempty(h))
    fprintf(2, 'aopen ERROR: Unable to display filename');
    return;
end;
set(h, 'String', ACQ_FILENAME);
h = findobj('Tag', 'Acq');
if(ishandle(h))
    set(h, 'Name', sprintf('ACQ: Data Acquisition [%s] - File: %s', ...
        CONFIG.Config.v, ACQ_FILENAME));
end;
disp_rec;

return;

% --------------------------
function [fo, hf] = nextname(acq_path)
% function nextname finds the next valid name on the specified path
% This works as follows:
% the filename is in datac format: ddmmmyyl.ext
% ext is always mat (? change later to better extension ?)
% dd = numeric day, leading 0
% mmm = month in letter format jan feb mar apr may jun jul aug sep oct nov dec
% yy = year (99,00, etc).
% l = letter for cell identification
%
% first get the date and generate the base filename parts.
%
global HFILE

fo = [];
hf = []; % header information
if(nargin ~= 1)
    fprintf(2, 'aopen ERROR: nextname.m requires path argument\n');
    return;
end;
dn = date;
base = lower([dn(1:2) dn(4:6) dn(10:11)]); % base name
lettera = 97; % base letter is 97 decimal, corresponding to ascii 'a' (lowercase)
for i = 0:25 % only the letters
    fn = [base char(lettera+i) '.mat'];
    ft = fullfile(acq_path, fn); % make full filename
    if(~exist(ft, 'file')) % file does not exist, so make it
        fo = fn;
        if(i > 0)
            hfn = [base char(lettera+i-1) '.mat']; % get the header hfile from the previous file in series
            hft = fullfile(acq_path, hfn); % we use this information to initialize the initial header information
            if(~exist(hft, 'file')) % no file,
                return;
            end;
            load(hft, 'HFILE'); % load the header
            hf = HFILE; % and return it
            return;
        else
            return; % i is 0, 'a' file, just do it
        end;

    end;
end;
QueMessage('nextfile.m is out of file names for this date\n');
fprintf(2, 'aopen.m ERROR: nextfile.m is out of file names for this date\n');
fo = [];
return;

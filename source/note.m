function note(varargin)
% note: Enter textual information into the data file during an experiment.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     note <cr> brings up a dialog box for entering multiline note information.
%     note text text text puts a single line note into the data file.

% Multiline dialog box, modal.... text from note is held in the NOTE structure
% in the file
%
% 8/11/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% generate the fields to fill in
global HFILE FILE_STATUS FILEFORMAT

if(isempty(HFILE)) % no file open?
    QueMessage('note: No Acquisition File Open!', 1);
    return;
end;

filename = fullfile(HFILE.path, [HFILE.filename HFILE.ext]);

if(nargin == 0) % no input data?
    prompt   = sprintf('Note for %s:', HFILE.filename);
    title    = 'Note';
    lines = 5;
    def     = {''};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
    answer   = inputdlg(prompt,title,lines,def, options);
    if(isempty(answer)) % we canceled out of the dialog...
        QueMessage('Cancel: Note Not Entered...', 1);
        return;
    end;
else
    answer = varargin;
end;

sfc = sprintf('Note%d_%d', FILE_STATUS.Block, FILE_STATUS.NoteCount);
eval([sfc '.v = answer{1};']);
% added 12/15/2000: also store the time that the note was written
eval([sfc '.t = clock;']);
if(~isempty(FILEFORMAT))
    save(filename, sfc, '-append', FILEFORMAT); % build data file
else
    save(filename, sfc, '-append'); % build data file
end;
% now we need to create and initialize the INDEX file
if(nargin == 0)
    jog = cell2struct(answer, 'n');
else
    jog.n = answer;
end;
p = min(length(jog.n), 15);
index_file('add', 'NOTE', [jog.n(1,1:p), '...'], sfc);
FILE_STATUS.NoteCount = FILE_STATUS.NoteCount + 1;
return;

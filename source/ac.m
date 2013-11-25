function ac()
% ac:  Close the currently open acquisition file. 
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% 10/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

global ACQ_FILENAME % this is null if there is no file in use; otherwise it holds the filename
global FILE_STATUS
global  CONFIG

if(isempty(ACQ_FILENAME))
   return;
end;
index_file('close'); % causes current index to be appended to the data file
olf = ACQ_FILENAME;
ACQ_FILENAME = [];

h = findobj('Tag', 'Acq');
if(ishandle(h))
   set(h, 'Name', sprintf('ACQ: Data Acquisition [%s] - No File', ...
      CONFIG.Config.v));
end;

h = findobj('Tag', 'DispFilename');
FILE_STATUS.Block = 1;
FILE_STATUS.Record = 1;
QueMessage(sprintf('File: %s closed\n', olf), 1);
if(isempty(h))
   return;
end;
set(h, 'String', '<closed>');
disp_rec;

return;

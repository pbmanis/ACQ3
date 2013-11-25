function lg()
% lg: list all the globals in the program.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     No arguments - just displays contents of globals.

% dumps all except the structures
%
global LASTPATH TEST_MODE RECORD_NO %#ok<NUSED> % control variables
global FILE_STATUS %#ok<NUSED>
global STOP_ACQ SCOPE_FLAG IN_ACQ SCOPE_RESTART %#ok<NUSED> % flags
global WIN_TITLE ACQ_FILENAME %#ok<NUSED>

x = who; % who will return all the declared globals so far in the routine.
for i = 1:length(x)
   y=eval(x{i});
   if(~isstruct(y))
      if isempty(y)
         fprintf('%s: <empty>\n', x{i});
      elseif ischar(y)
         fprintf('%s: [s] %s\n', x{i}, y);
      elseif isnumeric(y)
         fprintf('%s: [f] %f\n', x{i}, y);
      end;
      
   end;
end;
fprintf('\n');
return;


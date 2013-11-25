function bye()
% bye: close windows and files to exit acquisition program
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     Call with no arguments.

%
% Currently, only closes the window and the data file.
%
global MC700BConnection
global AO AI DEVICE_ID

fprintf(2, '\nACQ3 Quitting\n');
acq_stop;

if(~isnumeric(MC700BConnection) && ~isempty(MC700BConnection) && isvalid(MC700BConnection))
    fclose(MC700BConnection);
    delete(MC700BConnection);
end;
clear MC700BConnection;
if(~isempty(AO) && isvalid(AO))
    stop(AO)
end;
if(~isempty(AI) && isvalid(AI))
    stop(AI)
end;
if(DEVICE_ID > 0)
    if (~isempty(daqfind)) % causes preoblems - delete...
    delete(daqfind);
    end
    daqreset;
end;

ac;
% list the possible windows and then close them
win = {'Acq', 'StimControl', 'PEdit', 'Acq_OnlineWindow'};
for i = 1:length(win)
   h = findobj('Tag', win{i});
   if(ishandle(h))
      delete(h);
   end;
end;

return;

function out = valve(vn)
% Select valve n : valve(n)
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% set valve control output. Doesn't distrub anything else....
% 7/18/01
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% For Acq/acquire_one.m

% Configure Digital IO **************************************************************
global DIO

if(isempty(DIO))
    fprintf(2, 'Creating digital IO object\n');
    DIO = digitalio('nidaq', 1); % get the digital IO line
end;
if(length(DIO.Line) <= 2)
    addline(DIO, 2:5, 'out'); % then we need to add them.
end; % otherwise we do not... (this should be a little tighter).

out = getvalue(DIO.Line); % read the existing values.
if(nargin == 0) % read the valves
    out = out(3:6); % just the valve values.
    return;
end;
oval = [0 0 0 0];
switch(vn)
    case {0, '0', 'off'}
        oval = [0 0 0 0];
    case {1, '1'}
        oval = [0 0 0 1];
    case {2, '2'}
        oval = [0 0 1 0];
    case {3, '3'}
        oval = [0 1 0 0];
    case {4, '4'}
        oval = [1 0 0 0];
    case {'all', 'clean'}
        oval = [1 1 1 1];
    otherwise
        fprintf('Valve: unrecognized command\n');
        return;
end;
oval = [out(1:2) oval];
putvalue(DIO, oval); % set all output lines low
return;

function [s] = ls2(a)
% ls: List the current SFILE parameters that are in memory.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     If no arguments, prints the current SFILE
%     if an argument exists, the selected structure is printed
%     if an output argument is specified, the current SFILE is returned

%
global STIM2
if(nargin > 0)
    if(isstruct(a))
        print_block(a)
    end;
    return;
end;
if(nargout == 0)
    print_block(STIM2);
else
    s=STIM2;
end;
return;



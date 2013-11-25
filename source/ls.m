function [s] = ls(a)
% ls: List the current SFILE parameters that are in memory.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     If no arguments, prints the current SFILE
%     if an argument exists, and is a structure, the selected structure is printed
%     if the argument is a string, it is a filename in the current stimpar
%     to load and list
%     if an output argument is specified, the current SFILE is returned

%
global STIM CONFIG
if(nargin > 0)
    if(isstruct(a))
        print_block(a);
    end;
    if(ischar(a))
        a = load(slash4OS([CONFIG.StmPath.v '\' a]));
        print_block(a.STIM);
    end;
end;
if(nargin == 0 && nargout == 0)
    print_block(STIM);
    return;
end;
if(nargout > 0)
    s=STIM;
end;




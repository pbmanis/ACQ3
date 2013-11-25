function [c] = lc()
% lc: List the current CONFIG parameter block that is in memory.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     No arguments

%
global CONFIG

if(nargout == 0)
	print_block(CONFIG);
else
   c=CONFIG;
end;

return;

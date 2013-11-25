function [s] = ld(a)
% ld: List the current acquisition (DFILE) parameter block that is in memory.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage 
%     If no arguments, prints the current DFILE
%     if an argument exists, the selected structure is printed
%     if an output argument is specified, the current DFILE is returned
%
global DFILE
if(nargin > 0)
   if(isstruct(a))
      print_block(a)
   end;
   return;
end;
if(nargout == 0)
	print_block(DFILE);
else
   s=DFILE;
end;
return;

function da()
% da: acquire and store continuous data samples with current waveform until acquisition is stopped.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     Call with no arguments. Stop acquisition with "stop" button

% call acquisition to take continuous samples and store when stop is hit (if file open)
% 9/7/2000 P. Manis
%
if(nargin ~= 0)
   QueMessage('da: No arguments',1);
   return;
end;

% appears that all is ok. Go ahead and do it

acquire_one('data');
return;

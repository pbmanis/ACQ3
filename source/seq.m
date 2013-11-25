function seq()
% seq: Execute the stimulus sequence for the currently loaded STIM parameters
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     seq <cr> executes the sequence

% 8/4/2000
% P. Manis
%
if(nargin > 0)
   QueMessage('seq: call with NO arguments to execute sequence',1 );
   return;
end;

acquire_one('seq');
return;

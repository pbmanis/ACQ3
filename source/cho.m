function cho(ho1, ho2)
% cho: change the holding values (DAC outputs).
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%   Takes 1 or 2 arguments. 
%   If only one value is present, then sets ho1 to that value and ho2 to 0
%   If two values present, first applies to ho1 and second to ho2

%
global AO

% we have to assum that AO is valid for now
if(nargin == 0)
   QueMessage('cho requires 1 or 2 values, 1');
   return;
end;

if(~isnumeric(ho1))
   ho1 = str2double(ho1);
end;
if(nargin > 1)
   if(~isnumeric(ho2))
      ho2 = str2double(ho2);
   end;
else
   ho2 = 0;
end;
putsample(AO,[ho1 ho2]); % reset the output levels.
return;


function take(ntake)
% take: Acquire and store N samples with current stimulus waveform
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     take N - call acquisition to take N samples of current stimulus
%              and store to file when done(if the file is open)

% 9/7/2000 P. Manis
%
if(nargin ~= 1)
   QueMessage('take: requires number of samples to take',1);
   return;
end;

if(ischar(ntake))
   ntake=str2double(ntake);
end;

if(~isnumeric(ntake))
   QueMessage('take: argument did not parse to number', 1);
   return;
end;
if(isempty(ntake))
   QueMessage('take: argument is empty? ', 1);
   return;
end;

if(ntake < 1 || ntake > 3000)
   QueMessage('take: samples between 1 and 3000 only', 1);
   return;
else
   QueMessage(sprintf('Taking %d samples', ntake));
end;

% appears that all is ok.

acquire_one('take', ntake);
return;

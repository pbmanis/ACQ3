function do(varargin)
% do: execute a (series of) protocol(s) from disk and return to present protocol, in scope mode
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%    do p1 <p2 p3 ...> will execute the protocols p1, p2 and p3 etc.
%    in sequence until the end of the list. All protocols must exist on 
%    disk or the command will return an error without executing any.


% 11/7/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%  fixed /updated 7/7/07
%

global CONFIG STIM STOPPED_FLAG

% check for presence of a valid argument.
if(nargin == 0)
   QueMessage('do: no protocol(s) specified', 1);
   return;
end;
% first check for the protocols on disk - if any are missing, we do nothing.
missing = 0;

if(exist(CONFIG.StmPath.v, 'dir') ~= 7)
   QueMessage(sprintf('do: Configuration StimPath %s invalid', CONFIG.StmPath.v), 1);
   return;
end;
stms = dir(slash4OS([CONFIG.StmPath.v '\*.mat']));

k = 1;
for i = 1:length(stms)
   stms(i).name = lower(stms(i).name); % make it case independent.
end;
for i = 1:nargin % every element on the line is assumed to be a protocol (but see later) 
   p = varargin{i};
   if(isempty(strmatch(lower([p '.mat']), {stms.name}, 'exact')))
		QueMessage(sprintf('do: Protocol %s is missing', p), k);
      k = 0;
   end;
end;
if(k == 0)
   return;
end;

original = STIM.Name.v; % save original file we have loaded
% now we can do the big run.
STOPPED_FLAG = 0; % clear the stopped flag

for i = 1:nargin % every element on the line is assumed to be a protocol (but see later) 
   [sf, df] = g(varargin{i}); % load the protocol, and check for good structure
   if(isempty(sf))
      QueMessage(sprintf('do: Protocol %s couldn''t be loaded', p), k);
      g(original); % restore the original protocol
      return;
   end;
   STIM = sf;
   DFILE = df;
   seq; % execute the sequence within the protocol
   if(STOPPED_FLAG ~= 0) % detect if we were stopped without completing the protocol
      STOPPED_FLAG = 0;
      g(original); % get the original protocol, but DON'T jump into scope mode.
      return;
   end;
end;
g(original);
scope; % jump into scope mode
return;


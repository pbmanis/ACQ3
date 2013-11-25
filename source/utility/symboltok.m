function [token, remain] = symboltok(in, symb, inexflag)
%
% parse input according to a pair of tokens (in order, in symb)
% Takes the input in 'in' (string), and returns the first section between the
% pair of tokens in symb. If inexflag == 'include', the tokens are included in the 
% token output; if inexflag == 'exclude', the tokens are not included in the output.
% the remaining line of in AFTER the last token is returned in remain.
% This is a support routine for entering parameters on the command line
%
% 9/07/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
token = [];
remain = [];
if(nargin < 3)
   QueMessage(sprintf('symboltok: call requires 3 arguments - in, symbol, and flag\n'),1);
   return;
end;

if(isempty(in))
   QueMessage(sprintf('symboltok: input is empty\n'),1);
   return;
end;
if(length(symb) == 1) % if just one, assume we meant two and duplicate it
   symb(2)=symb(1);
end;
if(length(symb) ~= 2)
   QueMessage(sprintf('symboltok: symbols for parsing must be paired\n'),1);
   return;
end;
if(~strmatch(inexflag, strvcat('include', 'exclude'))) 
   QueMessage(sprintf('symboltok: flag must be include or exclude\n'),1);
   return;
end;

s1 = find(in == symb(1));
s2 = find(in == symb(2));
if(isempty(s1) | isempty(s2))
   QueMessage(sprintf('symboltok: Input ''%s'' does not have paired delimiters\n', in),1);
   return;
end;
if(symb(1) == symb(2)) % and if they are identical, split the list...
   s2=s1(2);
   s1=s1(1);
end;
% note we only parse the first occurance of these...
if(strcmp(inexflag, 'include'))
   token = in(s1(1):s2(1));
end;
if(strcmp(inexflag, 'exclude'))
   token = in(s1(1)+1:s2(1)-1);
   return;
end;
remain = in(s2(1)+1:end);
return;

function [s] = num_2_str(arg, fmt)
% convert arg (can be vector) to packed string display
% Uses minimum format feasible.
% fmt or maxdp sets the maximum number of decimals that will be displayed
% regardless of the actual values.
%
s='';
dp = 0;
f = 1.0;
if(nargin < 2)
   maxdp = 3;
end;
if(nargin == 2 & ischar(fmt)) % test for format statement..... extract the decimal from that.
   dot = findstr(fmt, '.');
   integer = intersect(fmt, 'dulx');
   if(isempty(dot))
      maxdp = 3;
   else
      maxdp = str2num(fmt(dot+1));
   end;
   if(~isempty(integer))
      maxdp = 0;
   end;
else
   maxdp = fmt;
end;
if(isempty(arg))
   s = '0';
   return;
end;

for i = 1:maxdp
   if(all(rem(arg, f) == 0))
      fmt = sprintf('%%.%df  ', dp);
      s = sprintf(fmt, arg);
      return;
   end;
   dp = dp + 1;
   f = f/10;
end;
fmt = sprintf('%%.%df  ', maxdp);
s = sprintf(fmt, arg);
return;


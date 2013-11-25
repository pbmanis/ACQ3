function [out] = append_backslash(in)
% append a backslash to the input argument if there isn't one already
ms = slash4OS('/');
a=findstr(in, ms);
l=length(a);
if(a(l) < length(in))   
   out=strcat(in, ms);
else
   out = in;
end

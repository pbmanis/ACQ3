function [id] = get_id(arg)
% get_id: return the type of the arg (first character, for naming)
%
id=[];
if(isempty(arg))
   return;
end;
if(isempty(arg.NAME))
   return;
end;

switch(arg.NAME)
case 'STIM'
   id = 'S';
case 'DFILE'
   id = 'D';
case 'CONFIG'
   id = 'C';
otherwise
   id = 'X';
end;
return;

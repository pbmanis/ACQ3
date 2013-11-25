function paste(arg, res);
global DFILE STIM CONFIG

%disp('paste')
%fprintf('arg: %s\n', arg);
%ls(res)
k = strmatch(lower(arg), strvcat('dfile', 'stim', 'config'), 'exact');
if(isempty(k))
   QueMessage(sprintf('paste: calling argument is empty\n'),1);
   return;
end;
switch(k)
case 1
   DFILE = res;
case 2
   STIM = res;
case 3
   CONFIG = res;
otherwise
end;
return;

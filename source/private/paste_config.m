function paste_config(res);
global CONFIG
if(~isempty(res))
   CONFIG = res;
else
   fprintf('paste_config.m : calling argument is empty\n');
end;
return;

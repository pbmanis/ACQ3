function paste_stim(res);
global STIM
if(~isempty(res))
   STIM = res;
else
   fprintf('paste_stim.m : calling argument is empty\n');
end;
return;

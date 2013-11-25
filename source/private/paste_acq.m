function paste_acq(res);
global DFILE
if(~isempty(res))
   DFILE = res;
else
   fprintf('paste_acq.m : calling argument is empty\n');
end;
return;

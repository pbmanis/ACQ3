function test()
% macro for acq to run.
global IN_MACRO STOP_MACRO
if(IN_MACRO)
   QueMessage('Macro already running');
   return;
end;
STOP_MACRO = 0;
IN_MACRO = 1;
QueMessage('I am the macro', 0);
g 'ap-iv';
seq;
if(check_macro_stop) return; end;
g 'ap-refract';
seq;
if(check_macro_stop) return; end;
return;


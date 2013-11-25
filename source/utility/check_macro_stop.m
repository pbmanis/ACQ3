function [stop] = check_macro_stop()
global IN_MACRO STOP_MACRO

stop = 0;
if (IN_MACRO & STOP_MACRO)
   QueMessage('Macro has been aborted');
   IN_MACRO = 0;
   STOP_MACRO = 0;
   stop = 1;
   return;
end;
return;

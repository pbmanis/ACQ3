function [go] = ok_macro_run()
%
% ok_macro_run: test if conditions are ok to run a macro. 

global IN_MACRO STOP_MACRO STOP_ACQ SCOPE_FLAG ACQ_FILENAME

go = 0; % flag : NOT ok to proceed.

if(SCOPE_FLAG)
   QueMessage('NOT OK to run Macro: Cannot start in Scope Mode', 1);
   acq_stop;  % go ahead and stop the scope mode....
   return;
end;
% make sure collection is fully stopped when we start any macros.
if(IN_MACRO)
   QueMessage('NOT OK to run Macro: A Macro is already running', 1);
   return;
end;

if(isempty(ACQ_FILENAME))
   QueMessage('NOT OK to run Macro: No File Open? ', 1);
   return;
end;

STOP_MACRO = 0; % clear stop flag so we can set it with the stop command
IN_MACRO = 1; % indicate that we are running a macro.
go = 1; % set ok to proceed.
return;

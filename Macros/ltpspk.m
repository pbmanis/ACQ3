function ltpspk()
% ltpspk.m  -  protocol for "ltp" of a discharge pattern
% 1/19/2001
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% Updated, 6/4/01 to allow stopping without problems.

% Required in all macros:

%-----------------------------------------
global IN_MACRO STOP_MACRO STOP_ACQ
if(IN_MACRO)
   QueMessage('Macro already running');
   return;
end;
STOP_MACRO = 0; % clear stop flag so we can set it with the stop command
IN_MACRO = 1; % indicate that we are running a macro.
%-----------------------------------------

% Total protocol length about 37 minutes.
% make sure collection is fully stopped when we start this protocol.
%acq_stop;
%pause(0.5);
%acq_stop;
%pause(0.5);
%
g ltp_base  % baseline measurement of 'buildup' response

% insert a 5-minute pause before we start the data collection to allow the cell to stabilize.
pausetime = 1; % 10 second update
totpause = 5*60; % total pause in seconds
for i = 1:floor(totpause/pausetime)
   QueMessage(sprintf('Pausing for stability: %d sec remaining', totpause - (i-1)*pausetime), 1);
   pause(pausetime);
	% a line like this is necessary after every command to stop the macro completely.
	if(check_macro_stop) return; end;
end;

%cycle 5000
take 60  % sets up for 5 minutes as 5 sec/trial (12/min)

% a line like this is necessary after every command to stop the macro completely.
if(check_macro_stop) return; end;

g ltp_cond % conditioning stimuli are 100 Hz pulse trains, superthreshold stimuli
take 120 % does 1/sec for 2 minutes
if(check_macro_stop) return; end;

g ltp_base % measure again with same parameters as baseline
%cycle 5000
take 240	% take 20 minutes at 12/minute (5 sec interval)
if(check_macro_stop) return; end;
%
% now get cciv again and re-run with all parameters
%
g ap-iv % to confirm basic cell information
seq
if(check_macro_stop) return; end;

g ap-hyp % also repeat the hyp protocol.
seq
if(check_macro_stop) return; end;
%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



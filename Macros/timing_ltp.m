function timing_ltp(varargin)
% timing_ltp : protocol for timing based ltp/ltd.
% Use timing_shock.mat to shock parallel fibers
% PF stimulus current level is set in timing_base.mat
% intracellular current pulse level is set in timing_cond.mat
%
% Test stimuli consist of pf shocks at 1/10 seconds. 
% Pairing consists of pairing identical pf shocks with current pulse
% to evoke an AP at varying intervals with respect to the PF shock.
% Lastly, we monitor the epsp/epsc to pf shock for about 40 minutes.
% 
% 1/14/2002
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% Based on lptspk.m

% The following section is required in all macros:

%-----------------------------------------
global IN_MACRO STOP_MACRO STOP_ACQ
if(IN_MACRO)
   QueMessage('Macro already running');
   return;
end;
STOP_MACRO = 0; % clear stop flag so we can set it with the stop command
IN_MACRO = 1; % indicate that we are running a macro.
%-----------------------------------------

%
% define parameters here for defaults in run.
% these may override the parameters set in the main protocols
mon_cycle = 10000;
cond_cycle = 1000;
% make sure protocols are current
g timing_cond
pv
s

g timing_base
pv
s
% Total protocol length about 40 minutes.
% Start with the base...
cycle mon_cycle % force cycle time
% insert a 3-minute pause before we start the data collection to allow the cell to stabilize.
pausetime = 1; % 10 second update
totpause = 3*60; % total pause in seconds
for i = 1:floor(totpause/pausetime)
   QueMessage(sprintf('Pausing for stability: %d sec remaining', totpause - (i-1)*pausetime), 1);
   pause(pausetime);
	% a line like this is necessary after every command to stop the macro completely.
	if(check_macro_stop) return; end;
end;

take 60  % sets up for 600 seconds (10 minutes) at 10 sec intervals

% a line like this is necessary after every command to stop the macro completely.
if(check_macro_stop) return; end;

g timing_cond % conditioning stimuli delivered here. Large pulse used to ensure stimulation
cycle cond_cycle
take 120 % conditioning consists of 120 pairings over 2 minutes.
if(check_macro_stop) return; end;

g timing_base % measure again with same parameters as baseline
cycle mon_cycle
take 240	% take 40 minutes at 10 second intervals
if(check_macro_stop) return; end;
%
% now get cciv again and re-run with all parameters
%
g ap-iv % to confirm basic cell information
seq
if(check_macro_stop) return; end;

%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



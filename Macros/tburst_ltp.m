function tburst_ltp(varargin)
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
% 
% Modified 3/15/02 Paul B. Manis, Ph.D.
% include online analysis and analysis windows in the program. 
% manipulate the online data structure so that analysis during acquisition
% runs properly.
%
% Modified 5/21/02 Paul B. Manis, Ph.D.
% hold cell at "-60" mV during baseline and testing; not during conditioning.
% to keep EPSPs well below spike threshold
% tburst does bursting protocol... 
% 5 stim @ 20Hz with spikes staggered.
%
global STIM
global STIM2
global ONLINE % access ONLINE to control online display of information.

% parameters for the run.
holdvoltage = '-58';
def_delta_t = '10'; % time between spike and external shock - in msed. Neg means spike precedes shock
def_iinj = '1000'; % current injection level to initiate a spike during conditioning
def_shkv = '30';	% the number to use for the shock stimulus.	
def_ipi = '33.3'; % default interpulse interval....
def_delay2 = '50'; % the time where the shock occurs during conditioning.
def_prepause = '0'; % pause in seconds before starting protocol.
def_baseline = '780'; % seconds baseline.
% define parameters here for defaults in run.
% these may override the parameters set in the main protocols
mon_cycle = 10000; % capture 1/10 seconds to monitor 
cond_cycle = 4000; % once per 4 seconds for conditioning stimulation (per Markhram 97)
stim_ipi = 100; % conditioning interpulse interval
stim_dur = 5; % duration of AP stimlulus pulse
stim_npulses = 5; % number of stimuli in each conditioning train
stim_NCycles = 15; % number of repeates of conditioning burst

% The following section is required in all macros:

%-----------------------------------------
global IN_MACRO

if(~ok_macro_run) % function returns 0 if not ok to run the macro
   return;
end;
%-----------------------------------------

if(nargin > 0)
   testmode = 1; % set test mode...
else
   testmode = 0;
end;
def_testmode = sprintf('%d', testmode);
% we ask for the stimlulus parameters (and make a note!)
prompt={'Enter Shock Level:','Enter the Cell Current Level:','Enter the time delay (msec):', ...
        'Enter the Burst IPI (msec):', 'Enter Pre-pause (seconds):', ...
        'Test Mode (set to 1 for test mode):', 'Baseline time (sec):'};
def={def_shkv, def_iinj, def_delta_t, def_ipi, def_prepause, def_testmode, def_baseline};
dlgTitle='Input for Tburst_LTP';
lineNo=1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
   IN_MACRO = 0; % turn off macro flag.
   QueMessage('Tburst_LTP cancelled', 1);
   return; % that's all
end;

shkv = str2num(answer{1});
iinj = str2num(answer{2});
deltat = str2num(answer{3});
stim_ipi = str2num(answer{4});
prepause = str2num(answer{5});
testmode = str2num(answer{6});
baseline = str2num(answer{7});
if(testmode)
    QueMessage('tburst_ltp is running in test mode', 1);
end;

% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('Timing -burst LTP Parameters: Delta-T: %7.1f ms  IInj: %7.1f pA   Shock Level: %7.1f (V, uA) Condition Cycle time: %7.1f sec  Monitor Cycle time: %8.1f sec', ...
   deltat, iinj, shkv, cond_cycle, mon_cycle);
nb = [nb sprintf('\n   stim_ipi: %7.1f ms  stim_Npulses: %8d', stim_ipi, stim_npulses)];
note(nb);

% make sure protocols are current
% first set shock level...
g timing_pfshock;
STIM.Level.v(1)=shkv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v = 10; % change delay time for EPSP start 
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s timing_pfshock;

g tb_pfcond
STIM.Level.v(1)=shkv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v(1) = str2num(def_delay2); % change delay time for EPSP start 
STIM.Npulses.v = stim_npulses;
STIM.IPI.v = stim_ipi;
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s tb_pfcond

% second make sure timing_pfshock is current in timing_base protocol
g timing_base
STIM.Addchannel.v = '';
STIM.update = 0;
STIM=pv(STIM, 1);
STIM.Addchannel.v='timing_pfshock';
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s timing_base

onl = ONLINE; % get current ONLINE structure - will include measurement windows

% build the conditioning protocol
g tb_cond
% now set the current injection and force update of shock information
STIM.Addchannel.v = ''; % remove the previous pfshock and replace it with whatever is current
STIM.update = 0;
STIM=pv(STIM, 1); % clear the condioning on the second channel
STIM.Cycle.v=cond_cycle;
STIM.Level.v(2:2:10) = iinj;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(2));
STIM.Duration.v(1) = str2num(def_delay2) + deltat; % duration 1 is spike lag time from start
STIM.Duration.v(2:2:10) = stim_dur;
STIM.Duration.v(3:2:10) = stim_ipi-stim_dur;
STIM.Addchannel.v='tb_pfcond';
STIM.update = 0;
STIM=pv(STIM, 1);
ONLINE = onl; % duplicate online structure for the conditioning stimuli
pv;
s tb_cond

% Total protocol length about 40 minutes.
% Start with the base...

g timing_base % back to baseline protocol

STIM.Cycle.v=mon_cycle; % force cycle time
% insert a 3-minute pause before we start the data collection to allow the cell to stabilize.
pausetime = 1; % 10 second update
if(testmode == 0)
   totpause = prepause; % total pause in seconds
else
   totpause = 5;
end;

sethold('off');
%sethold(holdvoltage);
for i = 1:floor(totpause/pausetime)
   QueMessage(sprintf('Pausing for stability: %d sec remaining', totpause - (i-1)*pausetime), 1);
   pause(pausetime);
   % a line like this is necessary after every command to stop the macro completely.
   if(check_macro_stop) 
      sethold('off');
      return;
   end;
end;

ONLINE.Enable{1} = 1; % make sure both analysis windows are enabled.
ONLINE.Enable{2} = 1;
ONLINE.AutoReset{1} = 1; % turn on auto reset to clear online display
ONLINE.AutoReset{2} = 1; % turn on auto reset to clear online display
%on_line('update'); % update online display window.

%sethold(holdvoltage);
nt = floor(baseline/10);
if(testmode == 0)
   take(nt)  % sets up for 600 seconds (10 minutes) at 10 sec intervals
else
   take 3  % TEST
end;
% a line like this is necessary after every command to stop the macro completely.
if(check_macro_stop) 
   sethold('off');
   return;
end;

for i = 1:2
   
   sethold('off'); % relieve clamp
   if ( i == 2) % make a different conditioning stimulus with the delay negated!
      % build the conditioning protocol
      g tb_cond
      % now set the current injection and force update of shock information
      STIM.Addchannel.v = ''; % remove the previous pfshock and replace it with whatever is current
      STIM.update = 0;
      STIM=pv(STIM, 1); % clear the condioning on the second channel
      STIM.Cycle.v=cond_cycle;
      STIM.Level.v(2:2:10) = iinj;
      STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(2));
      STIM.Duration.v(1) = str2num(def_delay2) - deltat; % duration 1 is spike lag time from start
      STIM.Addchannel.v='tb_pfcond';
      STIM.update = 0;
        STIM=pv(STIM, 1);
      ONLINE = onl; % duplicate online structure for the conditioning stimuli
      pv('-f');
      s tb_cond
      
   end;
   
   
   g tb_cond % conditioning stimuli delivered here. Large pulse used to ensure stimulation
   
   ONLINE.Enable{1} = 0; % Leave membrane potential monitor ON during conditioning.
   ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
   ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
   ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
   % set up window 2 analysis as above....
   
   sethold('off'); % relieve clamp
   
   if(testmode == 0)
      %   take 120 % conditioning consists of 120 pairings over 2 minutes.
      take 15
   else
      take 5
   end;
   
   if(check_macro_stop) 
      sethold('off');
      return;
   end;
   
   g timing_base % measure again with same parameters as baseline
   STIM.Cycle.v=mon_cycle;
   
   ONLINE.Enable{1} = 1; % Leave membrane potential monitor ON during conditioning.
   ONLINE.Enable{2} = 1; % stop measuring during conditioning for the PSP.
   ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
   ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
   
   %sethold(holdvoltage)
   
   if(testmode == 0)
      take 120	% take 40 minutes at 10 second intervals
      %   take 120 % in two different blocks
   else
      take 5
   end;
   if(check_macro_stop) 
      sethold('off');
      return;
   end;
end;

sethold('off');
%
% now get cciv again and re-run with all parameters
%
g ap-iv2 % to confirm basic cell information
seq
if(check_macro_stop) 
   sethold('off');
   return;
end;

%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



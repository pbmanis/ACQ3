function hpc_ltpvc(varargin)
% hpc_ltpvc : protocol for depolarization-paired ltp/ltd.
% Use hpc_shock.mat to shock ca1 sc
% stimulus current level is set in hpc_base.mat
% Depolarization level is set in hpc_cond.mat
%
% Test stimuli consist of sc shocks at 1/10 seconds. 
% Pairing consists of pairing identical sc shocks, at 3 hz, with 
% depolarization of the postsynatpic cell to 0 mv.
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
% modifiedl 6/27/2007 for hippocampal experiments w/ Rao - Dudek.
% uses voltage clamp to measure epscs.
%
global STIM
global STIM2
global ONLINE % access ONLINE to control online display of information.

% parameters for the run.
def_holdvoltage = '-65';
def_condvoltage = '0';
def_ipi = '333'; % Stimulus rate during pairing
def_pairingdur = '60'; % seconds for pairing protocol
def_shkv = '60';	% the number to use for the shock stimulus.	
def_baseline = '30'; % seconds baseline.
% define parameters here for defaults in run.
% these may override the parameters set in the main protocols
mon_cycle = 10000; % capture 1/10 seconds to monitor 

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
prompt={'Enter Shock Level:', ...
        'Enter the Conditioning IPI (ms):',...
        'Conditioning duration (sec)', ...
        'Holding voltage (mV)',  ...
        'Condition voltage (mV)', ...
        'Baseline time (sec):'};
def={def_shkv, def_ipi def_pairingdur, def_holdvoltage, def_condvoltage, def_baseline};
dlgTitle='Input for ltpvc_LTP';
lineNo=1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
    IN_MACRO = 0; % turn off macro flag.
    QueMessage('hpc_LTPvc cancelled', 1);
    return; % that's all
end;
testmode

shkv = str2num(answer{1});
stimipi = str2num(answer{2});
pairingdur = str2num(answer{3});
holdvoltage = str2num(answer{4});
condvoltage = str2num(answer{5});
baseline = str2num(answer{6});

postn = floor(30 * 60);
ncond = floor(pairingdur*1000/stimipi);

fprintf(1, 'Postn: %d   ncond: %d\n', postn, ncond);
% ans = inputdlg({sprintf('postn=%d, ncond = %d  are ok? (anything to proceed)', postn, ncond)}, 'Cancel Now');
% if(isempty(ans))
%     IN_MACRO = 0; % turn off macro flag.
%     QueMessage('hpc_LTPvc cancelled', 1);
%     return; % that's all
% end;

if(testmode)
    QueMessage('hpc_ltpvc is running in test mode', 1);
    fprintf(1, 'Test mode\n');
end;

% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('hpc_ltpvc Parameters:  Shock Level: %7.1f (V, uA) Stim ipi: %7.1f (ms) Pairing Duration: %7.1f (sec)  Monitor Cycle time: %8.1f sec', ...
    shkv, stimipi, pairingdur, mon_cycle);
nb = [nb sprintf('\n   hold V: %7.1f (mV)  cond V: %7.1f (mV) baseline duration: %8d (s)', ...
        holdvoltage, condvoltage, baseline)];
note(nb);
fprintf(1, '%s', nb);

% make sure protocols are current
% first set shock level...


% second make sure timing_pfshock is current in timing_base protocol
g hpc_ltpvc_base
STIM.Addchannel.v = '';
STIM.Cycle.v = mon_cycle;
STIM.Holding.v = holdvoltage;
STIM.Level.v = sprintf('[%d %d %d]', holdvoltage, holdvoltage-10, holdvoltage);
STIM.Duration.v = '[110 10 10]';
STIM.update = 0;
STIM=pv(STIM, 1);
pause(2)
STIM.Addchannel.v='hpc_ltpvc_shock';
STIM2.Level.v = [shkv 0];
STIM2.Duration.v = [0.2 0];
STIM2.Sequence.v = sprintf('%7.1f', STIM2.Level.v(1));
STIM2.update = 0;
STIM2=pv(STIM2, 1);
pause(2)
s2('hpc_ltpvc_shock');
STIM.update = 0;
pv;
pause(2)
STIM=pv(STIM, 1);

s('hpc_ltpvc_base');

onl = ONLINE; % get current ONLINE structure - will include measurement windows

% build the conditioning protocol
STIM.Name.v = 'hpc_ltpvc_cond';
STIM.Holding.v = condvoltage;
STIM.Level.v = sprintf('[%d %d %d]', condvoltage, condvoltage-10, condvoltage);
STIM.Cycle.v = stimipi;
STIM.update = 0;
STIM=pv(STIM, 1);
pause(2)
STIM.Addchannel.v='hpc_ltpvc_shock';
STIM2.Level.v = [shkv 0];
STIM2.Duration.v = [0.2 0];
STIM2.Sequence.v = sprintf('%7.1f', STIM2.Level.v(1));
STIM2.update = 0;
STIM2=pv(STIM2, 1);
pause(2)
s2('hpc_ltpvc_shock');
STIM.update = 0;
pv;
pause(2)
STIM=pv(STIM, 1);
pause(2)

s hpc_ltpvc_cond

% Total protocol length about 40 minutes.
% Start with the base...

g hpc_ltpvc_base % back to baseline protocol

STIM.Cycle.v=mon_cycle; % force cycle time

sethold('off');
%sethold(holdvoltage);

ONLINE.Enable{1} = 0; % make sure both analysis windows are enabled.
ONLINE.Enable{2} = 0;
ONLINE.AutoReset{1} = 1; % turn on auto reset to clear online display
ONLINE.AutoReset{2} = 1; % turn on auto reset to clear online display
%on_line('update'); % update online display window.

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

sethold('off'); % relieve clamp   

g hpc_ltpvc_cond % conditioning stimuli delivered here. Large pulse used to ensure stimulation

ONLINE.Enable{1} = 0; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
% set up window 2 analysis as above....

sethold('off'); % relieve clamp

if(testmode == 0)
    take(ncond);
else
    take 5
end;

if(check_macro_stop) 
    sethold('off');
    return;
end;

g hpc_ltpvc_base % measure again with same parameters as baseline
STIM.Cycle.v=mon_cycle;

ONLINE.Enable{1} = 0; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates


if(testmode == 0)
    take(postn);	% take 30 minutes at 10 second intervals
else
    take 5
end;
if(check_macro_stop) 
    sethold('off');
    return;
end;


sethold('off');
%
%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



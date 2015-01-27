function ltp(varargin)
% ltp : protocol for LTP - timing based or otherwise ltp/ltd.
% This uses 4 stimulus protocols:
% baseline test is ltp_base, and ltp_base2
% Conditioning is ltp_cond and ltp_cond2
% where 2 refers to the second channel.
% Stimulus current level is set in ltp_base2.mat
% intracellular current pulse level is set in ltp_cond.mat
%
% Test stimulus typically consists of afferent shocks at 1/10 seconds. 
% Pairing consists of pairing identical afferent shocks with current pulse
% to evoke an AP at varying intervals with respect to the PF shock.
% Lastly, we monitor the epsp/epsc to pf shock for about 40 minutes.
% 
% Latest version: 8/27/2008
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% this version uses new ACQ3 path definitions; parameters are stored on a
% per user basis in their own directories.
%

%
global STIM
global ONLINE % access ONLINE to control online display of information.
global CONFIG BASEPATH

fprintf(2, 'Running LTP from Macros Directory\n');
% define filenames for the protocols
% base protocol:
BaselineProtocol = 'ltp_base';
BaselineProtocol2 = 'ltp_base2';
ConditionProtocol = 'ltp_cond';
ConditionProtocol2 = 'ltp_cond2';

% parameters for the run.
ParameterFile = slash4OS([BASEPATH CONFIG.MacroPath.v '/ltp_parameters.mat']);
if(exist(ParameterFile, 'file')) % read the file... if it exists
    load(ParameterFile, 'par');
    
else
    % Otherwise initialize the structure and save it
    % for standard thresholding analysis.
    
    par.holdvoltage = -58;
    par.delta_t = 10; % time between spike and external shock - in msec. Neg means spike precedes shock
    par.iinj = 1000; % current injection level to initiate a spike during conditioning
    par.shkv = 30;	% the number to use for the shock stimulus.	
    par.ipi = 100; % default interpulse interval....
    par.delay2 = 100; % the time where the shock occurs during conditioning.
    par.nCycles = 10; % # repeats of conditioning
    par.cell_stim_dur = 5;
    par.cell_stimN = 1;
    par.cond_cycle = 1000; % cycle in conditioning protocol (stim rate).
    % define parameters here for defaults in run.
    % these may override the parameters set in the main protocols
    par.mon_cycle = 10000; % capture 1/10 seconds to monitor 
    par.stim_ipi = 100; % conditioning interpulse interval
    par.stim_dur = 5; % duration of AP stimlulus pulse
    par.stim_npulses = 5; % number of stimuli in each conditioning train
    par.stim_nCycles = 100; % number of repeats of conditioning burst
    
    save(ParameterFile, 'par'); % save it to disk


end;


% The following section is required in all macros:

%-----------------------------------------
global IN_MACRO
%-----------------------------------------

testmode = 1;

if(nargin > 0)
    testmode = varargin{1}; % set test mode...
    IN_MACRO = 0;
else
    testmode = 0;
end;
if(~ok_macro_run) % function returns 0 if not ok to run the macro
    return;
end;
testmode = 0;

% we ask for the stimlulus parameters (and make a note!)
prompt={'Shock Level:','Cell Current Level:','Cell Current Dur (ms):', ...
        'Cell pulse count (N): ', 'Conditionomg cycle time (ms): ', 'Conditioning delay (msec):', ...
        'Presynaptic Burst IPI (msec):', 'Presynaptic pulses in train:', 'Number of Pairings:'};
def={num2str(par.shkv), num2str(par.iinj), num2str(par.cell_stim_dur), ...
        num2str(par.cell_stimN), num2str(par.cond_cycle), num2str(par.delta_t), ...
        num2str(par.ipi), num2str(par.stim_npulses), num2str(par.nCycles)};
dlgTitle='Input_for_LTP';
lineNo=1;

options.Resize='off';
options.WindowStyle='normal';
options.Interpreter='none';

answer=my_inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
    IN_MACRO = 0; % turn off macro flag.
    QueMessage('LTP macro cancelled', 1);
    return; % that's all
end;

par.shkv = str2double(answer{1});
par.iinj = str2double(answer{2});
par.cell_stim_dur = str2double(answer{3});
par.cell_stimN = str2double(answer{4});
par.cond_cycle = str2double(answer{5});
par.delta_t = str2double(answer{6});
par.stim_ipi = str2double(answer{7});
par.stim_npulses = str2double(answer{8});
par.stim_nCycles = str2double(answer{9});

save(ParameterFile, 'par'); % save updated parameters
%
% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('LTP Parameters: Delta-T: %7.1f ms  IInj: %7.1f pA   Shock Level: %7.1f (V, uA) Condition Cycle time: %7.1f sec  Monitor Cycle time: %8.1f sec', ...
    par.delta_t, par.iinj, par.shkv, par.cond_cycle, par.mon_cycle);
nb = [nb sprintf('\n   par.stim_ipi: %7.1f ms  par.stim_Npulses: %4d par.stim_nCycles: %4d, par.stim_dur: %6.1f ms', par.stim_ipi, par.stim_npulses, par.stim_nCycles, par.stim_dur)];
note(nb);

% make sure protocols are current
% first set shock level...
g(BaselineProtocol2);
STIM.Level.v(1)=par.shkv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v = 10; % change delay time for EPSP start 
STIM.update = 0;
pv('-f');
s(BaselineProtocol2);

% now make sure main protocol is updated
g(BaselineProtocol);
STIM.Addchannel.v = '';
STIM.Cycle.v = 10000;
STIM.update = 0;
STIM.Addchannel.v=BaselineProtocol2;
pv('-f');
s(BaselineProtocol);
onl = ONLINE; % get current ONLINE structure - will include measurement windows

g(ConditionProtocol2);
STIM.Level.v(1)=par.shkv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v(1) = number_arg(par.delay2); % change delay time for EPSP start 
STIM.Npulses.v = number_arg(par.stim_npulses);
STIM.IPI.v = number_arg(par.stim_ipi);
STIM.update = 0;
pv('-f');
s(ConditionProtocol2);

onl = ONLINE; % get current ONLINE structure - will include measurement windows

% build the main conditioning protocol
g(ConditionProtocol);
% now set the current injection and force update of shock information
STIM.Addchannel.v = ''; % remove the previous pfshock and replace it with whatever is current
STIM.update = 0;
STIM=pv(STIM, 1); % clear the condioning on the second channel
STIM.Cycle.v=par.cond_cycle;
STIM.Npulses.v = par.cell_stimN; 
STIM.Delay.v(1) = number_arg(par.delay2) + number_arg(par.delta_t); % duration 1 is spike lag time from start
STIM.Level.v = par.iinj;
STIM.Duration.v = par.cell_stim_dur;

STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v);
STIM.Addchannel.v=ConditionProtocol2;
STIM=pv('-f');
ONLINE = onl; % duplicate online structure for the conditioning stimuli
pv('-f');
pv('-p');
s(ConditionProtocol);


% Total protocol length about 40 minutes.
% Start with the base...

g(BaselineProtocol)% back to baseline protocol
pv('-p'); % update plot on screen to be sure it is current

STIM.Cycle.v=par.mon_cycle; % force cycle time
% insert a 3-minute pause before we start the data collection to allow the cell to stabilize.
    
if(testmode == 2) % if mode is 1, we do an abbreviated test run. If 2, we just calculate waveforms.
    IN_MACRO = 0; % turn off macro flag.
    return;
end;

sethold('off');

ONLINE.Enable{1} = 1; % make sure both analysis windows are enabled.
ONLINE.Enable{2} = 1;
ONLINE.AutoReset{1} = 1; % turn on auto reset to clear online display
ONLINE.AutoReset{2} = 1; % turn on auto reset to clear online display
%on_line('update'); % update online display window.

%sethold(holdvoltage);

%
% Take the baseline data here:
%

if(testmode == 0)
    take 30  % sets up for 600 seconds (10 minutes) at 10 sec intervals
else
    take 3  % TEST
end;
% a line like this is necessary after every command to stop the macro completely.
if(check_macro_stop) 
    sethold('off');
    return;
end;

sethold('off'); % relieve clamp   

%
% Perform the conditioning:
%
g(ConditionProtocol); % conditioning stimuli delivered here. Large pulse used to ensure stimulation
pv('-p');

ONLINE.Enable{1} = 0; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
% set up window 2 analysis as above....

sethold('off'); % relieve clamp

if(testmode == 0)
    take(par.stim_nCycles)
else
    take(par.stim_nCycles)
end;

if(check_macro_stop) 
    sethold('off');
    return;
end;

% 
% post conditioning data collection begins here:
%
g(BaselineProtocol); % measure again with same parameters as baseline
pv('-p');
STIM.Cycle.v=par.mon_cycle;

ONLINE.Enable{1} = 1; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 1; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates

%sethold(holdvoltage)

if(testmode == 0)
    take 240	% take 40 minutes at 10 second intervals
else
    take 5
end;
if(check_macro_stop) 
    sethold('off');
    return;
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



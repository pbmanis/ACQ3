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

fprintf(2, 'Running LTP from Macros/hao Directory\n');
% define filenames for the protocols
% base protocol:
BaselineProtocol = 'ltp_base';
BaselineProtocol2 = 'ltp_base2';
ConditionProtocol = 'ltp_cond';
ConditionProtocol2 = 'ltp_cond2';

% parameters for the run.
ParameterFile = slash4OS([BASEPATH CONFIG.MacroPath.v '/ltp_parameters_pbm.mat']);

if(exist(ParameterFile, 'file')) % read the file... if it exists
    load(ParameterFile, 'par');
else
    % Otherwise initialize the structure and save it
    % for standard thresholding analysis.
    
    % Presynaptic parameters
    par.pre_shockv = 30;	% the number to use for the shock stimulus.
    par.pre_delay = 100; % the time where the shock occurs during conditioning and baseine.
    par.pre_conditioning_nPulses = 1;
    par.pre_conditioning_ipi = 100;
    par.pre_conditioning_dur = 0.1;  % Not adjustable
    
    % postsynaptic parameters during conditioning:
    par.post_holdvoltage = -58;
    par.post_iinj = 800; % current injection level to initiate a spike during conditioning
    par.post_pairing_ipi = 8; % default interpulse interval for postsynaptic current during pairing
    par.post_iinj_dur = 3;
    par.post_iinj_stimN = 5;
    
    % conditioning parameters:
    par.conditioning_pre_post_delta_t = 10; % time between spike and external shock - in msec. Neg means spike precedes shock
    par.conditioning_nCycles = 10; % # repeats of conditioning
    par.conditioning_cycle = 1000; % cycle in conditioning protocol (stim rate).
    
    % define parameters here for defaults in run.
    % these may override the parameters set in the main protocols
    par.monitor_cycle = 10000; % capture 1/10 seconds to monitor
    
    save(ParameterFile, 'par'); % save it to disk
end;


% The following section is required in all macros:

%-----------------------------------------
global IN_MACRO
%-----------------------------------------


if(~ok_macro_run) % function returns 0 if not ok to run the macro
    return;
end;
testmode = 0;

% we ask for the stimlulus parameters (and make a note!)
prompt={'Presynaptic Shock Level:', 'Conditioning: Postsynaptic Current:', ...
    'Conditioning: Postsynaptic pulse dur (ms):', 'Conditioning: # Postsynaptic APs: ', ...
    'Conditioning: Postsynaptic IPI (ms):', ...
    'Conditioning: Cycle time (ms): ', 'Conditioning: Pre-Post delay (ms):', ...
    'Conditioning: # Presynaptic pulses:', 'Conditioning: Presynaptic IPI (ms):', ...
    'Conditioning: # of Pairings:', 'Testmode (1 for test)'};
def={num2str(par.pre_shockv), num2str(par.post_iinj), ...
    num2str(par.post_iinj_dur), num2str(par.post_iinj_stimN), ...
    num2str(par.post_pairing_ipi), ...
    num2str(par.conditioning_cycle), num2str(par.conditioning_pre_post_delta_t), ...
    num2str(par.pre_conditioning_nPulses), num2str(par.pre_conditioning_ipi), ...
    num2str(par.conditioning_nCycles), ...
    num2str(testmode)};
dlgTitle='Input_for_LTP';
lineNo=1;

options.Resize='off';
options.WindowStyle='normal';
options.Interpreter='none';
answer=inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
    IN_MACRO = 0; % turn off macro flag.
    QueMessage('LTP macro cancelled', 1);
    return; % that's all
end;

par.pre_shockv = str2double(answer{1});
par.post_iinj = str2double(answer{2});
par.post_iinj_dur = str2double(answer{3});
par.post_stimN = str2double(answer{4});
par.post_pairing_ipi = str2double(answer{5});
par.conditioning_cycle = str2double(answer{6});
par.conditioning_pre_post_delta_t = str2double(answer{7});
par.pre_conditioning_ipi = str2double(answer{8});
par.pre_conditioning_npulses = str2double(answer{9});
par.conditioning_nCycles = str2double(answer{10});
testmode = str2double(answer{11});
if (testmode <= 0)
    testmode = 0;
else
    testmode = 1;
end

save(ParameterFile, 'par'); % save updated parameters
%
% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('LTP Parameters: Delta-T: %7.1f ms  IInj: %7.1f pA   Shock Level: %7.1f (V, uA) Condition Cycle time: %7.1f sec  Monitor Cycle time: %8.1f sec', ...
    par.conditioning_pre_post_delta_t, par.post_iinj, par.pre_shockv, par.conditioning_cycle, ...
    par.monitor_cycle);
nb = [nb sprintf('\n   pre conditioning ipi: %7.1f ms  Pre conditioning Npulses: %4d Conditioning nCycles: %4d, par.stim_dur: %6.1f ms', ...
    par.pre_conditioning_ipi, par.pre_conditioning_npulses, par.conditioning_nCycles, ...
    par.pre_conditioning_dur)];
note(nb);

% make sure protocols are current
% first set shock level...
g(BaselineProtocol2);
STIM.Level.v(1 ) = par.pre_shockv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v(1) = number_arg(par.pre_delay); % change delay time for EPSP start
STIM.update = 0;
pv('-f');
s(BaselineProtocol2);

% now make sure main protocol is updated
g(BaselineProtocol);
STIM.Addchannel.v = '';
STIM.Cycle.v = 10000;
STIM.update = 0;
STIM.Addchannel.v = BaselineProtocol2;
pv('-f');
s(BaselineProtocol);
onl = ONLINE; % get current ONLINE structure - will include measurement windows

g(ConditionProtocol2);
STIM.Level.v(1) = par.pre_shockv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Delay.v(1) = number_arg(par.pre_delay);
STIM.Npulses.v = number_arg(par.pre_conditioning_npulses);
STIM.IPI.v = number_arg(par.pre_conditioning_ipi);
STIM.update = 0;
pv('-f');
s(ConditionProtocol2);

onl = ONLINE; % get current ONLINE structure - will include measurement windows

% build the main conditioning protocol
g(ConditionProtocol);
% now set the current injection and force update of shock information
STIM.Addchannel.v = ''; % remove the previous pfshock and replace it with whatever is current
STIM.update = 0;
STIM = pv(STIM, 1); % clear the condioning on the second channel
STIM.Cycle.v = par.conditioning_cycle;
STIM.Npulses.v = par.post_stimN;
STIM.IPI.v = par.post_pairing_ipi;
if (par.conditioning_pre_post_delta_t >= 0.)  % + delay: time from EPSP to first AP; - delay: time from last AP to EPSP
    STIM.Delay.v(1) = number_arg(par.pre_delay) + number_arg(par.conditioning_pre_post_delta_t); % duration 1 is spike lag time from start
else
    aptraindur = par.post_stimN*par.post_pairing_ipi;
    STIM.Delay.v(1) = number_arg(par.conditioning_pre_post_delta_t) - aptraindur - number_arg(par.pre_delay);
end
STIM.Level.v = par.post_iinj;
STIM.Duration.v = par.post_iinj_dur;

STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v);
STIM.Addchannel.v=ConditionProtocol2;
STIM = pv('-f');
ONLINE = onl; % duplicate online structure for the conditioning stimuli
pv('-f');
pv('-p');
s(ConditionProtocol);


% Total protocol length about 40 minutes.
% Start with the base...

g(BaselineProtocol)% back to baseline protocol
pv('-p'); % update plot on screen to be sure it is current

STIM.Cycle.v = par.monitor_cycle; % force cycle time
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
fprintf(2, 'Test mode is: %d\n', testmode);

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

ONLINE.Enable{1} = 1; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
% set up window 2 analysis as above....

sethold('off'); % relieve clamp

if(testmode == 0)
    take(30)
else
    take(5)
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
STIM.Cycle.v = par.monitor_cycle;

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
g cciv % to confirm basic cell information
seq
if(check_macro_stop)
    sethold('off');
    return;
end;

%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



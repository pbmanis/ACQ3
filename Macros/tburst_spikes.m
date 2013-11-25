function tburst_spikes(varargin)
% timing_spikes : protocol for stimulus based changes in spiking.
% Use spikeburst.mat to shock parallel fibers
% PF stimulus current level is set in spikeburst.mat
% intracellular current pulse level is set in spike_base.mat
%
% Test consists of a hyperpolarizing pulse followed by a depolarizing pulse. 
% conditioning consists of 4 Hz bursts of 10 pulses at 100 Hz.
% Lastly, we monitor the spike latency shifts with a sequence of hyperpolarizing steps.
% 
% Created from tburst_ltp macro 2/16/05 by Jaime Mancilla, Ph.D. and  Paul
% B. Manis, Ph.D.


global STIM
global STIM2
global ONLINE % access ONLINE to control online display of information.

% parameters for the run.
def_shkv = '30';	% Amplitude for the shock stimulus.	
def_prepause = '0';  % pause in seconds before starting protocol.
def_baseline = '10'; % baseline in minutes.
def_posttime = '20'; % post-conditioning time.
def_mcycle = '30000'; % time between samples during monitoring.
def_ccycle = '250';  % time between bursts during conditioning.
def_npulses = '10';  % number of stimulus pulses during conditioning bursts.
def_NBursts = '50';  % number of bursts during conditioning.
def_testmode = '0'; % flag for test mode.

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
prompt={'Enter Shock Level:','Enter Pre-pause (seconds):',...
        'Baseline time (min):', 'Enter Post Cond Time (min):', 'Enter Monitor Cycle (msec):',...
        'Enter Conditioning Cycle (msec):', 'Enter Number of Pulses:',...
        'Enter Number of Bursts:', 'Test Mode (1 for test): '};
def={def_shkv,def_prepause, def_baseline, def_posttime, def_mcycle,... 
        def_ccycle, def_npulses, def_NBursts, def_testmode};
dlgTitle='Input for Tburst_Spike';
lineNo=1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
    IN_MACRO = 0; % turn off macro flag.
    QueMessage('Tburst_Spike cancelled', 1);
    return; % that's all
end;

shkv = str2num(answer{1});
prepause = str2num(answer{2});
baseline = (str2num(answer{3})*60);
posttime = str2num(answer{4});
mon_cycle = str2num(answer{5});
cond_cycle = str2num(answer{6});
stim_npulses = str2num(answer{7});
stim_NBursts = str2num(answer{8});
testmode = str2num(answer{9});



if(testmode)
    QueMessage('tburst_spike is running in test mode', 1);
    mon_cycle = 2000;
end;

% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('Timing -burst Spike Parameters: Shock Level: %7.1f (V, uA) Condition Cycle time: %7.1f sec  Monitor Cycle time: %8.1f sec Number of Pulses: %7.1f  Number of Bursts: %7.1f',...
    shkv, cond_cycle, mon_cycle, stim_npulses, stim_NBursts);
nb = [nb sprintf('\n  stim_Npulses: %8d', stim_npulses)];
note(nb);

% make sure protocols are current
% first set shock parameters...
g spikeburst
STIM.Level.v(1) = shkv;
STIM.Sequence.v = sprintf('%7.1f', STIM.Level.v(1));
STIM.Npulses.v = stim_npulses;
STIM.NBurst.v = stim_NBursts;
STIM.IBI.v = cond_cycle;
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s spikeburst

g spike_pfcond
STIM.Addchannel.v = 'spikeburst';
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s spike_pfcond

% second make sure spike_base and ap-hyp2 are current.
g spike_base
STIM.Addchannel.v = '';
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s spike_base

g ap-hyp2
STIM.Addchannel.v = '';
STIM.update = 0;
STIM=pv(STIM, 1);
pv;
s ap-hyp2

onl = ONLINE; % get current ONLINE structure - will include measurement windows


if(testmode == 0)
    % Total protocol length about 40 minutes.
% Start by checking spike latency shifts...
g ap-hyp2
seq
end;

g spike_base % back to baseline protocol

STIM.Cycle.v=mon_cycle; % force cycle time
% insert a 3-minute pause before we start the data collection to allow the cell to stabilize.
pausetime = 1; % 10 second update
if(testmode == 0)
    totpause = prepause; % total pause in seconds
else
    totpause = 5;
end;

for i = 1:floor(totpause/pausetime)
    QueMessage(sprintf('Pausing for stability: %d sec remaining', totpause - (i-1)*pausetime), 1);
    pause(pausetime);
    % a line like this is necessary after every command to stop the macro completely.
    if(check_macro_stop) 
        return;
    end;
end;

ONLINE.Enable{1} = 1; % make sure both analysis windows are enabled.
ONLINE.Enable{2} = 1;
ONLINE.AutoReset{1} = 1; % turn on auto reset to clear online display
ONLINE.AutoReset{2} = 1; % turn on auto reset to clear online display
%on_line('update'); % update online display window.


nt = floor(baseline/(mon_cycle / 1000));
if(testmode == 0)
    take(nt + 1)  % sets up the baseline number of traces based on the monitor cycle in msec
    % and the baseline time in minutes.
else
    take 3  % TEST
end;
% a line like this is necessary after every command to stop the macro completely.
if(check_macro_stop) 
    return;
end;

g spike_pfcond % conditioning stimuli delivered here.

ONLINE.Enable{1} = 0; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 0; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates
% set up window 2 analysis as above....

if(testmode == 0)
    take 1 %conditioning stimuli are in one trace.
else
    take 1
end;

if(check_macro_stop) 
    return;
end;

g spike_base % measure again with same parameters as baseline
STIM.Cycle.v=mon_cycle;

ONLINE.Enable{1} = 1; % Leave membrane potential monitor ON during conditioning.
ONLINE.Enable{2} = 1; % stop measuring during conditioning for the PSP.
ONLINE.AutoReset{1} = 0; % turn off auto reset so that display accumulates
ONLINE.AutoReset{2} = 0; % turn off auto reset so that display accumulates


if(testmode == 0)
    pt = floor(posttime*(60/(mon_cycle / 1000)));
    take (pt + 1)	% take the post-conditioning number of traces based on the posttime in minutes
    %and the monitor cycle in msec.
    
else
    take 2
end;
if(check_macro_stop) 
    return;
end;
% now get the spike latency shifts again.

g ap-hyp2 
seq
if(check_macro_stop) 
    return;
end;

%------ REQUIRED OF ALL MACROS::: successful exit
IN_MACRO = 0; % turn off macro flag.
return; % that's all



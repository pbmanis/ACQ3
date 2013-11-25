function [outarg] = new(varargin)
% new: create and initialize the driving data structures
% ***CMD***
% The line above specifies this file as available at the command line in
% acq3

% Usage
%     new type, where type is 'steps', 'pulse', 'ramp', 'alpha', 'sine',
%         or any other defined stimulus method.

% The argument 'type' determines the details of the structure.
% The argument 'method' must correspond to an accessible m file that is used
% to generate the stimulus waveforms.
%
% Sfile obeys the struct_edit format...
% 7/10/2000
%
% 9/7/2000: changed so that this routine embeds all "new" commands
% by putting newacq and newc sources into the file and detecting
% the request via the calling argument
%
% 10/3/2000: added noise to possibilities
% added duplicate stimuli.
%
% 1/30/2004: added "sine" to possibilities
%
% 3/18/2008: clean up in preparation for new configuration setups
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global STIM DFILE CONFIG

if(nargout >= 1)
    outarg = [];
end;
if(nargin == 0)
    QueMessage('new: arg is type: stim method, acq or config', 1);
    return;
end;
type = varargin{1};

% determine from calling argument 'method' whether we are initializing
% an acq, config or some stimulus
switch(lower(type))
    case 'acq'
        dfile = newacq;
        if(nargout == 0) % no output - do our usual thing
            struct_edit('clear', DFILE);
            DFILE = dfile;
            struct_edit('Edit', DFILE);
        else
            outarg = dfile; % if there is an output arg, we just make the structure and return it
        end;

    case 'config'
        cfile = newc;
        if(nargout == 0) % no output - do our usual thing
            struct_edit('clear', CONFIG);
            CONFIG = cfile;
            struct_edit('Edit', CONFIG);
        else
            outarg = cfile; % if there is an output arg, we just make the structure and return it
        end;

    otherwise
        % determine whether the method we asked for exists as a stimulus method.
        fe=exist(type, 'file');
        if(fe ~= 2 && fe ~= 6)
            QueMessage(sprintf('new stim: Unable to find method %s', type), 1);
            return;
        end;
        sfile = newstim(type);
        if(nargout == 0) % no output - do our usual thing
            struct_edit('clear', STIM);
            STIM = sfile;
            struct_edit('edit', STIM);
        else
            outarg = sfile; % if there is an output arg, we just make the structure and return it
        end;

end;


function [sfile] = newstim(method)
% definitions
SGL = 0;
MULT = 1;

% the stim file consists of a base set of information and a variable
% section
%
%Base section;

sfile.title='Stimulus Parameters';
sfile.NAME='STIM';
sfile.callback='paste';
sfile.Calculate = 'Stim_calculate'; % routine for recalculation of dependent parameters
sfile.frame = 'FStim'; % frame to associate window with
sfile.fhandles = []; % handles for data elements (used dynamically - not structure)
sfile.method_code=[]; % holds the source file for the method on writing.
sfile.waveform = []; % holds the actual stimulus command waveforms after they are computed
sfile.tbase = []; % holds the time base for the waveform
sfile.outrate = []; % holds the output rate for the waveform.
sfile.update = 0; % flag to control updating - the waveform, tbase and out_rate are not current unless this is set
sfile.start=1;
% the following are common to all stim types:

sfile.Method =    create_element(method,    SGL, 1, 'Method',  '%s'); % the source file for the method
sfile.Name =      create_element('IV',      SGL, 2, 'Name',    '%s'); % name of this file
sfile.AcqFile =   create_element('', SGL, 3, 'AcqFile', '%s'); % define the acquisition file to control input
sfile.Addchannel = create_element('', SGL, 98, 'Addchannel', '%c'); % file to place on second output line
sfile.Cycle =     create_element(1000,      SGL, 4, 'Cycle(ms)',       '%6.1f', 0, 50, 65000); % cycle time in msec;
sfile.Repeats =   create_element(1,         SGL, 5, 'Reps(N)',  '%d',    0,  1,  1000); % number of reps for each stimulus
sfile.Stim_Repeat = create_element(1,       SGL, 6, 'ProtoReps(N)', '%d',    0,  1,    50); % number of times to do the whole stim sequence
sfile.Holding = create_element(0, SGL, 99, 'Holding', '%6.2f'); % all must have holding.

% the following determines the variable section:
switch(method)

    case 'steps' % Create a series of steps with duration and level, with a sequence
        sfile.Sample_Rate = create_element(1000, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Sequence=create_element('-100;50/5', SGL, 8, 'Sequence', '%c'); % use seq_parse to set these values up
        sfile.SeqParList=create_element('Level', SGL, 9, 'SeqPar', '%c');
        sfile.SeqStepList=create_element(2, MULT, 10, 'SeqStepNo', '%d', 0, 1);
        sfile.Duration=create_element([5,100,50], MULT, 11, 'Durs(ms)', '%6.1f', 0, 0, 30000); % hold duration
        sfile.Level=create_element([0,-100,0], MULT, 12, 'Level', '%6.1f'); % interim holding value
        sfile.Superimpose = create_element('', SGL, 14, 'Superimpose', '%c'); % file to superimpose on present one

    case 'ramp'
        sfile.Sample_Rate = create_element(1000, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Sequence=create_element('-100;50/5', SGL, 8, 'Sequence', '%c'); % use seq_parse to set these values up
        sfile.SeqParList=create_element('Level', SGL, 9, 'SeqParameter', '%c');
        sfile.SeqStepList=create_element(2, MULT, 10, 'SeqStepNo', '%d', 0, 1);
        sfile.Duration=create_element([5,5,400], MULT, 11, 'Durations(ms)', '%8.1f', 0, 0, 30000); % hold duration
        sfile.Level=create_element([-60,-100,0], MULT, 12, 'Levels(mV)', '%8.1f'); % interim holding value
        sfile.RampFlag=create_element([0 1 0], MULT, 13, 'RampFlags', '%d'); % flags for ramp/steady sections
        sfile.Superimpose = create_element('', SGL, 14, 'Superimpose', '%c'); % file to superimpose on present one

    case 'pulse'
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Npulses=create_element(5, SGL, 8, 'NPulses', '%d', 0, 0, 65000);
        sfile.Delay=create_element(5, SGL, 9, 'Delay(ms)', '%7.1f', 0, 0, 100000);
        sfile.IPI=create_element(10, SGL, 10, 'IPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.Duration=create_element([0.1, 0.1], MULT, 11, 'Durations(ms)', '%8.2f', 0, 0, 30000);
        sfile.Level=create_element([100,0], MULT, 12, 'Levels(mV)', '%8.1f'); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 13, 'LevelFlag', '%s');
        sfile.Scale=create_element(1, SGL, 14, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Sequence=create_element('1;100/25 & 10,20,50', SGL, 16, 'Sequence', '%c');
        sfile.SeqParList=create_element('Level ipi', MULT, 18, 'SeqParameter', '%c');
        sfile.SeqStepList=create_element(1, MULT, 19, 'SeqStepNo', '%d', 0, 1);
        sfile.Superimpose = create_element('', SGL, 20, 'Superimpose', '%c'); % file to superimpose on present one

    case 'SAM'
        sfile.Sample_Rate = create_element(100, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Npulses=create_element(5, SGL, 8, 'NPulses', '%d', 0, 0, 65000);
        sfile.Delay=create_element(5, SGL, 9, 'Delay(ms)', '%7.1f', 0, 0, 100000);
        sfile.IPI=create_element(10, SGL, 10, 'IPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.Duration=create_element(0.1, MULT, 11, 'Durations(ms)', '%8.2f', 0, 0, 30000);
        sfile.Level=create_element(100, MULT, 12, 'Levels(mV)', '%8.1f'); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 13, 'LevelFlag', '%s');
        sfile.Scale=create_element(1, SGL, 14, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Sequence=create_element('100', SGL, 16, 'Sequence', '%c');
        sfile.SeqParList=create_element('Level', MULT, 18, 'SeqParameter', '%c');
        sfile.SeqStepList=create_element(1, MULT, 19, 'SeqStepNo', '%d', 0, 1);
        sfile.SamDuration=create_element(1000.0, SGL, 20, 'SAMDur(ms) ', '%f', 0, 10000.0);
        sfile.SamRF = create_element(10.0, SGL, 21, 'SAMRF(ms) ', '%f', 1, 50);
        sfile.SamCarrier = create_element(2000.0, SGL, 22, 'SAMCarrier(Hz) ', '%f', 200.0, 5000.0);
        sfile.SamFMod = create_element(100.0, SGL, 23, 'SAMFmod(Hz) ', '%f', 10.0, 500.0);
        sfile.SamDepth = create_element(50.0, SGL, 24, 'SAMDepth(%) ', '%f', 0.0, 200.0);
        sfile.Superimpose = create_element('', SGL, 20, 'Superimpose', '%c'); % file to superimpose on present one

    case 'burst'
        sfile.Sample_Rate = create_element(100, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Npulses=create_element(1, SGL, 8, 'NPulses', '%d', 0, 0, 65000);
        sfile.Delay=create_element(5, SGL, 9, 'Delay(ms)', '%7.1f', 0, 0, 100000);
        sfile.IPI=create_element(10, SGL, 10, 'IPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.NBurst=create_element(1, SGL, 11, 'NBurst', '%d', 0, 0, 100);
        sfile.IBI=create_element(250, SGL, 12, 'IBI(ms)', '%8.2f', 0, 1, 10000);
        sfile.Duration=create_element([0.1, 0.1], MULT, 13, 'Durations(ms)', '%8.2f', 0, 0, 30000);
        sfile.Level=create_element([100,-100], MULT, 14, 'Levels(mV)', '%8.1f'); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 15, 'LevelFlag', '%s');
        sfile.Scale=create_element(1, SGL, 16, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Sequence=create_element('1;100/25', SGL, 17, 'Sequence', '%c');
        sfile.SeqParList=create_element('Level', MULT, 18, 'SeqParameter', '%c');
        sfile.SeqStepList=create_element(1, MULT, 19, 'SeqStepNo', '%d', 0, 1);
        sfile.Superimpose = create_element('', SGL, 20, 'Superimpose', '%c'); % file to superimpose on present one

    case 'testpulse' % pulse train, but with multiple test pulse added in later...or a sequence...
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Npulses=create_element(20, SGL, 8, 'NPulses', '%d', 0, 0, 65000);
        sfile.Delay=create_element(5, SGL, 9, 'Delay(ms)', '%7.1f', 0, 0, 100000);
        sfile.IPI=create_element(5, SGL, 10, 'IPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.Duration=create_element([0.1, 0.1], MULT, 11, 'Durations(ms)', '%8.2f', 0, 0, 30000);
        sfile.Level=create_element([100,0], MULT, 12, 'Levels(mV)', '%8.1f'); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 13, 'LevelFlag', '%s');
        sfile.Scale=create_element(1, SGL, 14, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Sequence=create_element('[2.5]', SGL, 15, 'Sequence', '%c');
        sfile.SeqParList=create_element('ipi', MULT, 16, 'SeqParameter', '%c');
        sfile.SeqStepList=create_element(1, MULT, 17, 'SeqStepNo', '%d', 0, 1);
        sfile.TestLevel=create_element(100, MULT, 18, 'TestLevel', '%8.1f'); % test pulse Level
        sfile.TestDelay=create_element(5, SGL, 19, 'TestDelay(ms)', '%8.1f'); % test pulse Delay
        sfile.TestNpulses=create_element(2, SGL, 20, 'TestNPulses', '%d', 0, 0, 65000);
        sfile.TestIPI=create_element(2.5, SGL, 21, 'TestIPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.TestDuration=create_element(0.1, MULT, 22, 'TestDuration(ms)', '%8.1f'); % test pulse Duration
        sfile.TestSequence = create_element('5;1000/5l', SGL, 23, 'TestSequence', '%c');
        sfile.TestSeqParList=create_element('delay', MULT, 24, 'TestSeqParameter', '%c');
        sfile.Superimpose = create_element('', SGL, 25, 'Superimpose', '%c'); % file to superimpose on present one

    case 'alpha'
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Npulses=create_element(1, SGL, 8, 'NPulses', '%d', 0, 0, 65000);
        sfile.Delay=create_element(5, SGL, 9, 'Delay(ms)', '%7.1f', 0, 0, 100000);
        sfile.IPI=create_element(10, SGL, 10, 'IPI(ms)', '%8.2f', 0, 0.001, 65000);
        sfile.Alpha=create_element(0.1, SGL, 11, 'tauAlpha', '%8.2f', 0, 0, 30000);
        sfile.Amplitude=create_element(1, SGL, 12, 'Amplitude', '%8.1f'); % interim holding value
        sfile.Scale=create_element(1, SGL, 13, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Sequence=create_element('1;100/25', SGL, 14, 'Sequence', '%c');
        sfile.SeqParList=create_element('Level', MULT, 15, 'SeqParameter', '%c');
        sfile.SeqLevelList=create_element(1, MULT, 16, 'SeqStepNo', '%d', 0, 1);
        sfile.Superimpose = create_element('', SGL, 17, 'Superimpose', '%c'); % file to superimpose on present one

    case 'noise' % Create a gaussian noise waveform, low pass filtered, with dc (possibily sequence lpf or dc)
        sfile.Sample_Rate = create_element(50, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Sequence=create_element('-100,0,100', SGL, 8, 'Sequence', '%c'); % use seq_parse to set these values up
        sfile.SeqParList=create_element('DC', SGL, 9, 'SeqParameter', '%c');
        sfile.Amplitude=create_element(5, SGL, 10, 'Amplitude', '%6.2f',0, 0, 5000);
        sfile.DC=create_element(0, SGL, 11, 'DC Current', '%6.1f', 0, 0, 30000); % DC current superimposed
        sfile.LPF=create_element(100, SGL, 12, 'LPF(Hz)', '%6.1f'); % LPF filtering of waveform
        sfile.Duration=create_element(250, SGL, 13, 'Duration(ms)', '%6.1f'); % duration of stimulus
        sfile.Seed = create_element(1,SGL, 14, 'Seed', '%d'); % random number seed (can be LIST)
        sfile.Superimpose = create_element('', SGL, 15, 'Superimpose', '%c'); % file to superimpose on present one

    case 'sine' % Create a gaussian noise waveform, low pass filtered, with dc (possibily sequence lpf or dc)
        sfile.Sample_Rate = create_element(50, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Sequence=create_element('-100,0,100', SGL, 8, 'Sequence', '%c'); % use seq_parse to set these values up
        sfile.SeqParList=create_element('DC', SGL, 9, 'SeqParameter', '%c');
        sfile.Amplitude=create_element(5, SGL, 10, 'Amplitude', '%6.2f',0, 0, 5000);
        sfile.DC=create_element(0, SGL, 11, 'DC Current', '%6.1f', 0, 0, 30000); % DC current superimposed
        sfile.Duration=create_element(250, SGL, 12, 'Duration(ms)', '%6.1f'); % duration of stimulus
        sfile.RiseFall=create_element(2, SGL, 13, 'RiseFall(ms)', '%6.1f'); % rise/fall time
        sfile.Frequency = create_element(1,SGL, 14, 'Frequency (Hz)', '%f'); % sin frequency
        sfile.Superimpose = create_element('', SGL, 15, 'Superimpose', '%c'); % file to superimpose on present one

    case 'audnerve' % create and auditory-nerve like stimulus train, using DSAM.
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Spont=create_element('high', SGL, 8, 'SpontClass', '%c');
        sfile.Frequency=create_element(8.0, SGL, 9, 'Frequency(Hz)', '%9.4f', 0, 1.0, 100000.0);
        sfile.Intensity=create_element(60.0, SGL, 10, 'Intensity(dBSPL)', '%8.1f', 0, 0.0, 120.0);
        sfile.Delay=create_element(500, SGL, 11, 'Delay(ms)', '%8.2f', 0, 0, 5000.0);
        sfile.Duration=create_element(100, SGL, 12, 'Duration(ms)', '%8.2f', 0, 1, 10000.0); % interim holding value
        sfile.Post=create_element(50, SGL, 13, 'Poststim(ms)', '%8.2f', 0, 1, 1000.0);
        sfile.Alpha=create_element(0, SGL, 14, 'Tau(ms)', '%8.3f', 0, -1000., 1000);
        sfile.Amplitude=create_element(1, SGL, 15, 'Amplitude(nA)', '%8.3f', 0, -10000., 10000);
        sfile.Converge=create_element(1, SGL, 16, 'Convergence(N)', '%d', 0, 1, 100);
        sfile.Prelease=create_element(1.0, SGL, 17, 'Prelease (0-1)', '%7.3f', 0, 0, 1.0);
        sfile.CV = create_element(0.0, SGL, 18, 'CV (sigma/mean)', '%7.3f', 0, 0, 2.0);
        sfile.Sequence=create_element('40;60/20', SGL, 19, 'Sequence', '%c');
        sfile.SeqParList=create_element('Intensity', MULT, 20, 'SeqParameter', '%c');
    %    sfile.Superimpose = create_element('', SGL, 21, 'Superimpose', '%c'); % file to superimpose on present one
    
    case 'anf' % create an anf stimulus - based on Jason Rothman's model (Johnson, 1980, Rothman et al, 1993).
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Spont=create_element(10.0, SGL, 8, 'Spont Rate (Hz)', '%%6.2f');
        sfile.Rate=create_element(50.0, SGL, 9, 'Mean Rate (Hz)', '%9.4f', 0, 0.1, 5000.0);
        sfile.Deadtime=create_element(1.40, SGL, 10, 'Deadtime (ms)', '%8.1f', 0, 0.0, 20.0);
        sfile.Delay=create_element(10, SGL, 11, 'Delay(ms)', '%8.2f', 0, 0, 5000.0);
        sfile.Duration=create_element(0.1, SGL, 12, 'Duration(ms)', '%8.2f', 0, 1, 10000.0); % interim holding value
        sfile.StimDur=create_element(500.0, SGL, 13, 'Stim Duration(ms)', '%8.2f', 0, 1, 10000.0); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 14, 'LevelFlag', '%s');
        sfile.Alpha=create_element(0, SGL, 15, 'Tau(ms)', '%8.3f', 0, -1000., 1000);
        sfile.Scale=create_element(1, SGL, 16, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Amplitude=create_element(100, SGL, 17, 'Amplitude(uA)', '%8.3f', 0, -10000., 10000);
        sfile.Converge=create_element(1, SGL, 18, 'Convergence(N)', '%d', 0, 1, 100);
        sfile.Sequence=create_element('[1:20]', SGL, 19, 'Sequence', '%c');
        sfile.SeqParList=create_element('seed', MULT, 20, 'SeqParameter', '%c');
        sfile.Seed = create_element(-1 ,MULT, 21, 'Seed', '%d', 0, 0, 10000); % random number seed (can sequence; this is "starting" seed.  Setting thi seed negative causes it to always be random!
        sfile.Superimpose = create_element('', SGL, 22, 'Superimpose', '%c'); % file to superimpose on present one

    case 'poisson' % create a poisson stimulus train (specify mean interval, dead time).
        sfile.Sample_Rate = create_element(20, SGL, 7, 'Rate(us)', '%6.1f', 0, 1); % base clock rate for stimulus, in microseconds.
        sfile.Spont=create_element(10.0, SGL, 8, 'Spont Rate (Hz)', '%%6.2f');
        sfile.Rate=create_element(50.0, SGL, 9, 'Mean Rate (Hz)', '%9.4f', 0, 0.1, 5000.0);
        sfile.Deadtime=create_element(1.40, SGL, 10, 'Deadtime (ms)', '%8.1f', 0, 0.0, 20.0);
        sfile.Delay=create_element(10, SGL, 11, 'Delay(ms)', '%8.2f', 0, 0, 5000.0);
        sfile.Duration=create_element(0.1, SGL, 12, 'Duration(ms)', '%8.2f', 0, 1, 10000.0); % interim holding value
        sfile.StimDur=create_element(500.0, SGL, 13, 'Stim Duration(ms)', '%8.2f', 0, 1, 10000.0); % interim holding value
        sfile.LevelFlag=create_element('absolute', MULT, 14, 'LevelFlag', '%s');
        sfile.Alpha=create_element(0, SGL, 15, 'Tau(ms)', '%8.3f', 0, -1000., 1000);
        sfile.Scale=create_element(1, SGL, 16, 'Scale', '%8.3f', 0, -100000, 100000);
        sfile.Amplitude=create_element(100, SGL, 17, 'Amplitude(uA)', '%8.3f', 0, -10000., 10000);
        sfile.Converge=create_element(1, SGL, 18, 'Convergence(N)', '%d', 0, 1, 100);
        sfile.Sequence=create_element('[1:20]', SGL, 19, 'Sequence', '%c');
        sfile.SeqParList=create_element('seed', MULT, 20, 'SeqParameter', '%c');
        sfile.Seed = create_element(-1 ,MULT, 21, 'Seed', '%d', 0, 0, 10000); % random number seed (can sequence; this is "starting" seed.  Setting thi seed negative causes it to always be random!
        sfile.Superimpose = create_element('', SGL, 22, 'Superimpose', '%c'); % file to superimpose on present one

    otherwise
        QueMessage('new: Method is not yet implemented', 1);
        return;
end;

sfile.end=1;
return;


function [dfile] = newacq()
% newacq.m  -  create and initialize the data acquisition file structure.
% 7/10/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
maxchan=16; % this can be changed
% parameters from here to start are NOT user adjustable
dfile.title = 'Data Acquisition Parameters V2';
dfile.NAME = 'DFILE';
dfile.callback = 'paste';
dfile.Calculate = 'acq_calculate'; % recalculation routine after every change
dfile.frame = 'FDfile';
dfile.fhandles = []; % handles for data elements (used dynamically - not structure)
dfile.Z_Time=0;
dfile.F_Time=0; % file time
dfile.File_Mode=-1;
dfile.Block = 1; % internal block information
dfile.Record=1; % incremented internally
% definitions
SGL = 0;
MULT = 1;
CALC = -1; % calculated value - no ability to edit
% the following paramters are adjustable...
dfile.start = 1;
dfile.Filename = create_element('Default', SGL, 1, 'File', '%s'); % file
dfile.Record_Skip=create_element(4, SGL, 2, 'Display Skip (n)', '%d', 4, 1, 100);
dfile.Refresh=create_element(-1, SGL, 2, 'Refresh (n)', '%d', 4, 1, 100); % default refresh plots whole sequence
dfile.Data_Mode = create_element('CC', SGL, 4, 'Acquisition mode', '%s'); % default data collection mode if not otherwise defined...
dfile.Sample_Rate = create_element(20, SGL, 5, 'Rate (us/pt)', '%d', 20, 1, 65000); % usec/pt sample rate
dfile.Actual_Rate = create_element(20, CALC, 6, 'Actual Rate', '%d', 20, 1, 65000);
dfile.Points = create_element(5000, SGL, 7, 'Points per record', '%d', 2048, 256, 1000000); % points per record
dfile.TraceDur = create_element(50, CALC, 8, 'Trace Duration', '%8.1f', 25, 1, 65000);
dfile.ChannelList = create_element('v1 i1', SGL, 9, 'Channel List', '%s'); % channel list
dfile.Channels = create_element([0 1], CALC, 10, 'Channels to sample', '%d', 2, 1, maxchan); % channels
%dfile.Amplifier_Gain=create_element([0 0], MULT, 8, 'Amplifier Gains', '%8.1f', 1, 0.1, 10000);
%dfile.AD_Range=create_element([5 5], MULT, 9, 'A-D Range (V)', '%8.2f', 5, 0.1, 10000);
%dfile.Sensor_Range=create_element([200 20], MULT, 10, 'Sensor Ranges', '%8.2f', 5, 0.001, 100000);
dfile.Low_Pass=create_element([10.0 10.0], MULT, 11, 'LPF (kHz)', '%8.2f', 10.0, 0.01, 1000);
dfile.High_pass=create_element([0 0], MULT, 12, 'HPF (kHz)', '%8.2f', 0, 0, 1000);
%dfile.Junction_Potential = create_element(0, MULT, 13, 'JP (mV)', '%8.1f', 0, -200, 200); % junction potential offset (display and analysis only)
dfile.end = 1;

return;

function [cfile] = newc()
% new - create and initialize the configuration structure
% 8/15/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% Cfile obeys the struct_edit format...

if(nargin ~= 0)
    QueMessage('newc: command format is newc', 1);
    return;
end;

% the config file consists of a base set of information and a variable
% section
%
%Base section;
% definitions
SGL = 0;


cfile.title='Configuration Parameters';
cfile.NAME='CONFIG';
cfile.callback='paste';
cfile.frame = 'FConfig'; % frame to associate window with
cfile.fhandles = []; % handles for data elements (used dynamically - not structure)
cfile.start = 1;

cfile.Config = create_element('YourConfiguration', SGL, 1,'Config', '%s'); % name of this file
cfile.Owner = create_element('YourName', SGL, 1, 'Owner', '%s');
cfile.BasePath = create_element('c:\mat_datac\UserName', SGL, 3, 'BasePath', '%s');
cfile.StmPath = create_element('StmPar', SGL, 4, 'StmPath', '%s'); % define the base stimulus file to open on startup
cfile.AcqPath = create_element('AcqPar', SGL,  5, 'AcqPath', '%s'); % define the base stimulus file to open on startup
cfile.MacroPath = create_element('MacroPar', SGL, 6, 'MacPath', '%s');
cfile.DataPath = create_element('Data', SGL, 7, 'DataPath', '%s'); % define the base stimulus file to open on startup
cfile.Amplifier = create_element('Axopatch200', SGL, 8, 'Amplifier', '%s'); % define the base stimulus file to open on startup
cfile.VC = create_element('VC_Default', SGL, 9, 'VCStim', '%s'); % vc default parameter set
cfile.CC = create_element('CC_Default', SGL, 10, 'CCSTim', '%s'); % cc default parameter set
cfile.UserExt = create_element('Your Initials', SGL, 11, 'UserExt', '%s'); % user file extension (before mat).
cfile.end = 1;

return;

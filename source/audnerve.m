function [outdata, tbase, out_rate, err] = audnerve(sfile);
% audnerve: create a train of stimuli with intervals like
% auditory nerve (generated by DSAM models)
%
%(stimulus routine)
% Usage
%    Normally this routine is not called directly by the user
%    and executed as specified by the parameters in the structure sfile.
%
% This routine generates 3 kinds of stimuli:
% A. Pulse waveform for stimulating fibers with an extracellular electrode.
%   1. Set Alpha to a negative value to specify the width of the stimulus
%   pulse
%   2. set Converge to 1, and set Prelease to 1. This will cause all events
%   computed by DSAM/AIM to produce stimulus pulses. 
%   3. set amplitude to stimulus amplitude for shocking the fibers.
%
% B. Alpha waveform for simulating a single input:
%   1. Set alpha to tau of EPSC. 
%   2. set Converge to 1.
%   3. Set Prelease to release probability. Each event will be subject to
%   deletion or inclusion depending on a random number selected from a uniform distribution
%   4. Set the amplitude to the desired amplitude.
%
% C. Alpha waveform simulating convergence:
%   1. Set alpha to tau of EPSC.
%   2. set converge to N (between 1 and 100).
%   3. set Prelease for population as above. 
%   4. set the amplitude of the individual events. 
%
%
%   The stimulus structure is generated by new.m.
%	The following parameters are required:
%   sfile.Sample_Rate = base clock rate for stimulus, in microseconds.
%   sfile.Spont = spont class (low, medium, high)
%   sfile.Frequency = stimulus frequency (kHz);
%   sfile.Intensity = stimulus intensity (dB, SPL)
%   sfile.Delay = delay to stimulus onset (msec)
%   sfile.Duration = stimulus duration (msec)
%   sfile.Post = amount of time for post-stimulus activity
%   sfile.Alpha = alpha : if +, then is tau for alpha function; if -, then is duration of rectangular pulse
%   sfile.Amplitude = amplitude of output waveform - either current or pulse stimulation
%   sfile.Converge = number of convergent synapses (independent fibers)
%   sfile.Prelease = release probability given an AP invades the terminal -
%   applied independently to each N in convergence
%   sfile.CV = coefficient of variation of the amplitude (useful for alpha
%           only, if alpha is negative, then is set to 0)
%   sfile.Sequence = the sequencing parameter
%   sfile.Superimpose = file to superimpose on present one

% the alpha function is defined as used in Rothman & Manis, 2003c
%
%		F = ge*T/tau*exp(1-T/tau)
%  a value of 0.16 would be suitable for auditory nerve EPSCs on bushy cells in VCN, for example		
%
% Original stimulus structure, etc. 
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% 9/11/2000   uses new seq_parse and step generator
%
% calls DSAM module (which must therefore be installed in the default location) 
% to generate the spike trains. an_generate returns the array of spike times for the
% number of cycles called. These are then convolved with the alpha function or the pulse function.
% 4/4/04 pbm.

% initialize output 
outdata = {};
err = 0;
tbase = {};
out_rate = [];

% check input
if(isempty(sfile))
    QueMessage('audnerve: No STIM?', 1);
    return;
end;

% compute the sequences
vlist=seq_parse(sfile.Sequence.v); % partition list. Result is cell array, fastest first.
if(isempty(vlist))
    err = 1;
    return;
end;

nvl = size(vlist, 2); % number of vlist elements
nout = length(vlist{1}); % length of protocol

% copy sequence parameter into cell array
s = lower(sfile.SeqParList.v); % get the parameter to sequence
pars={}; % pars holds the parameters sequenced
i = 1;
while(~isempty(s))
    [pars{i}, s] = strtok(s, ' '); % get the tokens into a cell array
    i = i + 1;
end;

% verify valid sequence parameter for this stimulus type
for i = 1:length(pars)
    if(~strmatch(pars{i}, strvcat('frequency','intensity', 'alpha', 'amplitude')))
        QueMessage('audnerve: Sequencing only allowed on freq, intensity, alpha and amplitude', 1);
        err = 1;
        return;
    end;
end;

parn = [1:length(pars)];
ns = 1; % none of these are multi - variables, and so take only one value.

% at this point, the basic parameters appear to be valid.
base_sample_rate = sfile.Sample_Rate.v;

out_rate=(1000000/base_sample_rate); % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...

base_tau = sfile.Alpha.v; % get basic duration list
base_amp = sfile.Amplitude.v; % get basic level list
base_freq = sfile.Frequency.v; % base IPI list
base_inten = sfile.Intensity.v; % base IPI list

nrate=0.001*base_sample_rate;

% get levels sequenced
base_amplitude = sfile.Amplitude.v;
i_amp = strmatch('amplitude', pars); % gets which one is the level
if(~isempty(i_amp))
    base_amplitude(parn(i_amp)) = min(vlist{parn(i_amp)});
end;

% get Intensity sequenced
base_intensity = sfile.Intensity.v;
i_inten = strmatch('intensity', pars); % gets which one is the level
if(~isempty(i_inten))
    base_intensity(parn(i_inten)) = min(vlist{parn(i_inten)});
end;
% get frequency sequenced
base_frequency = sfile.Amplitude.v;
i_freq = strmatch('frequency', pars); % gets which one is the level
if(~isempty(i_freq))
    base_frequency(parn(i_freq)) = min(vlist{parn(i_freq)});
end;
% get tau sequenced
base_alpha = sfile.Amplitude.v;
i_alpha = strmatch('alpha', pars); % gets which one is the level
if(~isempty(i_alpha))
    base_alpha(parn(i_alpha)) = min(vlist{parn(i_alpha)});
end;

% total duration of longest stimulus
tot_dur = sfile.Delay.v + sfile.Duration.v +sfile.Post.v; % (dur is in msec).
npts = floor(0.5+tot_dur/nrate);  % points in the array
%
% Run DSAM
% create pulsetrain template from levels & durations
i=ns; % there is only one to sequence!
seed1 = -3;
seed2 = -1;
for m = 1:nout % for each element of the sequence
    outdata{m}.v=zeros(1, npts); % initialize the output array
    t = [0:nrate:tot_dur]; % fundamental time base (msec)
    r = 0;
    % sequence the waveform shape?
    if(isempty(i_alpha))% ? no changes in waveform 
        tx = sfile.Alpha.v; % get the base alpha value and use it
    else
        if(i == parn(i_alpha))
            tx = vlist{i_alpha}(m);   
        else
            tx = sfile.Alpha.v; % Number of points in the duration step dur in msec; convert rate to msec too
        end;
    end;
    
    % sequence the waveform amplitude?
    if(isempty(i_amp)) % level setup
        amp = sfile.Amplitude.v;
    else
        if(i == parn(i_amp)) % check sequencing
            amp = vlist{i_amp}(m); % copy it over   
        else
            amp = sfile.Amplitude.v;
        end;
    end;
    % sequence the acoustic frequency?
    if(isempty(i_freq)) % level setup
        freq = sfile.Frequency.v;
    else
        if(i == parn(i_freq)) % check sequencing
            freq = vlist{i_freq}(m); % copy it over   
        else
            freq = sfile.Frequency.v;
        end;
    end;
    % sequence the sound intensity?
    if(isempty(i_inten)) % intensity setup
        inten = sfile.Intensity.v;
    else
        if(i == parn(i_inten)) % check sequencing
            inten = vlist{i_inten}(m); % copy it over   
        else
            inten = sfile.Intensity.v;
        end;
    end;
    
    % elementary waveform to convolve
    % make basic waveform - either alpha or pulse
    if(base_tau > 0)
        wv = make_alpha(tx, nrate);
    else
        wv = make_pulse(-tx, nrate);
    end;
    
    spont = sfile.Spont.v;
    delay_totone = sfile.Delay.v;
    stimdur = sfile.Duration.v;
    end_silence = sfile.Post.v;
    
    % now generate the nerve response to sound.
    % handle convergence. Note that r(1,:) is in seconds (time base)
    % We run through the calculation for every fiber, so each is
    % statistically independent..... then summed.
    %
    for nn = 1:sfile.Converge.v % generate a convergent waveform by summing independent an activity
    seed1 = -(abs(seed1*m*nn));
    seed2 = -(abs(seed2*m*nn));
        r = [];
        r = an_generate(spont, freq, inten, delay_totone/1000, stimdur/1000, end_silence/1000, seed1, seed2);
        
        
        % resample r into our time base before moving forward
        rn = zeros(length(t), 1);
        for kk = 1:length(r(:,1))
            ii = floor(r(kk,1)*1000/nrate);
            rn(ii) = r(kk,2);
        end;
        
        
        % handle release probability
        if(sfile.Prelease.v < 1) % if release prob. is not 1, then clip out random events.
            x = find(rn > 0); % find all events
            for kk = 1:length(x);
                if(sfile.Prelease.v < rand)
                    rn(x(kk)) = 0;
                end;
            end;
        end;
        
        % handle variance of events
        if(sfile.CV.v > 0) % perturbate the amplitudes of each event.
            x=find(rn > 0);
            cv = sfile.CV.v;
            for kk = 1:length(x)
                rn(x(kk)) = 1+cv*randn; % replace with random amplitude around 1
            end;
        end;
        
        %
        
        awave = conv(rn, wv)*amp;
        if(length(awave) > npts)
            awave = awave(1:npts-1); % clip waveform and return to 0 at the end
            awave(npts) = 0;
        end;
        outdata{m}.v=outdata{m}.v + awave'; % sum over "convergence"
    end; % end of convergence loop
end; % done with generating the whole waveform set

% generate ONE waveform for scope mode
outdata{1}.vsco = [];
tbase{1}.vsco = []; % special arrays for scope mode

for m = 1:nout
    tbase{m}.v =nrate*(0:size(outdata{m}.v, 2)-1); % time base, in msec for the output
end;
outdata{1}.vsco = outdata{1}.v;
tbase{1}.vsco = tbase{1}.v;

%check for superposition, and do it if necessary
if(~isempty(unblank(sfile.Superimpose.v)))
    [outdata, tbase, out_rate, err] = combine(outdata, tbase, out_rate, sfile, 'superimpose');
    if(err)
        return;
    end;
end;
% and the second channel information
if(~isempty(unblank(sfile.Addchannel.v)))
    [outdata, tbase, out_rate, err] = combine(outdata, tbase, out_rate, sfile, 'addchannel');
    if(err)
        return;
    end;
end;

return

function wv = make_alpha(alpha, nrate)
rate = nrate;
n = 5*floor(alpha/rate);
t=[0:rate:(n-1)*rate];
wv = t/alpha.*exp(1-t/alpha);
  
return;

function [wv] = make_pulse(alpha, nrate)
al = floor(alpha/nrate);
wv = zeros(al*2, 1);
wv(1:al) = 1;
return;



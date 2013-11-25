function [outdata, tbase, out_rate, err] = testpulse(varargin)
% pulse: Method to generate pulse train waveforms
% Usage
%     Not normally called directly by the user

% PULSEGEN - create pulse train waveform
%
%    PULSEGEN produces a pulse train waveform pulse_out
%    specified by the parameters in the structure sfile.
%
%    The stimulus structure is generated by new.m.
%		The following parameters are required:
%   sfile.Npulses= number of pulses in the train
%   sfile.Delay= delay to first pulse
%   sfile.IPI= interpulse interval (one number)
%   sfile.Duration = duration list for pulses (compound pulses allowed at each interval)
%   sfile.Level= level list for pulses (compound levels corresponding to durations)
%   sfile.LevelFlag= 'absolute' or 'relative': levels after first are either absolute or relative
%   sfile.Scale= scale factor applied to output
%	 sfile.Offset = offset added to output (after scaling)
%   sfile.Sequence= sequence (operates as in steps - multiple seqeuences allowed)
%   sfile.SeqParList= parameters to sequence (apply according to entries in sequence)
%   sfile.SeqStepList= which step to be operated on by the sequence element if level or duration
%			
%
% original by S.C. Molitor, 8/2000
% modified Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% 9/1/2000   uses new record_parse and step generator
%

% just call pulse and return it's output - handles this case as well now. 
% 6/20/2012

% initialize output 
outdata = {};
tbase = {};
out_rate = [];

plotflag = 0;
if(nargin == 0) % test mode...
    sfile = new('testpulse');  
    plotflag = 1;
else
    sfile = varargin{1};
    if(isempty(sfile))
        QueMessage('testpulse: No STIM?', 1);
        err = 1;
        return;
    end;
end;
[outdata, tbase, out_rate, err] = pulse(sfile, plotflag);
return

% The rest of this file is unreachable!!!!!


% check input
if(isempty(sfile))
    QueMessage('testpulse: No STIM?', 1);
    return;
end;

% perform parameter checking - are duration and level lists matched?
if(length(sfile.Duration.v) ~= length(sfile.Level.v))
    QueMessage(sprintf('testpulse: in %s, unmatched # dur and levels ', sfile.Name.v), 1);
    err = 1;
    return;
    %   ns = min([length(sfile.Duration.v) length(sfile.Level.v)]); % ns is number of steps in protocol
else
    ns = length(sfile.Duration.v); % use either they are the same
end;

% perform test pulse parameter checking - are duration and level lists matched?
if(length(sfile.TestDuration.v) ~= length(sfile.TestLevel.v))
    QueMessage(sprintf('testpulse: in %s, unmatched # testdur and testlevels ', sfile.Name.v), 1);
    err = 1;
    return;
    %   ns = min([length(sfile.Duration.v) length(sfile.Level.v)]); % ns is number of steps in protocol
else
    nts = length(sfile.TestDuration.v); % use either they are the same
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
    if(~strmatch(pars{i}, strvcat('level','duration', 'ipi', 'testlevel', 'testdelay')))
        fprintf('pulse: Sequencing only allowed on level, duration, ipi, testlevel, and testdelay\n');
        err = 1;
        return;
    end;
end;

% get pulse number and check to see if its valid
parn = sfile.SeqStepList.v; % and the pulse element number to operate on
if(any(parn > ns) || any(parn < 1))
    fprintf('pulse: Attempt to sequence invalid step #\n');
    err = 1;
    return;
end;

% at this point, the basic parameters appear to be valid.
% compute some base values

out_rate=(1000000/sfile.Sample_Rate.v); % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...

base_dur = sfile.Duration.v; % get basic duration list
base_lev = sfile.Level.v; % get basic level list
base_ipi = sfile.IPI.v; % base IPI list
nrate = sfile.Sample_Rate.v; % sample rate, in microseconds (note divisions below!)

test_lev = sfile.TestLevel.v;
test_del = sfile.TestDelay.v;
test_dur = sfile.TestDuration.v;

% if we are sequencing durations, the the stimulus duration must accomodate the longest we must make
% find out and substitute it to get the total duration
du = strmatch('duration', pars); % for duration sequences
if(~isempty(du))
    base_dur(parn(du)) = max(vlist{parn(du)});
end;

if(any(base_dur < 2*nrate/1000))
    k = find(base_dur > 0);
    nrate = min(base_dur(k))*1000/2;
end;

% if we are sequencing IPIs, the get information
ipi = strmatch('ipi', pars); % for ipi sequences
if(~isempty(ipi))
    base_ipi(parn(ipi)) = max(vlist{parn(ipi)});
end;
if(any(base_ipi < nrate/1000)) % check rate
    k = find(base_ipi > 0);
    nrate = min(base_ipi(k))*1000;
end;

% get levels sequenced
base_level = sfile.Level.v;
le = strmatch('level', pars); % gets which one is the level
if(~isempty(le))
    base_level(parn(le)) = min(vlist{parn(le)});
end;

test_lev = sfile.TestLevel.v;
tle = strmatch('testlevel', pars);
if(~isempty(tle))
    test_lev(parn(tle)) = min(vlist{parn(tle)});
end;

test_dur = sfile.TestDuration.v;
test_du = strmatch('testduration', pars); % for duration sequences
if(~isempty(test_du))
    test_dur(parn(test_du)) = max(vlist{parn(test_du)});
end;

if(any(test_dur < nrate/1000))
    k = find(test_dur > 0);
    nrate = min(test_dur(k))*1000;
end;

test_del = sfile.TestDelay.v;
test_de = strmatch('testdelay', pars); % for duration sequences
if(~isempty(test_de))
    test_del(parn(test_de)) = max(vlist{parn(test_de)});
end;

if(any(test_del < nrate/1000))
    k = find(test_del > 0);
    nrate = min(test_del(k))*1000;
end;

% total duration of longest stimulus
tot_dur = sfile.Delay.v + (sfile.Npulses.v+1)*(max(base_ipi)+sum(base_dur)); % (dur is in msec).
if(~isempty(test_de))
    tot_dur2 = max([vlist{test_de}]);
else
    tot_dur2 = test_del;
end;
if(~isempty(test_du))
    tot_dur2 = tot_dur2 + max([vlist{test_du}]);
else
    tot_dur2 = tot_dur2 + test_dur+1; % always add 1 msec to end of the thing.
end;


tot_dur = tot_dur2 + tot_dur +1;

if(isempty(nrate) || nrate < 1)
    nrate = sfile.Sample_Rate.v;
end;
npts = floor(0.5+tot_dur/(nrate/1000));  % points in the array

% check the level flag.
if (strcmpi(sfile.LevelFlag.v, 'relative'))
    relflag = 1;
elseif (strcmpi(sfile.LevelFlag.v, 'absolute'))
    relflag = 0; % means nothing - just a place holder
else % error
    QueMessage('pulse: LevelFlag must be ''relative'' or ''absolute''\n', 1);
    return
end
%fprintf(1, 'Level flag is: %d (0 - absolute, 1 = relative)\n', relflag);

% generate ONE waveform for scope mode
outdata{1}.vsco=zeros(1,npts);
if(length(base_ipi) > 1) % compute step start times, according to npulses and ipi
    pulse_begin = sfile.Delay.v + [0 : sfile.Npulses.v  - 1]*base_ipi(1);
else
    pulse_begin = sfile.Delay.v + [0 : sfile.Npulses.v - 1] * base_ipi;
end;

for n = 1 : length(pulse_begin) % for each pulse in the train
    k = floor(pulse_begin(n)/(nrate/1000))+1; % get the index of start of pulse
    for i=1:1 % each pulse consists of a series of steps, so create steps
        j = 0;
        j = floor(sfile.Duration.v(i)/(nrate/1000)); % Number of points in the duration step dur in msec; convert rate to msec too
        if(relflag && i > 1) % check relative
            outdata{1}.vsco(k:k+j) = sfile.Level.v(1)*sfile.Level.v(i); % value is constant for that time
        else
            outdata{1}.vsco(k:k+j) = sfile.Level.v(i);
        end;
        k = k + j;
    end;
end
%outdata{1}.vsco(k:k+1) = 0;
if(length(test_de) > 1) % compute step start times, according to npulses and ipi
    pulse_begin = test_de(1);
else
    pulse_begin = sfile.TestDelay.v; % single pulse.
end;
k = floor(pulse_begin/(nrate/1000)); % get the index of start of pulse

j = floor(test_dur(1)/(nrate/1000))-1;

outdata{1}.vsco(k:k+j) = sfile.TestLevel.v(1);
nps1 = length(sfile.Duration.v);

outdata{1}.vsco = outdata{1}.vsco*sfile.Scale.v + sfile.Holding.v; % scale and offset the data
tbase{1}.vsco=nrate*(0:length(outdata{1}.vsco)-1)/1000; % time base, in msec for the output

% create pulsetrain template from levels & durations

for m = 1:nout % for each element of the sequence
    outdata{m}.v=zeros(1,npts);
    
    if(~isempty(ipi)) % compute step start times, according to npulses and ipi
        pulse_begin = sfile.Delay.v + [0 : sfile.Npulses.v  - 1]*vlist{ipi}(m);
    else
        pulse_begin = sfile.Delay.v + [0 : sfile.Npulses.v - 1] * base_ipi; % single pulse.
    end;
    
    for n = 1 : length(pulse_begin) % for each pulse in the train
        k = floor(pulse_begin(n)/(nrate/1000))+1; % get the index of start of pulse
        
        for i=1:nps1 % each pulse consists of a series of steps, so create steps
            j = 0;
            if(isempty(du))% ? no changes in duration
                j = floor(sfile.Duration.v(i)/(nrate/1000))-1; % Number of points in the duration step dur in msec; convert rate to msec too
            else
                if(i == parn(du)) % are we altering duration on this pulse component?
                    j = floor(vlist{du}(m)/(nrate/1000))-1;   % yes, set from sequence list
                else
                    j = floor(sfile.Duration.v(i)/(nrate/1000))-1; % no, just set from input. Number of points in the duration step dur in msec; convert rate to msec too
                end;
            end;
            if(isempty(le)) % level setup
                if(relflag && i > 1) % check relative
                    outdata{m}.v(k:k+j) = sfile.Level.v(1)*sfile.Level.v(i); % adjust subsequent levels relative to first level
                else
                    outdata{m}.v(k:k+j) = sfile.Level.v(i); % otherwise just use the values
                end;
            else
                if(find(i == parn(le))) % check if we are sequencing levels
                    ii = find(i == parn(le)); % find out which sequence corresponds
                    if(relflag && i > 1) % check relative if sequencing
                        outdata{m}.v(k:k+j) = sfile.Level.v(1)*vlist{le(ii)}(m); % relative scaling
                    else
                        outdata{m}.v(k:k+j) = vlist{le(ii)}(m); % copy it over   
                    end;
                else
                    if(relflag && i > 1) % check relative if not sequencing
                        outdata{m}.v(k:k+j) = sfile.Level.v(1)*sfile.Level.v(i); % value is constant for that time
                    else
                        outdata{m}.v(k:k+j) = sfile.Level.v(i);
                    end;
                end;
            end;
            k = k + j;
        end;
    end
    outdata{m}.v(k+1:k+2) = 0;
    % now add the test pulses - in the same way.... 
    pulse_end = max(pulse_begin); % time of last pulse in current stimuluse
    if(~isempty(test_de)) % compute step start times, according to npulses and ipi
        pulse_begin = vlist{test_de}(m) + pulse_end;
    else
        pulse_begin = test_del + pulse_end; % single pulse.
    end;
    k = floor(pulse_begin/(nrate/1000)); % get the index of start of pulse
    for i=1:nts % each pulse can consist of a series of steps, so create steps
        j = 0;
        if(isempty(test_dur))% ? no changes in duration
            j = floor(sfile.TestDuration.v(i)/(nrate/1000))-1; % Number of points in the duration step dur in msec; convert rate to msec too
        else
            if(~isempty(test_du)) % are we altering duration on this pulse component?
                ii = parn(test_du);
                j = floor(vlist{test_du}(m)/(nrate/1000))-1;   % yes, set from sequence list
            else
                j = floor(sfile.TestDuration.v(i)/(nrate/1000))-1; % no, just set from input. Number of points in the duration step dur in msec; convert rate to msec too
            end;
        end;
        if(isempty(test_lev)) % level setup
            if(relflag && i > 1) % check relative
                outdata{m}.v(k:k+j) = sfile.TestLevel.v(1)*sfile.TestLevel.v(i); % adjust subsequent levels relative to first level
            else
                outdata{m}.v(k:k+j) = sfile.TestLevel.v(i); % otherwise just use the values
            end;
        else
            %if(find(i == parn(tle))) % check if we are sequencing levels
            if(~isempty(tle))
                ii = find(i == parn(tle)); % find out which sequence corresponds
                if(relflag && i > 1) % check relative if sequencing
                    outdata{m}.v(k:k+j) = sfile.TestLevel.v(1)*vlist{test_lev(ii)}(m); % relative scaling
                else
                    outdata{m}.v(k:k+j) = vlist{tle(ii)}(m); % copy it over   
                end;
            else
                if(relflag && i > 1) % check relative if not sequencing
                    outdata{m}.v(k:k+j) = sfile.TestLevel.v(1)*sfile.TestLevel.v(i); % value is constant for that time
                else
                    outdata{m}.v(k:k+j) = sfile.TestLevel.v(i);
                end;
            end;
        end;
        k = k + j;
    end;
    outdata{m}.v(k+1) = 0;
    
    outdata{m}.v = outdata{m}.v*sfile.Scale.v + sfile.Holding.v; % scale and offset the data
    tbase{m}.v=nrate*(0:length(outdata{m}.v)-1)/1000; % time base, in msec for the output
end; % done with generating the pulse train waveform set

%outdata{1}.v=outdata{1}.vsco; % make the same !!!! %%%% kludge.

%check for superposition, and do it if necessary
if(~isempty(sfile.Superimpose.v))
    fprintf(1, 'Superimposing\n');
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

err = 0; % only clear error flag if we make it all the way through.

return

function [outdata, tbase, out_rate, err] = steps(varargin)
% steps: Method to to generate step waveforms based on the STIM parmaeters
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     Normally not called directly by user

%
% The stim parameters in sfile are used to determine the waveforms generated
% outdata is a matrix of stimuli - different stimuli vs time.\
% so that outdata(1) will produce the first stimulus of the set,
% and outdata(n) will be the nth
% tbase is the output time base
% out_rate is the output sample rate (in microseconds)
% err is an error flag: != 0 if an error occurs
%
% Version 1.0 11/29/99
% Version 1.1 3/27/2000 - slight modifications
% Version 1.2 8/15/2000 - single function for a "method"
% Version 1.3 8/31/2000 - Use modified seq_parse returning cell array
% 									to allow multiple parameters to be sequenced in nested fashion
% Version 1.4 9/11/2000 - Many modifications; also added function to allow superimposition of anoth
%									steps file on top of present one  (e.g., combine waveforms).
% Version 1.5 9/12/2000 - Modified output to be in form of cell arrays for outdata and tbase
%									This allows stim arrays to have different lengths in different trials.
%
%	Use of superposition flag is simple, but requires care.
%  IF a superposition is desired, it is possible for multiple superpositions to exist if
% 	that structure also specifies a superposition.  Best to limit to one level
%  Also, at present superposition cannot be sequenced.
% Paul B. Manis, Ph.D.
%
% pmanis@med.unc.edu
%
% Version 2.0 4/9/2008 Cleaned up to use checklength and check pars. 
% and introduce a test mode.

outdata={}; tbase={}; out_rate=[]; err = 1;

if(nargin == 0) % test mode...
    sfile = new('steps');
else
    sfile = varargin{1};
    if(isempty(sfile))
        QueMessage('steps: No STIM?', 1);
        return;
    end;
    if(~strcmp(sfile.Method.v, 'steps'))
        QueMessage(sprintf('steps: loaded sfile is of type %s, not ours!', sfile.Method.v), 1);
        return;
    end;
end;

% define the potential variables that can be sequenced and confirm that
% args are ok
possible_sequences = {'level', 'duration'};
levpos = 1;
durpos = 2;
if(chklength(sfile, possible_sequences, ones(length(possible_sequences), 1)))  % make sure incoming arguments are acceptable
   return;
end;

% check the parameters to be sequenced to be sure they are valid also
% seqflags is an nxm array of 0's and 1's
% iterating each row tells you which sequence parameter is being run (by
% column entry)
% successive rows are nested sequences.
% first index is row, second is column.
[seqflags, errp] = chkpars(sfile.SeqParList.v, possible_sequences); 
if(errp)
   return;
end;
seqsteps = eval('sfile.SeqStepList.v');
seqmatrix = zeros(length(possible_sequences), length(eval('sfile.Duration.v')));
seqparlist = textscan(sfile.SeqParList.v, '%s');
for i = 1:length(seqparlist) %
    which = strcmpi(seqparlist{1}(i), possible_sequences);
    k = find(which == 1);
    seqmatrix(k,seqsteps(i)) = i; %#ok<FNDSB> % store order in the proper location
end

% compute the sequences
if(~strcmp(unblank(sfile.Sequence.v), '') && ~isempty(sfile.Sequence.v))
    [vlist, nlist]=seq_parse(sfile.Sequence.v); % partition list. Result is cell array, fastest first.
    if(isempty(vlist))
        err = 1;
        return;
    end;
else
    vlist{1}= 0;
end;

nvl = prod(nlist); % number of vlist elements

% at this point, the basic parameters appear to be valid.
base_sample_rate = sfile.Sample_Rate.v;
out_rate=(1000000/base_sample_rate); % convert to samples per second (rate in usec)
base_dur = sfile.Duration.v; % get basic duration list
base_lev = sfile.Level.v; % get basic level list

total_dur = sum(base_dur); % (dur is in msec).
npts = total_dur*base_sample_rate/1000;
tbase2=base_sample_rate*(0:npts)/1000000; % express in msec...
nout = length(vlist{1});
ns = length(eval('sfile.Duration.v')); % number of steps can be extracted here.
nrate=0.001*base_sample_rate;
maxpts = floor(total_dur/nrate);

outdata = cell(nout, 1);
tbase = cell(nout, 1);

% generate ONE waveform for scope mode
outdata{1}.vsco = [];
tbase{1}.vsco = []; % special arrays for scope mode
k = 1;
t0 = 0;
for i = 1:ns % for each step
    j = floor(sfile.Duration.v(i)/nrate);
    outdata{1}.vsco(k:k+j) = sfile.Level.v(i);  % value is constant for that time
    tbase{1}.vsco(k:k+j) = t0 + (0:j)*nrate;  % fill tbase for that window also, same way
    t0 = tbase{1}.vsco(k+j); % and advance time
    k=k+j;
end;
jnan=find(isnan(outdata{1}.vsco));
if(~isempty(jnan))
    outdata{1}.vsco(jnan) = 0;
end;

for m=1:nout % for all stimuli in the set (sequence)
    k=1;
    t0 = 0;
    outdata{m}.v=[];
    tbase{m}.v=[];
    for i=1:ns % for each step in the waveform
        lev = sfile.Level.v(i); % get default level
        dur = sfile.Duration.v(i); % and duration
        j = floor(dur/nrate); % get index for duration
        % first, is this step variable at all?
        if(~any(seqmatrix(:,i)))
            outdata{m}.v(k:k+j) = lev; % value is constant for that time
        else  % a parameter is sequencing on this step
            if(seqmatrix(durpos, i)) % duration is being sequenced
                j = floor(vlist{seqmatrix(durpos, i)}(m)/nrate);
                outdata{m}.v(k:k+j) = lev; % value is constant for that time
            end;            % note that if both are sequenced, order is important!
            if(seqmatrix(levpos, i)) % level is being sequenced for this step
                outdata{m}.v(k:k+j) = vlist{seqmatrix(levpos, i)}(m); 
            end;
        end;
        tbase{m}.v(k:k+j) = t0 + (0:j)*nrate; % fill tbase for that window also, same way
        t0 = tbase{m}.v(k+j); % and advance time
        k=k+j;
    end;
    jnan=find(isnan(outdata{m}.v));
    if(~isempty(jnan))
        outdata{m}.v(jnan) = 0;
    end;
end % of the big for loop

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

if(nargin == 0)
    teststimplot(tbase, outdata, 0);
end;

err = 0; % only clear error flag if we make it all the way through.
return;


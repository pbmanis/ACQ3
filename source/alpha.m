function [outdata, tbase, out_rate, err] = alpha(sfile)
% alpha: create a train of alpha functions (stimulus routine)
% Usage
%    Normally this routine is not called directly by the user

%
%    specified by the parameters in the structure sfile.
%
%    The stimulus structure is generated by new.m.
%		The following parameters are required:
%   sfile.Npulses= number of alpha pulses in the train
%   sfile.Delay= delay to first pulse
%   sfile.IPI= interpulse interval (one number)
%   sfile.Alpha = time constant for each pulse
%   sfile.Level = level list for pulses (compound levels corresponding to durations)
%   sfile.Scale= scale factor applied to output
%	 sfile.Offset = offset added to output (after scaling)
%   sfile.Sequence= sequence (operates as in steps - multiple seqeuences allowed)
%   sfile.SeqParList= parameters to sequence (apply according to entries in sequence)
%   sfile.SeqStepList= which step to be operated on by the sequence element if level or duration

% the alpha function is defined after Rall (in Koch and Segev, Methods in Neuronal Modeling,
% (first edition), page 49 as:
%
%		alpha^2*T*exp(-T/alpha)
%
% since the peak amplitude of this is alpha/e, the result is scaled by level * e
% to obtain a waveform with a known amplitude.
%			
%
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% 9/11/2000   uses new seq_parse and step generator
%

% initialize output 
outdata = {};
err = 0;
tbase = {};
out_rate = [];

% check input
if(isempty(sfile))
   QueMessage('alpha: No STIM?', 1);
   return;
end;

   ns = length(sfile.Amplitude.v); % ns is number of steps in protocol

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
   if(~strmatch(pars{i}, {'level','alpha', 'ipi', 'npulse'}))
      fprintf('alpha: Sequencing only allowed on level, alpha, ipi, and number of pulses\n');
      err = 1;
      return;
   end;
end;

% get pulse number and check to see if its valid
parn = sfile.SeqLevelList.v; % and the pulse element number to operate on
if(any(parn > ns) || any(parn < 1))
   fprintf('alpha: Attempt to sequence invalid step #\n');
   err = 1;
   return;
end;

% at this point, the basic parameters appear to be valid.
% compute some base values

out_rate=(1000000/sfile.Sample_Rate.v)/1000*2; % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...

base_tau = sfile.Alpha.v; % get basic duration list
base_lev = sfile.Amplitude.v; % get basic level list
base_ipi = sfile.IPI.v; % base IPI list
nrate = sfile.Sample_Rate.v; % sample rate, in microseconds (note divisions below!)

% if we are sequencing durations, the the stimulus duration must accomodate the longest we must make
% find out and substitute it to get the total duration
alpha = strmatch('alpha', pars); % for duration sequences
if(~isempty(alpha))
   base_tau(parn(alpha)) = max(vlist{parn(alpha)});
end;

% if we are sequencing IPIs, the get information
ipi = strmatch('ipi', pars); % for ipi sequences
if(~isempty(ipi))
   base_ipi(parn(ipi)) = max(vlist(parn(ipi)));
end;
if(any(base_ipi < nrate/1000)) % check rate
   k = find(base_ipi > 0);
   nrate = min(base_ipi(k))*1000;
   k = find(nrate < 10);
   nrate(k) = 10;
end;

% get levels sequenced
base_level = sfile.Amplitude.v;
le = strmatch('level', pars); % gets which one is the level
if(~isempty(le))
   base_level(parn(le)) = min(vlist{parn(le)});
end;

% total duration of longest stimulus
tot_dur = sfile.Delay.v + (sfile.Npulses.v+1)*(base_ipi); % (dur is in msec).
npts = floor(0.5+tot_dur/(nrate/1000));  % points in the array

% create pulsetrain template from levels & durations
outdata = cell(nout, 1);
tbase = cell(nout, 1);

for m = 1:nout % for each element of the sequence
   outdata{m}.v=zeros(1, npts); % initialize the output array
   if(length(base_ipi) > 1) % compute step start times, according to npulses and ipi
      pulse_begin = sfile.Delay.v + (0 : sfile.Npulses.v  - 1)*base_ipi(m);
   else
      pulse_begin = sfile.Delay.v + (0 : sfile.Npulses.v - 1) * base_ipi;
   end;
   if(isempty(alpha))% ? no changes in duration
      tx = sfile.Alpha.v; % Number of points in the duration step dur in msec; convert rate to msec too
   else
      if(i == parn(alpha))
         tx = vlist{alpha}(m);   
      else
         tx = sfile.Alpha.v; % Number of points in the duration step dur in msec; convert rate to msec too
      end;
   end;
   if(isempty(le)) % level setup
      lev = sfile.Amplitude.v;
   else
      if(i == parn(le)) % check sequencing
         lev = vlist{le}(m); % copy it over   
      else
         lev = sfile.Amplitude.v;
      end;
   end;
   awave = lev*alphawave(tx, nrate/1000);   
   lawave = length(awave)-1;
   for n = 1 : length(pulse_begin) % for each pulse in the train
      k = floor(pulse_begin(n)/(nrate/1000))+1; % get the index of start of pulse
         lp1 = length(outdata{m}.v);
         lp2 = length(awave);
         if(lp1 < k + lp2)
            outdata{m}.v=[outdata{m}.v outdata{m}.v(lp1)*ones(1, k+lp2-lp1)]; % this is the pad operation
         end;      
      % now compute the relevant alpha function and add it with the pulses just entered
      outdata{m}.v(k:k+lawave) = (outdata{m}.v(k:k+lawave) + awave);
   end
end; % done with generating the pulse train waveform set

% generate ONE waveform for scope mode
outdata{1}.vsco = [];
tbase{1}.vsco = []; % special arrays for scope mode

for m = 1:nout
   outdata{m}.v = outdata{m}.v * sfile.Scale.v *sfile.Amplitude.v+ sfile.Holding.v; % scale and offset the data
	tbase{m}.v =nrate*(0:size(outdata{m}.v, 2)-1)/1000; % time base, in msec for the output
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

function [out] = alphawave(a, dt)

% generate an alpha waveform, with the limitation that the smallest value on the falling
% phase will be < limit
% Waveform is scaled to unit height.
%
e = exp(1);
i = 1;
a0 = 1;
t = 0;
npts  = floor(10*a/dt);
out = zeros(npts, 1);
for i = 1:floor(10*a/dt)
   t = (i - 1) * dt;
   out(i) = a*t*exp(-t*a)*e;
end;
return;



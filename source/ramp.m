function [outdata, tbase, out_rate, err] = ramp(sfile);
% ramp: Method to to generate step waveforms based on the STIM parmaeters
% Usage
%     Not normally called directly by the user

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

outdata={}; tbase={}; out_rate=[]; err = 1;
if(isempty(sfile))
   QueMessage('steps: No STIM?', 1);
   return;
end;

% perform parameter checking
if((length(sfile.Duration.v) ~= length(sfile.Level.v)) | (length(sfile.RampFlag.v) ~= length(sfile.Duration.v)))
   QueMessage(sprintf('steps: Number of durations, levels, or RampFlag not matched\n'),1);
   return;
else
   ns = length(sfile.Duration.v); % use either they are the same
end;

% copy sequence parameter into cell array
s = lower(sfile.SeqParList.v); % get the parameter to sequence
pars={};
i = 1;
while(~isempty(s))
   [pars{i}, s] = strtok(s, ' '); % get the tokens into a cell array
   i = i + 1;
end;

% verify valid sequence parameter for this stimulus type
for i = 1:length(pars)
   k = strmatch(pars{i}, strvcat('level','duration'), 'exact');
   if(isempty(k) || k == 0)
      QueMessage(sprintf('steps: Sequencing only allowed on level and duration\n'),1);
      err = 1;
      return;
   end;
end;

% get pulse number and check to see if its valid
parn = sfile.SeqStepList.v; % and the pulse element number to operate on
if(any(parn > ns) || any(parn < 1))
   QueMessage(sprintf('steps: Attempt to sequence invalid step #\n'),1);
   err = 1;
   return;
end;

%make sure number of pars and parn are the same
if(length(parn) ~= length(pars))
   QueMessage(sprintf('steps: seqp and seqn unmatched length (%d,%d)', length(pars), length(parn)), 1);
   err = 1;
   return;
end;

% compute the sequences
if(~strcmp(unblank(sfile.Sequence.v), '') && ~isempty(sfile.Sequence.v))
   vlist=seq_parse(sfile.Sequence.v); % partition list. Result is cell array, fastest first.
   if(isempty(vlist))
      err = 1;
      return;
   end;
else
   vlist{1}= 0;
   du = [];
   le = [];
end;

% if we are sequencing durations, the the stimulus duration must accomodate the longest we must make
% find out and substitute it to get the total duration
du = strmatch('duration', pars, 'exact');
if(~isempty(du))
   base_dur(parn(du)) = max(vlist{du});
end;

le = strmatch('level', pars, 'exact'); % gets which one is the level


nvl = size(vlist, 2); % number of vlist elements

% at this point, the basic parameters appear to be valid.
base_sample_rate = sfile.Sample_Rate.v;

out_rate=(1000000/base_sample_rate); % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...

base_dur = sfile.Duration.v; % get basic duration list
base_lev = sfile.Level.v; % get basic level list


total_dur = sum(base_dur); % (dur is in msec).
npts = total_dur*base_sample_rate/1000; 
tbase2=base_sample_rate*(0:npts)/1000; % express in msec...
nout = length(vlist{1});
nrate=0.001*base_sample_rate;
maxpts = floor(total_dur/nrate);


% generate ONE waveform for scope mode
outdata{1}.vsco = [];
tbase{1}.vsco = []; % special arrays for scope mode
k = 1;
t0 = 0;
for i = 1:ns % for each step
   j = floor(sfile.Duration.v(i)/nrate); % find starting point for this "step"
   if(i == 1) % initialize values
      lev = sfile.Holding.v;
      sl = 0;
   else
      if(i < ns)
         lev = sfile.Level.v(i);
         nextlev = sfile.Level.v(i+1); % determine the "rise"
      else
         lev = sfile.Level.v(i); % different for final step
         nextlev = sfile.Holding.v;
      end;
      
      if(sfile.RampFlag.v(i) == 1) % compute the slope if the ramp flag is set for the step
         sl = (nextlev - lev)/sfile.Duration.v(i);
      else
         sl = 0;
      end;
   end;
   outdata{1}.vsco(k:k+j) = lev + sl * tbase2(k:k+j); % compute ramped signal
   tbase{1}.vsco(k:k+j) = t0 + [0:j]*nrate; % fill tbase for that window also, same way
   t0 = tbase{1}.vsco(k+j); % and advance time
   k=k+j;
end;


for m=1:nout % for all stimuli in the set (sequence)
   k=1;
   t0 = 0;
   outdata{m}.v=[];
   tbase{m}.v=[];
   for i=1:ns % for each step...
      j = 0;
      if(isempty(du))% ? no changes in duration
         j = floor(sfile.Duration.v(i)/nrate); % Number of points in the duration step dur in msec; convert rate to msec too
      else
         if(i == parn(du))
            j = floor(vlist{du}(m)/nrate);   
         else
            j = floor(sfile.Duration.v(i)/nrate); % Number of points in the duration step dur in msec; convert rate to msec too
         end;
      end;
      if(j < 1)
         QueMessage('steps: Duration < 0? (assume absolute value)', 1);
         j = abs(j); % just assume some kind of error... - and its ok for j to be 0.
      end;
      
      if(i == 1) % initialize values
         lev = sfile.Holding.v;
         sl = 0;
      else % get values for rise and run
         if(i < ns)
            nextlev = sfile.Level.v(i+1); % determine the "rise"
         else
            nextlev = sfile.Holding.v;
         end;
         if(isempty(le))
            lev = sfile.Level.v(i); % value is constant for that time
         else
            if(find(i == parn(le)))
               ii = find(i == parn(le));
               lev = vlist{le(ii)}(m); % copy it over   
            else
               lev = sfile.Level.v(i); % value is constant for that time
            end;
         end;
         
         if(sfile.RampFlag.v(i) == 1) % compute the slope if the ramp flag is set for the step
            sl = (nextlev - lev)/sfile.Duration.v(i);
         else
            sl = 0;
         end;
      end;
      tbase{m}.v(k:k+j) = t0 + [0:j]*nrate; % fill tbase for that window also, same way
      outdata{m}.v(k:k+j) = lev + sl * tbase{m}.v(k:k+j); % compute ramped signal
      t0 = tbase{m}.v(k+j); % and advance time
      k=k+j;
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

err = 0; % only clear error flag if we make it all the way through.
return;


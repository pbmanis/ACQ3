function [outdata, tbase, out_rate, err] = noise(sfile, comp_num)
% noise: Acquisition method to make low-pass filtered gaussian noise.
% Usage
%     noise(sfile, comp_num).
%     This routine is not normally called by the user.

% This version for Acq, the matlab program for acquisition and stimulation
%
% 10/3/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% Returns for outdata and tbase are cell arrays as required by acq program.
%

plotflag = 0;

if(nargin == 1) % see if comp_num is defined, in which case we compute only the nth waveform..
   comp_num = 0; % assume we compute the whole list
end;

outdata={}; tbase={}; out_rate=[]; err = 1;
if(isempty(sfile))
   QueMessage('noise: No STIM?', 1);
   return;
end;
lpf = [];

possible_sequences = {'DC', 'LPF', 'Amplitude', 'Seed'};
if(chklength(sfile, possible_sequences, [1,1,1,1]))  % make sure incoming arguments are acceptable
   return;
end;

[dc, lpf, amp, seed, errp] = chkpars(sfile.SeqParList.v, possible_sequences); % check the parameters to be sequenced to be sure they are valid also
if(errp)
   return;
end;

% compute the sequences
vlist=seq_parse(sfile.Sequence.v); % partition list. Result is cell array, fastest first.
if(isempty(vlist))
   return;
end;

if(comp_num > length(vlist{1}))
   QueMessage('noise  -  index at end');
   return;
end;

% at this point, the basic parameters appear to be valid.
base_sample_rate = sfile.Sample_Rate.v;

out_rate=(1000000/base_sample_rate); % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...

base_dur = sfile.Duration.v; % get basic duration list
base_amp = sfile.Amplitude.v; % get basic level list

total_dur = sum(base_dur); % (dur is in msec).
npts = total_dur*base_sample_rate/1000; 
tbase2=base_sample_rate*(0:npts)/1000000; % express in msec...
nout = length(vlist{1});
nrate=0.001*base_sample_rate;
maxpts = floor(total_dur/nrate);
fsamp = base_sample_rate;
%fprintf('maxpts: %d   base_sample_rate: %d    npts = %s\n', maxpts, base_sample_rate, npts);

% set up the frame for a plot
if(plotflag > 0)
   h = findobj('Tag', 'Acq');
   if(~isempty(h))
      hola_f = findobj('Tag', 'Nspec'); % get the on -line analysis frame for spectral plot
      if(isempty(hola_f))
          hola_f = figure('Tag', 'Nspec');
      end;
      figure(hola_f)
      clf;
      hola(1) = subplot(1,2,1);
      hola(2) = subplot(1,2,2);
          %hola = get(hola_f, 'UserData'); % get the handles; we will use first for the plots
      axes(hola(1));
      set(gca, 'color', 'black');
      set(gca, 'YLimMode', 'auto');
      set(gca, 'XLimMode', 'auto');
      hold off;
      axes(hola(2));
      set(gca, 'color', 'black');
      set(gca, 'YLimMode', 'auto');
      set(gca, 'XLimMode', 'auto');
      hold off;
   end;
end;
c_ax = [0.37 0.37 0.8];

showraw = 0; % turns off the raw amplitude graph

seedo = sfile.Seed.v;
dco = sfile.DC.v;
lpfo = sfile.LPF.v;
ampo = sfile.Amplitude.v;

if(comp_num > 0)
   ml = comp_num; % allow computations on the fly of just one trace
   QueMessage('noise: on the fly');
else
   ml = [1:nout]; % compute the whole thing...
   QueMessage('noise: batch computation');
end;

k = 1;

for m=ml % for all stimuli in the set (sequence)
   t0 = 0;
   outdata{k}.v=zeros(1,maxpts);
   if(~isempty(seed)) % do we sequence the random number seed? (many different traces!)
      seedo = vlist{seed}(m);
   end;
   if(~isempty(dc))% ? no changes in dc level
      dco = vlist{dc}(m);   
   end;
   if(~isempty(lpf))% ? no changes in dc level
      lpfo = vlist{lpf}(m);   
   end;
   if(~isempty(amp)) % for changes in amplitude
      ampo = vlist{amp}(m);
   end;
   
   wco = lpfo/(0.5*1/(base_sample_rate*0.000001)); % wco of 1 is for half of the sample rate, so set it like this...
   %   fprintf('wco: %f   base_sample_rate: %f   lpfo:  %f\n', wco, base_sample_rate, lpfo);
   
   tbase{k}.v=[0:nrate:nrate*(maxpts-1)]; % time base, in milliseconds
   winl = maxpts/10;
   w=hanning(winl*2);
   w=w(1:length(w)/2); % just use half of it
   yn(1)=0;
   
   randn('state', seedo); % initialize generator with the appropriate seed
   
   yn(1:maxpts)=randn(1,maxpts); % normally distributed random noise, 0 mean amplitude 1
   yn(1:winl) = yn(1:winl).*w';
   n1 = length(yn) - winl + 1;
   n2 = length(yn);
   yn(n1:n2) = yn(n1:n2).*fliplr(w');
   yn = ampo*yn + dco;
   
   if(wco > 0 & wco < 1 ) % verify cutoffs
      %     [b, a] = ellip(8, 0.01, 120, wco);   % elliptical filter
      %[b, a] = cheby1(8, 0.1, wco);  % filter used from 4/03 through 9/3/03
    %[b, a] = besself(8, wco); %  
    [b, a] = butter(8, wco); % implemented 9/4/03.
      vsmo = filter(b, a, yn); % filter all the traces..
   else
      vsmo = yn; % unfiltered version
      QueMessage('noise: Warning - no filter', 1);
   end
   vsmo(1:winl) = vsmo(1:winl).*w'; % reapply taper...
   vsmo(n1:n2) = vsmo(n1:n2) .*fliplr(w');
   
   vsmo = vsmo + dco;
   outdata{k}.v=vsmo;
   outdata{k}.v(maxpts) = sfile.Holding.v; % make sure the final point is at holding level
   k = k + 1;
   
   % we plot the power spectra in the on-line analysis graphs
   % this is so the user can see what they have accomplished.. important feedback
   if(plotflag > 0)
   [p, f] = pwelch(vsmo,  1024, 1000/nrate); % convert to Hz
   [px, fx] = pwelch(yn, 1024, 1000/nrate); % note psd result is already in dB
   r = p./px; % this is the actual filtering that took place: the ratio of in to out...
      if(~isempty(h))
         axes(hola(1)); % use the on-line area to show the filtering.
         semilogx(f, 10*log10(r(:,1)));
         set(gca, 'YLimMode', 'manual');
         set(gca, 'YLim', [-100, 10]);
         set(gca, 'color', 'black');
         set(gca, 'XColor', c_ax);
         set(gca, 'YColor', c_ax);
         hold on;
         grid;
         
         if(showraw)
            axes(hola(2));
            semilogx(f, 10*log10(p(:,1)), 'g-', fx, 10*log10(px(:,1)), 'y.');
            set(gca, 'YLimMode', 'manual');
            set(gca, 'YLim', [-100, 10]);
            set(gca, 'color', 'black');
            set(gca, 'XColor', c_ax);
            set(gca, 'YColor', c_ax);
            hold on;
            grid;
         end;
      end;
   end;   
end; % of the big for loop
outdata{1}.vsco = outdata{1}.v;
tbase{1}.vsco = tbase{1}.v;

%check for superposition, and do it if necessary
if(~isempty(sfile.Superimpose.v))
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




function err = chklength(sf, namelist, maxcount)
% chklength: Check to see that the structure elemtents in namelist have correct lengths
err = 1;

if(nargin ~= 3)
   fprintf(2, 'chklength: Incorrect calling list \n');
   return;
end;
if(length(namelist) ~= length(maxcount))
   fprintf(2, 'chklength: name and count lists have different lengths\n');
   return;
end;
fn = fieldnames(sf);
for i = 1:length(namelist)
   if(~strmatch(namelist{i}, fn, 'exact'))
      fprintf(2, 'chklength: %s is not an element of input structure\n', namelist{i});
      return;
   end;
   t = eval(['sf.' namelist{i} '.v']);
   if(length(t) ~= maxcount(i))
      QueMessage(sprintf('chklength: Requires %d value(s) in %s field\n', maxcount(i), snamelist{i}),1);
      return;
   end;
end;

err = 0;
return;



function [varargout] = chkpars(list, possibles)
% chkpars: check the possibile sequence list against the request
% format:
% [out1 out2 err] = chkpars(string, {cellarray of possibles});
%

for i = 1:nargout-1
   varargout{i}=[];
end;
varargout{nargout} = 1; % the error flag is the last argument

if(nargin ~= 2)
   fprintf(2, 'chkpars: expect 2 input arguments\n');
   return;
end;

if(length(possibles) ~= (nargout -1))
   fprintf(2, 'chkpars: input possibles and output list are not matched in size\n');
   return;
end;

% copy sequence parameter into cell array
s = lower(list); % get the parameter to sequence
pars={};
i = 1;
while(~isempty(s))
   [pars{i}, s] = strtok(s, ' '); % get the tokens into a cell array
   i = i + 1;
end;

pars = lower(pars);

% verify valid sequence parameter for this stimulus type
poss_pars = lower(possibles);
for i = 1:length(pars)
   x = strmatch(pars{i}, poss_pars);
   if(isempty(x))
      QueMessage(sprintf('noise: Sequencing only allowed on %s\n', possibles),1)
      return;
   else
      varargout{x} = i;
   end;
end;
varargout{nargout} = 0;
return;

function [outdata, tbase, out_rate, err] = steps(sfile);
% steps  -  function to generate pulse steps based on the stim parmaeters, as
% defined in ths structure sfile.
%
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
% Paul B. Manis, Ph.D.
%
% pmanis@med.unc.edu
%

outdata=[]; tbase=[]; out_rate=[]; err = 0;
if(isempty(sfile))
   QueMessage('steps: No STIM?', 1);
   return;
end;

err=0;
out_rate=(1000000/sfile.Sample_Rate.v)*2; % convert to samples per second (rate in usec)
% note factor of 2 is to allow for using the second channel simultaneously...
duration = sum(sfile.Duration.v); % (dur is in msec).
npts = duration*sfile.Sample_Rate.v/1000; 
tbase2=sfile.Sample_Rate.v*(0:npts)/1000000; % express in msec...
vlist=seq_parse(sfile.Sequence.v);
nout = length(vlist);
nrate=0.001*sfile.Sample_Rate.v;
maxpts = floor(sum(sfile.Duration.v)/nrate);
outdata=zeros(nout, maxpts);
var = char(sfile.PrimaryP.v);
nvar = sfile.PrimaryI.v;
if(nvar > length(eval(['sfile.' var '.v'])));
   QueMessage(sprintf('Bad Stim arg: sfile.%s(%d)', var, nvar));
   err = 1;
   return;
end;
cmd=sprintf('sfile.%s.v(%d)=vlist(m);', var, nvar);
for m=1:nout % for all stimuli in the set (sequence)
   try
      eval(cmd); % set the new value  
   catch
      QueMessage(sprintf('Error in stimus syntax: evaluating %s', cmd))
      err=1;
      return;
   end
      k=1;
      h=length(sfile.Duration.v); % get the number of steps in the protocol
      t0 = 0;
      for i=1:h % for each step...
         j = floor(sfile.Duration.v(i)/nrate); % Number of points in the duration step dur in msec; convert rate to msec too
         outdata(m,k:k+j) = sfile.Level.v(i); % value is constant for that time
         tbase(m,k:k+j) = t0 + [0:j]*nrate; % fill tbase for that window also, same way
         t0 = tbase(m,k+j); % and advance time
         k=k+j;
      end;
      
   
end % of the big for loop
return;


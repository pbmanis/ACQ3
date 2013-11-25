function make_standard(arg)
% make_standard: make the standard STIM and ACQ files for data acquisition
% 10/13/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% The files made here are our basic set. Any new protocols should be added
% so that this routine can generate the files as necessary for new
% installations or for modifications of the underlying structures.

% requires the acq window to run
h = findobj('Tag', 'Acq')
if(isempty(h))
   fprintf('make_standard requires Acq to be running\n');
   return;
end;

if(nargin == 0)
   arg = 'all';
end;
all = 'all';

% Make VC_Default and CC_Default, so we have modes for switching
% First, VC_Default for voltage clamp search mode
name = 'vc_default';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -90;-65/5');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [-60 -70 -60]');
   set_cmd('holding -60');
   set_cmd('cycle 300');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 20');
   set_cmd('points 1000');
   sa([name '_acq']);
end;

% Next, CC_Default for current clamp switching
name = 'cc_default';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -200;200/50');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [0 -10 0]');
   set_cmd('holding 0');
   set_cmd('cycle 300');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 20');
   set_cmd('points 1000');
   sa([name '_acq']);
end;

% Basic protocols for searching and breakin

% Next, s for voltage clamp search mode
name = 's';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -10;0/2');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [0 -10 0]');
   set_cmd('holding 0');
   set_cmd('cycle 300');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 20');
   set_cmd('points 1000');
   sa([name '_acq']);
end;

% First, i for voltage clamp breakin mode
name = 'i';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -90;-65/5');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [-60 -70 -60]');
   set_cmd('holding -60');
   set_cmd('cycle 300');
   set_cmd(['acqfile s_acq']); % this uses the same one; we don't need another
   pv;
   s(name);
end;

% Next, iv for voltage clamp iv's
name = 'iv';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 500');
   set_cmd('sequ -100;50/5');
   set_cmd('seqp level');
   set_cmd('seqstep 2');
   set_cmd('dur [5 100 50]');
   set_cmd('lev [-60 -70 -60]');
   set_cmd('holding -60');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 50');
   set_cmd('points 2048');
   sa([name '_acq']);
end;

% Next, prepulse protocol for patches 
name = 'qinactp2';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 500');
   set_cmd('sequ [-100, -60, -40] & -100;50/5');
   set_cmd('seqp level level');
   set_cmd('seqstep [2 3]');
   set_cmd('dur [5 100 300 100 50]');
   set_cmd('lev [-60 -100 -40 0 -60]');
   set_cmd('holding -60');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 50');
   set_cmd('points 5000');
   sa([name '_acq']);
end;

% **********************************************
% The next set are current-clamp prototocols.
%

% First, ccs for current clamp search mode
name = 'ccs';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -100;0/50');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [0 -10 0]');
   set_cmd('holding 0');
   set_cmd('cycle 300');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 20');
   set_cmd('points 1000');
   sa([name '_acq']);
end;

% next, i for current clamp breakin mode
name = 'cci';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ -200;0/25');
   set_cmd('dur [5 10 5]');
   set_cmd('lev [0 -200 0]');
   set_cmd('holding 0');
   set_cmd('cycle 300');
   set_cmd(['acqfile ccs_acq']); % this uses the same one; we don't need another
   pv;
   s(name);
end;

% Next, cciv for current clamp iv's
name = 'cciv';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 500');
   set_cmd('sequ -500;500/50');
   set_cmd('seqp level');
   set_cmd('seqstep 2');
   set_cmd('dur [5 100 50]');
   set_cmd('lev [0 -100 0]');
   set_cmd('holding 0');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 50');
   set_cmd('points 2048');
   sa([name '_acq']);
end;

% Next, hyp for current clamp prepulse protocol
name = 'hyp';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 500');
   set_cmd('sequ -1000;200/50');
   set_cmd('seqp level');
   set_cmd('seqstep 2');
   set_cmd('dur [5 100 200 50]');
   set_cmd('lev [0 -200 200 0]');
   set_cmd('holding 0');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 50');
   set_cmd('points 5000');
   sa([name '_acq']);
end;


% Next, hyp2 for current clamp iv's
name = 'hyp2';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 50');
   set_cmd('sequ 1;150/25l');
   set_cmd('seqp duration');
   set_cmd('seqstep 2');
   set_cmd('dur [5 100 200 50]');
   set_cmd('lev [0 -250 200 0]');
   set_cmd('holding 0');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 50');
   set_cmd('points 5000');
   sa([name '_acq']);
end;

% Next, refract measuring refractory period between pairs of spikes
name = 'refract';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 10');
   set_cmd('sequ 0.1;15/50l');
   set_cmd('seqp duration');
   set_cmd('seqstep 3');
   set_cmd('dur [5 1.5 5 1.5  20]');
   set_cmd('lev [0 1000 0 1000 0]');
   set_cmd('holding 0');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 10');
   set_cmd('points 5000');
   sa([name '_acq']);
end;

% Next, forward measuring effect of preconditioning stimulation on a response
name = 'forward';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 50');
   set_cmd('sequ 10;150/20');
   set_cmd('seqp duration');
   set_cmd('seqstep 3');
   set_cmd('dur [5 100 5 100  50]');
   set_cmd('lev [0 250 0 200 0]');
   set_cmd('holding 0');
   set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setcc;
   set_cmd('rate 50');
   set_cmd('points 5000');
   sa([name '_acq']);
   
end;

% preipsp - a voltage clamp protocol with an ipsp that preceds a voltage step
% to determine whether deinactivation of an A current is acheived by the ipsp.
%

name = 'ipsp';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new alpha;  % note: alpha waveform
   set_cmd(['name ' name]);
   set_cmd('rate 25');
   set_cmd('sequ -15;0/5');
   set_cmd('seqp level');
   set_cmd('Alpha 0.5');
   set_cmd('holding 0');
   % set_cmd(['acqfile ' name '_acq']);
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 50');
   set_cmd('points 3000');
   sa([name '_acq']);
end;

% now the actual protocol
name = 'preipsp';
if(strmatch(arg, strvcat(all, name), 'exact'))
   fprintf(1, 'Making %s\n', name);
   new steps;
   set_cmd(['name ' name]);
   set_cmd('rate 500');
   set_cmd('sequ -50;0/10');
   set_cmd('seqp level');
   set_cmd('seqstep 2');
   set_cmd('dur [50 200 50]');
   set_cmd('lev [-60 -70 -60]');
   set_cmd('holding -60');
   set_cmd(['acqfile ' name '_acq']);
   set_cmd(['superimp ipsp']); % superimpose the ipsp waveform
   pv;
   s(name);
   
   new acq;
   set_cmd(['file ' name '_acq']);
   setvc;
   set_cmd('rate 25');
   set_cmd('points 5000');
   sa([name '_acq']);
   
end;
QueMessage('make_standard completed file generation', 1);
return;

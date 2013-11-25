function mcc_gains()
% make_axoprobe: make the standard STIM and ACQ files for data acquisition
% Files are specific to the axoprobe amplifier.
% Usage
%     No arguments: makes all the files
%     Argument: will make the selected files

% This one is for the axoprobe....
% 10/19/2000
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

% ap_CC_Default for current clamp switching
name = 'ap_cc_default';
if(strmatch(arg, strvcat(all, name), 'exact'))
fprintf(1, 'Making %s\n', name);
new steps;
set_cmd(['name ' name]);
set_cmd('rate 10');
set_cmd('sequ -500;500/50');
set_cmd('dur [5 10 5]');
set_cmd('lev [0 -10 0]');
set_cmd('holding 0');
set_cmd('cycle 300');
set_cmd(['acqfile ' name '_acq']);
pv;
s(name);

new acq;
set_cmd(['file ' name '_acq']);
setap;
set_cmd('rate 20');
set_cmd('points 1000');
sa([name '_acq']);
end;

% Basic protocols for searching and breakin

% Next, s for voltage clamp search mode
name = 'ap-s';
if(strmatch(arg, strvcat(all, name), 'exact'))
fprintf(1, 'Making %s\n', name);
new steps;
set_cmd(['name ' name]);
set_cmd('rate 10');
set_cmd('sequ -200;0/50');
set_cmd('dur [5 10 5]');
set_cmd('lev [0 -10 0]');
set_cmd('holding 0');
set_cmd('cycle 300');
set_cmd(['acqfile ' name '_acq']);
pv;
s(name);

new acq;
set_cmd(['file ' name '_acq']);
setap;
set_cmd('rate 20');
set_cmd('points 1000');
sa([name '_acq']);
end;

% First, i for breakin mode
name = 'ap-i';
if(strmatch(arg, strvcat(all, name), 'exact'))
fprintf(1, 'Making %s\n', name);
new steps;
set_cmd(['name ' name]);
set_cmd('rate 10');
set_cmd('sequ -200;0/25');
set_cmd('dur [5 10 5]');
set_cmd('lev [0 -100 0]');
set_cmd('holding 0');
set_cmd('cycle 300');
set_cmd(['acqfile s_acq']); % this uses the same one; we don't need another
pv;
s(name);

new acq;
set_cmd(['file ' name '_acq']);
setap;
set_cmd('rate 20');
set_cmd('points 1000');
sa([name '_acq']);
end;

% Next, iv for current clamp iv's
name = 'ap-iv';
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
setap;
set_cmd('rate 25');
set_cmd('points 4096');
sa([name '_acq']);
end;

% Next, hyp for current clamp prepulse protocol
name = 'ap-hyp';
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
setap;
set_cmd('rate 50');
set_cmd('points 5000');
sa([name '_acq']);
end;

% Next, hyp2 for current clamp iv's
name = 'ap-hyp2';
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
setap;
set_cmd('rate 50');
set_cmd('points 5000');
sa([name '_acq']);
end;

% Next, refract measuring refractory period between pairs of spikes
name = 'ap-refract';
if(strmatch(arg, strvcat(all, name), 'exact'))
fprintf(1, 'Making %s\n', name);
new steps;
set_cmd(['name ' name]);
set_cmd('rate 10');
set_cmd('sequ [1000 0] & 0.5;15/25l');
set_cmd('seqp level duration');
set_cmd('seqstep [4 3]');
set_cmd('dur [5 1.5 5 1.5  20]');
set_cmd('lev [0 1000 0 1000 0]');
set_cmd('holding 0');
set_cmd(['acqfile ' name '_acq']);
pv;
s(name);

new acq;
set_cmd(['file ' name '_acq']);
setap;
set_cmd('rate 10');
set_cmd('points 5000');
sa([name '_acq']);
end;

% Next, forward measuring effect of preconditioning stimulation on a response
name = 'ap-forward';
if(strmatch(arg, strvcat(all, name), 'exact'))
fprintf(1, 'Making %s\n', name);
new steps;
set_cmd(['name ' name]);
set_cmd('rate 50');
set_cmd('sequ [250 0] & 10;150/20');
set_cmd('seqp level duration');
set_cmd('seqstep [2 3]');
set_cmd('dur [5 100 5 100  50]');
set_cmd('lev [0 250 0 200 0]');
set_cmd('holding 0');
set_cmd(['acqfile ' name '_acq']);
pv;
s(name);

new acq;
set_cmd(['file ' name '_acq']);
setap;
set_cmd('rate 50');
set_cmd('points 5000');
sa([name '_acq']);
end;

QueMessage('make_axoprobe completed file generation', 1);

return;

function setsinglevc()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% and multiple electrodes
% configuration: MC700A : cell 1 and 2
% AProbe: cell 3. 
%
% Usage
%     setmulticell <cr> sets default parameters for MC700A in current clamp mode
% version for single recording! 8/2/05 P. Manis

global DFILE
global DISPCTL ONLINE
er;

QueMessage('setsinglevc -- ', 1);

DISPCTL.online = 1;
DISPCTL.utility = 1;
DISPCTL.ysizes(1) = 1;
DISPCTL.ysizes(3) = 1;
[ONLINE.Enable{:}] = deal(0);
DFILE.Data_Mode.v = 'VC';
DFILE.AD_Range.v = [10 10];
DFILE.Sensor_Range.v = [40 2000];
DFILE.Channels.v = [5 3]; % funny channels.....
DFILE.lpf.v = [10 10];
DFILE.hpf.v = [0 0];

chdis(2,-1000,1000);
chdis(1,-120, 60);
%chdis(3,-1000,1000);
%chdis(4,-120, 60);

QueMessage('setsinglevc -- done');
return;

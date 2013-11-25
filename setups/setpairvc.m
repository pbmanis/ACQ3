function setpairvc()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% and multiple electrodes
% configuration: MC700A : cell 1 and 2
% AProbe: cell 3. 
%
% Usage
%     setmulticell <cr> sets default parameters for MC700A in current clamp mode
% version for pair recording! 7/5/05 P. Manis

global DFILE
global DISPCTL ONLINE
er;

QueMessage('setpairvc -- ', 1);

DISPCTL.online = 0;
DISPCTL.utility = 0;
DISPCTL.ysizes(1) = 6;
DISPCTL.ysizes(3) = 6;
[ONLINE.Enable{:}] = deal(0);
DFILE.Data_Mode.v = 'VC';
DFILE.AD_Range.v = [10 10 10 10];
DFILE.Sensor_Range.v = [40 2000 800 40];
DFILE.Channels.v = [5 3 6 7]; % funny channels.....
DFILE.lpf.v = [10 10 10 10];
DFILE.hpf.v = [0 0 0 0];

chdis(2,-1000,1000);
chdis(1,-120, 60);
chdis(3,-1000,1000);
chdis(4,-120, 60);

QueMessage('setpairvc -- done');
return;

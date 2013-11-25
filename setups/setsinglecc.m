function setsinglecc()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% and single electrodes
% configuration: MC700A : cell 1 and 2
% 
%
% Usage
%     setmulticell <cr> sets default parameters for MC700A in current clamp mode
% version for sing recording! 8/2/05 P. Manis

global DFILE
global DISPCTL
global ONLINE

er;
QueMessage('setsinglecc -- ', 1);
DISPCTL.online = 0;
DISPCTL.utility = 1;
DISPCTL.ysizes(1) = 4;
DISPCTL.ysizes(3) = 1;
[ONLINE.Enable{:}] = deal(0);
DFILE.Data_Mode.v = 'CC';
DFILE.AD_Range.v = [10 10 ];
DFILE.Sensor_Range.v = [2000 800];
DFILE.Channels.v = [3 5]; % funny channels.....
DFILE.lpf.v = [10 10];
DFILE.hpf.v = [0 0];

chdis(1,-120,40);
chdis(2,-1000, 1000);
% chdis(3,-120,40);
% chdis(4,-1000, 1000);
acq_plot_data(1);
QueMessage('setsinglecc -- done');
return;

function setmcc2()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% Usage
%     setmcc <cr> sets default parameters for MC700A in current clamp mode

global DFILE

% This assumes: multiclamp 700
% I reads signal GOING IN, with I set at 2 nA/V
% if I is 400 pA/V, use 800 in sensor_range(2),
DFILE.Data_Mode.v = 'CC';
DFILE.AD_Range.v = [10 10 10 10];
DFILE.Sensor_Range.v = [2000 800 2000 800];
DFILE.Channels.v = [3 5 6 7]; % funny channels.....

struct_edit('edit', DFILE);
return;

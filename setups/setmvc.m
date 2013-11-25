function setmvc()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% Usage
%     setmcc <cr> sets default parameters for MC700A in current clamp mode
% assumes that amplifier gain is 1nA/V (= gain of 2!)
%
global DFILE

DFILE.Data_Mode.v = 'VC';
DFILE.AD_Range.v = [10 10];
DFILE.Sensor_Range.v = [40 2000];
DFILE.Channels.v = [5 3]; % funny channels.....

struct_edit('edit', DFILE);
return;

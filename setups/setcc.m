function setmcc()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% Usage
%     setmcc <cr> sets default parameters for MC700A in current clamp mode

global DFILE

DFILE.Data_Mode.v = 'CC';
DFILE.AD_Range.v = [10 10];
DFILE.Sensor_Range.v = [400 800];
DFILE.Channels.v = [3 11]; % funny channels.....

struct_edit('edit', DFILE);
return;

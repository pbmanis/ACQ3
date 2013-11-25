function setmulticell()
% setcc: set acquisition parameters for axon multiclamp 700A current clamp
% and multiple electrodes
% configuration: MC700A : cell 1 and 2
% AProbe: cell 3. 
%
% Usage
%     setmulticell <cr> sets default parameters for MC700A in current clamp mode

global DFILE

DFILE.Data_Mode.v = 'CC';
DFILE.AD_Range.v = [10 10 10 10 2 0.1];
DFILE.Sensor_Range.v = [40 800 40 800 40 2000];
DFILE.Channels.v = [3 5 6 7 8 9]; % funny channels.....

chdis(1,50,-120);
chdis(3,50,-120);
chdis(5,50,-120);
chdis(2,-1000,1000);
chdis(4,-1000,1000);
chdis(6,-1000,1000);

struct_edit('edit', DFILE);
return;

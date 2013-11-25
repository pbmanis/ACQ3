function setvc()
% setvc: Set acquisition parameters for axo200 voltage clamp
% Usage
%     setvc <cr> sets acquisition paramters for axo200 in voltage clamp

global DFILE

DFILE.Data_Mode.v='VC';
DFILE.AD_Range.v = [10 10];
DFILE.Sensor_Range.v = [200 2000];
DFILE.Channels.v = [1 0];

struct_edit('edit', DFILE);
return;

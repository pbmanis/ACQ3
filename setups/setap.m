function setap()
% setap: set acquisition parameters for AxoProbe 1A current clamp
% Usage
%     setap<cr> to set parameter defaults (for acquisition)

global DFILE

DFILE.Data_Mode.v = 'CC';
DFILE.AD_Range.v = [2 1]; % optimize for +/- 250 mV and +/0 2000 pA
DFILE.Sensor_Range.v = [400 2000]; % sensor range corrects for voltage gain of amplifier
DFILE.Channels.v = [3 4]; % inputs are V on ACH3 and I on ACH4

struct_edit('edit', DFILE);
return;

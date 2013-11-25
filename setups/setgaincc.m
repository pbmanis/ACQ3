function setgaincc(gain, maxsig)
%
% gain
% maxsig is in pA
% multiclamp in voltage clamp...
global DFILE

gain = str2num(gain);
maxsig = str2num(maxsig);

maxad = [0.05 0.10 0.25 0.50 1 2.5 5 10];
adr = [10 10];
sense = [400 800];
relgain = 10; % amplifier intrinsic gain (V/V)

maxv = (gain/relgain) * maxsig*1000; % REMEMBER mV!!!
x = find(maxv <= maxad);
if(isempty(x))
   x = length(maxad);
	adr(2) = maxad(x(1));
	sense(2) = (adr(2)/10)*sense(2)*relgain/gain;
else
	adr(2) = maxad(x(1));
	sense(2) = (adr(2)/10)*sense(2)*relgain/gain;
end;

DFILE.AD_Range.v = adr;
DFILE.Sensor_Range.v = sense;

struct_edit('edit', DFILE);

vdis(sprintf('%f',maxsig));

return;



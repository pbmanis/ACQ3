function setgain(gain, maxsig)
%
% gain
% maxsig is in pA
% multiclamp in voltage clamp...
global DFILE

gain = str2num(gain);
maxsig = str2num(maxsig);

maxad = [0.05 0.10 0.25 0.50 1 2.5 5 10];
adr = [10 10];
sense = [40 2000];
relgain = 2; % amplifier

maxv = (gain/relgain) * (maxsig /1000); % REMEMBER pA!!!
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

idis(sprintf('%f',maxsig));
return;



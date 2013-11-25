function setreed(arg)
% set the level and testlevel to the same value
global STIM
inj = str2num(arg);
STIM.level.v(1)=inj;
STIM.level.v(2)=inj;
STIM.testlevel.v(1)=inj;
return;

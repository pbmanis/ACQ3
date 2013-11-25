function setreed(arg)
% set the level and testlevel to the same value
global STIM
inj = number_arg(arg);
STIM.level.v(1)=inj;
STIM.level.v(2)=inj;
STIM.testlevel.v(1)=inj;
    STIM.update = 0;
    STIM=pv(STIM, 1);
pv('-f');
return;

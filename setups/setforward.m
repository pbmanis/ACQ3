function setforward(cond, test)
%
% set up the levels for the forward2 protocol
global STIM
g forward_test
t = number_arg(test);
STIM.Level.v=eval(sprintf('[0 %d 0]', t));
STIM.Sequence.v=sprintf('[%d]', t);
pv('-f')
s forward_test
% now the main protocol
g forward2
t = number_arg(cond);
STIM.Level.v=eval(sprintf('[0 %d 0]', t));
STIM.Sequence.v=sprintf('[0 %d] & 10;1160/50', t);
pv('-f')
s forward2
return


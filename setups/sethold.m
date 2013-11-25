function sethold(arg)
%
% hold command: hold [value | off]
%
% use this command to enable a tracking holding current between trials
% that attempts to hold the membrane potential at value.
% if command is 'off', the hold is turned off (0 addititonal current).
%
% 7/18/01 Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

global HOLD_FLAG HOLD_VOLTAGE HOLD_CURRENT TEST_MODEL
global AI AO

if(nargin ~= 1)
   QueMessage('Hold requires one argument', 1);
   return;
end;
if(TEST_MODEL)
    return;
end;

switch arg
case 'off' % turn it OFF
   HOLD_FLAG = 0;
   HOLD_VOLTAGE = 0;
   HOLD_CURRENT = 0;
   if(length(AO.Channel) == 0)
       ao_chans = addchannel(AO, 0:1); % set up for 2 channels
   end;
   putsample(AO, [HOLD_CURRENT 0]);
   return;
case 'set' % use the current RMP to set the holding voltage
   if(isempty(AI) | isempty(AO))
      fprintf('sethold: AI or AO not set up yet; returning\n');
      return;
   end;
   vm = 0;
   for i = 1:5
      v1 = getsample(AI); % read the acquisition..... hope its already on!
      vm = v1(1)+vm;
      pause(0.01);
   end;
   vm = vm/5;
   HOLD_VOLTAGE = vm;
   HOLD_FLAG = 1;
   HOLD_CURRENT = adj_rmp(HOLD_VOLTAGE, 1, HOLD_CURRENT); % adjust the holding current (not necessary?)
otherwise
   HOLD_FLAG = 1;
   HOLD_VOLTAGE = number_arg(arg);
   if(~isnumeric(HOLD_VOLTAGE))
      HOLD_VOLTAGE = -50;
   end;
   HOLD_CURRENT = 0;
   HOLD_CURRENT = adj_rmp(HOLD_VOLTAGE, 1, HOLD_CURRENT);
end;
if(isempty(AO))
   fprintf('sethold: AO is not set up yet; returning\n');
   return;
end;
putsample(AO, [HOLD_CURRENT 0]);
return;

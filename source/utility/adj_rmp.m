function [hold] = adj_rmp(vrmp, verr, this_hold)

% function to try to hold the RMP value at vrmp by adjusting the holding current.....
% vrmp is the target RMP.
% verr is the allowable error in potential. If vrmp +/- verr can't be found,
% within a few iterations (set by maxiteration), then we leave the hold at this_hold.
%
% this algorithm works by getting a quick estimate of the input resistance (25 msec pulse)
% and then calculating the current necessary to set a particular voltage.
% A small loop then samples the voltage, and injects a current to try to make the fine
% adjustment. 
% 7/18/01 P. Manis.

global AI % the adjrmp input object... so we don't have to create it every time...
global AO % access the output object...
global HOLD_FLAG

if(~HOLD_FLAG)
   hold = this_hold;
   return;
end;

hold = this_hold;
if(isempty(AO) | isempty(AI))
   fprintf('adj_rmp: Analog objects not set, returning\n');
   return;
end;

pause_time = 0.01;
iteration = 1;
maxiteration = 35; 	% max find adjustment
deltaI = 10; % in pA...
testI = -25;
navg = 4;
v = 0;
for i = 1:navg
   vn = getsample(AI);
   v = v + vn;
end;
v0 = v/navg; % make it an average
%putsample(AO, [this_hold+testI 0]); % change holding
%pause(pause_time);
%v1 = getsample(AI);
%rin = 1000*(-v0(1)+v1(1))/testI; % compute estimated input resistance
% get first target current level by ohm's law
%new_hold = ((v0(1)-vrmp)/rin)+this_hold;
%v0
%v1
%rin
%this_hold
%new_hold
%putsample(AO, [new_hold 0]); % change holding
%pause(pause_time);
%v0=getsample(AI); % read it...
if(abs(v0(1)-vrmp) <= verr/2)
   hold = this_hold;
   return;
end;
new_hold = this_hold;
while(abs(v0(1)-vrmp) > verr/2)
   iteration = iteration  + 1;
   if(iteration > maxiteration)
      hold = new_hold; % don't change it becasuse... we ran out of trials.
      putsample(AO, [new_hold 0]);
      return;
   end;
   dI = deltaI;
   if(abs(v0(1)-vrmp) > 10)
      dI = 4*deltaI; % faster move....
   end;
   if(v0(1) > vrmp) % adjust holding up or down in fixed steps to find target
      new_hold = new_hold - dI;
   else
      new_hold = new_hold + dI;
   end;
   putsample(AO, [new_hold 0]);
   pause(pause_time);
   v = 0;
   for i = 1:navg
      vn = getsample(AI);
      v = v + vn;
   end;
   v0 = v/navg; % make it an average
end;
hold = new_hold;
putsample(AO, [new_hold 0]);
return;

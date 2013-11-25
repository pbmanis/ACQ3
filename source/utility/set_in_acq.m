function set_in_acq(flag)
% set the IN_ACQ flag or clear it. Also sets state of stop button to indicate when running
global IN_ACQ

switch(flag)
case 1
   IN_ACQ = flag;
   h = findobj('Tag', 'acq_stop');
   if(~isempty(h))
      set(h, 'ForegroundColor', [1 1 1]); % indicate that button will be active
      set(h, 'BackgroundColor', [1 0 0]);
   end;
case 0
   IN_ACQ = 0;
   h = findobj('Tag', 'acq_stop');
   if(~isempty(h))
      set(h, 'ForegroundColor', [0.4 0.4 0.4]); % indicate button is inactive
      set(h, 'BackgroundColor', [0.4 0.4 0.4]);
   end;
otherwise
   QueMessage('acquire_one/set_in_acq: ? bad flag in call', 1);
   return;
end;

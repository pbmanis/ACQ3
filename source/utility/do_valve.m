function do_valve(arg)

switch arg
case 'computer'
   message = 'Switch control of valves to computer';
   [valveicon, vcmap] = imread('c:\mat_datac\acq\macros\valve-computer.png');
case 'manual'
   message = 'Switch control of valves to Manual';
   [valveicon, vcmap] = imread('c:\mat_datac\acq\macros\valve-manual.png');
otherwise
   message = 'Switch Valves???';
end;

hhd = msgbox(message, 'MACRO Hyp_Drug Valve Setup', ...
   'custom', valveicon, vcmap);
uiwait(hhd);

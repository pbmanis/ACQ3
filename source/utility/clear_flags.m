function clear_flags(arg)
%
% clear the status flags on us to restore acquisition.
% use this routine with caution. It should only be used because of a program error.
% ALso now restores the base path. 

global IN_MACRO STOP_MACRO STOP_ACQ IN_ACQ BASEPATH

if(nargin ~= 1)
    return;
end;
if(arg == 1)
    curr_flags=sprintf('IN_MACRO: %2d \n STOP_MACRO: %2d \n STOP_ACQ: %2d \n IN_ACQ: %2d', ...
        IN_MACRO, STOP_MACRO, STOP_ACQ, IN_ACQ);
    h=msgbox(curr_flags, 'Current Flags', 'warn', [], [], 'modal');
    return;
end;

if(arg == 2)
    button = questdlg('Clearing flags should only be done if there is a program error!',...
        'Continue Operation?','Yes','No','Help','No');
    if strcmp(button,'Yes')
        STOP_ACQ = 0;
        IN_MACRO = 0;
        STOP_MACRO = 0;
        IN_ACQ = 0;
        set_in_acq(0);
        cd(BASEPATH);
        QueMessage('Cleared Acquisition State Flags!', 1);
        
    elseif strcmp(button,'No')
        QueMessage('Canceled clear flags operation', 1);
        %   msgbox('Canceled clear flags operation')
    elseif strcmp(button,'Help')
        msgbox('Only clear the flags if there\n has been a program error!')
    end
    return;
end;



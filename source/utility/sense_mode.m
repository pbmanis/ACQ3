function sense_mode(obj, event, old_mode, hold_level);

% sense the mode switch upon detecting that the mode has changed.
% also change the window for the trigger detection
% This routine is executed as a TriggerFcn from watch_mode.

% MODIFIED 9/19/01 by SCM
% MAKE SURE appropriate scaling on holding values!!!
% added subroutine at end to handle the putsample() command
%
% MODIFIED 9/26/01 by SCM
% moved AO scaling & holding command into new function (SET_HOLD.M)
%
% MODIFIED 10/9/01 SCM - allow holding value to be passed as a parameter
% the specified holding level is automatically set when the new stim file is loaded
%
% MODIFIED 7/11/03 SCM - added Multiclamp amplifier code

global CONFIG

% stop AI object if needed
% reset to prevent retriggering
if (validobj(obj, 'analoginput'))
    stop(obj);
    flushdata(obj);
    set(obj, 'TriggerType', 'Manual');
    %delete(obj.channel);
    %delete(obj);
end

% determine whether timeout or trigger was detected
switch (lower(event.Type))
    case 'timer'
        QueMessage('sw: timeout occurred before mode change detected', 1);
        return
    case 'trigger'
        % pass through to switch mode
    otherwise
        return
end

% new mode is assumed to be opposite of old mode
% specify stimulus parameters file
switch (old_mode)
    case {'V', 'T'}
        stim_file = CONFIG.CC.v;
        new_mode = 'CC';
    case {'I', 'F'}
        stim_file = CONFIG.VC.v;
        new_mode = 'VC';
    case {'0'}
        QueMessage('Caught in Track: reset and try again', 1);
        return
    otherwise
        QueMessage('sense_mode: unrecognized amplifier mode', 1);
        return
end

% get the updated stimulus parameters
% pass the holding level if provided
if (isempty(hold_level))
    g(stim_file);
else
    g(stim_file, hold_level);
end
QueMessage(sprintf('Switching to %s', new_mode), 1);
return

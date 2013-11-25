function acq_stop()
% acq_stop:  stop acquisition cleanly
% 8/17/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% % this can be called by the STOP button
% or by the program to insure that acquistion is correctely stopped.
%
global STOP_ACQ SCOPE_FLAG IN_ACQ
global IN_MACRO STOP_MACRO
global AO AI DIO

% set stop flag first. If acquisition is running, we will catch it there.
if(STOP_ACQ == 0)
    STOP_ACQ = 1;
    QueMessage('Acquisition STOPPED');
else
    QueMessage('Stop already set');
end;

% make macro end
if(IN_MACRO)
    STOP_MACRO = 1; % force it.
end;

if(IN_ACQ) % check if acquisition is running - if so, then stop it
    if(exist('DIO', 'var') && ~isempty(DIO) && isvalid(DIO) && isrunning(DIO))
        stop(DIO); % make sure clock is stopped first so it can't interrupt
    end;
    % force hardware to stop and turn off the flag
    if(exist('AO', 'var') && ~isempty(AO) && isvalid(AO) && isrunning(AO))
        stop(AO);
    end;
    if(exist('AI', 'var') && ~isempty(AI) && isvalid(AI) && isrunning(AI))
        stop(AI);
    end;
end;

IN_ACQ = 0;

% reset the scope button
if(SCOPE_FLAG > 0)
    scope('off');
end;

h = findobj('Tag', 'acq_stop');
if(~isempty(h))
    %      set(h, 'ForegroundColor', [0.2 0.2 0.2]); % indicate button press by greying it out
    set(h, 'BackgroundColor', [0.35 0.35 0.35]);
end;
return;


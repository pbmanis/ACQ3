function scope(arg)
% scope: Run in oscilloscope mode (no data storage).
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     scope <cr> activates the scope mode (stimulate and display, no data save)
%     scope arg performs actions according to arg (Used internally only).

% 8/17/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% 10/21/2000
% major changes in logic to make running more intuitive
% scope now ONLY operates on the scope flag, and can
% force stop of acquisition if necessary.
% P. Manis.
%

global SCOPE_FLAG IN_ACQ

h = findobj('Tag', 'scope'); % find tag for button

if(nargin == 0) % set our own arg state
    switch(SCOPE_FLAG)
        case {0, 2} % current state is off or pause, so set 'on'
            arg = 'on';
        case 1 % current state is on, so set 'off'
            arg = 'off';
        otherwise
            QueMessage('scope: Unknown value for SCOPE_FLAG', 1);
            return;
    end;
end;

switch(lower(arg))
    case 'off' % turn scope mode off (absolute)
        SCOPE_FLAG = 0; % set scope flag OFF, and then
        if(~isempty(h))
            set(h, 'BackgroundColor', [0 1 0]); % green means we can go to scope
            set(h, 'ForegroundColor', [1 1 1]);
        end;
        return;
    case 'on' % turn scope mode on(absolute)
        if(SCOPE_FLAG == 1 && IN_ACQ)
            return;
        end;
        SCOPE_FLAG = 1; % enter scope mode
        if(~isempty(h))
            set(h, 'BackgroundColor', [1 0 0]); % read means we are in scope and next press will stop us
            set(h, 'ForegroundColor', [1 1 1]);
        end;
        acquire_one('data'); % start the acquisition
        return;
    case 'pause'
        SCOPE_FLAG = 2;
        if(~isempty(h))
            set(h, 'BackgroundColor', [1 1 0]); % yellow indicates pause mode
            set(h, 'ForegroundColor', [1 1 1]);
        end;
        acq_stop;
        return;
    case 'continue'
        if(SCOPE_FLAG == 2) % only do something if we are "paused"
            SCOPE_FLAG = 1; % force "on" (not pause)
            if(~isempty(h))
                set(h, 'BackgroundColor', [1 0 0]); % green means we can go to scope
                set(h, 'ForegroundColor', [1 1 1]);
            end;
            acquire_one('data');
            return;
        end;
    otherwise % unrecognized command to scope; just emit error and do nothing
        QueMessage('scope: argument must be either on or off', 1);
        return;
end;

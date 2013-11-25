function idis(arg1, arg2)
% idis: set current axes display limits
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%    idis min max sets I display min and max

%
% 10/19/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global DISPLIM DFILE DISPCTL

if(isempty(DISPCTL))
    initdispctl;
end;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
switch nargin
    case 1
        arg2 = ['-' arg1]; % use negative and make display symmetrical
    case 0
        deflim = {sprintf('%d', DISPLIM.I(2)) sprintf('%d', DISPLIM.I(1))};
        [x] = inputdlg({'Max', 'Min'}, 'I_Display_Limits', [1 15], deflim, options); % make an input dialog
        if(~isempty(x))
            arg1 = x{1};
            arg2 = x{2};
        else
            return;
        end;
    otherwise
        if(nargin > 2)
            QueMessage('idis: requires only two arguments (min, max) for display limits', 1);
            return;
        end;
end;
if(~isnumeric(arg1))
    arg1 = str2double(arg1);
end;
if(~isnumeric(arg2))
    arg2 = str2double(arg2);
end;

if(arg1 == arg2)
    QueMessage('idis: Display limits must not be equal', 1);
    return;
end;


DISPLIM.I = sort([arg1 arg2]);

hc1 = findobj('Tag', 'Acq_MW2');
if(isempty(hc1))
    QueMessage('idis: Cannot find display Acq_MW2? ', 1);
    return;
end;
hc2 = findobj('Tag', 'Acq_MW1');
if(isempty(hc2))
    QueMessage('idis: Cannot find display Acq_MW1? ', 1);
    return;
end;

switch(lower(DFILE.Data_Mode.v))
    case 'cc' % for current clamp, display the voltage on top, big, and the current below
        DISPCTL.ymax(2) = DISPLIM.I(2);
        DISPCTL.ymin(2) = DISPLIM.I(1);
        DISPCTL.unit{2} = 'pA';
        acq_plot_data(1);

    case 'vc'
        DISPCTL.ymax(1) = DISPLIM.I(2);
        DISPCTL.ymin(1) = DISPLIM.I(1);
        DISPCTL.unit{1} = 'pA';
        acq_plot_data(1);
    otherwise
        QueMessage(sprintf('idis: mode %s not recognizned', DFILE.Data_Mode.v),1);
end;

return


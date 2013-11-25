function vdis(arg1, arg2)
% vdis: set voltage axes display limits
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%    vdis min max sets V display min and max

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
        deflim = {sprintf('%d ', DISPLIM.V(2)) sprintf('%d ', DISPLIM.V(1))};
        [x] = inputdlg({'Max', 'Min'}, 'V_Display_Limits', [2 15], deflim, options); % make an input dialog
        if(isempty(x))
            return;
        end;
        if(~isempty(x))
            arg1 = x{1};
            arg2 = x{2};
        else
            return;
        end;
    otherwise
        if(nargin > 2)
            QueMessage('vdis: requires only two arguments (min, max) for display limits', 1);
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
    QueMessage('vdis: Display limits must not be equal', 1);
    return;
end;

DISPLIM.V = sort([arg1 arg2]);

hc=[];
hc1 = findobj('Tag', 'Acq_MW1');
if(isempty(hc1))
    QueMessage('vdis: Cannot find display Acq_MW1? ', 1);
    return;
end;
hc2 = findobj('Tag', 'Acq_MW2');
if(isempty(hc2))
    QueMessage('vdis: Cannot find display Acq_MW2? ', 1);
    return;
end;

switch(lower(DFILE.Data_Mode.v))
    case 'cc' % for current clamp, display the voltage on top, big, and the current below

        DISPCTL.ymax(1) = DISPLIM.V(2);
        DISPCTL.ymin(1) = DISPLIM.V(1);
        DISPCTL.unit{1} = 'mV';
        acq_plot_data(1);

    case 'vc' % reversed for voltage clamp...

        DISPCTL.ymax(2) = DISPLIM.V(2);
        DISPCTL.ymin(2) = DISPLIM.V(1);
        DISPCTL.unit{2} = 'mV';
        acq_plot_data(1);
    otherwise
end;

return


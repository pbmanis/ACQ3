function initdispctl()
% initialize the DISPCTL structure. 7/5/05 P. Manis
global DISPCTL
DISPCTL = [];
DISPCTL.online = 0; % enable the online-analysis window in this display.
DISPCTL.utility = 0; % enable the preview window in this display
DISPCTL.ysizes = ones(16,1);
DISPCTL.ysizes(1) = 6; % voltage is bigger...
DISPCTL.ysizes(3) = 6;
DISPCTL.ymax = [40,2,40,2,40,2,40,2,40,2,40,2,40,2,40,2];
DISPCTL.ymin = [-120,-2,-120,-2,-120,-2,-120,-2,-120,-2,-120,-2,-120,-2,-120,-2];
DISPCTL.grid = ones(16,1);
DISPCTL.unit = {'mV', 'pA', 'mV', 'pA', 'mV', 'pA', 'mV', 'pA', ...
    'mV', 'pA', 'mV', 'pA', 'mV', 'pA', 'mV', 'pA'};


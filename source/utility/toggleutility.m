function toggleutility()
% Change state of utility display in the plot area
%
global DISPCTL
h = findobj('tag', 'menu_utility');

if(DISPCTL.utility == 0)
    DISPCTL.utility = 1;
    set(h, 'checked', 'on');
else
    DISPCTL.utility = 0;
    set(h, 'checked', 'off');
end;

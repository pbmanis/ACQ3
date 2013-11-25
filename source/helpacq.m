function helpacq()
% helpacq: display help information code comments in a window
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

global CMDS
hpf = findobj('Tag', 'AcqHelp'); % see if one exists...
if(isempty(hpf))
    hpf = figure( ...
        'name', 'AcqHelp', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.1 0.8 0.8], ...
        'BackingStore', 'on', ...
        'NumberTitle', 'off', ...
        'Tag','AcqHelp');
end;
figure(hpf);
clf;
hlist = uicontrol('Parent',hpf, ...
    'Units','normalized', ...
    'BackgroundColor','white', ...
    'ForegroundColor', 'black', ...
    'ListboxTop',1, ...
    'Position', [0.02 0.02 0.98 0.98], ...
    'HorizontalAlignment','left', ...
    'String','', ...
    'Style','ListBox', ...
    'FontSize', 8, ...
    'FontName', 'FixedWidth', ...
    'Tag','TheList');


[c, u] = sort(CMDS);
list = {};
for i = 1:length(c)
    if(strcmp(char(c{i}), 'Contents.m'))
    else
        x = help(c{i});
        ln = strfind(x, char(10)); % find line breaks.
        if(isempty(ln))
            list = cellcat(list, help(c{i}));
        else
            sl = 1;
            for j = 1: length(ln)
                if(j == 1)
                    u = strfind(x, ':');
                    if(isempty(u))
                        x = upper(x);
                    else
                        x = [upper(x(1:u(1))) x(u(1)+1:end)];
                    end;
                    list = cellcat(list, x(sl:ln(i)-1));
                else
                    list = cellcat(list, x(sl:ln(i)-1));
                end;
                sl = ln(j)+1;
            end;
        end;
        list = cellcat(list, ' ');
        list = cellcat(list, '-----');

    end;
end;
set(hlist, 'String', list);

return;


function [o] = cellcat(in, string)
o = in;
p = length(in) + 1;
o{p} = string;
return;


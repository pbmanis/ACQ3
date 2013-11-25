function QueMessage(varargin)

if(nargin >= 1)
    arg = varargin{1};
end;
clear = 0;
if(nargin == 2)
    clear = varargin{2};
end;

hfile=findobj('Tag','QueMessage');
if(isempty(hfile)) % just display the message on the output and return
    fprintf(2, '%s\n', arg)
    return;
end;

set(hfile, 'Max', 2);
set(hfile, 'Min', 0); % make it a multiline edit box
s = get(hfile, 'String');
if(clear)
    set(hfile, 'String', '');
end;
set(hfile, 'String', cellstr(strvcat(char(get(hfile, 'String')), (arg))));
u=length(get(hfile, 'String'));
if(u(1) > 0)
    set(hfile, 'Value', u(1)); % "select" the most recent line (forces scrolling)
end
return

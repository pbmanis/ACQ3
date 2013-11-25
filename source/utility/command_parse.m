function command_parse()
% command_parse  -  parse and try to execute the commands via feval
%
% 8/3/2000  Use this as a callback function from a command window.
%   It expects the input to come from 'InputBox'
% the commands are parsed against the list in CMDS, which is usually
% the locally available m files (they need to be on the path)
%
global SCOPE_FLAG  IN_ACQ CMDS

QueMessage(' ', 1); % clear the message que
h = findobj('Tag', 'InputBox'); % we accept commands only from the main input box
if(isempty(h))
    fprintf(2, 'command_parse: no InputBox?\n');
    return;
end;

% check to see if we are in scope mode - if so, stop the scope mode, execute commands,
% and return to it later
inscope = 0;
if(IN_ACQ || SCOPE_FLAG)
    inscope = 1; % set a local flag
    acq_stop; % use the standard stop routine
end;

set(h, 'UserData', 0);
set(h, 'Interruptible', 'on'); % Allow interupptions. This is the only way we can "stop" in a routine.
set(h, 'BusyAction', 'queue'); % force everything to que behind us.

cmd = get(h, 'String'); % read the command line
cmd = strtrim(cmd); % remove leading and trailing spaces

if(isempty(cmd)) % be sure it has something
    clear_input(inscope);
    return;
end;
if(cmd(1) == '>')
    cmd = cmd(2:end);
end;

if(isempty(cmd))
    clear_input(inscope);
    return;
end;

% try to match the first part of the commands against the current list.
[first, rest] = strtok(cmd, ' '); % get the first command argument

if(any(strcmp(first, {'quit', 'exit'}))) % block commands that might cause matlab to quit
    cmd = 'bye'; % replace with our own routine
    first = 'bye';
end;
lasterr = '';
c = strcmp(first, CMDS); % first search for those that are exact
%fprintf('first: <%s>,  c: %d', first, c);
%fprintf('\n');
if(~any((c))) % no exact matches? then try for inexact matches
    c = strcmpi(first, CMDS);
    if(~any(c)) % not even inexact - then try internal commands
      %  try
            cmd_struct(cmd); % try to operate on the internal commands
      %  catch ME %#ok<NASGU>
      %      QueMessage(sprintf('command_parse: Internal command %s failed (cmd_struct)', cmd));
      %      QueMessage(sprintf('Error: %s',lasterr));
      %  end;
        clear_input(inscope); % whether it passes or fails, we are done
        return;
    else
        if(length(c) > 1) % the command is ambiguous -
            QueMessage(sprintf('Command %s is ambiguous', cmd),1);
            QueMessage(sprintf('Error: %s',lasterr));
            clear_input(inscope);
            return;
        else % length of c is 1 - good for the command, but it is not exact, so reconstruct exact command
            cmd = [CMDS{c} ' ' rest];
        end;
    end; % c is not empty, and its length is 1
end; % c is not empty and the match was exact

try
    eval(cmd); % run the command
catch ME %#ok<NASGU>
    QueMessage(sprintf('m-file Command %s failed', cmd));
    %   QueMessage(sprintf('Error: %s',lasterr));
end;
clear_input(inscope);
return;

function clear_input(inscope) %#ok<INUSD>
% clear the input box and make sure restart flag is set if we are in scope mode.

h = findobj('Tag', 'InputBox'); % we accept commands only from the main input box
if(isempty(h)) % we don't restart if there is an error here
    return;
end;
set(h, 'String', ''); % remove the command line
uicontrol(h); % set focus to our input again
return;

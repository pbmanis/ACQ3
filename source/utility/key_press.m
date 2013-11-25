function key_press()
% key_press: function reached by callback from main ACQ screen
% this function processes keystrokes in the buffer, displays them in the
% input text box, and when <cr> is sent, sends the result to the
% command parser.
% Also provides support for command history
% 
% 
global IN_ACQ
persistent HISTORY hist_p

if(IN_ACQ == 1)
   h = findobj('Tag', 'InputBox'); % we accept commands only from the main input box
   if(~isempty(h)) % we don't restart if there is an error here
      set(h, 'String', ' '); % remove the command line
   end;
      acq_stop;
   % previous command is probably still up
end;


if(~exist('HISTORY'))
   HISTORY=[];
end;
if(~exist('hist_p'))
   hist_p = 0;
end;

IN_ACQ = 0; % this cannot occur when we are truly acquiring, so to be safe we reset the flag

h = findobj('Tag', 'Acq');
c = get(h, 'CurrentCharacter');
if(isempty(c))
    c = ' ';
end;
hi = findobj('Tag', 'InputBox');
%fprintf('c = %d\n', c);
if(isempty(hi))
   return;
end;
cmd = get(hi, 'String');

cm=double(c);
%fprintf(2, 'c: %s, cm: %f\n',c, cm);
switch(cm) % operate on the character
   
case 4 % control-d moves forward in the history
   %  fprintf('ctl-d\n');
   hist_p = hist_p + 1;
   if(hist_p <= size(HISTORY, 1))
   else
      hist_p = size(HISTORY, 1);
   end;
   cmd = HISTORY(hist_p,:);
   
case 21 % control-u moves backwards in the history
   % fprintf('ctl-u\n');
   hist_p = hist_p - 1;
   if(hist_p > 0)
      cmd = HISTORY(hist_p,:);
   else
      hist_p = 1;
      cmd = HISTORY(hist_p, :);
   end;
   
case 13 % carriage return - try to execute the command.
   %   fprintf('<cr>\n');
   cmd = fliplr(deblank(fliplr(deblank(cmd)))); % remove leading and trailing spaces
   if(length(cmd) == 0)
      cmd = [];
      return;
   end;
   if(cmd(1) == '>') cmd = cmd(2:end); end;
   command_parse;
   if(size(HISTORY, 1) >= 50)
      HISTORY = HISTORY(2:end,:); % make room for next command
   end;
   HISTORY=strvcat(HISTORY, cmd); % add the putative command to the history list even if it is wrong
   hist_p = size(HISTORY, 1);
   scope('continue'); % check scope mode and continue running
   return;
   
case 8  % backspace key deletes previous character
   %  fprintf('<bs>\n');
   if(length(cmd) > 1)
      cmd = cmd(1:end-1); % remove last character
   else
      cmd='';
   end;
   
case 27 % escape key - clear command string
   %   fprintf('<esc>\n');
   cmd = '';
   
case 127 % delete key - same as backspace for now (no editing cursor)
   %  fprintf('<del>\n');
   if(length(cmd) > 1)
      cmd = cmd(1:end-1); % remove last character
   else
      cmd='';
   end;
   
otherwise
   if(cm > 31 & cm < 127)
      cmd = [cmd c];
   else
      %	fprintf(' %d ', c);
   end;
end;
set(hi, 'String', cmd);
return;

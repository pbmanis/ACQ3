function key_in()
% key_in: grab keyboard input from the command window
return;
h = findobj('Tag', 'Acq'); % restore the keypress function so we get commands back
if(~isempty(h))
   set(h, 'KeyPressFcn', 'key_press');
   h = findobj('Tag', 'Acq');
   c = get(h, 'CurrentCharacter');
   hi = findobj('Tag', 'InputBox');
   if(isempty(hi))
      return;
   end;
   cmd = get(hi, 'String');
   %set(hi, 'String', [cmd c]);
   disp(str2num(c))
   if(c == '\r' | c == '\n')
      command_parse;
   end
   
end;
return;

function update_macros()

global CONFIG
macdir = slash4OS(CONFIG.MacroPath.v);
hfig = findobj('Tag', 'MacroMain');
if(isempty(hfig))
    return; % probably didn't build the main window just yet...
end;
% delete any 'protocol_' tagged references
h = findobj;
v = get(h, 'Tag');
p = strmatch('macro_', v); % find all protocols.
if(~isempty(p))
   delete(h(p)); % remove them...
end;
% find the protocols in the directory
if(exist(macdir, 'dir') == 7)
   allmacro = dir(slash4OS([macdir '\*.m']));
else
   QueMessage(sprintf('Update_macros: invalid macro path'), 1);
   QueMessage(sprintf('>> %s', macdir));
   return;
end;
QueMessage(sprintf('Found %d macros', length(allmacro)), 1);
pnc = {allmacro.name};
pn = sort(pnc); % sort alphabetically
for i = 1:length(allmacro)
   if(i == 1)
      sep = 'On';
   else
      sep = 'Off';
   end;
   [p cb] = fileparts(pn{i});
   %cb = ['Macros\' cb];
   uimenu(hfig, 'Label', pn{i}, 'Callback', sprintf('do_macro(''%s'');', cb), 'Tag', sprintf('macro_%d', i), ...
      'Separator', sep); % get the protocol if selected...
end;   

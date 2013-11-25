function update_protocols()

global CONFIG

hfig = findobj('Tag', 'ProtocolMain');
if(isempty(hfig))
    return; % probably did not build the main window yet...
end;
% delete any 'protocol_' tagged references
h = findobj;
v = get(h, 'Tag');
p = strmatch('protocol_', v); % find all protocols.
if(~isempty(p))
   delete(h(p)); % remove them...
end;
% delete any 'protodir__' tagged references
h = findobj;
v = get(h, 'Tag');
p = strmatch('protodir_', v); % find all protocols directories
if(~isempty(p))
   delete(h(p)); % remove them...
end;

% create the full directory path name
fullstmpath = slash4OS(append_backslash([append_backslash(CONFIG.BasePath.v) CONFIG.StmPath.v]));
% find the protocols in the directory

if(exist(fullstmpath, 'dir') == 7)
   allproto = dir([fullstmpath '*.mat']);
else
   QueMessage(sprintf('update_protocols: Configuration StimPath %s invalid', fullstmpath), 1);
   return;
end;
if(exist(fullstmpath, 'dir') == 7)
   alldirs = dir([fullstmpath '*.*']);
else
   QueMessage(sprintf('update_protocols: Configuration StimPath %s invalid', fullstmpath), 1);
   return;
end;
% j_alldir = find([alldirs.isdir] == 1);
% alldirs = alldirs(j_alldir); %#ok<FNDSB>
QueMessage(sprintf('Found %d protocols', length(allproto)), 1);


pnc = {allproto.name};
pn = sort(pnc); % sort alphabetically
for i = 1:length(allproto)
   if(i == 1)
      sep = 'On';
   else
      sep = 'Off';
   end;
   uimenu(hfig, 'Label', pn{i}, 'Callback', ['g ' pn{i}], 'Tag', sprintf('protocol_%d', i), ...
      'Separator', sep); % get the protocol if selected...
end;   

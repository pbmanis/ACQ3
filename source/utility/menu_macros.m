function menu_macros(hfig)
% menu_protocols: get the "macro" files from the directory and build a menu
% list with them.

global CONFIG

%
% delete the current menu items
%
%uimenu(hfig, 'Label', 'Open Macro', 'Callback', 'm;');
%uimenu(hfig, 'Label', 'Change Directory', 'Callback', 'change_macro_dir;');
uimenu(hfig, 'Label', 'Update Macro List', 'Callback', 'update_macros;');
update_macros;


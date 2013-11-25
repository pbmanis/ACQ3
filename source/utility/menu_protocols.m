function menu_protocols(hfig)
% menu_protocols: get the stim protocol files from the directory and build a menu
% list with them.


uimenu(hfig, 'Label', 'Open Protocol', 'Callback', 'g;');
uimenu(hfig, 'Label', 'Save Protocol', 'Callback', 's;');
uimenu(hfig, 'Label', 'Change Directory', 'Callback', 'change_protocol_dir;');
uimenu(hfig, 'Label', 'Update Protocol List', 'Callback', 'update_protocols;', 'Separator', 'On');

update_protocols;


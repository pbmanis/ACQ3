function do_macro(mac)
%
global BASEPATH
global CONFIG IN_MACRO
if(IN_MACRO)
    QueMessage('Macro Already Running');
    return;
end;
macrodir = slash4OS([BASEPATH CONFIG.MacroPath.v]);
olddir = cd(macrodir);
try
    feval(mac)
catch
    cd(olddir); % always return to original directory
    QueMessage(sprintf('Macro %s failed?', mac), 1);
    IN_MACRO = 0;
end;
return;


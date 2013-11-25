function show_configuration()
%
% Provide configuration information in static text window
global CONFIG

h = findobj('tag', 'ConfigInfo');
if(~isempty(h))
    s{1} = sprintf('Config: %s     Owner: %s  UserExt: %s', ...
        CONFIG.title, CONFIG.Owner.v, CONFIG.UserExt.v);
    s{2} = sprintf('Base Path: %s', CONFIG.BasePath.v);
    s{3} = sprintf('Stim Path: %-18s  Acqpath:   %-18s', CONFIG.StmPath.v, CONFIG.AcqPath.v);
    s{4} = sprintf('Macro Path:%-18s  Data Path: %-18s', CONFIG.MacroPath.v, CONFIG.DataPath.v);
    s{7} = sprintf('Comment: %s', CONFIG.Comment);
    [ostr] = textwrap(h, s);
    set(h, 'string', ostr);
    set(h, 'fontname', 'fixedwidth');
    set(h, 'fontweight', 'bold');
    set(h, 'foregroundcolor', [1 1 1]);
    set(h, 'backgroundcolor', [.1 .1 .1]);
end;


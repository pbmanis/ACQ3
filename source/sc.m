function sc(sfilename)
% sc: save the current Configuration parameters to disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     sc <cr> saves the current configuration, using the file dialog box
%     sc filename saves the current configuration to the specified file

% 8/15/2000
% Paul B. Manis   pmanis@med.unc.edu
%
% call s filename; if just called with s, then will use uiputfile
% to prompt for a filename
% NOTE: if filename is not same as Config.Name, then Config.Name will be set to the filename...
% else if there is no filename, we will suggest using Config.Name...
%

global CONFIG FILEFORMAT
if(isempty(CONFIG))
    QueMessage('Empty Configuration - no save');
    return
end


internal = CONFIG.Config.v;
if(nargin == 0)
    sug = sprintf('%s.cfg', internal);
    [stimname, stimpath] = uiputfile(sug,'Save Config File') ;
    if(stimname == 0)
        return;
    end;
    sfilename = fullfile(stimpath, stimname);
end

[p, sfn, e] = fileparts(sfilename);
if(~strcmp(internal, sfn))
    answer = questdlg('Filename and internal name do not match\nChange internal name to match filename and save?', 'Save Configuration File');
    if(strcmp(answer, 'Yes'))
        CONFIG.Config.v = sfn;
        struct_edit('Redisplay', CONFIG);
    else
        QueMessage('Config structure NOT saved', 1);
        return;
    end;
end;

if(isempty(FILEFORMAT))
    FILEFORMAT = '-mat'; % default version 6 file format
end;

save(sfilename, 'CONFIG', FILEFORMAT);
QueMessage(sprintf('Config Params save in %s', sfilename), 1);
return;

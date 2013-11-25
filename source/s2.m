function s2(sfilename)
% s: Save the current stimulus parameters (in STIM2) to disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     s <cr> opens a dialog box for saving the stim parameters
%     s filename attempts to save the stim parameters in the file filename

% 7/10/2000
% Paul B. Manis   pmanis@med.unc.edu
%
% call s filename; if just called with s, then will use uiputfile
% to prompt for a filename
% NOTE: if filename is not same as stim.name, then stim.name will be set to the filename...
% else if there is no filename, we will suggest using stim.name...
%

global STIM2 CONFIG FILEFORMAT

basepath = slash4OS(CONFIG.BasePath.v);
cd(basepath)
stimpath = slash4OS(CONFIG.StmPath.v);
if(exist(stimpath, 'dir') == 7)
    wd = cd(stimpath);
else
    QueMessage(sprintf('s: Configuration StmPath %s invalid', stimpath),1);
    return;
end;

% require properly calculated waveforms before a save.
if(STIM2.update == 0)
    pv('-f');
%    QueMessage('Stim protocol needs update- no save', 1);
%    cd(basepath);
%    return;
end;

STIM = STIM2;
internal = STIM.Name.v;
if(nargin == 0)
    sug = sprintf('%s.mat', internal);
    [stimname, stimpath] = uiputfile(sug,'Save Stimulus(2) File');
    if(stimname == 0)
        cd(basepath);
        return;
    end;
    sfilename=fullfile(stimpath, stimname);
end
auto_overwrite = 0;
if nargin == 1
    if strcmp(sfilename, '-f')
        auto_overwrite = 1;
        sfilename = STIM.Name.v; % get the name from the protocol.
    end
end;
[p, sfn, e] = fileparts(sfilename);


if(~strcmp(internal, sfn))
    answer = questdlg(sprintf('Filename (%s) and internal (%s) name do not match.\n Change internal name to match filename and save?', sfn, internal), 'Save Acq Param File');
    if(strcmp(answer, 'Yes'))
        STIM.Name.v = sfn;
        struct_edit('edit', STIM);
    else
        QueMessage('Stim structure NOT saved', 1);
        cd(basepath);
        return;
    end;
end;
if auto_overwrite == 0
    delete(sfilename);
end;

if(~isempty(FILEFORMAT))
    save(sfilename, 'STIM', FILEFORMAT);
else
    save(sfilename, 'STIM');
end;
QueMessage(sprintf('Stim2 Params saved in %s', sfilename), 1);
cd(basepath);
return;

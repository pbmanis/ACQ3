function s(varargin)
% s: Save the current stimulus parameters to disk
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

global CONFIG ONLINE DFILE FILEFORMAT DISPCTL STIM%#ok<NUSED>

basepath = slash4OS(CONFIG.BasePath.v);
cd(basepath)
stimpath = slash4OS(CONFIG.StmPath.v);
if(exist(stimpath, 'dir') == 7)
    wd = cd(stimpath);
else
    QueMessage(sprintf('s: Configuration StmPath %s invalid', stimpath),1);
    return;
end;

if(nargin == 0 || ~isstruct(varargin{1}))
    if(nargin ~= 0)
        sfilename = varargin{1};
    end;
else
    STIM = varargin{1}; % do this without overwriting
    sfilename = STIM.Name.v; % use the built-in name
end;

if(isempty(STIM))
    QueMessage('Empty Protocol - no save', 1);
    cd(basepath);
    return
end
if(STIM.update == 0)
    QueMessage('Stim protocol needs update- no save', 1);
    cd(basepath);
    return;
end;

% struct_edit('update'); % synchronize window with master version
% fprintf('pv: nwave: %d, wv(1): %f\n', length(STIM.waveform), STIM.waveform{1}.v(1));

internal = STIM.Name.v;
if(nargin == 0)
    sug = sprintf('%s.mat', internal);
    [stimname, stimpath] = uiputfile(sug,'Save Stimulus File');
    if(stimname == 0)
        cd(basepath);
        QueMessage('Protocol - has no stim name - no save');
        return;
    end;
    sfilename=fullfile(stimpath, stimname);
end
[p, sfn] = fileparts(sfilename);

if(~strcmp(internal, sfn))
    quest = questdlg(sprintf('Filename (%s) and internal (%s) name do not match.\n Change internal name to match filename and save?', sfn, internal), 'Save Acq Param File');
    if(strcmp(quest, 'Yes'))
        STIM.Name.v = sfn;
        struct_edit('edit', STIM);
    else
        QueMessage('Stim structure NOT saved', 1);
        cd(basepath);
        return;
    end;
end;

% DFILE.Filename.v = []; % empty the filename, since it is not relevant anymore

if(~isempty(FILEFORMAT))
    save(sfilename, 'STIM', FILEFORMAT);
    save(sfilename, 'ONLINE', '-append', FILEFORMAT);
    save(sfilename, 'DISPCTL', '-append', FILEFORMAT);
else
    save(sfilename, 'STIM');
    save(sfilename, 'ONLINE', '-append');
    save(sfilename, 'DISPCTL', '-append');
end;

if(isempty(deblank(STIM.AcqFile.v)))
    DFILE.Filename.v = []; % empty the filename, since it is not relevant anymore
    save (sfilename, 'DFILE', '-append'); % save the current acq file in the stim file when no acq file is specified
    QueMessage(sprintf('Stim and Acq Params saved in %s', sfilename), 1);
else
    QueMessage(sprintf('Stim Params saved in %s', sfilename), 1);
end;
cd(basepath);
return;
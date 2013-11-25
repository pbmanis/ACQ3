function stim_save(varargin)
% s: Save the current stimulus parameters to disk
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

global CONFIG ONLINE DFILE

cd(CONFIG.BasePath.v);
if(exist(CONFIG.StmPath.v) == 7)
   wd = cd(CONFIG.StmPath.v);
else
   QueMessage(sprintf('s: Configuration StmPath %s invalid', CONFIG.StmPath.v),1);
   return;
end;

if(nargin == 0 | ~isstruct(varargin{1}))
   global STIM;
   if(nargin ~= 0)
      sfilename = varargin{1};
   end;
else
   STIM = varargin{1}; % do this without overwriting
   sfilename = STIM.Name.v; % use the built-in name
end;

if(isempty(STIM))
   QueMessage('Empty Protocol - no save');
   cd(CONFIG.BasePath.v);
   return
end

% struct_edit('update'); % synchronize window with master version
%fprintf('pv: nwave: %d, wv(1): %f\n', length(STIM.waveform), STIM.waveform{1}.v(1));

internal = STIM.Name.v;
if(nargin == 0)
   sug = sprintf('%s.mat', internal);
   [stimname, stimpath] = uiputfile(sug,'Save Stimulus File');    
   if(stimname == 0)
		cd(CONFIG.BasePath.v);
      return;
   end;
   sfilename=fullfile(stimpath, stimname);
end
[p, sfn, e] = fileparts(sfilename);

if(~strcmp(internal, sfn))
   ans = questdlg(sprintf('Filename (%s) and internal (%s) name do not match.\n Change internal name to match filename and save?', sfn, internal), 'Save Acq Param File');
   if(strcmp(ans, 'Yes'))
      STIM.Name.v = sfn;
      struct_edit('edit', STIM);
   else
      QueMessage('Stim structure NOT saved', 1);
		cd(CONFIG.BasePath.v);
      return;
   end;
end;

save(sfilename, 'STIM');
save(sfilename, 'ONLINE', '-append');
if(isempty(deblank(STIM.AcqFile.v)))
   DFILE.Filename.v = []; % empty the filename, since it is not relevant
   save (sfilename, 'DFILE', '-append'); % save the current acq file in the stim file when no acq file is specified
   QueMessage(sprintf('Stim and Acq Params saved in %s', sfilename), 1);
else
   QueMessage(sprintf('Stim Params saved in %s', sfilename), 1);
end;
cd(CONFIG.BasePath.v);
return;

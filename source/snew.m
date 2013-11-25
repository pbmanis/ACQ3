function s(varargin)
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
% Modified 7/16/2007. Uses "new" STIM structure STIMN, which is a cell
% array that holds multiple STIM structures. 
% the first one also holds the Stimulus name 

global CONFIG ONLINE DFILE FILEFORMAT DISPCTL %#ok<NUSED>
global STIMN STIM

cd(CONFIG.BasePath.v); % make sure we are in the base path first
if(exist(CONFIG.StmPath.v, 'directory') == 7) % is the stim path file there?
   wd = cd(CONFIG.StmPath.v);
else
   QueMessage(sprintf('s: Configuration StmPath %s invalid', CONFIG.StmPath.v),1);
   return;
end;

if(nargin == 0 || ~isstruct(varargin{1})) 
   if(nargin ~= 0)
      sfilename = varargin{1}; % get the file name
   end;
else
   STIMN = varargin{1}; % do this without overwriting the STIM file
   sfilename = STIMN{1}.Name.v; % use the built-in name from the file
end;

if(isempty(STIMN))
    STIMN{1} = STIM; % copy over existing STIM protocol? 
    QueMessage('Empty Protocol - no save', 1);
   cd(CONFIG.BasePath.v);
   return
end
if(STIMN{1}.update == 0)
   QueMessage('Stim protocol needs update- no save', 1);
   cd(CONFIG.BasePath.v);
    return;
end;

% struct_edit('update'); % synchronize window with master version
%fprintf('pv: nwave: %d, wv(1): %f\n', length(STIM.waveform), STIM.waveform{1}.v(1));

internal = STIMN{1}.Name.v;
if(nargin == 0)
   sug = sprintf('%s.mat', internal);
   [stimname, stimpath] = uiputfile(sug,'Save Stimulus File');    
   if(stimname == 0)
		cd(CONFIG.BasePath.v);
         QueMessage('Protocol - has no stim name - no save');
return;
   end;
   sfilename=fullfile(stimpath, stimname);
end
[p, sfn] = fileparts(sfilename);

if(~strcmp(internal, sfn))
   answer = questdlg(sprintf('Filename (%s) and internal (%s) name do not match.\n Change internal name to match filename and save?', sfn, internal), 'Save Acq Param File');
   if(strcmp(answer, 'Yes'))
      STIMN{1}.Name.v = sfn;
      struct_edit('edit', STIMN{1});
   else
      QueMessage('Stim structure NOT saved', 1);
		cd(CONFIG.BasePath.v);
      return;
   end;
end;

 DFILE.Filename.v = []; % empty the filename, since it is not relevant anymore

if(~isempty(FILEFORMAT))
    save(sfilename, 'STIMN', FILEFORMAT);
    save(sfilename, 'ONLINE', '-append', FILEFORMAT);
    save(sfilename, 'DISPCTL', '-append', FILEFORMAT);
else
    save(sfilename, 'STIMN');
    save(sfilename, 'ONLINE', '-append');
    save(sfilename, 'DISPCTL', '-append');
end;

if(isempty(deblank(STIMN{1}.AcqFile.v)))
   DFILE.Filename.v = []; % empty the filename, since it is not relevant anymore
   save (sfilename, 'DFILE', '-append'); % save the current acq file in the stim file when no acq file is specified
   QueMessage(sprintf('Stim and Acq Params saved in %s', sfilename), 1);
else
   QueMessage(sprintf('Stim Params saved in %s', sfilename), 1);
end;
cd(CONFIG.BasePath.v);
return;

function change_protocol_dir(arg)
% change the directory where stimulus protocols are expected to be found.
% we change the directory and store result in the configuration.
%
% uses uigetfolder from matlab web site (path is in pbm_tools...).
% 6/4/01. P. Manis (updated).

global CONFIG

%if(nargin == 0)
   arg = uigetfolder('Select Stimulus Directory', [append_backslash(CONFIG.BasePath.v) CONFIG.StmPath.v]); % start in the current folder
%end;
fprintf(1, 'folder: %s\n', arg);

if(~isempty(arg) & exist(arg) == 7) % make sure it exists and that it is a directory
   % make the protocol directory contain only the path portion beyond basepath.
   j = findstr(lower(CONFIG.BasePath.v), lower(arg));
   if(j > 0)
      CONFIG.StmPath.v = arg(length(CONFIG.BasePath.v)+2:end);
		update_protocols;
   ;
   end;
end;
e config;




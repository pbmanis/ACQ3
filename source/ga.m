function [err] = ga(acqfile)
% ga: get acquisition protocol file from disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     ga [filename] gets the selected acquisition file from disk.
%     If no filename is specified, a browser window is provided to select a file.

%
% 7/10/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% if acqfile is defined, it is the file name we try to get
% otherwise, we open a uigetfile window to search for the file
%
global DFILE CONFIG
err = 0;
if(exist(CONFIG.AcqPath.v, 'dir') == 7)
   wd = cd(CONFIG.AcqPath.v);
else
   QueMessage(sprintf('ga: Configuration AcqPath %s is invalid', CONFIG.AcqPath.v), 1);
   err = 1;
   return;
end;
if(nargin == 0)
   [acqname, acqpath] = uigetfile('*.mat','Retrieve Acquisition File');    
   if(acqname == 0)
      err = 1;
      cd(wd);
      return;
   end;
   acqfile=fullfile(acqpath, acqname);
end;

[path file ext] = fileparts(acqfile); % if filename still missing extension, add the default
if(isempty(ext))
   acqfile = [acqfile '.mat'];
end;
fid = fopen(acqfile, 'r');
if(fid == -1)
   QueMessage(sprintf('ga.m: File %s not found? ', acqfile), 1);
   err = 1;
   cd(wd);
   return;
end;
fclose(fid);
a = load(acqfile);
cd(wd);
if(isempty(a)) 
   fprintf('ga.m: No data in file: %s\n', acqfile);
   err = 1;
   return;
end;
df=a.DFILE;
if(chkfile(df))
      return;
   end;

DFILE = df; % get it back

struct_edit('load', DFILE);

QueMessage(sprintf('Acquisition Params Restored from %s', acqfile), 1);
return;
   

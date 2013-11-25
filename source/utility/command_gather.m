function command_gather(directory)
% command_gather: gather from the directory all m-files as potential commands
% function to gather valid commands as the m-files from a particular directory
% Basically, we identify all the 'm' files in the directory
% and return them as a cell array for later comparisons.
%
% 17 October 2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global CMDS BASEPATH

if(nargin == 0)
   directory = slash4OS([BASEPATH 'source']);
end;
directory = append_backslash(directory);
fprintf(1, 'dir: %s\n', directory);
cmds = dir([directory '*.m']); % find all the m-files in the source directory
% for each m-file, check whether the THIRD line starts with % ***CMD***
%
cmdl = cell(10,1); % just a small list for starters. We don't do this often
k = 1;
for i = 1:length(cmds) % strip the extensions from the files to use as command names
    [p f] = fileparts(cmds(i).name);
    if(f(1) ~= '.' && exist([f '.m'], 'file'))
        hc = fopen([f '.m'], 'r');
        if(~isempty(hc))
            fgetl(hc);
            fgetl(hc);
            fline = fgetl(hc);
            if(strmatch(fline, '% ***CMD***', 'exact'))
                cmdl{k} = f;
                k = k + 1;
            end;
            fclose(hc);
        end;
    end;
end;
CMDS = cmdl;
QueMessage(sprintf('%d Commands found', length(CMDS)), 1);
return;



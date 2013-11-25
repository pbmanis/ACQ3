function acq_paths()
%
% set paths as necessary for acq to run. 
% also remove paths that are normally unnecessary (plotgen, figures).
% THis version for new acq - just sets paths, but these should be set before.
%
[bp f e] = fileparts(which('acq3'));
%bp2 = 'c:\mat_datac\';
p = path;
%removepath(bp2, 'c:\Acq\');
%removepath(bp2, 'plotgen');
%removepath(bp2, 'Figures');
%removepath(bp2, 'MiscUtilities');
removepath(bp, '\source');
removepath(bp, '\source\utility');

%addpath([bp '\source']);
try
    addpath(slash4OS([bp, '\utility']));
catch
    fprintf(1, 'Can''t add path to utility directory\n');
    exit(1);
end;

addpath(bp); % do this last so it appears first in the list



function removepath(base, pbye)
% from the base path, remove pbye, if it exists.....

if(findstr(lower([base '\' pbye]), lower(path)))
try % embed in try-catch so that we don't have to listen to warning messages.
    rmpath(slash4OS([base '\' pbye]));
catch
end;
end;
return;


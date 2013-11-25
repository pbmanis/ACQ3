function newdir=uicd()
% UICD gets a directory path under GUI control. Returns new current dir
% unless change was cancelled, in which case, nothing happens
% and newdir is null. 
%

newdir = [];
[f, p]=uiputfile('Save to select current dir','Directory Changer');
if p
   olddir = cd(p);
   newdir = p;
   cd(olddir);
end


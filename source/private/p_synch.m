function p_synch()
%
% p_synch synchronizes the p files with the latest m files in a directory
% by making sure pcode is run on any either not existing, or with dates later
% than the p file.
% 9/3/2000 Paul B. Manis
%
 
% 1. get the m and p files.
original = pwd;
cd('source');
files = what;
p={};
m={};
for i = 1:length(files.m)
   m{i} = dir(files.m{i});
end;
for i = 1:length(files.p)
   p{i} = dir(files.p{i});
end;

pc=[];
if(~isempty(p))
   for i = 1:length(p)
      pc=strvcat(pc, char(p{i}.name));
   end;
end;

for i = 1:length(m)
   if(~strcmp(m{i}.name, 'p_synch.m')) % only do this for other files, not us.
   if(isempty(pc))
      pcode(m{i}.name); % no p files to check
   else
      j = strmatch(m{i}.name, pc); % file does not have a pcode match
      if(isempty(j) | j == 0)
         pcode(m{i}.name);
      elseif(datenum(m{i}.date) > datenum(p{j}.date)) % both files exist, check date
         pcode(m{i}.name); % m file was later than the local p file.
      end;
   end;
end;
end;
copyfile('*.p', [original '\pcode\*.p']);
delete('*.p');
cd(original);
return;
   
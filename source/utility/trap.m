function trap(n)
% trap when number of 'name' objects > 1
% prints n when trapped

if(length(findobj('Tag', 'Name')) > 1)
   fprintf(2, 'Trap (Name): %d\n', n);
end;

if(length(findobj('Tag', 'File')) > 1)
   fprintf(2, 'Trap (File): %d\n', n);
end;

if(length(findobj('Tag', 'Config')) > 1)
   fprintf(2, 'Trap (Config): %d\n', n);
end;

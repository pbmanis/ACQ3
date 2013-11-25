function cmds()
% cmds: Prints the list of commands available and their help information
% Usage
%     Called with no arguments


global CMDS
[c, u] = sort(CMDS);

for i = 1:length(c)
   x = help(c{i});
   fprintf(1, '%3d: %s\n', i, x);
end;
return;

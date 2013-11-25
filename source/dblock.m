function dblock(filename)
% db: display valid data blocks in the file (use lif instead)
% Usage
%     Call with a filename to list the valid blocks in the currently open file
%     Note: does not work if file does not have an index entry yet (use lif instead)

%
% 8/11/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global ACQ_FILENAME

if(isempty(ACQ_FILENAME))
   if(nargin < 1)
      fprintf(2, 'db: expecting 1 argument: db filename\n');
      return;
   end;

else
 	if(nargin == 0)
      filename = ACQ_FILENAME;
   end;
end;
u=load('INDEX');
Index = u.INDEX;
vs = [Index.record];
l = strmatch('DATA', [char(Index.type)]);
if(isempty(l))
   fprintf(2, 'db:  No valid data blocks found\n');
   return;
end;
fprintf(1, 'Data Blocks in file %s\n', filename);
for i = 1:length(l)
   fprintf(1, '%d ', vs(l(i)));
end;
fprintf('\n');

return;

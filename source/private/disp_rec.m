function disp_rec()
%
% disp_rec  -  helper to display record number and block number
% to text regions of display 
% Last change: 9/19/2000
% Paul B. Manis
%
global FILE_STATUS

h = findobj('Tag', 'Recn');
if(isempty(h))
   fprintf(2, 'disp_rec: Unable to display record number');
   return;
end;
set(h, 'String', sprintf('%20d', FILE_STATUS.Record));
h = findobj('Tag', 'Blockn');
if(isempty(h))
   fprintf(2, 'disp_rec: Unable to display Block number');
   return;
end;
set(h, 'String', sprintf('%20d', FILE_STATUS.Block));

return;

function fix_file(filename, block_no)
% fix_file.m - fix a file where the temp files were not added from the last acquisition.
% Allows fixup by taking the temp files and adding them as the final block to
% a data file that is already closed (you must close the file before doing this).
% This is a hack for a bug in the acquisition program that occured in mid-dec 2000.
% The temp files are not deleted in case we need to fix th=e index again.
% 6 Jan 2000. Paul B. Manis, Ph.D.
%

%
% gather all the independent files of name tmp_file*
% and store them under the block db####{:}as .data and .events...
% this will work whether we make temp files ourselves, or let
% the data acquisition toolbox do disk streaming
% 10/17/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% Modified version here to fixup data files after incorrect writing.

% find the sf block in the file - it better be there.
sfb = sprintf('sf%d', block_no);
load(filename, sfb);
if(~exist(sfb))
   fprintf(1, 'Block %d not found in file?\n', block_no);
   return;
end;


% find and gather into one array the temp files
x=dir(sprintf('%s_t_*', filename)); % find the temporary files generated
block_id = sprintf('db_%d', block_no);
RL=[];
if(~isempty(x))
   fprintf(1, 'Gathering files\n');
   % sort the temp file records in ascending order - there is no guarantee that they will
   % be in any particular order, especially after transfering files to another system.
   % this ensures that we put the data in the file in the order it would be if it were
   % collected
   [v, w] = sort({x.name});
   for i = 1:length(x)
      j = w(i);
      if(x(j).isdir == 0)
         eval([block_id '{i} = load(x(j).name);']);
         RL(i)=str2num(x(j).name(end-7:end-4)); % pull record number out.
      end;
   end;
end;

% if successful, save the temp files to the main file
if(~isempty(block_id))
   fprintf(1, 'Appending data block %s to file\n', block_id);
   save(filename, block_id, '-append'); % build data file
   
   % then update the index by appending the data block information
   Index = load(filename, 'Index');
   Index = Index.Index;
   s=length(Index)
   s = s + 1; % position to next entry
   t = now; % get serial date/time number
   Index(s).date = datestr(t,1);
   Index(s).time = datestr(t,13);
   Index(s).block = block_no;
   Index(s).record = max(RL);
   Index(s).type = 'DATA';
   Index(s).type2 = eval([sfb '.Name.v']);
   Index(s).MatName = block_id;
   
   fprintf(1, 'Updating index\n');
   save(filename, 'Index', '-append');
end;
return;

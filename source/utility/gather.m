function gather(filename, tmp_file, filewrite, local_sf)
%
% function to gather all the independent files of name tmp_file*
% and store them under the block db####{:}as .data and .events...
% this will work whether we make temp files ourselves, or let
% the data acquisition toolbox do disk streaming
% 10/17/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

global FILE_STATUS SCOPE_FLAG FILEFORMAT
% gather the files and store a new block
if (SCOPE_FLAG > 0 || ~filewrite) % be sure we need to write before doing this
   return;
end;

x=dir(sprintf('%s*', tmp_file)); % find the files generated
block_id = sprintf('db_%d', FILE_STATUS.Block);
if(~isempty(x))
   for i = 1:length(x)
      if(x(i).isdir == 0)
         eval([block_id '{i} = load(x(i).name);']);
      end;
   end;
end;
if(~isempty(block_id))
    if(~isempty(FILEFORMAT))
        save(filename, block_id, '-append', FILEFORMAT); % build data file
    else
        save(filename, block_id, '-append'); % build data file
    end;
    index_file('add', 'DATA', local_sf.Name.v, block_id); % add the information to the index file
    FILE_STATUS.Block = FILE_STATUS.Block + 1; % only increment the block after we gather data sets and some data is written
end;
return;

function create_index()
% create_index  -  from the contents of a file, create an index.
% note that created index is date/time stamp at the time it is added, not the
% time of the original data (although that could be done).
% this is not critical as the index date/time is not used for anything except display.
%
% 14 Jan 2001
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

% we must define the globals this way as we will use the existing routine
% index_file to write the index entries. It needs these globals for information.
% this means that create_index should not be run in a matlab session in which the
% acquisition program is running.....

global ACQ_FILENAME % this is null if there is no file in use; otherwise it holds the filename
global ACQ_PATH % default path to the data
global DFILE STIM FILE_STATUS

[fname, pname] = uigetfile('c:\mat_datac\acq\*.mat', 'File to index')
if(~ischar(fname))
   QueMessage(sprintf('Unable to access file? %s - %s', pname, fname));
   err = 1;
   return;
end

filename = [pname fname];

v = load(filename, 'Index'); % see if file has index
fn = fieldnames(v);
if(~isempty(fn)) % existing indices are not overwritten
   fprintf(2, 'create_index: The file %s appears to have a valid index\n', filename);
   return;
end;

fprintf(2, 'Creating a new index for file %s\n', filename);

FILE_STATUS.Block = 1;
FILE_STATUS.Record = 1;
FILE_STATUS.NoteCount = 1;
ACQ_FILENAME = fname;
ACQ_PATH = pname;

index_file( 'new', 'HFILE'); % start the new index

dbnum = whos('-file', filename, 'db_*');
blkn = [];
for i = 1: length(dbnum)
   blnk(i) = str2num(dbnum(i).name(4:end));
end;
blnk(length(dbnum) + 1) = max(blnk) + 1; % add one more to capture the last note if there is one

for i = 1: length(blnk)
   FILE_STATUS.Block = blnk(i);
   [sf, df, notes] = block_info(filename, blnk(i));
   
   MatName = ['db_' sprintf('%d', blnk(i))];
   v=load(filename, MatName); % load all the relevant data
   if(~isempty(fieldnames(v)))
      fn=fieldnames(v); % find out the names in the list
      d = strmatch('db_', fn); % search for data blocks
      d2 = eval(['v.' fn{d}]);
      drl = get_record_list(d2); % find the record numbers present in the block
      if(~isempty(sf))
         sfc = sprintf('sf%d', FILE_STATUS.Block);
         index_file('add', 'STIM', sf.Name.v, sfc);
      end;
      if(~isempty(df))
         dfc = sprintf('df%d', FILE_STATUS.Block);
         index_file('add', 'DFILE', df.Filename.v, dfc);
      end;
      FILE_STATUS.Record = max(drl)+1;
      index_file('add', 'DATA', sf.Name.v, MatName); 
   else
      fprintf(1, 'create_index.m: There appears to be no data for block %d\n', MatName);
   end;
   if(~isempty(notes))
      index_file('add', 'NOTE', '(note here)', 'Note');
   end;
   
   
end;

load('INDEX'); % get the index
[u, i] = sort([INDEX.record]); % sort by record number
INDEX = INDEX(i);
save('INDEX', 'INDEX');

index_file('close'); % causes index to be appended to the original file
return;

function [sfile, df, notes] = block_info(filename, wblk)

sfile=[];
df=[];
notes={};
sfc = sprintf('sf%d', wblk);
sfile = load(filename, sfc); % read the stim block
if(~isempty(fieldnames(sfile)))
   sfile = eval(['sfile.' sfc]);
   dfc = sprintf('df%d', wblk);
   df = load(filename, dfc); % read the data block
   df = eval(['df.' dfc]);
else
   sfile = [];
   df = [];
end;
nfc = sprintf('Note%d_*', wblk);
nf = load(filename, nfc);
if(~isempty(fieldnames(nf)))
   fn = fieldnames(nf);
   for i = 1:length(fn)
      notes{i}.v = eval(['nf.' fn{i} '.v']);
      %      notes{i}.t = eval(['nf.' fn{i} '.t']);
   end;
end;
return;

function [rl] = get_record_list(d)
rl = [];
for i = 1:length(d)
   dn = char(fieldnames(d{i})); % get the fieldname of the entry
   j = find(dn == '_'); % parse data to find record name
   sn = dn(j(end)+1:end); % get the record
   rl(i) = str2num(sn); % make a number
end;
return;

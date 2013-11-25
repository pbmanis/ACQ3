function make_index(filename)
% make_index  -  Utility to make an index file from a data file contents post-experiment
%
% use to update index in files that do not have one.
%
% 8 jan 2001
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

if(nargin == 0)
   [filename, pathname] = uigetfile('c:\data\hm-pbm\DrugControl\*.mat', 'File for Make_Index');
   if(filename == 0)
      return;
   end;
   filename = [pathname, filename];   
end;

s=whos('-file', filename);
db = strmatch('db_', {s.name}); % identify data blocks.
hf = strmatch('HFILE', {s.name}); % identify data blocks.

dbn = sscanf([s(db).name], 'db_%d'); % get list of db counters

[dbs, dbi] = sort(dbn); % get sorted list, not alphabetical list.
[p f e] = fileparts(filename);
Index = [];
Index = local_index_file('new', 'HFILE', [f e], [], [], [], Index);
for i = 1:length(dbs)
   sfn = strmatch(sprintf('sf%d', dbs(i)), {s.name}, 'exact'); % find matching sf
   dfn = strmatch(sprintf('df%d', dbs(i)), {s.name}, 'exact'); % find matching df
   fprintf('data: %d: dbi(i): %d  %s, %s, %s\n', i, db(i), s(db(dbi(i))).name, s(sfn).name, s(dfn).name);
end;

for i = 1:length(dbs)
   v=load(filename, s(db(dbi(i))).name); % load the relevant data
   if(isempty(v))
      QueMessage(sprintf('make_index.m: There appears to be no data for this block'), 1);
      return;
   end;
   
   fn=fieldnames(v); % find out the names in the list
   d = strmatch('db_', fn); % search for data blocks
   if(isempty(d))
      QueMessage(sprintf('make_index.m: There appears to be no data for this block'), 1);
      return;
   end;
   blk = dbs(i);
   d2 = eval(['v.' fn{d}]);
   drl = get_record_list(d2); % find the record numbers present in the block
   sfn = strmatch(sprintf('sf%d', dbs(i)), {s.name}, 'exact'); % find matching sf
   dfn = strmatch(sprintf('df%d', dbs(i)), {s.name}, 'exact'); % find matching df
   load(filename, s(sfn).name);
   proto = eval([s(sfn).name '.Name.v']);
   % now get the date and time at which the data was written...
   dblk = sprintf('db_%d', blk);
   x=load(filename, dblk);
   x = eval(['x.' dblk]);
   z = eval(['x{1}.' char(fieldnames(x{1}))]);
   t = z.events(1).Data.AbsTime;
   n = datenum(t(1), t(2), t(3), t(4), t(5), t(6));
   tf.date = datestr(n, 1);
   tf.time = datestr(n, 13);
   Index = local_index_file('add', blk, drl(1),  'SFILE', proto, s(sfn).name, Index, tf);
   Index = local_index_file('add', blk, drl(1), 'DFILE', ' ', s(dfn).name, Index, tf);
   Index = local_index_file('add', blk, drl(end)+1,  'DATA', proto, sprintf('db_%d', blk), Index, tf);
   
end;
save(filename, 'Index', '-append');



function [Index] = local_index_file(op, Block, Record, Entry, id, id2, in_Index, tf)
%
% local_index_file  -  add an entry to the index file specified on the input
% The entry ent is added as an element of the index structure
% INDEX
% INDEX contains:
% INDEX(i).date % date of entry
% INDEX(i).time  % time of entry
% INDEX(i).Block % = block number of the data set
% INDEX(i).record  % current record position associated with entry
% INDEX(i).type % s - the Name of the element being added  (STIM, DFILE, DATA, etc).
% INDEX(i).type2 % - any arguments - usually the name of the stim or acq file
% INDEX(i).MatName - Matlab variable name that is stored - pass in id2
% 8/10/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% changed 9/18/2000 to reflect new structures
%
% This local version just returns the index to the input index structure...
%
% op controls what happens with the index file
% if op is 'add', then the index array is updated and appended to the current data and saved
% if op is 'close', then the index file is read and appended to the data file in ACQ_FILENAME
%     the index file is then deleted
% if op is 'new', then the existing index file is cleared
%
% in any case, the first action is to open the index file

INDEX = in_Index;

t = now; % get serial date/time number
s=length(INDEX);
s = s + 1; % position to next entry

switch(op)
case 'add'
   INDEX(s).date = tf.date; % datestr(t,1);
   INDEX(s).time = tf.time; % datestr(t,13);
   INDEX(s).block = Block;
   INDEX(s).record = Record;
   INDEX(s).type = Entry;
   INDEX(s).type2 = id;
   INDEX(s).MatName = id2;
   Index = INDEX;
   return;
case 'new' % (called Index('new', 'HFILE', filename))
   INDEX = [];
   s = 1;
   INDEX(s).date = datestr(t,1);
   INDEX(s).time = datestr(t,13);
   INDEX(s).block = 1;
   INDEX(s).record = 1;
   INDEX(s).type = Block;
   INDEX(s).type2 = Record; % fake entries when 'new'
   INDEX(s).MatName = Block;    
   Index = INDEX;
   
otherwise
end;

function [rl] = get_record_list(d)
rl = [];
for i = 1:length(d)
   dn = char(fieldnames(d{i})); % get the fieldname of the entry
   j = find(dn == '_'); % parse data to find record name
   sn = dn(j(end)+1:end); % get the record
   rl(i) = str2num(sn); % make a number
end;
return;

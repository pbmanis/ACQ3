function index_file(op, ent, id, id2)
%
% index_file  -  add an entry to the index file associated with the currently open file
% The entry ent is added as an element of the index structure
% Calling parameters:
% op: what kind of opereation is being done.
% ent: matlab variable type (data, stim, etc)
% id: the name of the data . (df1, sf1, etc)
% id2: the ID for the block (block number).
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
%
global ACQ_FILENAME FILEFORMAT% this is null if there is no file in use; otherwise it holds the filename
global ACQ_PATH % default path to the data
global DFILE STIM FILE_STATUS %#ok<NUSED>

% op controls what happens with the index file
% if op is 'add', then the index array is updated and appended to the current data and saved
% if op is 'close', then the index file is read and appended to the data file in ACQ_FILENAME
%     the index file is then deleted
% if op is 'new', then the existing index file is cleared
%
% in any case, the first action is to open the existing index file
% if there is none, we will create a new one

IndexFile = 'c:\acq3\INDEX.mat';
fid = fopen(IndexFile, 'r'); % open for reading?
if(fid < 0)
    %  fprintf(2, 'index_file: Creating new index\n');
    INDEX = [];
else
    fclose(fid);
    load(IndexFile);
end;

t = now; % get serial date/time number
s=length(INDEX);
s = s + 1; % position to next entry

switch(op)
    case 'add'
        if(nargin < 4)
            fprintf(2, 'Index_file error: add operation requires 4 arguments\n');
            return;
        end;
        if(isempty(ACQ_FILENAME))
            QueMessage('index_file: ? No open file to index', 1);
            return;
        end;
        INDEX(s).date = datestr(t,1);
        INDEX(s).time = datestr(t,13);
        INDEX(s).block = FILE_STATUS.Block;
        INDEX(s).record = FILE_STATUS.Record;
        INDEX(s).type = ent;
        INDEX(s).type2 = id;
        INDEX(s).MatName = id2; %#ok<NASGU>
        if(~isempty(FILEFORMAT))
            save(IndexFile, 'INDEX', '-append', FILEFORMAT); % build data file
        else
            save(IndexFile, 'INDEX', '-append'); % build data file
        end;        
        
    case 'close'
        if(isempty(ACQ_FILENAME))
            QueMessage('index_file: ? No file to append index to', 1);
            return;
        end;
        filename = fullfile(ACQ_PATH, ACQ_FILENAME);
        filename = [filename '.mat'];
        x = exist(IndexFile, 'file');
        if(any(x ==2))
            Index = load(IndexFile);
            Index = Index.INDEX; %#ok<NASGU>
            if(~exist(filename, 'file'))
                return;
            end;
            if(~isempty(FILEFORMAT))
                save(filename, 'Index', '-append', FILEFORMAT); % build data file
            else
                save(filename, 'Index', '-append'); % build data file
            end;
            delete (IndexFile); % remove existing index file
        else
            QueMessage('index_file: INDEX is missing at close', 1);
        end;

    case 'new'
        if(nargin < 2)
            fprintf(2, 'Index_file error: New operation requires 2 arguments\n');
            return;
        end;

        DFILE.Record = 1;
        INDEX = [];
        s = 1;
        INDEX(s).date = datestr(t,1);
        INDEX(s).time = datestr(t,13);
        INDEX(s).block = FILE_STATUS.Block;
        INDEX(s).record = FILE_STATUS.Record;
        INDEX(s).type = ent;
        if(~isempty(ACQ_FILENAME))
            INDEX(s).type2 = ACQ_FILENAME;
        else
            INDEX(s).type2 = '?filename';
        end;
        INDEX(s).MatName = ent; %#ok<NASGU>
        if(~isempty(FILEFORMAT))
            save(IndexFile, 'INDEX', FILEFORMAT); % build data file
        else
            save(IndexFile, 'INDEX'); % build data file
        end;   % blithley overwrite existing index file
    otherwise
end;



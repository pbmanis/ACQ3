function pf(filename, bspec)
% pf: print the file details
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%   1) pf<cr> lists the index/contents of the current open acquisition file.
%   2) pf filename lists index of disk file.
%
% opens the file and loades the index...
% and lists contents to matlab window
% pf is derived from lif, but lists more information
%

if(nargin < 1)
    filename = [];
end;
if(nargin < 2)
    bspec = []; % block specification (to pick certain block types)
else
    if(~strmatch(lower(bspec), {'data', 'sf', 'df', 'note', 'header'}, 'exact'))
        fprintf(2, 'block spec type %s not recognized\n', bspec);
        return;
    end;
end;

if(isempty(filename))
    if(exist('INDEX.mat', 'file') ~= 2)
        [filename, pathname] = uigetfile('*.mat', 'File for listing?');
        if(filename == 0)
            return;
        end;
    else
        filename = 'INDEX';
    end;
    filename = [pathname, filename];
end;
v=[];
v = load(filename, 'Index');
if(isempty(fieldnames(v)))
    v=load('INDEX'); % maybe file is not closed
    if(isempty(fieldnames(v)))
        fprintf(2, 'lif: No index associated with file %s\n', filename);
        return;
    end;
end;
element = fieldnames(v);
INDEX = eval(['v.' char(element)]);

s = length(INDEX);
fprintf(1, '\nINDEX:\n---------------------------------------------------------------------------\n');
for i = 1:s
    if(isempty(bspec))
        fprintf('%8s  %8s  %4d  %4d  %12s  %12s  %12s\n', INDEX(i).date, INDEX(i).time, INDEX(i).block, INDEX(i).record, INDEX(i).type, INDEX(i).type2, INDEX(i).MatName);
    else
        if(strmatch(lower(bspec), lower(INDEX(i).type), 'exact'))
            fprintf('%8s  %8s  %4d  %4d  %12s  %12s  %12s\n', INDEX(i).date, INDEX(i).time, INDEX(i).block, INDEX(i).record, INDEX(i).type, INDEX(i).type2, INDEX(i).MatName);
        end;
    end;

end;
fprintf(1, '---------------------------------------------------------------------------\n<eof>\n\n');

data_blks = strmatch('DATA', char(INDEX.type), 'exact');
notes = strmatch('NOTE', char(INDEX.type), 'exact');
note_blks = [INDEX(notes).block]; % identify these by the BLOCK number itself...
data_blks = union(data_blks, notes); % identify indices to all blocks we need to access
% now for each element of the input index, print some information
done_blk = [];
for indxi = 1:length(data_blks) % look for the data in all the blocks (it doesn't hurt to search)
    ind = data_blks(indxi);
    this_block = INDEX(ind).block;
    dblk = [];
    if(~isempty(done_blk)) % just prevent warning message
        dblk = find(this_block == done_blk); % check to see if we have already processed block number (union may return multiple indices for same block)
    end;
    if(isempty(dblk))
        done_blk = [done_blk this_block]; %#ok<AGROW> % add (provisionally) finished block to the list
        this_time = INDEX(ind).time;
        fprintf(1, '\n****************************\nBLOCK: %d started at %8s, contains', ...
            this_block, this_time);
        [sfile, df, notes] = block_info(filename, this_block);
        fprintf(1, ' records: %d-%d\n', INDEX(ind-1).record, INDEX(ind).record);

        if(~isempty(df) && ~ isempty(sfile))
            fprintf(1, '----------------------------\nAcquisition Parameters                         Stimulus Parameters\n');
            if(isempty(df.Filename.v))
                fnm = '<auto>';
            else
                fnm = df.Filename.v;
            end;
            fprintf(1, 'File: %-24s                 File: %-24s\n', fnm, sfile.Name.v);
            fprintf(1, 'Rate (us): %6.2f   Points: %5d              Cycle (s): %.1f   Repeats: %d   Stim_Repeat: %d\n',...
                df.Sample_Rate.v, df.Points.v, sfile.Cycle.v, sfile.Repeats.v, sfile.Stim_Repeat.v);
            fprintf(1, 'Channels [');
            for ii = 1: length(df.Channels.v)
                fprintf(1, ' %2d ', df.Channels.v(ii));
            end;
            fprintf(1, ']');
            for ii = length(df.Channels.v):8
                fprintf(1, '    ');
            end;
            fprintf(1, 'SeqPar: %s    Sequence: %s\n', sfile.SeqParList.v, sfile.Sequence.v);

            fprintf(1, 'Gain     [');
            for ii = 1: length(df.Amplifier_Gain.v)
                fprintf(1, '%4.1f', df.Amplifier_Gain.v(ii));
            end;
            fprintf(1, ']');
            for ii=length(df.Amplifier_Gain.v):8
                fprintf(1, '    ');
            end;

            si = sfile.Superimpose.v;
            if(isempty(si))
                si = '<none>';
            end;
            ac=sfile.Addchannel.v;
            if(isempty(ac))
                ac = '<none>';
            end;
            fprintf(1,'Superimpose: %s   AddChannel: %s\n----------------------------\n', ...
                sfile.Superimpose.v, sfile.Addchannel.v);
        end;

        if(~isempty(notes))
            for i = 1:length(notes)  % notes{1}.v
                c=char(notes{i}.v);
                if(strmatch(fieldnames(notes{1}), 't'))
                    fprintf(1, '\nNote (%2d:%2d:%2.0f):\n', notes{1}.t(4), notes{1}.t(5), notes{1}.t(6))
                else
                    fprintf(1, '\nNote:\n');
                end;
                for j = 1:size(c,1)
                    if(~isempty(c(j,:)))
                        fprintf(1, '     %s\n', c(j,:));
                    end;
                end;
            end;
        end;
    end;
end;
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
    notes = cell(length(fn), 1);
    for i = 1:length(fn)
        notes{i}.v = eval(['nf.' fn{i} '.v']);
    end;
end;
return;



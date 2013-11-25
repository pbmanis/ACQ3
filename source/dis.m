function dis(r1, filename)
% dis: display some records
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     dis b# <filename>, where b is the block.
%     if no filename is given, the routine attempts to use the currently open acquisition file

%
% Modified to handle new file format records are stored in blocks.
%
% 8/11/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
%
% data is displayed directly to the window
% Data may be displayed as blocks
% e.g., dis bnn <filename>
% or as records,
% e.g., dis recordparse <filename>   ---> this is not implemented(:
% where filename is only required if there is no file already open.
%

global ACQ_FILENAME
global ONLINE

h0 = findobj('Tag', 'Acq'); % get the big window
if(isempty(h0))
    fprintf(2, 'dis: must run from within Acq\n'); % message must go to matlab window...
    return;
end;

if(nargin == 1)
    % try to read from the current file that is in acquisition
    INDEX=[];
    load('INDEX');
    if(~isempty(fieldnames(INDEX)))
        filename = INDEX(1).type2;
    else
        QueMessage('dis: No file open, expecting second argument filename',1);
        return;
    end;

else
    if(nargin == 1)
        filename = ACQ_FILENAME;
    end;
end;
if(~exist([filename '.mat'], 'file'))
    QueMessage(sprintf('dis: File %s not found?', filename), 1);
    return;
end;

% parse the record argument
% if first char is b, then use block format...
if(ischar(r1) && r1(1) == 'b')
    block = str2double(r1(2:end));

    ab = sprintf('df%d', block); % to access the acquistion block
    sb = sprintf('sf%d', block); % to access the stim block
    rb = sprintf('d_%d_*', block); % to access all the data in the data associated with the block

    %   s=whos('-file', filename); % find structures in the data
    %   sa={s.name}';
    Index = [];
    load(filename, 'Index');
    if(isempty(Index)) % we expect Index back
        v=load('INDEX', 'INDEX');
        Index=v.INDEX;
        if(isempty(fieldnames(Index)))
            QueMessage(sprintf('dis.m: No Index in file %s', filename), 1);
            return;
        end;

    end;
    %Index = Index.INDEX; % download the structure. (this is for very first version of file; not necessary now)
    w = find([Index.block] == block);
    if(isempty(w))
        QueMessage(sprintf('dis.m: Block %d seems to absent in file', block), 1);
        return;
    end;
    v=load(filename, Index(w).MatName); % load all the relevant data
    if(isempty(v))
        QueMessage(sprintf('dis.m: There appears to be no data for this block'), 1);
        return;
    end;
    sf = eval(['v.' sb]);
    df = eval(['v.' ab]);

    fn=fieldnames(v); % find out the names in the list
    %   d=strmatch('d_', fn);
    d = strmatch('db_', fn); % search for data blocks
    if(isempty(d))
        QueMessage(sprintf('dis.m: There appears to be no data for this block'), 1);
        return;
    end;
    d2 = eval(['v.' fn{d}]);
    for i = 1:length(d2)
        dn = fieldnames(d2{i});
        data(:,:,i) = eval(['d2{i}.' dn{1} '.data']); %#ok<AGROW>
    end;
    volt = data(1,:,:);
    curr = data(2,:,:);
    %dotheaverage = 0;
    if(exist('dotheaverage', 'var'))
        k = size(volt, 1);
        l = k/8;
        k1 = floor(k/l);
        j = 1;
        for i = 1:k1
            volta(i,:) = mean(volt((j:j+l-1),:), 2); %#ok<AGROW>
            curra(i,:) = mean(curr((j:j+l-1),:), 2); %#ok<AGROW>
            j = j + l;
        end;
        j = 1;
        for i = 1:k1/2
            voltb(i,:) = volta(j+1,:) - volta(j,:); %#ok<AGROW>
            currb(i,:) = curra(j+1,:) - curra(j,:); %#ok<AGROW>
            j = j + 2;
        end;

        figure;
        clf;
        subplot(2,1,1);
        plot(1:length(volta), voltb);
        subplot(2,1,2);
        plot(1:length(curra), currb);
    end;

else
    rlist = seq_parse(r1); % try a record parse operation
    return; % not implemented yet

end;
%fprintf(2, 'Block: %d   rate: %7.2f  points: %d\n', block, df.Sample_Rate.v, df.Points.v);




nreps=sf.Repeats.v;
cycle=sf.Cycle.v/1000;

samp_rate = 10^6/df.Sample_Rate.v;
nchan=length(df.Channels.v);
duration = nchan * df.Points.v / samp_rate; % duration (in seconds) for each epochbufsize = round(duration*samp_rate*2/nchan);

outdata = sf.waveform;
[m1,n1] = size(outdata);

time=(0:df.Sample_Rate.v*nchan/1000:duration*1000);
t1 = 50/(df.Sample_Rate.v*nchan/1000);
t2 = 90/(df.Sample_Rate.v*nchan/1000);
hp=[]; % clear the display handles;
first=2;
df.Refresh.v = length(outdata); % display the whole thing...

acq_plot_data(-1, 1, ONLINE, [], 1, df);  % this will clear the acq_plot (-1)

first = 1;
for i = 1:size(data,3)
    acq_plot_data(i-1, first, ONLINE, data(:,:,i), 2, df);
    first = 0;
end;
QueMessage(sprintf('Data Block %d displayed from file', block), 1);
return;

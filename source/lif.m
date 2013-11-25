function lif(filename, bspec)
% lif: list the Index file
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     lif with no arguments lists the Index of the currently open acquisition file.
%     lif filename <bspec> lists the Index of the disk file; if bspec is specified then
%     only the blocks of that type are listed
%     valid blocks are 'data', 'sf', 'df', 'note', 'header'

%
% opens the file and loades the index...
% and lists contents to matlab window
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
    [filename, pathname] = uigetfile('*.mat', 'File for listing?');
    if(filename == 0)
        return;
    end;
    filename = [pathname, filename];
end;

if(exist([filename '.mat'], 'file') ~= 2)
    fprintf(2, 'File %s not found?\n', [filename '.mat']);
    return;
end;

v=[];
v = load(filename, 'Index');
if(isempty(fieldnames(v)))
    if(exist('INDEX.mat', 'file')  == 2) % see if file is open on disk
        v=load('INDEX'); % maybe file is not closed
        if(isempty(fieldnames(v)))
            fprintf(2, 'lif: No index associated with file %s\n', filename);
            return;
        end;
    else
        fprintf(2, 'lif: No index in file or on disk\n');
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
return;

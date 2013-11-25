function [dataout] = manage_table(varargin)


if ~isstruct(varargin{1})
    ht = varargin{1};
    newdata = get(ht, 'UserData');
    dataout = newdata{1};
    [changed] = find(newdata{2} ~= 0);
    for j = 1:length(changed) % only mess with the stuff that changed.
        i = changed(j);
        dataout.(char(newdata{3}(i))).v = newdata{1}.(char(newdata{3}(i))).v;
    end;
    disp 'new dataout'
    dataout
    return;
end;
dataout = [];
datastruct = varargin{1};
if nargin > 1
    h0 = varargin{2};
else
    h0 = [];
end;

if(isempty(h0))
    h0 = newfigure('datatable', 'datatable');
end;

ht = uitable('tag', 'edittable', 'Parent', h0);
%fpos = get(h0, 'Position');
%set(hf, 'Position', [fpos(1), fpos(2), 840, 450]);
set(ht, 'Position', [20, 20, 350, 460]);
cc = struct2cell(datastruct); % convert to cell array
colnames = {'Value'};
rownames = fieldnames(datastruct);
ds_start = strcmpi('start', rownames);
ds_end = strcmpi('end', rownames);
editable = logical([1]);
rn = {};
c2 = {};
k = 1;

for m = 1:length(cc)
    rn{k} = rownames{m};
    if isstruct(cc{m})
        dss =   ['datastruct.' rownames{m} '.v']
        c2{1,k} = eval(dss);
        k = k + 1;
        continue; % fprintf(1, 'fn %s is struct\n', char(colnames{m}));
        
    end;
    if ischar(cc{m})
        % fprintf(1, 'field %s is char: %s\n', char(colnames{m}), char(cc{m,i}));
        c2{1,k} = cc{m};
    elseif isnumeric(cc{m})
        if length(cc{m}) > 1
            %     fprintf(1, 'numeric field %s has length > 1 : %d\n',  char(colnames{m}), length(cc{m,i}));
            c2{1,k} = num2str(cc{m});
        else
            c2{1,k} = cc{m};
        end;
    end;
    k = k + 1;
end;
changed = zeros(length(c2));
set(ht, 'Data', c2');
set(ht, 'ColumnName', colnames, 'ColumnEditable',editable);
set(ht, 'ColumnWidth', {100});
set(ht, 'RowName', rn);
set(ht, 'Enable', 'on');
set(ht, 'CellEditCallback', {@manage_table});
set(ht, 'UserData', {datastruct, changed, rn});  % save data here - this is how we will update later
% that is all - the callback can handle the changes.
return;
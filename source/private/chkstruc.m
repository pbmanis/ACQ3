function valid_struct = chkstruc(test_struct, field_name, field_test);

% CHKSTRUC - test a structure for valid fields & types
%
%    FLAG = CHKSTRUC(STRUCT, FIELDS, TEST) checks a structure STRUCT for the
%    existence of fields whose names are provided in the cell array FIELDS.
%    If present, the field contents are checked with a test function provided
%    in the cell array TEST ('isnumeric', 'iscell', etc.) to determine if the
%    field contents are valid.

% initialize output

valid_struct = 0;

% validate arguments

if (nargin ~= 3)
   fprintf('CHKSTRUC: invalid number of arguments\n');
   return
elseif (~isstruct(test_struct))
   fprintf('CHKSTRUC: STRUCT must be a structure\n');
   return
elseif (~iscell(field_name))
   fprintf('CHKSTRUC: FIELDS must be a cell array\n');
   return
elseif (~all(cellfun('isclass', field_name, 'char')))
   fprintf('CHKSTRUC: elements of FIELDS must be strings\n');
   return
elseif (~iscell(field_name))
   fprintf('CHKSTRUC: FIELDS must be a cell array\n');
   return
elseif (~all(cellfun('isclass', field_name, 'char')))
   fprintf('CHKSTRUC: elements of FIELDS must be strings\n');
   return
elseif (~iscell(field_test))
   fprintf('CHKSTRUC: FIELDS must be a cell array\n');
   return
elseif (~all(cellfun('isclass', field_test, 'char')))
   fprintf('CHKSTRUC: elements of FIELDS must be strings\n');
   return
end

% loop through structure fields
% test for existence & validity

valid_struct = 1;
for i = 1 : min(length(field_name), length(field_test))
   if (~isfield(test_struct, field_name{i}))
      fprintf('CHKSTRUC: field %s does not exist\n', field_name{i});
      valid_struct = 0;
   elseif (~feval(field_test{i}, getfield(test_struct, field_name{i})))
      fprintf('CHKSTRUC: field %s failed %s\n', field_name{i}, field_test{i});
      valid_struct = 0;
   end
end
return

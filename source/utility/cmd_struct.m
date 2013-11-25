function [cmdo] = cmd_struct(cmd, flag)
%
% execute a command based on a structure
% operates on sfile
% 9/08/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% 9/19/2000 - generalized to work with each available structure
% gets the structure currently on top (e.g., visible)
% with struct_edit ('get'); those become the available commands
%
% when the flag is set (flag = 1), we do not update the display
% this is for use with set_cmd, so that it simply accesses the
% fields and saves the files, without synchronizing the display
%
global STIM STIM2 DFILE CONFIG STIMBUFFER %#ok<NUSED>

cmdo = [];
cmd = lower(cmd);
if(nargin == 1)
   flag = 0;
elseif nargin < 1
   QueMessage('cmd_struct: bad call', 1);
   return;
end;

curr_frame = struct_edit('get', STIMBUFFER);
if(isempty(curr_frame))
   QueMessage('cmd_struct: ? no window active', 1);
   
   return;
end;
switch(curr_frame)
case 'FStim'
   if STIMBUFFER == 1
       curr_s = 'STIM';
   elseif STIMBUFFER == 2
       curr_s = 'STIM2';
   else
       curr_s = 'STIM';
   end;
   
case 'FDfile'
   curr_s = 'DFILE';
case 'FConfig'
   curr_s = 'CONFIG';
otherwise
   QueMessage('cmd_struct: can''t identify current frame', 1);
   
   return;
end;

fn = fieldnames(eval([curr_s])); % get field names in the sturcture
s=strmatch('start', fn); % find editable limits
e=strmatch('end', fn);
c=[];
for i=s+1:e-1
   c=strvcat(c, eval([curr_s '.' fn{i} '.t'])); % make cell array from structure .t entries
end;
c=lower(c); % list of valid fields
orig_cmd = cmd;

% Now begin to parse the command line:
toksep = ' ';
[cmd, alist] = strtok(cmd, toksep); % find first argument in cmd
alist = unblank(alist); % remove leading and trailing spaces

k=strfind(cellstr(c), cmd); % see if command matches anything in the structure - i.e., get the field name to work
u = 0;
for i = 1:length(k)
    if k{i} == 1
        u = i;
    end;
end;
if(isempty(k) || u == 0)
   QueMessage(sprintf('Unrecognized command ''%s''\n', cmd), 1);
   
   return;
end;

thisname = fn{u+s};
pointer = sprintf('%s.%s', curr_s, thisname);
v = eval([pointer '.v']); % get the value held there
fmt = eval([pointer '.f']); % get the format
mflag = eval([pointer '.m']); % get the single/multi flag. Only really applies to numeric fields (text fields can have all the spaces they want)
if(mflag < 0) % not an editable field, so return (4/16/2008)
    QueMessage(sprintf('cmd_struct: field %s is calculated, not editable', thisname), 1);
    return;
end;

if(strcmp(fmt,'%s') || strcmp(fmt,'%c'))
   fmtc = 1; % character format - we have to handle things one way for strings, another for numbers
else
   fmtc = 0;
end;

% 1. If stored data is in string, just get the rest of the line and store it.
if(fmtc)
   try
      eval([pointer '.v = alist;']); % store the new variable
   catch ME
      QueMessage(sprintf('cmd_struct: Unable to store input? %s\n', alist),1);
      
      return;
   end;
   set_local_data(eval(curr_s));
   
else
   
   % 2. Data is stored as numeric array (fmtc = 0)
   % is the input argument in array format (i.e., '[0 3 5 9 10]')?
   %    if so, we just use it to replace v
   
   k = find(ismember(alist, '[]'));
   if(rem(length(k), 2) == 0 && length(k) >= 2)
      
      [arg, alist] = symboltok(alist, '[]', 'include'); % get the matrix input
      if(isempty(arg))
         QueMessage(sprintf('cmd_struct: Failed to tokenize %s with []\n', alist),1);
         return;
      end;
      try
         w = eval(arg);
      catch
         QueMessage(sprintf('cmd_struct: Failed to eval on %s\n', arg),1);
         cmdo = [];
         return;
      end;
      if(mflag)
         if(size(w, 1) > 1)
            w = w';
         end
         if(size(w, 1) > 1) % still?
            QueMessage(sprintf('cmd_struct: Arrays must have single dimension\n'),1);
            return;
         end;
         v=w;
         eval([pointer '.v = v;']); % store the new variable
         set_local_data(eval(curr_s));
      else
         v=w(1); % just the single first argument (technically, could be an error)
         eval([pointer '.v = v;']); % store the new variable
         set_local_data(eval(curr_s));
      end;
   else 
      % in this case we must process data according to the SGL/MULTI flag
      % 
      
      if(~mflag) % SGL mode specified for this argument: just read the next number and move on
         [arg, alist] = strtok(alist, toksep);
         if(isempty(arg))
            QueMessage(sprintf('cmd_struct: No argument for %s\n',orig_cmd),1);
            cmdo = [];
            return;
         end;
         v=str2num(arg); %#ok<ST2NM> % convert the number
         try
            eval([pointer '.v = v;']); % store the new variable
         catch
            QueMessage(sprintf('cmd_struct: Unable to store argument %s\n', arg),1);
            cmdo = [];
            return;
         end;
         set_local_data(eval(curr_s));
      else
         % we are now in "multi" mode. The first argument is the index, and the second is the argument
         % when storing a whole new set, use the [] style above.
         [index, alist] = strtok(alist, toksep); %  % now get the next arg, which is the index...
         if(isempty(index))
            QueMessage(sprintf('cmd_struct: Command lacks index ''%s''\n', orig_cmd),1);
            
            return;
         end;
         index=str2double(index);
         if(index <= 0 || index > length(v))
            QueMessage(sprintf('cmd_struct: Index argument %d is invalid', index), 1);
            return;
         end;
         
         [arg, alist] = strtok(alist, toksep); % now get the value(s) to enter
         
         if(ischar(arg)) % if its a char, but we need a number, convert it to number
            if(strcmp(unblank(arg), '-')) % the deletion argument
               v(index) = Inf; % tag it
               v = v(v ~= Inf);
            else
               varg = str2double(arg);
               v(index) = varg; % store it in the indexed place
            end;
         else
            if(isempty(arg))
               QueMessage('cmd_struct: ? missing argument', 1);
               return;
            end;
            v(index) = arg; % store numeric
         end;
         try 
            eval([pointer '.v = v;']); % store the new variable
         catch
            QueMessage(sprintf('cmd_struct: Unable to store arg %f?\n', arg),1);
            return;
         end;
         set_local_data(eval(curr_s));
         
      end;
   end;
end;

% now we update the display....
if(flag == 0) % only when we have to...
%    id=get_id(eval(curr_s));
    update_current_field(curr_s, pointer, fmt); % fix up the display
    this = eval(curr_s);
    warning off MATLAB:dispatcher:InexactMatch
    if(isfield(this, 'Calculate')) % make sure a field exists for this first
        try
            cmdr = this.Calculate;
        eval(cmdr);
        catch ME
            ME
        end;
        
    end;
    warning on MATLAB:dispatcher:InexactMatch

end;
cmdo = alist; % return the remainder of the input string we didn't process
if(strcmp(curr_frame, 'FStim'))
   eval([curr_s '.update = 0;']);
end;

return;


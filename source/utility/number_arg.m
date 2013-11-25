function [result] = number_arg(arg)
% number_arg returns the value of arg as a number, regardless of the original type
% used to extract numbers from control worksheet, which is usually in character/string
% format.
% Modified 7/30/2007 to return NaN if the input was not a number (such, as
% a string). 
%
result = NaN;

if(ischar(arg))
   arg = unblank(arg);
   result = str2num(arg);
   if(isempty(result))
      result = NaN;
   end;
else
   
   
   for i = 1:length(arg)
      if(iscell(arg(i)))
         if(isempty(arg{i}))
            result(i) = 0;
         elseif(isnumeric(arg{i}))
            result(i) = arg{i};
         elseif(ischar(arg{i}))
            chk = findstr(arg{i}, '_');
            if(~isempty(chk))
               chr = char(arg{i});
               arg{i} = char(1:min(chk));
            end;
            result(i) = str2num(arg{i});
         else
            result(i) = NaN;
         end;
      elseif(isempty(arg(i)))
         result(i) = NaN;
      elseif(isnumeric(arg(i)))
         result(i) = arg(i);
      elseif(ischar(arg(i)))
         result(i) = str2num(arg(i));
      else
         result(i) = NaN;
      end
      % if we get here, maybe the argument is empty in other ways...
   end;
end;
return;

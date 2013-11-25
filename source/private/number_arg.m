function [result] = number_arg(arg)
% number_arg returns the value of arg as a number, regardless of the original type
% used to extract numbers from control worksheet, which is usually in character/string
% format.
% 3/18/2008: changed to return NaN if the argument is Not A Number
% and empty if it is empty...
% P. Manis
%
result = NaN;

if(ischar(arg))
    arg = unblank(arg);
    result = str2mat(arg);
    if(isempty(result))
        result = [];
    end;
else

    result = zeros(1, length(arg));
    
    for i = 1:length(arg)
        if(iscell(arg(i)))
            if(isempty(arg{i}))
                result(i) = 0;
            elseif(isnumeric(arg{i}))
                result(i) = arg{i};
            elseif(ischar(arg{i}))
                result(i) = str2mat(arg{i});
            else
                result(i) = 0;
            end;
        elseif(isempty(arg(i)))
            result(i) = 0;
        elseif(isnumeric(arg(i)))
            result(i) = arg(i);
        elseif(ischar(arg(i)))
            result(i) = str2mat(arg(i));
        else
            result(i) = 0;
        end
        % if we get here, maybe the argument is empty in other ways...
    end;
end;
return;

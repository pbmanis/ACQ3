function [res, err] = strparse(inpstring)
err = 0;
if(~ischar(inpstring))
    inpstring = char(inpstring);
end;
[serr, arglist] = strtok(inpstring, ',');
if(str2double(serr) ~= 1)
    err = 1;
    return;
end;
i = 1;
while(~isempty(arglist))
    [res{i} arglist] = strtok(arglist, ',');
    i = i + 1;
end;
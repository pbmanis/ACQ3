function [axinfo] = acq_getlastpos()
%
% function to search the windows for the most recent pointer information
%
h_axes = findobj('Type', 'axes');

for i = 1:length(h_axes) % search all the windows for the pointer
   axinfo = get(h_axes(i), 'UserData'); % There may be information in userdata we can use
    if(isfield(axinfo, 'lastaxis') && axinfo.lastaxis > 0)
        return;
    end;
end;
axinfo = [];
return;

     
        
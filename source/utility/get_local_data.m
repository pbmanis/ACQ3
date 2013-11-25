function result = get_local_data(win_title)
%-----------------------------------------------------------------------
% get the data from userdata in the editor window
% note we call with just the window title.
if(nargout == 1)
   result = [];
end;

if(isempty(win_title))
   fprintf(2, 'get_local_data: Empty win_title\n');
   return;
end;
htag = findobj('Tag', win_title);
if(htag == 0)
   fprintf(2, 'get_local_data: ? failed to find window %s\n', win_title);
   return;
end
if(nargout == 1)
   result = get(htag, 'UserData');
end;
return;

function set_local_data(arg)
%-----------------------------------------------------------------------
% set the data as userdata in the editor window so we can access it
% note non-symmetry with get_local_data - here we use the full dataset
htag = findobj('Tag', arg.frame);
if(htag == 0) 
   fprintf('set_local_data: Unable to find tag for %s\n', arg.frame);
   return;
end
set(htag, 'UserData', arg);
return

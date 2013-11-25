function clean_up(tmp_file)
% clean up all that is necessary to clean up before returning
% usage:
%     clean_up (tmp_file)
%     Not normally called by user.

global STOP_ACQ SCOPE_FLAG
global FILE_STATUS ACQ_FILENAME

if(~isempty(tmp_file))
   x=dir(sprintf('%s*', tmp_file));
   if(~isempty(x))
      for i = 1:length(x)
         if(x(i).isdir == 0)
            delete(x(i).name); % delete the temporary files
         end;
         
      end;
   end;
end;
set_in_acq(0);
STOP_ACQ = 0;
return;


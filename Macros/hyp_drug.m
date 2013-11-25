function hyp_drug(arg)
% hyp_drug.m  -  protocol for to test effect of drugs on discharge pattern
% 7/18/2001
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu

% Required in all macros:

%-----------------------------------------
global IN_MACRO

if(~ok_macro_run) % function returns 0 if not ok to run the macro
   return;
end;

try % handle errors - note that this makes it hard to find 
    % the errors, but keeps the program sync'd
   
	%-----------------------------------------
   % set up a test mode for quick testing to be sure macro works
   % and is error free
   
   testmode = 0; % flag: 0 is normal full run, 1 is the 'test mode'
   
   nsamp = 60 % number of samples to take...
   if(testmode)
      nsamp = 6; % use for testing....
   end;
   
   pausetime = 1; % set up pause timer
   if(nsamp == 6) % in test mode, we use a short wait.
      totpause = 5; % 10 second update
   else
      totpause = 5*60; % total pause in seconds
   end;
   
   
   %---------------------------------------------------------
   % initialize
    % we control the valves: tell user to switch valve control
   do_valve('computer');
   
   valve(1); % select valve 1.
   
   % do we use 'slow voltage clamp' ?
   % any argument on the input is same as 'hyp_drug_manual...' 
   % - i.e., we don't set holding ourselves
   if(nargin == 0) 
      sethold set   % make sure holding is locked 
   end;
   
   g ltp_base  % baseline measurement of 'buildup' response
      
   % insert a 5-minute pause before we start the data collection
   % to allow the cell to stabilize.
   
   for i = 1:floor(totpause/pausetime)
      QueMessage(sprintf('Pausing for stability: %d sec remaining', ...
         totpause - (i-1)*pausetime), 1);
      pause(pausetime);
      % a line like this is necessary after every command 
      % to stop the macro completely.
      if(check_macro_stop) 
         do_valve('manual');
         sethold off
         return;
      end;
   end;
   
   % --------------------------------------------------
   % collect baseline data
   
   take(nsamp);  % sets up for 5 minutes as 5 sec/trial (12/min)
   if(check_macro_stop) 
      do_valve('manual');
      sethold off
      return;
   end;
   
   % do hyp protocol before switching the valves
   g ap-hyp
   seq
   if(check_macro_stop) 
      do_valve('manual');
      sethold off
      return;
   end;
   
   % --------------------------------------------------
   % now change the valve to the test solution
   % and collect data during drug wash-in
   
   QueMessage(sprintf('Switching to valve %d NOW!!! ', 2), 1);
   valve(2)
   
   g ltp_base % measure again with same parameters as baseline
   take(nsamp*2); % 10 minutes worth here...
   if(check_macro_stop) 
      do_valve('manual');
      sethold off
      return;
   end;
   
   % return the valve to the normal solution
   QueMessage(sprintf('Switching to valve %d NOW!!! ', 1), 1);
   valve(1);
   
   % --------------------------------------------------
   % collect post-drug data
   % the following loop does 2 things:
   % we watch and we do parameteric measurements
   % watch for 20 minutes or so, but keep doing 
   % the hyp protocol every 5 minutes.
   
   for i = 1:4 
      % do/verify hyp protocol
      g ap-hyp
      seq
      if(check_macro_stop)
         do_valve('manual');
         sethold off
         return;
      end;
      %
      g ltp_base % measure again with same parameters as baseline
      take(nsamp);	% take 5 minutes
      if(check_macro_stop) 
         do_valve('manual');
         sethold off
         return;
      end;
   end;
   
   % --------------------------------------------------
   % done - now just check cell properties at the end of the run
   
   g ap-hyp % repeat the hyp protocol.
   seq
   if(check_macro_stop) 
      do_valve('manual');
      sethold off
      return;
   end;
   %
   % get cciv again and re-run with all parameters
   g ap-iv % to confirm basic cell information
   seq
   if(check_macro_stop) 
      do_valve('manual');
      sethold off
      return;
   end;
   
	% --------------------------------------------------
   % restore default conditions
   
   do_valve('manual'); % tell user to return valves to manual control
   
   sethold off % always turn off slow vclamp
   
   %------ REQUIRED OF ALL MACROS::: successful exit
   IN_MACRO = 0; % turn off macro flag.
   return;
   
   %*********
   % handle matlab errors.
   
catch
   QueMessage('Macro hyp_drug: FATAL error detected (try/catch)',  1);
   acq_stop;
   do_valve('manual');
   sethold off;
   IN_MACRO = 0;
   return;
end;

return; % that's all



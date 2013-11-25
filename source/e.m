function e(arg)
% e: edit parameters
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     use 'e a' for acquisition
%     use 'e s' for stimulus (main)
%	  use 'e 2' for secondary stimulus (parameter adjustment.....)
%     use 'e 1' for primary stimulus channel parameter adjustment
%     use 'e c' for configuration

% function to bring up different parameter views for editing
%
global DFILE STIM STIM2 CONFIG

switch(arg)
    case {'a', 'acq'}
        struct_edit('edit', DFILE);
        
    case {'s', '1', 'stim', 'main'}
        struct_edit('load', STIM, 1);
        
    case {'2', 'stim2'}
        struct_edit('load', STIM2, 2);
    
    case {'add'},
        if isempty(STIM) 
            return
        end;
        if isempty(STIM.Addchannel.v)
            QueMessage('No Secondary Channel found to edit', 1);
            return
        end;
        [err, STIM2] = g2(char(STIM.Addchannel.v)); % bring to the main buffer to edit and save
        if err
            return
        end;
        struct_edit('load', STIM2, 2);
    
    case {'super', 'superimpose'},
        if isempty(STIM)|| isempty(STIM.Superimpose.v)
            return
        end;
        err =g2(STIM.Superimpose.v);
        if err
            return
        end;
        struct_edit('load', STIM2, 2);
        
    case {'c', 'config'}
        struct_edit('edit', CONFIG);
    otherwise
        if(isempty(cmd))
            QueMessage(sprintf('e: unrecognized parameter block %s', arg), 1);
            return;
        end;
end;
return;

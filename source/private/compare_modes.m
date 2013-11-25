function [AmpMode, err] = compare_modes(varargin)
%
% function to read telegraph and return 0 if amplifier is in same mode as
% target from acq (DFILE)
% and return 1 if it is not in same mode (which is an error)
% 9/11/2000
% do NOT let this return an "AmpStatus" since the result returned is
% incomplete with respect to the telegraph AmpStatus outputs ... 
% Paul B. Manis
% 8/29/2008 
%
global MCList AXPList APRList HARDWARE DEVICE_ID %#ok<NUSED,NUSED>

err = 1; % assume error
switch nargin
    case 0
        target = 'CC';
        InputSelect = 1;
    case 1
        target = varargin{1};
        InputSelect = 1; % use default first amplifier
    case 2
        InputSelect = varargin{2};
        target = varargin{1};
end;
amplifier_string = eval(sprintf('HARDWARE.InputDevice%d.Amplifier', InputSelect));
if(strcmpi(amplifier_string, 'TTL') || DEVICE_ID < 0)
    amplifier_string = 'none';
end;

switch lower(amplifier_string)
    case {'axoprobe1a', 'axoprobe'}
        err = 0;
        AmpMode.Mode = 'I';
        AmpMode.LPF = 5.0;
        AmpMode.Gain = 10.0;
        return;


    case AXPList % process axopatch amplifiers.
        AmpMode=telegraph; % read em and weep.
        switch(AmpMode.Mode)
            case 'T'
                QueMessage('Amplifier Mode Error: Track Mode - No Acquisition', 1);
                return;
            case '0'
                QueMessage('Amplifier I = 0', 1);
                err = 0; % not an error!
                return;
            case 'V'
                if(~strcmpi('VC', target))
                    QueMessage('Amplifier Mode Error: Amplifier is in Voltage Clamp', 1);
                    QueMessage(sprintf('Protocol requests mode = %s (use sw to switch)', target));
                    return;
                end;
            case {'I', 'F'}

                if(~strcmpi('CC', target))
                    QueMessage('Amplifier Mode Error: Amplifier in Current Clamp', 1);
                    QueMessage(sprintf('Protocol requests mode = %s  (use sw to switch)', target));
                    return;
                end;
            otherwise
                QueMessage('compare_modes: Amplfier status unknown', 1);
                QueMessage(sprintf('Protocol requests mode = %s (use sw to switch)', target));
                err = 1;
                return;
        end;
        err = 0; % ok, we made it
        return;

    case MCList % process multiclamp amplifiers a little differently.
        [AmpMode] = checkMC700Mode; % read em and weep.
        for i = [1,2]
            switch(AmpMode(i).mode)  % get the mode for this amplifier
                case '0'
                    QueMessage('Amplifier I = 0', 1);
                    err = 0; % not an error!
                    return;
                case 'V'
                    if(strcmpi('CC', target))
                        sw(0, 'CC', i);
                        err = 0;
                    end;
                    if(strcmpi('VC', target)) % already in correct mode
                        err = 0;
                        return;
                    end;
                case {'I', 'F'}

                    if(strcmpi('VC', target))
                        sw(-60, 'VC', i);
                        err = 0;%         QueMessage('Amplifier Mode Error: Amplifier in Current Clamp', 1);
                        %        QueMessage(sprintf('Protocol requests mode = %s  (use sw to switch)', target));
                    end;
                    if(strcmpi('CC', target))
                        err = 0; % already in the correct mode
                        return;
                    end;
                otherwise
                    QueMessage('compare_modes: Amplfier status unknown', 1);
                    QueMessage(sprintf('Protocol requests mode = %s (use sw to switch)', target));
                    err = 1;
                    return;
            end;
        end;
    otherwise
        err = 0; % can't read mode, just return OK.
        AmpMode.Mode = 'X'; % unknown
        AmpMode.LPF = 5.0; % filler information.
        AmpMode.Gain = 10.0;
end;

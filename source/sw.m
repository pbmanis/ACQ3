function sw(varargin)
% sw: switch data acquisition modes (detects amplifier telegraphs)
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     sw <cr> waits for user to change amplifier settings, the loads
%             the appropriate default stimuli for that mode.
%
%     sw HOLD automatically loads the specified holding current or
%             voltage when the stimulus parameters are loaded.

% function to switch the data acquisition mode
% sets up the watch operation, and lets sense_mode
% get called when the changes occur.
%
% Basic  operation for Axon Instruments AxoPatch 200 series amplifiers:
% 1. find the current mode (assumed to be either I or V)
% 2. set a threshold accordingly, so that when the switch is moved to the
%    track position, the alternate stimulus file is loaded
% 3. that's all. When the switch is moved to the next position, the correct
%    drive should be applied to the amplifier.
%
% Modified 9/27/01 SCM - added Data field to AmpStatus to prevent voltage estimate.
%
% Modified 9/28/01 SCM - detect entry into I = 0 mode, not exit previous mode
% this corrects for switching between normal & fast CC modes
% this does not require changing stim files
%
% Modified 10/9/01 SCM - allow holding value to be passed as a parameter
% the specified holding level is automatically set when the new stim file is loaded

% Modified 7/11/03 SCM - added Multiclamp amplifier code

% Plan for modification :::::
% 4/28/2004 PBM. Input parameter string is more flexible.
% sw {a,b,c,d, ...} causes switch on amplifier 1,2,3,4, etc.
% sw # causes switch on amplifier 1 with holding (as original)
% sw a # causes switch on amplifier 1,2,3,4 etc. with holding specified.

% also note that BUS parameters must be set up on a "station" basis. One of
% our rigs requires "BUS" be 1, not 0.
%
% 4/18/2004: PBM.
% changed behavior with multiclamp. We now work like axo:
% if you are in VCLAMP, then wait for i=0, load ccstim, then wait for
% ICLAMP.
% if you are in ICLAMP, wait for i=0, load vcstim, then wait for VCLAMP.
% if you are in I=0, give message and DO NOTHING>
%
%
% 2/11/2008 PBM
% changed behavior to accomodate MC700B (which we can control).
% second argument:
% if you specify 'V', we switch the amplifier to V clamp
% if you specify '0' (zero), we switch to I = 0;
% if you specify 'I', we switch to I clamp.
% specify a hold for each of the modes (-60, 0, 0, typical)
% 
% 4/1/2008 PBM
% added third argument, to specify which amplfier to switch...
% if it is unspecified, only the first amplfier is switched. 
% if specified, we attempt to switch that amplifier, as defined in the
% HARDWARE parameter set.
%
global ACQ_DEVICE HARDWARE AO MCList AXPList APRList
global DEVICE_ID WAI CONFIG AmpStatus

oldmclamp = {'old_multiclamp'};

% default parameters

wait_time = 25;  % maximum time to wait for mode change
bus = 1; % for mc700 usb bus control... old version
hold_value = 0;
targetMode = 'C';
InputSelect = 1;
if(nargin >= 1)
    hold_value = varargin{1};
end;
if(nargin >= 2)
    targetMode = varargin{2}; % note that target mode can be an array of modes for each amplfier in the InputSelect list
end;
if(nargin >= 3)
    InputSelect = varargin{3};
end;

% routine can only be called when a device has been registered and
% specified
if (DEVICE_ID > 0)
    amplifier_string = eval(sprintf('HARDWARE.InputDevice%d.Amplifier', InputSelect));
    if(strcmpi(amplifier_string, 'TTL') || DEVICE_ID < 0)
        amplifier_string = 'none';
    end;
else
    return
end

% check for holding level
% convert value to numeric if needed
% may be string when called from command line
if (nargin < 1)
    hold_level = [];
elseif (isnumeric(hold_value))
    hold_level = hold_value;
else
    hold_level = str2double(hold_value);
end

% read the current value
% cannot start in I = 0 mode!
% AmpStatus = telegraph;
old_mode = AmpStatus.Mode;

switch (amplifier_string)

    case AXPList
        if (strcmp(AmpStatus.Mode, '0'))
            QueMessage('sw: caught in track mode, reset and try again', 1);
            return
        elseif (strcmp(AmpStatus.Mode, 'X'))
            QueMessage('sw: cannot read amplifier mode', 1);
            return
        end
        % default parameters for Axopatch mode
        mode_chan = 1;  % index of mode telegraph in AmpStatus.Data field
        mode_tel = [6 4 3 2 1]; % voltages in various modes
        mode_volt = mode_tel(3);  %  voltage in I = 0 mode
        watch_chan = 13; % default ACH for mode input
        watch_range = [-10 10]; % need full range

        % create AI object if needed
        if (~validobj(WAI, 'analoginput'))
            fprintf(2, 'Creating %s Watch Input object\n', upper(ACQ_DEVICE));
            WAI = analoginput(ACQ_DEVICE, sprintf('Dev%d', DEVICE_ID));
        end
        stop(WAI);
        delete(WAI.channel);

        % configure watch input object
        % set channels, define acquisition duration
        % waits for voltage to change
        % 7/11/03 SCM - add TimerFcn to replace timeout
        set(WAI, 'InputType', 'NonReferencedSingleEnded');
        set(WAI, 'DriveAISenseToGround', 'On');
        ai_chans = addchannel(WAI, watch_chan);
        set(ai_chans, 'InputRange', watch_range);
        set(WAI, 'SamplesPerTrigger', 10);
        set(WAI, 'SampleRate', 1000); % takes 100 usec to sample...
        set(WAI, 'TimerFcn', {@sense_mode, old_mode, hold_level});
        set(WAI, 'TimerPeriod', wait_time);
        set(WAI, 'TriggerChannel', ai_chans(1));
        set(WAI, 'TriggerType', 'Software');
        set(WAI, 'TriggerCondition', 'Entering');
        %set(WAI, 'TriggerType', 'HwAnalogChannel');
        %set(WAI, 'TriggerCondition', 'InsideRegion');
        set(WAI, 'TriggerConditionValue', [(mode_volt - 0.5) (mode_volt + 0.5)]);
        set(WAI, 'TriggerDelay', 0.02); % allow 20 msec to settle
        set(WAI, 'TriggerFcn', {@sense_mode, old_mode, hold_level}); % pass the current mode to trigger routine

        % starts waiting for the voltage to cross the threshold
        % we just return at this point. Seems that the callback can't occur until we do.
        start(WAI);
        QueMessage('Waiting for amplifier mode change', 1);

    case oldmclamp

        % call MCSWITCH MEX DLL
        % will respond when mode changes or timeout occurs
        switch AmpStatus.Mode
            case 'V'
                QueMessage('Waiting for amplifier mode change, VC -> I', 1);
            case 'I'
                QueMessage('Waiting for amplifier mode change, IC -> V', 1);
            case '0'
                QueMessage('Amplifier in I=0: Please manually load protocol and manually change mode', 1');
                return;
            otherwise
                QueMessage('Amplifier Mode not recognized (HELP!!!)', 1);
                return;
        end;
        [mode_flag, old_mode, new_mode] = mcswitch(1, bus, 1, wait_time);
        if(mode_flag == 0)
            QueMessage('Timed out waiting for amplifier mode change');
            return;
        end;

        % convert amplifier mode
        switch (old_mode)
            case 'V-Clamp' % voltage clamp
                old_mode = 'V';
            case 'I-Clamp'  % current clamp
                old_mode = 'I';
            case 'I = 0'    % I = 0
                old_mode = '0';
            otherwise       % unknown
                old_mode = 'X';
        end
        switch(new_mode)

            case 'V-Clamp'
                if(old_mode ~= '0') % whoops: quickly try to change (may lose cell)
                    g(CONFIG.VC.v); % hastily load the whole thing
                end;
                default_display(0);
                QueMessage('Switched to VC', 1);

            case 'I-Clamp'
                if(old_mode ~= '0') % try to quickly change, although this is not recommended.
                    g(CONFIG.CC.v); % hastily load the whole thing
                end;
                QueMessage('Switching to CC', 1);

            case 'I = 0' % in the middle, so we can cleanly load the files.
                switch(old_mode)
                    case 'V' % were in voltage clamp, so now go to current clamp.
                        stim=g(CONFIG.CC.v); % read the default file
                        if(~isempty(AO))
                            hold = stim.Holding.v;
                            putsample(AO,[hold 0]); % reset the output levels as quickly as possible
                        end;
                        QueMessage('Complete switch to IC', 1);
                        g(CONFIG.CC.v); % now lazily load the whole thing
                        [mode_flag, old_mode, new_mode] = mcswitch(1, bus, 1, wait_time);
                        if(mode_flag == 0)
                            QueMessage('Timed out waiting for amplifier mode change', 1);
                            QueMessage('Please switch amplifier to CC');
                            return;
                        else
                            switch(new_mode)
                                case 'I-Clamp'
                                    QueMessage('Mode Switch to CC Successful', 1)
                                    default_display(0);
                                    return;
                                otherwise
                                    QueMessage('CHECK AMPLIFIER MODE (SHOULD BE IC) !!!!', 1);
                                    return;
                            end;
                        end;
                    case 'I' % were in current clamp, now go to voltage clamp.
                        stim=g(CONFIG.VC.v); % read the default file
                        if(~isempty(AO))
                            hold = stim.Holding.v;
                            putsample(AO,[hold 0]); % reset the output levels as quickly as possible
                        end;
                        g(CONFIG.VC.v); % now lazily load the whole thing
                        QueMessage('Complete switch to VC', 1);
                        [mode_flag, old_mode, new_mode] = mcswitch(1, bus, 1, wait_time);
                        if(mode_flag == 0)
                            QueMessage('Timed out waiting for amplifier mode change', 1);
                            QueMessage('Please switch amplifier to VC');
                            return;
                        else
                            switch(new_mode)
                                case 'V-Clamp'
                                    default_display(0);
                                    QueMessage('Mode Switch Successful', 1)
                                    return;
                                otherwise
                                    QueMessage('CHECK AMPLIFIER MODE (SHOULD BE VC)!!!!', 1);
                                    return;
                            end;
                        end;

                    otherwise
                        return;
                end;

            otherwise
                QueMessage(['sw: invalid mode change (' new_mode ') for ' amplifier_string], 1);
                return
        end % new mode

    case MCList
        % use the new version...
        if(nargin < 2) % just switch to another mode.....
            switch AmpStatus.Mode
                case {'V', 'VV'}
                    QueMessage('Switching Amplifier, VC -> I', 1);
                    mc700bswitch(1, '0');
                    g(CONFIG.CC.v); % load the CC basic configuration file
                    QueMessage('Switching to CC', 1);
                    mc700bswitch(1, 'I');
                case {'I',  'II'}
                    QueMessage('Switching Amplifier I -> VC', 1);
                    mc700bswitch(1, '0');
                    g(CONFIG.VC.v); % load the save vc protocol.
                    QueMessage('Switching to VC', 1);
                    mc700bswitch(1, 'V');
                case {'0', '00'}
                    QueMessage('Amplifier in I=0, switching to VC', 1);
                    mc700bswitch(1, '0');
                    g(CONFIG.VC.v); % load the save vc protocol.
                    QueMessage('Switching to VC', 1);
                    mc700bswitch(1, 'V');
                    return;
                otherwise
                    QueMessage('Amplifier Mode not recognized (HELP!!!)', 1);
                    return;
            end;
        else
            switch targetMode
                case {'V', 'VC'}
                    QueMessage('Switching Amplifier to VC', 1);
                    mc700bswitch(InputSelect, '0');
                    g(CONFIG.VC.v); % load the VC basic configuration file
                    QueMessage('Switching to VC', 1);
                    mc700bswitch(InputSelect, 'V');
                case {'I', 'CC'}
                    QueMessage('Switching Amplifier to IC', 1);
                    mc700bswitch(InputSelect, '0');
                    g(CONFIG.CC.v); % load the CC basic configuration file
                    QueMessage('Switching to CC', 1);
                    mc700bswitch(InputSelect, 'I');
                case '0'
                    QueMessage('Switching Amplifier to I=0', 1);
                    mc700bswitch(InputSelect, '0');
                otherwise
                    QueMessage('Amplifier Mode not recognized (HELP!!!)', 1);
                    return;
            end;
        end;

    case APRList
    QueMessage ('No switch available for AxoProbe CC amplifier', 1);
    return;
    otherwise
        QueMessage(['Unrecognized Amplifer: ' amplifier_string], 1);
        return;
end;
return;

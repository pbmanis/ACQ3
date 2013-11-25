function [h1] = configure_AO(outrate, AmpStatus)

global AO STIM DFILE
global MCList AXPList APRList HARDWARE
global HOLD_CURRENT

if(~isvalid(AO))
    error('configure AO: invalid analog output object')
end;

h1 = [0 0];

stop(AO);
delete(AO.Channel);
ao_chans = addchannel(AO, 0:1); % set up for 2 channels
set(ao_chans, 'OutputRange', [-10 10]); % actually, only range available on nidaq system
set(AO, 'SampleRate', outrate); % determine the output rate
xmode = upper(DFILE.Data_Mode.v);

mc_debug = 0; % multiclamp debug command.

% we next set the output ranges and gains depending on the mode we are in and the
% capabilities of the amplfier

switch(xmode)
    case {'VC'}
        switch(lower(HARDWARE.InputDevice1.Amplifier)) % set range for amplifiers
            case APRList% use a value of 10 for voltage clamp with an axopatch200
                % this is an error - this amplifier DOES NOT HAVE VC!!!
                QueMessage('Attempt to use AxoProbe amplifier in VC!! (not allowed)');
                return;
            case MCList
                mcdebugprintf(mc_debug, 'acquire_one: using multiclamp amplifier\n');
                c=AmpStatus.Data(1);
                if(strcmp(c.VC_extcmd_unit, 'mV/V') && c.VC_extcmd == 20)
                    set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.multiclamp.OutputUnitsRangeVC(1))); % % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
                    mcdebugprintf(mc_debug, 'acquire_one: multiclamp Outputunitsrange 200 mV/V');
                elseif(strcmp(c.VC_extcmd_unit, 'mV/V') && c.VC_extcmd == 100) % here 10 V command yields 1V.
                    set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.multiclamp.OutputUnitsRangeVC(2)));
                    mcdebugprintf(mc_debug, 'acquire_one: multiclamp Outputunitsrange 1000 mV/V');
                else
                    fprintf(1, 'VC No multiclamp setup, using default?\n');
                    set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.multiclamp.OutputUnitsRangeVC(1)));
                    fprintf(1, 'acquire_one: mc_debug (no amplfier): unitsrange 200');
                end;
                set(ao_chans(1), 'Units', HARDWARE.multiclamp.OutputUnitsVC);
                set(ao_chans(2), 'UnitsRange', symrange(10)); % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
            case AXPList
                set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.axopatch.OutputUnitsRange(1))); % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
                set(ao_chans(1), 'Units', HARDWARE.axopatch.OutputUnitsVC);
                set(ao_chans(2), 'UnitsRange', symrange(10)); % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
            otherwise
                set(ao_chans(1), 'UnitsRange', symrange(200));
        end;
        h1=STIM.Holding.v; % hold;
        putsample(AO, [h1, 0]);
        %putdata(AO,[h1, h1; 0, 0]'); % reset the output levels.
        %start(AO); % necessarey to sync acqusition later.
        %stop(AO);
        
    case {'CC'}
        switch(lower(HARDWARE.InputDevice1.Amplifier)) % set range for amplifiers
            case APRList% use a value of 10 for voltage clamp with an axopatch200
                set(ao_chans(1), 'UnitsRange', HARDWARE.axoprobe.OutputUnitsRangeCC); % use a value of 20000 for the axoprobe 1A
                mcdebugprintf(mc_debug, 'axoprobe mode, CC');
            case MCList % note that channel order on input needs to be swapped.
                c=AmpStatus.Data(1);
                if(strcmp(c.CC_extcmd_unit, 'pA/V') && c.CC_extcmd == 400)
                    set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.multiclamp.OutputUnitsRangeCC(1)/5)); % for current clamp: this yields values in pA.
                    set(ao_chans(1), 'Units', HARDWARE.multiclamp.OutputUnitsCC); % for current clamp: this yields values in pA.
                    mcdebugprintf(mc_debug, ' multiclamp, Set CC for 400 pA/V');
                elseif(strcmp(c.CC_extcmd_unit, 'nA/V') && c.CC_extcmd == 2)
                    set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.multiclamp.OutputUnitsRangeCC(1)));
                    set(ao_chans(1), 'Units', HARDWARE.multiclamp.OutputUnitsCC); % for current clamp: this yields values in pA.
                    mcdebugprintf(mc_debug, ' multiclamp, Set CC for 2 nA/V');
                else
                    QueMessage(1, 'CC Problem with multiclamp setup\n');
                    return;
                end;
            case AXPList
                set(ao_chans(1), 'UnitsRange', symrange(HARDWARE.axopatch.OutputUnitsRangeCC(1))); % for current clamp: this yields values in pA.
                set(ao_chans(1), 'Units', HARDWARE.axopatch.OutputUnitsCC); % for current clamp: this yields values in pA.
                mcdebugprintf(mc_debug, 'axopatch200 \n');
            otherwise
                set(ao_chans(1), 'UnitsRange', symrange(4000));
                mcdebugprintf(mc_debug, 'unknown amplifier - You set some defaults in the configuration\n');
        end;
        set(ao_chans(2), 'UnitsRange', symrange(10)); % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
        h1=HOLD_CURRENT; % hold;
        putsample(AO, [h1, 0]);
        %putdata(AO,[h1, h1; 0, 0]'); % reset the output levels.
        %start(AO); % necessary to sync acquisition latere...
        %stop(AO);
    otherwise % unknown mode...
        set(ao_chans(1), 'UnitsRange', symrange(20000)); % use a value of 20000 for the axoprobe 1A
        set(ao_chans(2), 'UnitsRange', symrange(10)); % for voltage clamp: 10 v command yields 200 mV (e.g. 20 mV/V).
        mcdebugprintf(mc_debug, sprintf('unknown MODE: %s\n', xmode));
end;

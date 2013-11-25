function [] = config_gain(AmpStatus)
% configures AI channel gains on NIDAQ only
% call with config_gain(AmpStatus) where
% AmpStatus is output structure from TELEGRAPH.M

% created 4/24/02 SCM

% MODIFIED 7/9/03 SCM
% set gains on both channels for Multiclamp 700A

global AI ACQ_DEVICE CONFIG DFILE MCList

% only set channel gains with NIDAQ
if (strcmp(ACQ_DEVICE, 'nidaq'))
    amplifier_string = lower(CONFIG.Amplifier.v);
else
    return
end

% set scaled output gain based on mode
if (AmpStatus.Mode == 'V')
    scaled_chan = 2;
    raw_chan = 1;
else
    scaled_chan = 1;
    raw_chan = 2;
end
vg = ones(1, length(AI.Channel));
vg(scaled_chan) = AmpStatus.Gain;

% set stimulus gain if Multiclamp 700A
if (ismember(amplifier_string, MCList))
    
    % convert gain to V/nA (VC) or V/V (CC)
    % base A/D unit should = 1 mV
    switch (AmpStatus.Data(1).raw_unit)
        case 'V/mV'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ 3);
        case 'V/uV'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ 6);
        case 'V/A'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ 9);
        case 'V/mA'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ 6);
        case 'V/uA'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ 3);
        case 'V/pA'
            vg(raw_chan) = AmpStatus.Data(1).raw_gain * (10 ^ -3);
        otherwise   % includes V/mV and V/nA
            vg(raw_chan) = AmpStatus.Data(1).raw_gain;
    end
    
    % set sensor range to max (-2048 -> +2048)
    % ignore DFILE settings which assume telegraphs don't provide raw gain
    sensor_range = (vg .* DFILE.AD_Range.v) ./ (2000 * [1 1]);
    
else
    sensor_range = (vg .* DFILE.AD_Range.v) ./ DFILE.Sensor_Range.v;
end

for j = 1 : length(AI.Channel)
    set(AI.Channel(j), 'InputRange', DFILE.AD_Range.v(j) * [-1 1]);
    set(AI.Channel(j), 'SensorRange', sensor_range(j) * [-1 1]);
end
return

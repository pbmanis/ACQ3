function set_hold()
% set_hold: set analog output holding from STIM block
% Usage
%     Normally not called by user

% function to set analog output based on AO and STIM. Use to set holding.
global DEVICE_ID
global AmpStatus
if(DEVICE_ID <= 0)
    return;
end;
% Configure the analog output *************************************************
% AmpStatus = telegraph; % read the amplifier
% show_ampstatus;
ao_chans = configure_AO(100, AmpStatus);


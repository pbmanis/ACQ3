function set_testmode()
%
% set the program in to model test mode.
%

global ACQ_DEVICE DEVICE_ID

persistent save_old_acq_device
persistent save_old_device_id

if(DEVICE_ID) > 0
    save_old_device_id = DEVICE_ID;
    save_old_acq_device = ACQ_DEVICE;
    ACQ_DEVICE = 'none';
    DEVICE_ID = -1; % set into testmode.
else
    if(exist('save_old_device_id') & ~isempty('save_old_device_id'))
        DEVICE_ID = save_old_device_id;
        ACQ_DEVICE = save_old_acq_device;
    else
        QueMessage('Can''t restore acquisition - only in model mode\nuntil restart\n', 1);
        return;
    end;
end;

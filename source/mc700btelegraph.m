function [status] = mc700btelegraph()
%
% telegraph wrapper for Lukes TCP
% requires using tcp_ip code from mathworks user support.
% Modified 8/1/08 to use Instrument Control Toolbox rather than pnet.
% we always open and close the connection with each call.
%
% return
% mode
% scaled_unit
% scaled_gain
% lpf_unit
% lpf (in lpf_unit)
%
global HARDWARE
% global AmpStatus

persistent gain1errorflag gain2errorflag lpf1errorflag lpf2errorflag

status = [];

if(~exist('gain1errorflag', 'var')) % this flag controls the error report
    gain1errorflag = 0;
    gain2errorflag = 0;
    lpf1errorflag = 0;
    lpf2errorflag = 0;
end;


debugflag = 0;

[conn, err]  = MC700('open');
if(err)
    return;
end;

fprintf(conn, 'getNumDevices()')
ndev = getMC700(conn);
%u = find(ndev == 0);
%ndev(u) = ' '; % clean null strings.

devlist = eval(sprintf('[%s]', ndev)); % evaluate the device list
if(debugflag)
    fprintf(1, 'Devlist: %s\n', ndev);
    for i = devlist
        fprintf(1, 'device: %d\n', devlist(i));
    end;
end;



status = struct ('measure', {}, 'gain', {}, 'unit', {}, 'scaled_unit', {});
for i = fliplr(devlist) % for each device, get the information

        fprintf(conn, 'getDeviceInfo(%d)\n', i-1); % find out what the amplifier type is
    devtype = getMC700(conn);
    devlist = strparse(devtype); % 1 will be mc700 a or b, 2 will be SN
    device{i} =devlist{1};
    status(i).device = device{i};

    fprintf(conn, 'getPrimarySignalInfo(%d)\n', i-1);
    mc700msg = getMC700(conn);

   [vargs, err] = strparse(mc700msg);
    if(err == 0)
        status(i).measure = vargs{1};
        status(i).gain = vargs{2};
        status(i).unit = vargs{3};
        status(i).scaled_unit = ['V/' vargs{3}];
    end;
    if(debugflag)
        fprintf(1, 'Status.gain = %d\n', status(i).gain);
    end;

    fprintf(conn,  'getMode(%d)\n', i-1);
    mc700msg = getMC700(conn);
    [vargs, err] = strparse(mc700msg);
    if(err > 0)
        status(i).mode = 'X';
    end;
    tmode = vargs{1};
    if(debugflag)
        fprintf(1, '\nMode: %s\n', tmode);
    end;

    % we leave this hard codeed because we cannot read it. You must be sure that
    % you have set the amp to the corerect gain settings to match. At some point
    % I will write something to test this when the program is started.
    
    status(i).VC_extcmd = HARDWARE.multiclamp.ExtCmd_VC(i);
    status(i).VC_extcmd_unit = [HARDWARE.multiclamp.OutputUnitsVC '/V'];
    status(i).Zero_extcmd = HARDWARE.multiclamp.ExtCmd_CC(i);
    status(i).Zero_extcmd_unit = [HARDWARE.multiclamp.OutputUnitsCC '/V'];
    status(i).CC_extcmd = HARDWARE.multiclamp.ExtCmd_CC(i);
    status(i).CC_extcmd_unit = [HARDWARE.multiclamp.OutputUnitsCC '/V'];

    switch(unblank(tmode))
        case 'VC'
            status(i).mode = 'V-Clamp';
        case 'I=0'
            status(i).mode = 'I = 0';
        case {'IC', 'C'}
            status(i).mode = 'I-Clamp';
    end;
    fprintf(conn, 'getPrimarySignalGain(%d)\n', i-1);
    mc700bmsg = getMC700(conn);
    [vargs, err] = strparse(mc700bmsg);
    if(err > 0)
        if(~gain1errorflag)
            fprintf(1, 'Unable to get Primary Signal Gain on MC700A amplifier: setting to 1\n');
            gain1errorflag = 1;
        end;
        status(i).scaled_gain = 1;
    end;
    status(i).scaled_gain = str2double(vargs{1});

    fprintf(conn,  'getPrimarySignalLPF(%d)\n', i-1);
    mc700bmsg = getMC700(conn);
    [vargs, err] = strparse(mc700bmsg);
    if(err > 0)
        if(~lpf1errorflag)
            fprintf(1, 'Unable to get Primary Signal LPF on MC700A amplifier: setting to 0\n');
            lpf1errorflag = 1;
        end;
        status(i).lpf = 0;
    end;
    status(i).lpf = str2double(vargs{1});
    status(i).lpf_unit='Hz';

    status(i).scaled_gain2 = 10;
    status(i).lpf2 = 0; % secondary defaults
    status(i).lpf_unit2='Hz';

    switch(device{i})
        case 'MC700B'
            fprintf(conn, 'getSecondarySignalGain(%d)\n', i-1);
            mc700bmsg = getMC700(conn);
            [vargs, err] = strparse(mc700bmsg);
            if(str2double(vargs{1}) < 0.001 || err > 0)
                if(~gain2errorflag)
                    fprintf(1, 'Unable to Secondary Signal Gain on MC700A amplifier: setting to 10\n');
                    gain2errorflag = 1;
                end;
                status(i).scaled_gain2 = 10;
            else
                status(i).scaled_gain2 = str2double(vargs{1});
            end;

            fprintf(conn, 'getSecondarySignalLPF(%d)\n', i-1);
            mc700bmsg = getMC700(conn);
            [vargs, err] = strparse(mc700bmsg);
            if(str2double(vargs{1}) < 0.1 || err > 0)
                if(~lpf2errorflag)
                    fprintf(1, 'Unable to get Secondary LPF on MC700A amplifier: setting to 0\n');
                    lpf2errorflag = 1;
                end;
                status(i).lpf2 = 0;
            else
                status(i).lpf2 = str2double(vargs{1});
            end;
    end;


end;
MC700('close');






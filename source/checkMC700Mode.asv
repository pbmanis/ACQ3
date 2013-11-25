function [t,gain, clist] = checkMC700Mode()


status = [];
debugflag = 0;
t(1).mode = '';
t(2).mode = '';
t(1).gain = 1;
t(2).gain = 1;
clist  = [1];

[conn, err]  = MC700('open');
if(err)
    return;
end;

fprintf(conn, 'getNumDevices()')
    ndev = getMC700(conn); % use slow input mode...
%u = find(ndev == 0);
%ndev(u) = ' '; % clean null strings.

devlist = eval(sprintf('[%s]', ndev)); % evaluate the device list
if(debugflag)
    fprintf(1, 'Devlist: %s\n', ndev);
    for i = devlist
        fprintf(1, 'device: %d\n', devlist(i));
    end;
end;
gain = [1,1];
clist = devlist;

for i = fliplr(devlist) % for each device, get the information

    fprintf(conn,  'getMode(%d)\n', i-1);
    mc700msg = getMC700(conn);
    [vargs, err] = strparse(mc700msg);
    if(err > 0)
        status(i).mode = 'X';
    end;
    switch (unblank(vargs{1}))
        case {'V-Clamp', 'VC'} % voltage clamp
            t(i).mode = 'V';
        case {'I-Clamp', 'IC'}  % current clamp
            t(i).mode = 'I';
        case {'I = 0', 'I=0'}    % I = 0
            t(i).mode = '0';
        otherwise       % unknown
            t(i).mode = 'X';
    end
    if(debugflag)
        fprintf(1, '\nMode: %s\n', t.mode);
    end;
    fprintf(conn, 'getPrimarySignalGain(%d)\n', i-1);

    mc700bmsg = getMC700(conn);
    [vargs, err] = strparse(mc700bmsg);
    if(err > 0)
        t(i).gain = 1;
    else
        t(i).gain = str2double(vargs{1});
    end;
end;
MC700('close');


function [con, err] = MC700(arg)

% open or close the MC700B amplifier connection
% and return a flag to indicate if ok...
%global MC700BConnection

err = 0;
con = [];
persistent MC700BConnection
global DEVICE_ID
if DEVICE_ID == -1
    return
end

if(~exist('MC700BConnection', 'var'))
    MC700BConnection = [];
end;

switch (arg)
    case 'open'
        if(isempty(MC700BConnection))
        %            fprintf(1, 'mc700btelegraph: Making connnection...  ');
            MC700BConnection = tcpip('localhost', 34567);
            try
                fopen(MC700BConnection);
            catch
                fprintf(1, 'Unable to open TCP server\n');
                fprintf(1, 'Cannot Connect to Multiclamp TCP Server\n');
                err = 1;
                return;
            end;
            %            fprintf(1, 'Connection successful\n');
    end;
    con = MC700BConnection;
        while(con.BytesAvailable > 0)
            tmp  = fread(con, con.BytesAvailable, 'char');
        end;



    case 'close'
        if(exist('MC700BConnection', 'var') && ~isempty(MC700BConnection))
            fclose(MC700BConnection);
        MC700BConnection = [];
        end;
        con = [];
    otherwise
end;


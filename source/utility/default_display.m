function default_display(arg)
% default_display: restore display units to default
%
global DFILE
if(nargin == 0)
    arg = 1;
end;
switch(arg)
    case 5 % two cell mode
        switch(lower(DFILE.Data_Mode.v))
            case 'cc'
                vdis(-120, 60);
                idis(-1000, 1000);
                chdis(3, -120, 60);
                chdis(4, -1000, 1000);
            case 'vc'
                chdis(1, -2000, 1000);
                chdis(2, -120, 50);
                chdis(3, -2000, 1000);
                chdis(4, -120, 50);
        end;
        
    case 4
        vdis(-120, 60);
        idis(-1000, 1000);
        chdis(3, -1, 5); % set 3 for TTL pulse....
    case 3
        vdis(-85, -45);
        idis(-1000, 1000);
    case 2
        vdis(-100, 50);
        idis(-1000, 1000);
    case 1
        vdis(-120, 60);
        idis(-2000, 1000);
    otherwise % (0)
        %        DFILE.Data_Mode.v
        switch(lower(DFILE.Data_Mode.v))
            case 'cc'
                chdis(1, -120, 60);
                chdis(2, -1000, 1000);
            case 'vc'
                chdis(1, -2000, 1000);
                chdis(2, -120, 50);
            otherwise
                vdis(-120, 60);
                idis(-1000,1000);
        end;
end;        
return;

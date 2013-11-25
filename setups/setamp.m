function setamp()
%
% command to set all stim routines to the selected amplifier
% mode/configuration
% Basically, runs through all of the routines in the stmpar directory,
% reads the structures, checks the Acquisition Mode, and then runs
% either setmvc, setmcc, setvc, or setcc, depending on the type of amplfier
% that is configured. 
global CONFIG DFILE

spath = slash4OS([CONFIG.BasePath.v '\' CONFIG.StmPath.v]);
f = dir(spath);
amp = lower(CONFIG.Amplifier.v);
if(strfind(amp, 'multiclamp'))
    amplifier = 1;
elseif(strfind(amp, 'axopatch'))
    amplifier = 0;
else
    QueMessage(1, sprintf('Unrecognized Amplifier Type: %s', amp), 1);
    return;
end;
spath
amplifier
for i = 1:length(f)
    [fn, pn, en] = fileparts(f(i).name);
    if(strmatch(en, '.mat', 'exact'))
        g([spath '\' f(i).name]);
        mode = lower(DFILE.Data_Mode.v);
        switch(mode)
            case 'cc'
                if(amplifier == 1)
                    setmcc;
                    s(f(i).name);
                else
                    setcc;
                    s(f(i).name);
                end;
            case 'vc'
                if(amplifier == 1)
                    setmvc;
                    s(f(i).name);
                else
                    setvc;
                    s(f(i).name);
                end;
            otherwise
                QueMessage(sprintf('Unknown acquisition Mode %s in %s', mode, f(i).name), 1);
        end;
    end;
end;

    
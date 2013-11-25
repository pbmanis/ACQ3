function [err] = chkfile(in)
%
% function to check the structure of an input structure against our known structures
% A little awkward, but effective.
%
err = 1; % assume an error has occurred.
%
%
if(nargin ~= 1)
    QueMessage('chkfile: call with one argument input', 1);
    return;
end;

if(~isstruct(in))
    QueMessage('chkfile: Input must be a structure', 1);
    return;
end;

fnl = fieldnames(in);
if(~any(strcmp('NAME', fnl)))
    QueMessage('chkfile: Input structure lacks NAME field', 1);
    return;
end;

switch(in.NAME)
    
    case 'DFILE' % check against current acq structure
        df = new('acq');
        err = chkit(df, fnl, 'DFILE (Acq)');
        return;   % ok...

    case 'CONFIG' % check against current CONFIGURATION structure
        df = new('config');
        err = chkit(df, fnl, 'CONFIG');
        return;   % ok...

    case 'STIM' % check against current STIM structure -  paying attention to the method
        method = in.Method.v;
        switch(method)
            case 'steps'
                df = new('steps');
            case 'pulse'
                df = new('pulse');
            case 'burst'
                df = new('burst');
            case 'SAM'
                df = new('SAM');
            case 'ramp'
                df = new('ramp');
            case 'alpha'
                df = new('alpha');
            case 'noise'
                df = new('noise');
            case 'sine'
                df = new('sine');
            case 'testpulse'
                df = new('testpulse');
            case 'audnerve'
                df = new('audnerve');
            otherwise
                QueMessage(sprintf('chkfile: Method %s not recognized for STIM', method), 1);
                return;
        end;
        err = chkit(df, fnl, 'STIM');
        return;   % ok...

    otherwise
        QueMessage(sprintf('chkfile: Structure with name: %s not checked?', in.NAME), 1);
        return;
end;


function [err] = chkit(df, fnl, name)
err = 1;
dfn=fieldnames(df);
if(length(fnl) ~= length(dfn))
    QueMessage(sprintf('chkfile: %s Structure has wrong length', name), 1);
    fieldnames(df)
    length(fnl)
    length(dfn)
    return;
end;
s = strcmp(fnl, dfn);
if(any(s) ~= 1)
    QueMessage(sprintf('chkfile: %s Structure elements have different names-->', name), 1);
    fprintf(2, '\nChkfile: Unmatched fields in %s structure:\n', name);
    for i = 1:length(s)
        if(s == 0)
            fprintf(2, '(%d): Target: %s       Input: %s\n', i, dfn(i), fnl(i));
        end;
    end;
    return;
end;
err = 0;
return;

function varargout = scriptread(varargin)

% scriptread reads a "script" file with parameters from disk into local
% varaibles.
% the routine returns a structure with the variables stored in it.
%
% the script can contain the following kinds of arguments:
%
% lines starting with % or // are comment lines and are skipped.
% [substructure] : defines a "section" within the structure.
% xyz = "abc" : copies abc as a string into the structure xyz at what
% ever substrucutre position we are in (can be root if no substructure
% designated).

varargout{1} = 0;
if(nargout == 0)
    fprintf(1, 'scriptread Error: Define an output structure to receive the data\n');
    varargout{1} = 1;
    return;
end;
debugme = 0; % debug flag.
s=[];
substruct = [];
filename = varargin{1};
hf = fopen(filename, 'rt');
if(isempty(hf) || exist(filename, 'file') == 0)
    QueMessage(sprintf('Scriptread error: Cannot find file \"%s\"\n', filename));
    varargout{1} = 1;
    return;
end;

while (~feof(hf))
    line = fgetl(hf);

    if(isempty(line) || ~ischar(line)) % skip blank lines and "numeric" results from fgetl
        continue;
    end;

    % skip comment lines
    r = regexp(line, '^s*(%|[//]{2}|[/\*])', 'once' );
    if(~isempty(r))
        if(debugme)
            fprintf(1, 'scriptread.m (debug on): Comment line: %s\n', line);
        end;
        continue; % comment lines need no parsing
    end;

    % define the substructure sections
    r = regexp(line, '^\s*\[(?<dst>\w*)\]', 'names');
    if(~isempty(r))
        if(debugme)
            fprintf(1, 'scriptread.m (debug on): %s : substruct definition\n', line);
        end;
        if(~isfield(s, r.dst)) % create if not defined
            eval(sprintf('s.%s = [];', r.dst)); % create an empty structure
            substruct = r.dst; % get name of current substructure
        else
            substruct = r.dst;
        end;
        continue;
    end;

    %read the data - is it a number ?
    pat = '\s*(?<dst>[a-zA-Z0-9_\-]*)\s*=\s*(?<numarg>((\[)?[\+1|\-1]*\d*\.*\d*\,?\s?)*(\])?)';
    r = regexp(line, pat, 'names');
    if(~isempty(r) && ~isempty(r.numarg)) % no assignment? then check if we have a substructure definition
        if(debugme)
            fprintf(1, 'scriptread.m (debug on): numeric assigment: %s\n', line);
            fprintf(1, '>> %s = %s\n', r.dst, r.numarg)
        end;
        if(~isempty(substruct))
            eval(sprintf('s.%s.%s = %s;', substruct, r.dst, r.numarg));
        else
            eval(sprintf('s.%s = %s;', r.dst, r.numarg));
        end;
        continue;
    end;

    % was not recognized as just a number (or a matlab array expression)
    % try a quoted string
    % note RHS of string is very critical to parsing correctly. Expecialy
    % the \-\.\\ section, to allow hyphens, dots and backslashes in the
    % name
    pat = '\s*(?<dst>[a-zA-Z0-9/_-]*)\s*=\s*["]?(?<src>[a-zA-Z0-9/_\-\.\\:,\s*\[\]]*)["]?';
    r = regexp(line, pat, 'names');
    if(~isempty(r.src)) % no assignment? then check if we have a substructure definition
        if(debugme)
            fprintf(1, 'scriptread.m (debug on): text assigment: %s \n', line);
        end;
        if(~isempty(substruct))
            if(isnumeric(number_arg(r.src)) || (ischar(r.src) && r.src == 'i')) % not a number - parse as a string
                eval(sprintf('s.%s.%s = ''%s'';', substruct, r.dst, r.src));
            else % parse as a number
               s.(sprintf('%s', substruct)).(sprintf('%s', r.dst)) = number_arg(r.src);
            end;
            continue;
        else
            eval(sprintf('s.%s = ''%s'';', r.dst, r.src));
        continue;
        end;
        % not a quoted string - how about a simple string?
        pat = '^\s*(?<dst>\w+)\s*=\s*(?<src>\w+)';
        r = regexp(line, pat, 'tokens');
        if(~isempty(r)) % no assignment? then check if we have a substructure definition
            fprintf(1, 'scriptread.m: text assigment: %s (arg not recognized as a number) \n', line);
            continue;
        end;
    end;
    fprintf(1, 'scriptread.m:: Syntax error in file %s\n   line: %s\n', filename, line);
end;
fclose(hf);
if(nargout >= 1)
    varargout{1} = s;
end;



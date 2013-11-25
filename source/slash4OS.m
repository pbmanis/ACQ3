function strout = slash4OS(strin)
% strout = slash4OS(strin)
% Takes a string, containing paths, and converts any slashes to the correct
% form for the underlying operating system, automatically determining OS

if (strmatch(computer, 'PCWIN', 'exact'))
    newslash = '\';
    oldslash = '/';
else % all others are unix-based.
    newslash = '/';
    oldslash = '\';
end;

oldslashpos = findstr(strin,oldslash);
strin(oldslashpos) = ones(size(oldslashpos))*newslash;
strout = strin;
return;

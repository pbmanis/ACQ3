function mcdebugprintf(debugflag, s)
if(debugflag)
    fprintf(2, 'mc_debug: %s\n', s);
end;
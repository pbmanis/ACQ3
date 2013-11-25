======
Macros
======

One of the features of this program is the ability to write macros, or
scripts that control data acquisition, using MATLAB commands and the
routines/commands available to the program. The ability to use the
power of MATLAB within a macro greatly extends the usefulness of the
macros. Such macros are straightforward to create; however a few rules
must be applied to allow the macros to participate successfully with
the overall action of the program.

---------------
Writing Macros
---------------

Each macro should be defined as an m-file function, and stored in the
macros directory as defined in the configuration. You must always be
sure that the macro handles any errors gracefully, leaving the
relevant flags in a proper state. To help with this, macros must use
two supplied routines to insure proper operation.

At the beginning of the macro, you must check to see that it is ok to
run the macro. The routine ``ok_macro_run`` does several things. First, it
checks to see if the program is in scope mode, and if it is, it stops
scope mode and prints a warning message; the macro is not run (you can
start it again however, and it will run). Second, we make sure that no
macro is currently running: nested macros are not allowed. With the
GUI, which is an event-driven interface, it is possible to start
several processes and not realize that other processes are already
running, since once the macro starts, the menu is still active. Thus,
we prevent starting a second macro. Third, we make sure that a file is
open so we can store data. There is little point in running a large,
complex data collection controlled by a macro if there is no file
open.

Include this code as the first lines of the macro::

    global IN_MACRO \%access the macroflag; this flag will be et
        by theok_macro_runroutineifthemacrocanrun.

    if(~ok_macro_run)
        return
    end;
    

Next, after every acquisition call (e.g., seq or take), there must be
a call as follows::

    if(check_macro_stop)return;end;

This allows the user to use the stop button to stop the macro, without
having to stop each and every protocol that is attempted in the macro.
It may be necessary also to reset the valves (do_valve( manual ), and
turn off the slow voltage clamp (sethold off) if these are being used.
Finally, the last line in the macro should be::

    IN_MACRO=0;

This is to clear the macro flag when a stop is hit. check_macro_stop
routine also performs this action when a macro is stopped from the
button.

Example Macro
The following macro is somewhat complex, but illustrates the proper
way to write a macro. Note that try-catch error handling is wrapped
around the macro, so that if it fails because of a programming error,
the system state is maintained.
This macro controls valves to challenge a cell with a drug, while
running the slow-voltage clamp to keep the membrane potential
constant, and monitors the responses both to single pulses (ltp_base)
and to a parametric pulse protocol (ap-hyp protocol. Note also the
inclusion of a test mode flag, which allows the macro to be tested for
correctness in behavior and coding, without taking the full running
time (50 minutes)::

    functionhyp_drug(arg)
    %hyp_drug.m - protocol to test effect of drugs on discharge pattern
    %7/18/2001
    %PaulB.Manis, Ph.D.
    %pmanis@med.unc.edu
    
    %Required in all macros:
    
    %-----------------------------------------
    globalIN_MACRO
    
    if(~ok_macro_run) % function returns 0 if not ok to run the macro
    return;
    end;
    
    try %handle errors-note that this makes it hard to find
    %the errors, but keeps the program synced
    
    %-----------------------------------------
    %set up a test mode for quick testing to be sure macro works
    %and is error free
    
    testmode=0;%flag:0 is normal full run, 1 is the test mode
    
    nsamp=60%numberofsamplestotake...
    if(testmode)
    nsamp=6;%usefortesting....
    end;
    
    pausetime=1;%setuppausetimer
    if(nsamp==6)%intestmode,weuseashortwait.
    totpause=5;%10secondupdate
    else
    totpause=5*60;%totalpauseinseconds
    end;
    
    
    %---------------------------------------------------------
    %initialize
    %wecontrolthevalves:tellusertoswitchvalvecontrol
    do_valve(computer);
    
    valve(1);%selectvalve1.
    
    %doweuseslowvoltageclamp?
    %anyargumentontheinputissameashyp_drug_manual...
    %-i.e.,wedontsetholdingourselves
    if(nargin==0)
    setholdset%makesureholdingislocked
    end;
    
    gltp_base%baselinemeasurementofbuildupresponse
    
    %inserta5-minutepausebeforewestartthedatacollection
    %toallowthecelltostabilize.
    
    fori=1:floor(totpause/pausetime)
    QueMessage(sprintf(Pausingforstability:%dsecremaining,...
    totpause-(i-1)*pausetime),1);
    pause(pausetime);
    %alinelikethisisnecessaryaftereverycommand
    %tostopthemacrocompletely.
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    end;
    
    %--------------------------------------------------
    %collectbaselinedata
    
    take(nsamp);%setsupfor5minutesas5sec/trial(12/min)
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    
    %dohypprotocolbeforeswitchingthevalves
    gap-hyp
    seq
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    
    %--------------------------------------------------
    %nowchangethevalvetothetestsolution
    %andcollectdataduringdrugwash-in
    
    QueMessage(sprintf(Switchingtovalve%dNOW!!!,2),1);
    valve(2)
    
    gltp_base%measureagainwithsameparametersasbaseline
    take(nsamp*2);%10minutesworthhere...
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    
    %returnthevalvetothenormalsolution
    QueMessage(sprintf(Switchingtovalve%dNOW!!!,1),1);
    valve(1);
    
    %--------------------------------------------------
    %collectpost-drugdata
    %thefollowingloopdoes2things:
    %wewatchandwedoparametericmeasurements
    %watchfor20minutesorso,butkeepdoing
    %thehypprotocolevery5minutes.
    
    fori=1:4
    %do/verifyhypprotocol
    gap-hyp
    seq
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    %
    gltp_base%measureagainwithsameparametersasbaseline
    take(nsamp);%take5minutes
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    end;
    
    %--------------------------------------------------
    %done-nowjustcheckcellpropertiesattheendoftherun
    
    gap-hyp%repeatthehypprotocol.
    seq
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    %
    %getccivagainandre-runwithallparameters
    gap-iv%toconfirmbasiccellinformation
    seq
    if(check_macro_stop)
    do_valve(manual);
    setholdoff
    return;
    end;
    
    %--------------------------------------------------
    %restoredefaultconditions
    
    do_valve(manual);%tellusertoreturnvalvestomanualcontrol
    
    setholdoff%alwaysturnoffslowvclamp
    
    %------REQUIREDOFALLMACROS:::successfulexit
    IN_MACRO=0;%turnoffmacroflag.
    return;
    
    %*********
    %handlematlaberrors.
    
    catch
    QueMessage(Macrohyp_drug:FATALerrordetected(try/catch),1);
    acq_stop;
    do_valve(manual);
    setholdoff;
    IN_MACRO=0;
    return;
    end;
    
    return;%thatsall
    
    




=================
Data Structures
=================

--------------------------------
Stimulus Structure Definitions
--------------------------------

(The following information is out of date, but serves as an example).
The ``stim`` file consists of a base set of information and a variable
section.::

    % Base section
    sfile.title=StimulusParameters;
    sfile.NAME=STIM;
    sfile.callback=paste;
    sfile.frame=FStim; %frame to associate window with
    sfile.fhandles=[]; %handles for data elements
    sfile.method_code=[]; %holds thesource file for the method.
    sfile.waveform=[]; %holds the actual stimulus command waveforms
    sfile.start=1;
    
    %the following are common to all stimtypes:
    
    sfile.Method=create_element(method,SGL,1,Method,%s);
    sfile.Name=create_element(IV,SGL,2,Name,%s);
    sfile.AcqFile=create_element(default,SGL,3,AcqFile,%s);
    sfile.Cycle=create_element(1000,SGL,3,Cycle(ms),%8.1f,0,50,65000);
    sfile.Repeats=create_element(1,SGL,4,Repetitions(N),%d,0,1,1000);
    sfile.Stim_Repeat=create_element(1,SGL,5,ProtocolReps(N),%d,0,1,50);
    sfile.Sample_Rate=create_element(1000,SGL,6,SampleRate(us),%8.1f,0,1);
    
    
    
Variable sections::

    steps:%Create a series of steps with duration and level, with a sequence
    sfile.Sequence=create_element(-100;50/5,SGL,8,Sequence,%c);
    sfile.SeqParList=create_element(Level,SGL,9,SeqParameter,%c);
    sfile.SeqStepList=create_element(2,MULT,10,SeqStepNo,%d,0,1);
    sfile.Duration=create_element([5,100,50],MULT,11,Durations(ms),%8.1f,0
    ,0,30000);
    sfile.Level=create_element([0,-100,0],MULT,12,Level,%8.1f);
    sfile.Holding=create_element([00],MULT,13,Holding,%8.2f);
    sfile.Superimpose=create_element(,SGL,14,Superimpose,%c);
    
    % ramp:
    sfile.Durations=create_element([5,5,400],MULT,11,Durations(ms),%8.1f,0
    ,0,30000);
    sfile.Levels=create_element([-60,-100,0],MULT,12,Levels(mV),%8.1f);
    sfile.Holding=create_element([-600],MULT,13,Holding,%8.2f);
    
    %  pulse:
    sfile.Npulses=create_element(1,SGL,8,NPulses,%d,0,0,65000);
    sfile.Delay=create_element(5,SGL,9,Delay(ms),%7.1f,0,0,100000);
    sfile.IPI=create_element(10,SGL,10,IPI(ms),%8.2f,0,0.001,65000);
    sfile.Duration=create_element([0.1,0.1],MULT,11,Durations(ms),%8.2f,0,
    0,30000);
    sfile.Level=create_element([100,-100],MULT,12,Levels(mV),%8.1f);
    sfile.LevelFlag=create_element(absolute,MULT,13,LevelFlag,%s);
    sfile.Scale=create_element(1,SGL,14,Scale,%8.3f,0,-100000,100000);
    sfile.Offset=create_element(0,SGL,15,Offset,%8.3f,0,-100000,100000);
    sfile.Sequence=create_element(1;100/25,SGL,16,Sequence,%c);
    sfile.SeqParList=create_element(Level,MULT,18,SeqParameter,%c);
    sfile.SeqStepList=create_element(1,MULT,19,SeqStepNo,%d,0,1);
    
    alpha:
    sfile.Npulses=create_element(1,SGL,8,NPulses,%d,0,0,65000);
    sfile.Delay=create_element(5,SGL,9,Delay(ms),%7.1f,0,0,100000);
    sfile.IPI=create_element(10,SGL,10,IPI(ms),%8.2f,0,0.001,65000);
    sfile.Alpha=create_element(0.1,SGL,11,Alpha,%8.2f,0,0,30000);
    sfile.Amplitude=create_element(1,SGL,12,Amplitude,%8.1f);
    sfile.Scale=create_element(1,SGL,14,Scale,%8.3f,0,-100000,100000);
    sfile.Offset=create_element(0,SGL,15,Offset,%8.3f,0,-100000,100000);
    sfile.Sequence=create_element(1;100/25,SGL,16,Sequence,%c);
    sfile.SeqParList=create_element(Level,MULT,18,SeqParameter,%c);
    sfile.SeqLevelList=create_element(1,MULT,19,SeqStepNo,%d,0,1);
    

----------------------------
Data Acquisition Structure
----------------------------
::
    dfile.title=Data AcquisitionParameters;
    dfile.NAME=DFILE;
    dfile.callback=paste;
    dfile.frame=FDfile;
    dfile.fhandles=[];
    dfile.Z_Time=0;
    dfile.F_Time=0;%filetime
    dfile.File_Mode=-1;
    dfile.Block=1;%internal block information
    dfile.Record=1;%incremented internally
    dfile.Actual_Rate=20;%actual rate used by stim board
    
    %definitions
    SGL=0;MULT=1;
    
    %the following parameters are adjustable...
    dfile.start=1;
    dfile.Name=create_element(Default,SGL,1,File,%s);%file
    dfile.Record_Skip=create_element(4,SGL,2,DisplaySkip(n),%d,4,1,100);
    dfile.Refresh=create_element(0,SGL,2,Refresh(n),%d,4,1,100);
    dfile.Data_Mode=create_element(CC,SGL,4,Acquisitionmode,%s);
    dfile.Sample_Rate=create_element(20,SGL,5,SampleRate(us/pt),%d,20,1,65
    000);
    dfile.Points=create_element(5000,SGL,6,Pointsperrecord,%d,2048,256,100
    0000);
    dfile.Channels=create_element([01],MULT,7,Channelstosample,%d,2,1,16);
    dfile.Amplifier_Gain=create_element([00],MULT,8,AmplifierGains,%8.1f,1
    ,0.1,10000);
    dfile.AD_Range=create_element([55],MULT,9,A-DRange(V),%8.2f,5,0.1,1000
    0);
    dfile.Sensor_Range=create_element([20020],MULT,10,SensorRanges,%8.2f,5
    ,0.001,100000);
    dfile.Low_Pass=create_element([10.010.0],MULT,11,LPF(kHz),%8.2f,10.0,0
    .01,1000);
    dfile.High_pass=create_element([00],MULT,12,HPF(kHz),%8.2f,0,0,1000);
    dfile.Junction_Potential=create_element(0,MULT,13,JP(mV),%8.1f,0,-200,
    200);
    dfile.end=1;


-------------------------
Configuration Structure
-------------------------
::
    cfile.title=ConfigurationParameters;
    cfile.NAME=CONFIG;
    cfile.callback=paste;
    cfile.frame=FConfig;
    cfile.fhandles=[];
    cfile.start=1;
    
    cfile.Name=create_element(base,SGL,1,Name,%s);
    cfile.BasePath=create_element(BasePath,SGL,3,BasePath,%s);
    cfile.StmPath=create_element(StmPar,SGL,4,StmPath,%s);
    cfile.AcqPath=create_element(AcqPar,SGL,5,AcqPath,%s);
    cfile.DataPath=create_element(Data,SGL,6,DataPath,%s);
    cfile.Amplifier=create_element(Axopatch200,SGL,7,Amplifier,%s);
    cfile.VC=create_element(VC_Default,SGL,8,VCStim,%s);
    cfile.CC=create_element(CC_Default,SGL,9,CCSTim,%s);
    cfile.end=1;
    

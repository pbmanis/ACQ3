function mitchellreed(varargin)
% implement the triple pulse, subthreshold stimulus paradigm as suggested by 
% Colleen Mitchell and Michael Reed (Duke University), November, 2003.
% Modified to use the new 'testpulse' mode, with "reed" as the file.

global STIM
global STIM2
global ONLINE % access ONLINE to control online display of information.

% parameters for the run.
def_maxt = '4'; % time first and third pulses
def_mint = '0.5';
def_granularity = '0.1'; % step size
def_granularity2 = '0.1'; % outer step size
def_inj = '1000';	% the subthreshold current level	
def_dur = '0.1';

% The following section is required in all macros:

%-----------------------------------------
global IN_MACRO

if(~ok_macro_run) % function returns 0 if not ok to run the macro
    return;
end;
%-----------------------------------------

if(nargin > 0)
    testmode = 1; % set test mode...
else
    testmode = 0;
end;
%testmode = 1;
% we ask for the stimlulus parameters (and make a note!)
prompt={'Enter stimulus Level:','Enter Min 1-3 interval (ms):', 'Enter Max 1-3 interval (ms):', ...
        'Enter granularity (inside) (ms):', 'Enter graularity (outer range) (ms): ', ...
        'Enter I dur (ms):'};
def={def_inj, def_mint, def_maxt, def_granularity, def_granularity2, def_dur};
dlgTitle='Mitchell-Reed triple pulse protocol';
lineNo=1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=inputdlg(prompt,dlgTitle,lineNo,def, options);

if(isempty(answer))
    IN_MACRO = 0; % turn off macro flag.
    QueMessage('Mitchell-Reed cancelled', 1);
    return; % that's all
end;

iinj = str2num(answer{1});
mint = str2num(answer{2});
maxt = str2num(answer{3});
granularity = str2num(answer{4});
granularity2 = str2num(answer{5});
idur = str2num(answer{6});
%
% store the parameters in a note file AT least..... although they are in the stimulus file too...
nb = sprintf('Mitchell-Reed parameters: IInj: %7.1f pA   MIN 1-3 time: %7.1f (ms) Max 1-3 time: %7.1f (ms)\n   Granularity: %7.2f (ms) Granularity (outer): %7.2f (ms)', ...
    iinj, mint, maxt, granularity, granularity2);
note(nb);

tmin = 1; % delay to first pulse in train
tstart = mint; % starting interval to explore (1 msec duration)
nruns = floor(1+((maxt-tstart)/granularity2));
sethold('-60');
for i = 1:nruns
    this_maxt = (i-1)*granularity2+tstart;
    % make sure protocols are current
    g reed;
    STIM.Level.v(1)=iinj;
    %STIM.Level.v(1)=0;
    STIM.Level.v(2)=iinj;
    STIM.Duration.v(1) = idur/2; % start just after the first pulse in the other train
    STIM.Duration.v(2)= idur/2;
    STIM.IPI.v(1) = this_maxt-STIM.Duration.v(2); % change delay time for pulse start 
    STIM.update = 0;
    STIM=pv(STIM, 1);
    
    STIM.TestLevel.v(1)=iinj;
    STIM.TestDuration.v(1)=idur;
    STIM.Sequence.v = sprintf('%f;%f/%f', STIM.Delay.v(1)+idur, STIM.IPI.v(1)+STIM.Delay.v(1)-idur, ...
        granularity);
    STIM.update = 0;
    STIM=pv(STIM, 1);
    pv('-f');
    
    seq
    if(check_macro_stop) 
        sethold off
        return;
    end;
    
    
    
end;
IN_MACRO = 0; % turn off macro flag.
sethold off
return;

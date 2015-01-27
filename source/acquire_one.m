function acquire_one(flag, ntake)
% acquire_one: Acquire one block of data using the information in STIM and DFILE
% Usage
%     This routine is not normally called directly by the user

% 3/2000 P. Manis
% This is the core routine that acquires data, presents stimuli, and writes the file
% It is written as one routine because there are extensive requirements for shared
% communication variables and conditions.
% Included is a test mode for debugging logic when no acquisition system is available.
%
% V1.0 - working. synchronizing the A/D and D/A problem solved
% V1.1 - added file storage support and NRSE/RSE mode commands to control board
%
% v1.2 - added restart mode for scope mode.
% if the scope_flag is 1 before a return, then
% the routine is called again because the return value is 1.
% otherwise, it just runs once. The only cause of a restart is if the
% routine is in scope mode. Note that scope-flag = 2 is "pause" for scope, in which
% the user may be entering commands, and in which scope mode will be resumed
% (via key_press) when the command execution is complete (unless its a command
% that explicitly turns off the scope mode, such as seq).
%
% 10/12/2000 P.Manis.
% Logic changes for better scope mode operation: 10/21/2000
% Added handling of runtime error exceptions - esp. for timeout error
%  to handle failure of external trigger.
%	5/28/01 (also done in 3/1 but lost....) P. Manis
%
% V3.0 4/15/2008 P. Manis
% Changes to secure better gain setting performance - moved sensor range
% etc out to a hardware definition file; modified routines, cleaned by
% lint.
%
% V3.1 8/2008 P. Manis
% Moved the AO settings to configure_AO.m, to be called from sethold as
% well. Replaced putdata in that routine with putsamples, like it used to
% be. Upgraded to MATLAB 7.6 (R2008a) to fix problems with daq reset in
% other areas of program. 
% 
global IN_ACQ

if(IN_ACQ)  % are we acquiring ? uh - can't be - program is modal on this routine (supposedly)
    QueMessage('acquire_one: ? aleady in acquisition', 1);
    return;
end;

% reset the online analysis data if we need to...
try
    on_line('reset')
catch %#ok<CTCH>
    QueMessage('Online reset failed', 1);
end

if(nargin == 0)
    flag = 'take';
    ntake = 1;
elseif(nargin == 1)
    ntake = 1;
end;


while(get_one(flag, ntake) == 1) % the return value depends on the SCOPE_FLAG -
    if(STOP_ACQ == 1)
        break;
    end;
end;
return;


% this is the main routine that actually collects data...

function [retval] = get_one(flag, ntake)

% Most variables are declared global so that we can access them without passing
% them (which takes time).
%
global DFILE STIM DEVICE_ID TEST_MODEL 
global ACQ_FILENAME HFILE FILE_STATUS FILEFORMAT
global AI AO DIO
global SCOPE_FLAG STOP_ACQ ONLINE IN_MACRO IN_ACQ
global HOLD_FLAG HOLD_CURRENT HOLD_VOLTAGE FPOINTS
global AmpStatus
global HARDWARE

retval = 0;
STOP_ACQ = 0;
hfig = findobj('Tag', 'Acq'); % get our handle
if(length(hfig) == 1)
    figure(hfig); % always make us the current figure
else
%    fprintf(2, 'acquire_one: ? Too many figure windows named ''Acq''\n');
    set_in_acq(0);
    return;
end;
if isempty(STIM)
    set_in_acq(0);
    return
end;

% FIRST - determine acquisition modes and set the flags
da_mode = 0;
take_mode = 0;
if(nargin > 0)
    if(strcmp(flag, 'data'))
        da_mode = 1;
    end;
    if(strcmp(flag, 'take'))
        if(nargin == 2)
            take_mode = 1;
        else
            take_mode = 1;
            ntake = 1;
        end;
    end;
end;
% ntake is the number of trials to take in take mode (as: take n)
% da_mode is 1 if we are doing da (continuous acquisition until hit stop
% take_mode is 1 if we are in take mode.
% both modes use the defaults of the stimulus block by ghosting the block
% and setting the "sequence" to []. This should cause the generator code
% generate a single waveform with the default parameters.


% SECOND - check the status for writing the data to a disk file
if(isempty(ACQ_FILENAME)) % no filename, can't write
    filewrite = 0;
    filename = [];
elseif(SCOPE_FLAG > 0) % in scope mode, temporarily do not write
    filewrite = 0;
    filename = [];
else % there is a filename and SCOPE_FLAG == 0
    filewrite = 1;
    filename = fullfile(HFILE.path, [HFILE.filename HFILE.ext]);
end;

if(IN_MACRO && filewrite == 0)
    QueMessage('ACQUIRE_ONE: Running Macro Requires Open File', 1);
    return;
end;

% THIRD - set up the stim file with needed info and write it to disk
sfc = sprintf('sf%d', FILE_STATUS.Block);
getmethod; % store the method in the file

local_sf = STIM; % copy it over

% Compute the output waveforms ************************************************
if(take_mode) % set up the rep counter...
    local_sf.Repeats.v = ntake;
end;
if(da_mode) % set up the rep counter...
    local_sf.Repeats.v = 10000; % almost infinite... doubt if we ever go so far...
end;

switch(local_sf.update) % How do we prepare the stimulus?
    case 0 % compute the whole thing
        if(strcmp(local_sf.Method.v, 'noise')) %we do not store anything because the calculation is done on the fly
            for i = 1: length(local_sf.waveform)
                local_sf.waveform{i}.vsco=0;
                local_sf.waveform{i}.v=0;
                local_sf.waveform{i}.v2=0;
                local_sf.tbase{i}.vsco = 0; % delete the tbase arrays also when saving noise
                local_sf.tbase{i}.v = 0;
            end;
        else
            [outdata, tbase, outrate, err] = eval([local_sf.Method.v '(local_sf)']); % % generate the current stimulus with its method...
            if(err ~= 0)
                QueMessage(sprintf('acquire_one: Stimulus method <%s> failed', STIM.Method.v));
                clean_up([]);
                return;
            end;
            % if we get this far, we should store the resulting waveform...
            for i=1:length(outdata)
                local_sf.waveform{i}.v = single(outdata{i}.v); % store it in the local stim file ... because that is what we will write.
                if(strcmp('v2', fieldnames(outdata{i})))
                    local_sf.waveform{i}.v2 = single(outdata{i}.v2);
                else
                    outdata{i}.v2 = 0*outdata{i}.v;
                    local_sf.waveform{i}.v2 = single(outdata{i}.v2);
                end;
                local_sf.tbase{i}.v = single(tbase{i}.v);
                local_sf.tbase{i}.v2 = single(tbase{i}.v);

            end;
            if(strcmp('vsco', fieldnames(outdata{1})))
                local_sf.waveform{i}.vsco = single(outdata{1}.vsco);
                local_sf.tbase{1}.vsco = single(tbase{1}.v);
            else
                local_sf.waveform{1}.vsco = single(outdata{1}.v);
                outdata{1}.vsco = outdata{1}.v;
                local_sf.tbase{1}.vsco = single(tbase{1}.v);
            end;
            if(strcmp('v2sco', fieldnames(outdata{1})))
                local_sf.waveform{1}.v2sco = single(outdata{1}.v2sco);
            else
                local_sf.waveform{1}.v2sco = single(local_sf.waveform{1}.v2);
                outdata{1}.v2sco = double(local_sf.waveform{1}.v2); %#ok<NASGU>
            end;
        end;

        local_sf.update = 1; % set the update flag
    case 1 % it was already computed, so copy it to local areas for use. (do we really need to do this?)
        if(strcmp(local_sf.Method.v, 'noise')) %we do not store anything because the calculation is done on the fly
            for i = 1: length(local_sf.waveform)
                local_sf.waveform{i}.vsco=0;
                local_sf.waveform{i}.v=0;
                local_sf.waveform{i}.v2=0;
                local_sf.tbase{i}.vsco = 0; % delete the tbase arrays also when saving noise
                local_sf.tbase{i}.v = 0;
            end;
        else
            for i = 1:length(local_sf.waveform)
                if(isempty(strcmp('v2', fieldnames(local_sf.waveform{i}))))
                    local_sf.waveform{i}.v2 = single(0 * local_sf.waveform{i}.v);
                end;
            end;
            if(isempty(strcmp('vsco', fieldnames(local_sf.waveform{1}))))
                local_sf.waveform{i}.vsco = single(local_sf.waveform{1}.v);
                local_sf.tbase{1}.vsco = local_sf.tbase{1}.v;
            end;
            if(isempty(strcmp('v2sco', fieldnames(local_sf.waveform{1}))))
                local_sf.waveform{1}.v2sco = single(local_sf.waveform{1}.v2);
            end;
        end;

    case 2 % in this case, we do the computation on the fly...
        [outdata, tbase, outrate, err] = eval([local_sf.Method.v '(local_sf, 1)']); % generate first stimulus of the group with its method...
        if(err ~= 0)
            return;
        end;
        local_sf.outrate = outrate;

    otherwise
        for i = 1:length(local_sf.waveform)
            outdata{i}.v = double(local_sf.waveform{i}.v); %#ok<AGROW>
            if(strcmp('v2', fieldnames(local_sf.waveform{i})))
                outdata{i}.v2 = double(local_sf.waveform{i}.v2); %#ok<AGROW>
            else
                outdata{i}.v2 = 0*outdata{i}.v; %#ok<AGROW>
                local_sf.waveform{i}.v2 = outdata{i}.v2;
            end;
            tbase{i}.v = double(local_sf.tbase{i}.v); %#ok<AGROW>
        end;
        if(strcmp('vsco', fieldnames(local_sf.waveform{1})))
            outdata{1}.vsco = double(local_sf.waveform{1}.vsco);
            tbase{1}.vsco = double(local_sf.tbase{1}.vsco); %#ok<NASGU>
        else
            outdata{1}.vsco = outdata{1}.v;
            tbase{1}.vsco = double(local_sf.tbase{1}.v); %#ok<NASGU>
        end;
        if(strcmp('v2sco', fieldnames(local_sf.waveform{1})))
            outdata{1}.v2sco = double(local_sf.waveform{1}.v2sco); %#ok<NASGU>
        else
            outdata{1}.v2sco = double(local_sf.waveform{1}.v2); %#ok<NASGU>
        end;
end;

if(~isempty(local_sf.outrate))
    outrate = local_sf.outrate;
end;

eval(sprintf('%s=deal(local_sf);', sfc)); % this copies it to the structure that will be written (to get the name)

if(isempty(sfc))
    QueMessage('Acquire_one: Stimulus block is empty?', 1);
    return;
end;

% get the acquisition parameter file associated with this stim file - if we need to
acqfile = local_sf.AcqFile.v;
if(~isempty(STIM.AcqFile.v) && ~strcmpi(deblank(DFILE.Filename.v), deblank(acqfile)))
    if(ga(acqfile) ~= 0)
        return;
    end;
end;

if(DEVICE_ID >= 0) % check the amplifier status and see if it matches the acquisition file
    [AmpMode, amp_err] = compare_modes(DFILE.Data_Mode.v); % % returns 1 if in error
    if(amp_err)
        return;
    end;
end;

% FOURTH - write the sfile and DFILE information to disk - that's our acquisition parameters
if(~isempty(sfc) && filewrite) % and write it
    if(~isempty(FILEFORMAT))
        save(filename, sfc, '-append', FILEFORMAT);
    else
        save(filename, sfc, '-append');
    end;
    index_file('add', 'STIM', local_sf.Name.v, sfc);
end;

DFILE.Block = FILE_STATUS.Block; % update these with current information
DFILE.Record = FILE_STATUS.Record; % point to first record

dfc = sprintf('df%d', FILE_STATUS.Block);
eval(sprintf('%s=DFILE;', dfc));

if(isempty(dfc))
    QueMessage('Acquire_one: Acquisition block is empty?', 1);
    return;
end;

if(~isempty(dfc) && filewrite)
    if(~isempty(FILEFORMAT))
        save(filename, dfc, '-append', FILEFORMAT);
    else
        save(filename, dfc, '-append');
    end;
    index_file('add', 'DFILE', DFILE.Filename.v, dfc);
end;

err=0; %#ok<NASGU>

% *************************** Configure the acquisition block overall *************************************
nreps=local_sf.Repeats.v;
cycle=local_sf.Cycle.v/1000;

m1 = length(local_sf.waveform); % outdata is a cell array - length is how many stimuli are queued up to present
if(take_mode || da_mode)
    m1 = 1;
end;

time=acq_make_time(DFILE);

% *** Configure On-line analysis ************************************
if(isempty(ONLINE))
    try
        on_line('init', 0);
    catch %#ok<CTCH>
        QueMessage('On_line initialization failed');
    end;
end;
if(~isempty(nreps) && nreps > 0)
    %    cx = cycle*nreps*m1;
else
    %    cx = 50;
    nreps = 5000;
end;

data=[];

% *** Initialize the display area
acq_plot_data(-1, 1, ONLINE, data, filewrite, DFILE);  % this will clear the acq_plot (-1)

% set up temporary file for intermediate storage (speed up acquisition; rebuild structure
% after acquisition is complete.
%
tmp_file = '';
if(~isempty(filename))
    [p, f] = fileparts(filename); 
    tmp_file = sprintf('%s_t_', f); % just the main part of the filename
end;

% *** TEST MODE LOOP ************************************************************
% the test_mode loop just generates data using the actual stimulus to test
% our algorithms etc. Used only when no hardware is found. Its a kind of 'demo'
% mode. 8/3/2000 P. Manis
%
pause on;
if(DEVICE_ID == -1) % just fake data
    set_in_acq(1);
    total_trials = m1*nreps*local_sf.Stim_Repeat.v;
    for BigRepeat = 1:local_sf.Stim_Repeat.v % overall repetition..
        for m = 1:m1
            for i = 1:nreps
                % make fake event block
                % emulates events = AI.EventLog
                %
                timezero = clock; % get the time vector
                events.Type={'start', 'trigger', 'stop'};
                % start event
                events.Data(1).AbsTime=clock;
                events.Data(1).RelSample = 1;
                events.Data(1).Channel = [];
                events.Data(1).Trigger = 1;

                k = nreps * (m-1) + i;
                disp_rec; % show the current record number
                tic;

                % trigger event
                events.Data(2).AbsTime=clock;
                events.Data(2).RelSample = 1;
                events.Data(2).Channel = [];
                events.Data(2).Trigger = 1;

                DFILE.Actual_Rate.v = DFILE.Sample_Rate.v;
                outrate = STIM.Sample_Rate.v/1000;
                duration = (DFILE.Actual_Rate.v/1000)*DFILE.Points.v*length(DFILE.Channels.v);

                if(strcmpi(local_sf.Method.v, 'noise'))
                    ina = IN_ACQ; % temporary fix to save
                    IN_ACQ = 0; %#ok<NASGU>
                    [outdata, tbase, outrate] = eval([local_sf.Method.v '(local_sf, m)']); % % generate first stimulus of the group with its method...
                    IN_ACQ = ina;
                    outrate = 1000/outrate;
                    wave = outdata{1}.v;
                else
                    wave = local_sf.waveform{m}.v';
                end;
                if(strcmpi(DFILE.Data_Mode.v, 'cc'))
                    ampmode = 0;
                    wave = wave/1000;
                else
                    ampmode = 1;
                end;
                [t1, i1, v1] = runNEURON(TEST_MODEL, duration, outrate, wave, ampmode);
                if(STOP_ACQ == 1)
                    gather(filename, tmp_file, filewrite, local_sf);
                    clean_up(tmp_file);
                    return;
                end;
                if(~isempty(t1))
                    v2 = interp1(t1, v1, time);
                    i2 = interp1(t1, i1, time);
                    u = find(isnan(i2));
                    i2(u) = 0; %#ok<FNDSB> % delete the nans - they are just zeros.
                    if ampmode == 0
                        data = [i2; v2]';
                    else
                        data = [v2; i2]';
                    end
                else
                    QueMessage('Model returned empty data', 1);
                    clean_up(tmp_file);
                    return;
                end;

                % stop event
                events.Data(3).AbsTime=clock;
                events.Data(3).RelSample = length(data);
                events.Data(3).Channel = [];
                events.Data(3).Trigger = 1;
                %                rt = clock;
                QueMessage(sprintf('R: %d Trial %d:%d:%d of %d at %s',FILE_STATUS.Record, BigRepeat, m, i, total_trials, datestr(now, 'HH:MM:SS')), 1);

                if(filewrite)
                    % now save the data
                    data_c = sprintf('d_%d_%04d', FILE_STATUS.Block, FILE_STATUS.Record);
                    eval(sprintf('%s.data=single(data);', data_c)); % store data in the structure
                    eval(sprintf('%s.events=events;', data_c)); % store the events in the structure
                    data_f = sprintf('%s%04d', tmp_file, FILE_STATUS.Record);
                    if(~isempty(data_c))
                        if(~isempty(FILEFORMAT))
                            save(data_f, data_c, FILEFORMAT); % make a new file
                        else
                            save(data_f, data_c); % make a new file
                        end;

                        FILE_STATUS.Record = FILE_STATUS.Record + 1;
                    end;
                end;
                acq_plot_data(1, 0, ONLINE, data, filewrite, DFILE);

                if(SCOPE_FLAG == 0)
                    % Do the on line analysis... only if not in scope mode.
                    ola_analysis(data, k);
                end;
                pause(0.01);
                if(STOP_ACQ)
                    retval = SCOPE_FLAG;
                    if(~isempty(filename))
                        gather(filename, tmp_file, filewrite, local_sf);
                        clean_up(tmp_file);
                    end;
                    return;
                end
                while (etime(clock, timezero) < cycle)
                    pause(0.01);
                end; % wait for the end of the cycle
                if(STOP_ACQ)
                    retval =  0; % SCOPE_FLAG;
                    if(~isempty(filename))
                        gather(filename, tmp_file, filewrite, local_sf);
                        clean_up(tmp_file);
                    end;
                    return;
                end;
            end;
        end;
    end;
    if(~isempty(filename))
        gather(filename, tmp_file, filewrite, local_sf);
        clean_up(tmp_file);
    end;
    QueMessage('Model Acquisition Complete', 1);
    acq_stop;
    retval = 0; % SCOPE_FLAG;
    return;
end;

%---------
% end of test_mode. Everything that follows is for real acquisition.
%

% Main control/stimulus loop **************************************************
set_in_acq(1);

% Configure the analog output first *************************************************

AmpStatus = telegraph; % read the amplifier
show_ampstatus;

h1 = configure_AO(outrate, AmpStatus); % value returned is the vclamp holding level
xmode = upper(DFILE.Data_Mode.v);
% Configure Digital IO **************************************************************
if(isempty(DIO))
    DIO = digitalio('nidaq', 'Dev1'); % get the digital IO line
    delete(DIO.Line);
    addline(DIO, 0:1, 'out');
    valve; % install the valves.....
elseif(length(DIO.Line) == 4)
    delete(DIO.Line); % correct the order. Somehow the valves got set first...
    addline(DIO, 0:1, 'out');
    valve; % install the valves.....
end;
putvalue(DIO, [1 1 getvalue(DIO.Line(3:6))]); % set two of the output lines high
getvalue(DIO.Line);

%---------------------

% set the flag for which waveform goes out  - if we are in scope mode, it is special.
swave = 0;
if(SCOPE_FLAG && ~isempty(strcmp('vsco', fieldnames(local_sf.waveform{1}))))
    swave = 1;
end;
if strcmpi(xmode, 'CC')
    HOLD_Value = HOLD_CURRENT + double(HARDWARE.InputDevice1.OutputOffsetCC(1));
else
    HOLD_Value = HOLD_CURRENT + double(HARDWARE.InputDevice1.OutputOffsetVC(1));
end;

%cycle =  cycle - 0.016; % correct cycle so we get a more accurate timing
if(strcmpi(xmode, 'CC') && HOLD_FLAG) % set holding current in current clamp mode only.
    HOLD_Value = adj_rmp(HOLD_VOLTAGE, 1, HOLD_Value);       
    pause(0.5); % let things settle down
end;
stop(DIO);
putvalue(DIO,[1 1 getvalue(DIO.Line(3:6))]); % reset the dio's high again...

resetAI = 1;
AI = init_ai(AI, AmpStatus, resetAI); % set up analog input...
resetAI = 0; % don't reset it after this unless absolutely necessary


acqdebug = 0;
pertime = 0;
for BigRepeat = 1:local_sf.Stim_Repeat.v % overall repetition..
    for m=1:m1 % for each variation of the waveform

        % Main Acquisition Loop *******************************************************
        for i=1:nreps % for each rep of the waveform
            if(IN_ACQ == 0 || STOP_ACQ == 1)
                STOP_ACQ = 1;
                acq_stop;
                return;
            end;
            mcdebugprintf(acqdebug, sprintf('Nrep: %d m: %d  BigRepeat: %d\n', i, m, BigRepeat));
            putvalue(DIO,[1 1 getvalue(DIO.Line(3:6))]); % reset the dio's high again...
            k = nreps * (m-1) + i;
            tic;
            if(~SCOPE_FLAG) % only check satus when we are not in scope mode
                [tmode, amp_err] = compare_modes(DFILE.Data_Mode.v);
                if(amp_err)
                    clean_up(tmp_file);
                    retval = 0; % SCOPE_FLAG;
                    QueMessage('Acquire_one: Stopping, unable to read amp status');
                    return; % whoops....
                end;
                % AmpStatus.Gain=[tmode.gain];
            end;
            if(~SCOPE_FLAG)
                disp_rec;
            end;

            % set up the dac waveform
            if(strcmp(local_sf.Method.v, 'noise')) % for waveforms computed on the fly (e.g., lots of individual ones)
                [outdata, tbase, outrate, err] = eval([local_sf.Method.v '(local_sf, m)']); %#ok<NASGU> % generate each stimulus of the group on the fly...
                if(isempty(strcmp(fieldnames(outdata{1}), 'v2')))
                    outdata{1}.v2 = 0*outdata{1}.v;
                end;
                if(isempty(strcmp(fieldnames(outdata{1}), 'v2sco')))
                    outdata{1}.v2sco = 0*outdata{1}.v2;
                end;
                if(swave)
                    putdata(AO, [outdata{1}.vsco' + HOLD_Value ...
                        ,  outdata{1}.v2sco']); % just use the chosen scope waveform
                else
                    putdata(AO, [outdata{1}.v' + HOLD_Value ...
                        , outdata{1}.v2']);
                end;
            else % for waveforms computed in the batch mode
                if(swave && exist('local_sf.waveform{1}.vsco', 'var'))
                    nmain = length(local_sf.waveform{1}.vsco);
                    if(length(local_sf.waveform{1}.v2sco) > nmain)
                        local_sf.waveform{1}.v2sco = local_sf.waveform{1}.v2sco(1:nmain);
                    else
                        local_sf.waveform{1}.v2sco(end:nmain) = zeros(1, nmain-length(local_sf.waveform{1}.v2sco)+1);
                    end;
                    putdata(AO, double([double(local_sf.waveform{1}.vsco') + double(HOLD_Value) ...
                        , double(local_sf.waveform{1}.v2sco)'])); % just use the chosen scope waveform
                elseif (exist('local_sf.waveform{1}.v2', 'var'))
                        nmain = length(local_sf.waveform{m}.v);
                        nsecond = length(local_sf.waveform{m}.v2);
                        if (nsecond > nmain)
                            local_sf.waveform{m}.v2 = local_sf.waveform{m}.v2(1:nmain);
                        else if (nsecond < nmain)
                                local_sf.waveform{m}.v2(nsecond:nmain) = zeros(1, nmain-nsecond+1);
                            end;
                        end;
                        putdata(AO, double([double(local_sf.waveform{m}.v' + ...
                            double(HOLD_Value)), ...
                            double(local_sf.waveform{m}.v2')]));
                else
                    nmain = length(local_sf.waveform{m}.v);
                    putdata(AO, double([double(local_sf.waveform{m}.v' + ...
                        double(HOLD_Value)), double(zeros(nmain, 1))]));
                end;
            end;
            
%            mcdebugprintf(acqdebug, 'Waveform Computed and loaded\n');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CORE ACQUISTION CODE: Do NOT MODIFY
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            AI = init_ai(AI, AmpStatus, 1); % set up analog input...
            set(AO,'TransferMode', 'SingleDMA');
            set(AO,'TriggerType', 'HwDigital'); % trigger on digital line outputs
            set(AO, 'HwDigitalTriggerSource', 'PFI6');
            set(AO, 'TriggerCondition', 'PositiveEdge');

            
 
            nchan = length(DFILE.Channels.v);
            nsamp = DFILE.Points.v;
            data = zeros(DFILE.Points.v, nchan);
            [AI, ai_chans] = init_ai(AI, AmpStatus, resetAI);
            start([AI AO]); % but wait for the DIO... 
            pause(0.04); % delay seems necessary to be sure AO is set up
            if((i * m * BigRepeat) == 1) % on first cycle, start DIO when we are ready
                stop(DIO);
                putvalue(DIO, [0 0 getvalue(DIO.Line(3:6))]);
                set(DIO, 'TimerPeriod', cycle);
                DIO.TimerFcn = {'acqtimer'};
                putvalue(DIO, [1 1 getvalue(DIO.Line(3:6))]);
                start(DIO); % timer just runs until we don't need it anymore.
            end;
            % it is critical to test STOP_ACQ here - otherwise async call to acq_stop or bye can
            % kill the AI while we are "running", causing an error. 
            while(~STOP_ACQ && isvalid(AI) && (get(AI, 'SamplesAvailable') < nsamp)) % && (toc  < cycle*1.2))
                pause(0.01);
            end;
            if(STOP_ACQ || ~isvalid(AI)) % verify the stop conditions.
                retval = 0; % SCOPE_FLAG;
                gather(filename, tmp_file, filewrite, local_sf);
                clean_up(tmp_file);
                return;
            end
            if(isvalid(AI) && (get(AI, 'SamplesAvailable') > 0))
                if(~STOP_ACQ)
                    [data, time] = getdata(AI); %#ok<NASGU>
                else % handle condition where stop was requested  and # samples may be "short" of request
                    stop([AI AO]);
                    switch xmode
                        case 'CC'
                            putsample(AO,[HOLD_CURRENT, 0]); % reset the output levels.
                        case 'VC'
                            putsample(AO,[h1, 0]);
                        otherwise
                            putsample(AO,[0, 0]);
                    end;
                    retval = 0; %SCOPE_FLAG;
                    gather(filename, tmp_file, filewrite, local_sf);
                    clean_up(tmp_file);
                    return;
                end
            end;
            stop([AI AO]);
            %
            % END OF CORE ACQUISITION CODE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % fprintf(1, 'data = %8.2f  %8.2f\n', data(10,1), data(10,2));
            % fprintf(2, 'h1: = %8.2f\n', h1(1));
            rt = AI.InitialTriggerTime; % get the trigger time...
            rms1 = std(data(:,1)); % get rms value of top trace
            rms2 = std(data(:,2));
            FPOINTS = data(1,:);
            QueMessage(sprintf('R: %d Trial %d:%d:%d at %2d:%2d:%4.2f    rms1=%6.2e rms2=%6.2e\n Per: %8.3f s', ...
                FILE_STATUS.Record, BigRepeat, m, i, fix(rt(4)),fix(rt(5)),rt(6), rms1, rms2, round(1000*pertime)/1000), 1);
            events = AI.EventLog; %#ok<NASGU>
            
            % reset the output levels to the holding level
            switch xmode
                case 'CC'
                    putsample(AO,[HOLD_Value, 0]); % reset the output levels.
                case 'VC'
                    putsample(AO,[h1, 0]);
                otherwise
                    putsample(AO,[0, 0]);
            end;
            
            if(filewrite)
                % now save the data by constructing a structure... 
                data_c = sprintf('d_%d_%04d', FILE_STATUS.Block, FILE_STATUS.Record);
                eval(sprintf('%s.data=single(data);', data_c)); % store data in the structure
                eval(sprintf('%s.events=events;', data_c)); % store the events in the structure
                eval(sprintf('%s.status=AmpStatus;', data_c)); % store amplifier status too
                data_f = sprintf('%s%04d', tmp_file, FILE_STATUS.Record);
                if(~isempty(data_c))
                    if(~isempty(FILEFORMAT))
                        save(data_f, data_c, FILEFORMAT); % make a new file
                    else
                        save(data_f, data_c); % make a new file
                    end;
                    FILE_STATUS.Record = FILE_STATUS.Record + 1;
                end;
            end;

            if(SCOPE_FLAG == 0)
                % Do the on line analysis... only if not in scope mode.
                ola_analysis(data, k);
            end;
            if(IN_ACQ > 0) % don't update plot if STOP was hit.
                acq_plot_data(1, 0, ONLINE, data, filewrite, DFILE);
            end;
            pause(0.01);
            if(STOP_ACQ)
                retval = 0; %SCOPE_FLAG;
                gather(filename, tmp_file, filewrite, local_sf);
                clean_up(tmp_file);
                return;
            end
            if(strcmpi(xmode, 'CC') && HOLD_FLAG)
                while (toc < (cycle-0.5)) % until almost at end time, then... check for holding adjustment
                    pause(0.01);
                end; % wait for the end of the cycle
                HOLD_Value = adj_rmp(HOLD_VOLTAGE, 1, HOLD_CURRENT);
            end;

            pertime = toc;
            if(STOP_ACQ)
                retval = 0; % SCOPE_FLAG;
                gather(filename, tmp_file, filewrite, local_sf);
                clean_up(tmp_file);
                return;
            end
        end
    end
end;
stop(DIO);

QueMessage('Acquisition Complete', 1);
retval = 0; % SCOPE_FLAG;
gather(filename, tmp_file, filewrite, local_sf);
clean_up(tmp_file);
return;


function clean_up(tmp_file)
% clean up all that is necessary to clean up before returning
global STOP_ACQ DEVICE_ID  AI

if(~isempty(tmp_file))
    x=dir(sprintf('%s*', tmp_file));
    if(~isempty(x))
        for i = 1:length(x)
            if(x(i).isdir == 0)
                delete(x(i).name); % delete the temporary files
            end;
        end;
    end;
end;
if(DEVICE_ID >= 0 && isvalid(AI))
    set(AI, 'RuntimeErrorFcn', 'daqaction'); % restore the default run time error callback routine
end;
set_in_acq(0);
STOP_ACQ = 0;
return;



function gather(filename, tmp_file, filewrite, local_sf)
%
% function to gather all the independent files of name tmp_file*
% and store them under the block db####{:}as .data and .events...
% this will work whether we make temp files ourselves, or let
% the data acquisition toolbox do disk streaming
% 10/17/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%

global FILE_STATUS SCOPE_FLAG FILEFORMAT
% gather the files and store a new block
if (SCOPE_FLAG > 0 || ~filewrite) % be sure we need to write before doing this
    return;
end;

x=dir(sprintf('%s*', tmp_file)); % find the files generated
block_id = sprintf('db_%d', FILE_STATUS.Block);
if(~isempty(x))
    for i = 1:length(x)
        if(x(i).isdir == 0)
            eval([block_id '{i} = load(x(i).name);']);
        end;
    end;

    if(~isempty(block_id))
        if(~isempty(FILEFORMAT))
            save(filename, block_id, '-append', FILEFORMAT); % build data file
        else
            save(filename, block_id, '-append'); % build data file
        end;
        index_file('add', 'DATA', local_sf.Name.v, block_id); % add the information to the index file
        FILE_STATUS.Block = FILE_STATUS.Block + 1; % only increment the block after we gather data sets and some data is written
    end;
end;

return;


function [AI, ai_chans] = init_ai(AI, AmpStatus, resetAI) %#ok<INUSD>
% set up for this acquisition

global DFILE

% *** Set channels, define acquisition duration *********************
nchan=length(DFILE.Channels.v);
% DFILE.rate is in microseconds per point sampled... aggregate basis all channels.
% We convert that to sample per second for the matlab daq system.
samp_rate = 10^6/(DFILE.Sample_Rate.v*nchan);
duration = DFILE.Points.v / samp_rate; % duration (in seconds) for each epoch

if(isempty(AI) || ~isvalid(AI))
    delete(AI);
    AI = analoginput('nidaq','Dev1');   % now get a new one
    resetAI = 1; %#ok<NASGU> % force re-evaluation
end;
if(isrunning(AI)) % make sure we are stopped when we get this call.
    stop(AI);
end;

% Configure the AI ***********************************************************
% Set channels, define acquisition duration
if(isvalid(AI))
    %    bufsize = round(duration*samp_rate*2/nchan);
    stop(AI);
    % set(AI, 'ChannelSkewMode', 'Minimum');
    delete(AI.Channel);
    % get acquisition configuration - interaction between hardware
    % and the DFILE acquisition settings

    ca = configure_acquisition;
    ai_chans = addchannel(AI, [ca.chan]); % sample rate must be set after this

    % now set channel gains...
    % the standard values must be modified according to what we read from the amplifier
    % Units: these are the data units themselves
    % InputRange: this is the a/d input range (in volts) - e.g., 10 V
    % SensorRange: this is the range of the sensor device (in this case the
    % amplifier) that corresponds to the UnitsRange. The sensor range is the
    % compliance limit of the amplifier, not the sensor itself.
    % UnitsRange: the range of the input units corresponding to the sensor
    % range.
    for i = 1: length(ca)
        % units and inputrange are not modified by channel
        set(ai_chans(i), 'Units', ca(i).units);
        ir = setverify(ai_chans(i), 'InputRange', symrange(ca(i).inputrange)); %#ok<NASGU>
        % sensor range depends on gain, as does the units range. gain is
        % usually a string, not a number, so make sure it converts.
        whichamp = floor((i+1)/2);
        whichchan = mod(i,2)+1;
        switch(whichchan)
            case 1
                ur = ca(i).unitsrange/(AmpStatus.Data(whichamp).scaled_gain); %*str2double(AmpStatus.Data(1).gain));
            case 2
                ur = ca(i).unitsrange/(AmpStatus.Data(whichamp).scaled_gain2); % *str2double(AmpStatus.Data(2).gain));
        end;

        set(ai_chans(i), 'SensorRange', symrange(ca(i).sensorrange(1)));
        set(ai_chans(i), 'UnitsRange', symrange(ur));
    end;

    set(AI, 'SampleRate', samp_rate); % must be set AFTER addchannel is done
    % The board may not set the sample rate to the exact value we used,
    % so lets get the actual value and then compute the new buffer size.
    ActualRate = get(AI, 'SampleRate'); % is returned in microseconds

    % DFILE.rate is in microseconds per point sampled...
    % We convert that to sample per second for the matlab daq system.
    DFILE.Actual_Rate.v=ActualRate; % save it
    bufsize = round(duration*ActualRate*2/nchan);
    nsamp = round(duration*ActualRate); %/ nchan;

    set(AI, 'InputType', 'NonReferencedSingleEnded'); % Must be set before addchannel
    set(AI, 'DriveAISenseToGround', 'Off'); % set before addchannel
    set(AI, 'SamplesPerTrigger', nsamp);
    set(AI, 'BufferingMode', 'Manual');
    set(AI, 'BufferingConfig', [bufsize,3]); % needed to allow long buffers.
    % set up the skew for the minimum amount. This makes the sampling
    % nearly simultaneous for each group of channels.%
    set(AI, 'ChannelSkewMode', 'Equisample'); % keep samples close in time.
    % skew = get(AI, 'Channelskew');
    set(AI, 'TransferMode', 'SingleDMA');
    set(AI, 'RuntimeErrorFcn', 'acq_timeout');
    set(AI, 'Timeout', 5);
    set(AI, 'TriggerType', 'HwDigital'); % don't allow triggers.
    set(AI, 'HWDigitalTriggerSource', 'PFI6'); 
    set(AI, 'TriggerCondition', 'PositiveEdge');

else
    if(~isvalid(AI))
        QueMessage('No valid input device?');
        return;
    end;
end;
return;





function pulse_edit(cmd, varargin)
% Usage: pulse_edit(cmd)
%  called internally with 'edit stim2'. Creates a GUI to adjust the stimulus parameters for PULSE waveforms
%  only. future versions might implement other parameters...
%  7/01 Paul B. Manis pmanis@med.unc.edu
%  first version: rough, but works.
%  1/02 Second version. Cleaned up. Doesn't call 'stimcontrol' routines any more (which caused some
% significant confusion.....
%

global  STIM STIM2 % reference secondary stimulus; also primary so we can update it.
global SCOPE_FLAG
persistent old_lratio
stimtype = 0;
if nargin > 1
    SF2 = varargin{1};
else
    SF2 = STIM2; % copy from the global space
end;

if ~isempty(SF2)
    if(strcmpi('testpulse', SF2.Method.v))
        stimtype = 1; % indicate test pulse method.
    end;
end

if(nargin == 0) % when called with no command, build the window or update it with the new information
    old_lratio = 0;
    
    if(isempty(SF2)) % ? no block
        g2; % get a secondary stimulus parameter block
        if(isempty(SF2))
            return;
        end;
        
    end;
    if(~strcmpi(SF2.Method.v, {'pulse', 'burst', 'testpulse'})) % the method must be pulse
        QueMessage('pulse_edit: Require stimulus method PULSE or TESTPULSE', 1);
        return;
    end;
    SF2.LevelFlag.v = 'absolute';
    stim_pv(SF2);
    % method is pulse, so we can go ahead and make a new window for the controls
    
    h = findobj('Tag', 'PEdit');
    if(isempty(h))
        %open('pulse_editor.fig');
        pulse_editor(); % call our m-routine instead of guide
        h = findobj('Tag', 'PEdit');
        set(h, 'menubar', 'none');
        set(h, 'toolbar', 'none');
        local_Update(SF2);
    else
        figure(h);
    end;
    
    
else
    switch(cmd)
        case 'slider'
            hp = findobj('Tag', 'PEdit_level');
            hs = findobj('Tag', 'PEdit_slider');
            newlevel = get(hs, 'Value');
            if(SF2.Scale.v < 0)
                newlevel = abs(newlevel);
            end;
            set(hp, 'String', sprintf('%7.2f', newlevel));
            pulse_edit('level', SF2);
            STIM2 = SF2;
            return;
            
        case 'changesign'
            hp = findobj('Tag', 'PEdit_negative');
            negflag = get(hp, 'value'); % if box is checked, use negative leading; negflag will be 1
            if(negflag)
                SF2.Scale.v = -abs(SF2.Scale.v);
            else
                SF2.Scale.v = abs(SF2.Scale.v);
            end;
            hp = findobj('Tag', 'PEdit_level');
            newlevel = str2num(get(hp, 'string')); %#ok<*ST2NM>
            if(SF2.Scale.v < 0)
                newlevel = abs(newlevel);
            else
                newlevel = abs(newlevel);
            end;
            
            set(hp, 'String', sprintf('%7.2f', newlevel));
            pulse_edit('level', SF2);
            
        case 'npulse'
            hcmd = findobj('Tag', 'PEdit_npulse');
            oldnp = SF2.Npulses.v;
            np = get(hcmd, 'string');
            SF2.Npulses.v = floor(str2num(np));
            if(oldnp ~= SF2.Npulses.v) % if it changed, update it.
                stim_pv(SF2);
            end;
            
        case 'ipi'
            hcmd = findobj('Tag', 'PEdit_ipi');
            oldipi = SF2.IPI.v;
            ipi = get(hcmd, 'string');
            SF2.IPI.v = str2num(ipi);
            if(oldipi ~= SF2.IPI.v)
                stim_pv(SF2);
            end;
            
        case 'delay'
            hcmd = findobj('Tag', 'PEdit_delay');
            olddelay = SF2.Delay.v;
            delay = get(hcmd, 'string');
            SF2.Delay.v = str2num(delay);
            if(olddelay ~= SF2.Delay.v)
                stim_pv(SF2);
            end;
            
        case 'durp1'
            hcmd = findobj('Tag', 'PEdit_durp1');
            olddur1 = SF2.Duration.v(1);
            dur1 = get(hcmd, 'string');
            SF2.Duration.v(1) = str2num(dur1);
            if(olddur1 ~= SF2.Duration.v(1))
                stim_pv(SF2);
            end;
            
        case 'durp2'
            hcmd = findobj('Tag', 'PEdit_durp2');
            olddur2 = SF2.Duration.v(2);
            dur2 = get(hcmd, 'string');
            SF2.Duration.v(2) = str2num(dur2);
            if(olddur2 ~= SF2.Duration.v(2))
                stim_pv(SF2);
            end;
            
        case 'scale'
            hcmd = findobj('Tag', 'PEdit_scale');
            oldscale = SF2.Scale.v;
            scale = get(hcmd, 'string');
            SF2.Scale.v = str2num(scale);
            if(oldscale ~= SF2.Scale.v)
                stim_pv(SF2);
            end;
            
        case {'level', 'l1l2'}
            hcmd = findobj('Tag', 'PEdit_level');
            lev = str2num(get(hcmd, 'String'));
            oldlev = SF2.Level.v(1);
            hrat = findobj('Tag', 'PEdit_l1l2'); % get the ratio
            lratio = str2num(get(hrat, 'String'));
            SF2.Level.v(1) = lev;
            SF2.Level.v(2) = lev*lratio;
            SF2.LevelFlag.v = 'absolute';
            hslider = findobj('Tag', 'PEdit_slider');
            if(SF2.Scale.v > 0)
                set(hslider, 'value', SF2.Level.v(1)); % move the slider to match the value we typed in.
            else
                set(hslider, 'value', SF2.Level.v(1));
            end;
            % note slider only shows positive numbers...
            if(stimtype == 999) % only let it edit these directly if not in testpulse mode.
                hs = findobj('tag', 'PEdit_sequence');
                SF2.Sequence.v = sprintf('%7.1f', SF2.Level.v(1));
                set(hs, 'string', SF2.Sequence.v);
                SF2.SeqParList.v = 'Level';
                hs = findobj('tag', 'PEdit_Seqpar');
                set(hs, 'string', 'level');
                SF2.SeqStepList.v = 1;
                hs = findobj('tag', 'PEdit_seqparn');
                set(hs, 'string', 1);
            end;
            if(oldlev ~= SF2.Level.v(1) || old_lratio ~= lratio)
                stim_pv(SF2);
            end;
            
        case 'seqpar'
            hcmd = findobj('Tag', 'PEdit_Seqpar');
            sno = get(hcmd, 'String');
            oldsno = SF2.SeqParList.v;
            SF2.SeqParList.v = sno;
            if(~strcmp(oldsno,SF2.SeqParList.v))
                stim_pv(SF2);
            end;
            
        case 'seqparn'
            hcmd = findobj('Tag', 'PEdit_seqparn');
            sno = get(hcmd, 'String');
            oldsno = SF2.SeqStepList.v;
            SF2.SeqStepList.v = str2num(sno);
            if(length(SF2.SeqStepList.v) > 1)
                SF2.SeqStepList.v = SF2.SeqStepList.v(1);
            end;
            if(oldsno ~= SF2.SeqStepList.v)
                stim_pv(SF2);
            end;
            
        case 'sequence'
            hcmd = findobj('Tag', 'PEdit_sequence');
            sno = get(hcmd, 'String');
            oldsno = SF2.Sequence.v;
            SF2.Sequence.v = sno;
            if(~strcmp(oldsno,SF2.Sequence.v))
                stim_pv(SF2);
            end;
            
        case 'testlevel'
            if(stimtype == 1)
                hcmd = findobj('Tag', 'PEdit_TestLevel');
                sno = get(hcmd, 'String');
                oldsno = SF2.TestLevel.v;
                SF2.TestLevel.v = str2num(sno);
                if(oldsno ~= SF2.TestLevel.v)
                    stim_pv(SF2);
                end;
            end;
            
        case 'testduration'
            if(stimtype == 1)
                hcmd = findobj('Tag', 'PEdit_TestDuration');
                sno = get(hcmd, 'String');
                oldsno = SF2.TestDuration.v;
                SF2.TestDuration.v = str2num(sno);
                if(oldsno ~= SF2.TestDuration.v)
                    stim_pv(SF2);
                end;
            end;
            
        case 'testdelay'
            if(stimtype == 1)
                hcmd = findobj('Tag', 'PEdit_TestDelay');
                sno = get(hcmd, 'String');
                oldsno = SF2.TestDelay.v;
                SF2.TestDelay.v = str2num(sno);
                if(oldsno ~= SF2.TestDelay.v)
                    stim_pv(SF2);
                end;
            end;
             
        case 'testipi'
            if(stimtype == 1)
                hcmd = findobj('Tag', 'PEdit_TestIPI');
                sno = get(hcmd, 'String');
                oldsno = SF2.TestIPI.v;
                SF2.TestIPI.v = str2num(sno);
                if(oldsno ~= SF2.TestIPI.v)
                    stim_pv(SF2);
                end;
            end;
                        
        case 'testsequence'
            if(stimtype == 1)
                hcmd = findobj('Tag', 'PEdit_TestSequence');
                sno = get(hcmd, 'String');
                oldsno = SF2.TestSequence.v;
                SF2.TestLevel.v = sno;
                if(~strcmp(oldsno, SF2.TestSequence.v))
                    stim_pv(SF2);
                end;
            end;
            
            % button commands:
            
        case {'close', 'exit'}
            h = findobj('Tag', 'PEdit');
            close(h);
            return;
            
        case 'open'
            g2;
            if(isempty(STIM2))
                return;
            end;
            if(~strcmp(STIM2.Method.v, 'pulse'))
                QueMessage('pulse_edit: Requires stimulus method PULSE', 1);
                return;
            end;
            h = findobj('Tag', 'PEdit');
            if(ishandle(h))
                set(h, 'Name', sprintf('Pulse Editor: %s', STIM2.Name.v));
            end;
            local_Update(SF2);
            stim_pv(SF2);
            
            
        case 'changefile'
            if(isempty(SF2))
                return;
            end;
            if(~strcmp(SF2.Method.v, {'pulse','testpulse'})) % only if we are pulse mode
                return;
            end;
            h = findobj('tag', 'PEdit');
            if(ishandle(h))
                set(h, 'Name', sprintf('Pulse Editor: %s', SF2.Name.v));
            end;
            local_Update(SF2);
            stim_pv(SF2);
%            fprintf(1, 'STIM2 changed in P_Edit\n');
            
        case 'save'
            s2(SF2.Name.v);
            
        case 'update'
            %  SF2.Sequence.v = sprintf('%8.1f', SF2.Level.v(1));
            %  hcmd = findobj('Tag', 'PEdit_sequence');
            %  set(hcmd, 'String', SF2.Sequence.v);
            %stim_pv; % recalculate our local waveform
            s2(SF2.Name.v); % save the file to disk....
            %  STIM.update = 0;
            SF2.update = 0;
            STIM2 = SF2; % copy over before doing the calculation
            pv('-f'); % force update of main one too
            if(SCOPE_FLAG) % if we are in scope mode, stop and restart to update the stimulus.
                acq_stop;
                scope;
            end;
            h = findobj('Tag', 'PEdit');
            figure(h);
            
        case 'PV' % just preview locally....
            stim_pv(SF2);
            
        case 'addchannel' % force to add channel with main stimulus...
            STIM.Addchannel.v = SF2.Name.v;
            struct_edit('redisplay', STIM);
            stim_pv(SF2);
            s2(SF2.Name.v);
            STIM2 = SF2;
            pv('-f'); % force update of main one
            if(SCOPE_FLAG) % if we are in scope mode, stop and restart to update the stimulus.
                acq_stop;
                scope;
            end;
            
            
        otherwise
            QueMessage(sprintf('pulse_edit: Unrecognized Command: %s', cmd));
            return;
    end;
end;


function local_Update(SF2)

h = findobj('tag', 'PEdit');

set(h, 'Name', sprintf('Pulse Editor: %s', SF2.Name.v)); % display name in the title bar field.

h = findobj('tag', 'PEdit_negative');
if(SF2.Scale.v < 0)
    set(h, 'value', 1);
else
    set(h, 'value', 0);
end;
h = findobj('tag', 'PEdit_slider');
set(h, 'value', abs(SF2.Level.v(1)));
set(h, 'min', 0);
set(h, 'max', 1000);
h = findobj('tag', 'PEdit_level');
set(h, 'string', sprintf('%7.2f', SF2.Level.v(1)));
if(length(SF2.Level.v) > 1)
    h = findobj('tag', 'PEdit_l1l2');
    set(h, 'string', sprintf('%7.2f', SF2.Level.v(2)/SF2.Level.v(1)));
end;
h = findobj('tag', 'PEdit_npulse');
set(h, 'string', sprintf('%d', SF2.Npulses.v));
h = findobj('tag', 'PEdit_ipi');
set(h, 'string', sprintf('%7.1f', SF2.IPI.v));
h = findobj('tag', 'PEdit_durp1');
set(h, 'string', sprintf('%7.1f', SF2.Duration.v(1)));
if(length(SF2.Duration.v) > 1)
    h = findobj('tag', 'PEdit_durp2');
    set(h, 'string', sprintf('%7.1f', SF2.Duration.v(2)));
end;
h = findobj('tag', 'PEdit_delay');
set(h, 'string', sprintf('%7.1f', SF2.Delay.v));
h = findobj('tag', 'PEdit_Seqpar');
set(h, 'string', sprintf('%s', SF2.SeqParList.v));
h = findobj('tag', 'PEdit_seqstepn');
set(h, 'string', sprintf('%d', SF2.SeqStepList.v));
h = findobj('tag', 'PEdit_sequence');
set(h, 'string', sprintf('%s', SF2.Sequence.v));
if(strcmp(SF2.Method.v, 'testpulse'))
    h = findobj('tag', 'PEdit_TestLevel');
    set(h, 'string', sprintf('%s', num2str(SF2.TestLevel.v)));
    h = findobj('tag', 'PEdit_TestDuration');
    set(h, 'string', sprintf('%s', num2str(SF2.TestDuration.v)));
    h = findobj('tag', 'PEdit_TestDelay');
    set(h, 'string', sprintf('%s', num2str(SF2.TestDelay.v)));
end;


hg = findobj('tag', 'PEdit_graph');
set(hg, 'FontSize', 7);
stim_pv(SF2);
return;


function stim_pv(SF2)

SF2.update = 0;
SF2 = pv(SF2, 1); % update without showing the display; return updated structure to us.

hp = findobj('tag', 'PEdit_graph');
if(isempty(hp))
    return;
end;
cla(hp);
hg = findobj('tag', 'PEdit_graph');
set(hg, 'FontSize', 7);
n = length(SF2.tbase);
for i = 1:n
    line(F2.tbase{i}.v, SF2.waveform{i}.v, 'Parent', hp, 'color', 'black'); % now display our own copy of the data.
    hold on;
end;
line(SF2.tbase{1}.vsco, SF2.waveform{1}.vsco, 'Parent', hp, 'color', 'red');
return;



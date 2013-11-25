function [argo] = pv(varargin)
% pv: Preview display of the command waveforms
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%   pv <cr> generates the waveforms associated with the current STIM structure
%   pv(stile) generates the waveforms associated with the input sfile argument, which
%      must be a STIM style structure
%   out = pv () returns the stim structure with the computed waveform and any updated variables

% 7/10/2000
% Paul B. Manis, Ph.D.   pmanis@med.unc.edu
% second parameter nodisp: prevents data from being displayed if it is present (value is irrelevant)
% NODISP is no longer used.
% 1/14/2002
% PBM. Adjusted logic to correctly load secondary stimulus. Note that secondary stimulus is actually
% generated by combine.m, as called at the end of the methods (steps, pulses, noise, ramp, etc.).
% The waveforms are stored in struct.waveform.v, v2, vsco, v2sco.
% Since calling the method also computes the addchannel/superimpose waveform, this is all that needs to
% be done.
% singular updates of structures can be accomplished by calling:
% STIM2 = pv(STIM2, 1) (which updates STIM2 into STIM2, without displaying the result).
%
% 6/21/2012 COmpltely changed the logic - hopefully cleaner...
% added ability to just update channel 2...

global STIM STIM2 STIMBUFFER

if nargin == 0
    STIM = pv2(STIM);
    pv_plot(STIM, 1); % always plot
    if nargout == 1
        argo = STIM;
    end
       return;
end;

if(nargin >= 1)
    sfile = varargin{1};
end;


if isstruct(sfile)
   mode = 1; % operating on a data structure
else 
   mode = 0; % operating on a command
end;

if(mode && nargout ~= 0)
    argo = sfile; % just set it as default
end;

if mode == 0 % parse on the commands
    switch sfile
        case '1' % just compute #1 channel and replot
            STIM.update = 0;
            s1 = pv2(STIM);
            pv_plot(s1, 1);
            if nargout > 0
                argo = s1;
            else
                STIM = s1;
            end;
            return
        case '2' % just compute #2 channel and replot
            STIM2.update = 0;
            s2 = pv2(STIM2);
            pv_plot(s2, 2);
            if nargout > 0
                argo = s2;
            else
                STIM2 = s2;
            end;
            return
            
        case {'f', '-f'} % do both channels
            if STIMBUFFER == 1 && ~isempty(STIM.Addchannel.v)
                [err, STIM2] = g2(STIM.Addchannel.v); % get the second buffer
                if err % probablly failed to find the addchannel name
                    return
                end;
            end;
            STIM2.update = 0;
            STIM2=pv2(STIM2); % read the file from disk and recalculate it
            STIM.update = 0;
            STIM = pv2(STIM);
            pv_plot(STIM, 1);
            pv_plot(STIM, 2);
            
        case '-p' % just plot (that's all, no calculation)
            pv_plot(STIM, 1);
            pv_plot(STIM, 2);
            return;
        otherwise
            fprintf(2, 'pv: Unknown input command: %s\n', sfile);
            return
    end;
end

if(nargout > 0)
    argo = STIM;
end;
return


function [out] = pv2(sfile)

if sfile.update == 1 && ~isempty(sfile.waveform)
    out = sfile;
    QueMessage('PV: waveform is current');
    return;
end;
% otherwise we calculate the waveform

QueMessage('PV: computing...');
% try
[outdata, time_base, out_rate, err] = eval(sprintf('%s(sfile);',  sfile.Method.v));
% catch
%     QueMessage('PV: Stimulus Genenration Error (Fatal)', 1);
%     return;
% end;
if(err ~= 0)
    QueMessage('PV: Stimulus generation error');
    return;
end;
if(size(time_base, 1) ~= size(outdata, 1))
    outdata = outdata';
end;
if(size(time_base) ~= size(outdata))
    QueMessage('PV: Sizes of stim and time_base not matching?'); % this really should not occur
    return;
end;
QueMessage('PV: waveform computed', 1);
l=length(outdata);
sfile.waveform = [];
sfile.tbase=[];
sfile.waveform{1}.vsco = outdata{1}.vsco;
if(any(strcmp('v2sco', fieldnames(outdata{1}))))
    sfile.waveform{1}.v2sco = outdata{1}.v2sco;
end;
sfile.tbase{1}.vsco = time_base{1}.vsco;
for i = 1:l
    sfile.waveform{i}.v = outdata{i}.v; % store waveform here ... we can use it later.
    if(any(strcmp('v2', fieldnames(outdata{i}))))
        sfile.waveform{i}.v2 = outdata{i}.v2;
    end;
    sfile.tbase{i}.v = time_base{i}.v;
    sfile.outrate = out_rate;
end;
sfile.update = 1; % we computed - set the flag
out = sfile;
return


function pv_plot(stimfile, chan)
global STIMBUFFER
% now plot the waveform in sfile
h0 = findobj('Tag', 'Acq'); % get the big window
if(ishandle(h0))
    figure(h0); % force to be on top when we do this
end;
figsz=get(h0, 'Position');
hu = findobj('Tag', 'UtilityFrame'); % Plot in utility window
if(~isempty(hu))
    % make the on-line window (1)
    set(hu, 'Visible', 'off');
end;
hc = get(hu, 'UserData'); % get list of handles in the frame
if(~isempty(hc))
    for i=1:length(hc)
        if(ishandle(hc(i)))
            if i == chan
                if hc(i) == 0
                    continue
                end;
                delete(hc(i));
            end;
        end;
    end
end;
hc = []; % clear the handle list.
set(hu, 'UserData', hc); % keep it synchronized

framesz = get(hu, 'Position');
fsize = 7;
c_ax = [0.37 0.37 0.8];
if chan == 1
    pvw1=[0.08 0.08 0.84 0.45];
    pvf1 = frameit(pvw1, framesz, figsz);
    hp(1)=subplot('position', [pvf1.left, pvf1.bottom, pvf1.width, pvf1.height]);
    axno = 1;
elseif chan == 2
    pvw2=[0.08 0.65 0.84 0.35];
    pvf2 = frameit(pvw2, framesz, figsz);
    hp(2)=subplot('position', [pvf2.left, pvf2.bottom, pvf2.width, pvf2.height]);
    axno = 2;
end;

if isempty(stimfile)
    cla
    return
end;
p_type = 0; % stairs is default
if(any(strcmp(stimfile.Method.v, {'noise', 'alpha', 'sine', 'audnerve'})))
    p_type = 1;
end;

if axno == 1
    cla;
    hold off;
    if ~isempty(stimfile.waveform)
        
        if ~isempty(strcmp('v', fieldnames(stimfile.waveform{1})))
            showplot(stimfile, 'v', '-w', p_type);
        end;
        if(~isempty(strcmp('vsco', fieldnames(stimfile.waveform{1}))))
            showplot(stimfile, 'vsco', 'r', p_type);
        end;
    else
        cla
        hold off;
    end
elseif axno == 2
    cla;
    hold off;
    if STIMBUFFER == 1
        if ~isempty(stimfile.waveform)
            
            if ~isempty(strcmp('v2', fieldnames(stimfile.waveform{1})))
                showplot(stimfile, 'v2', '-g', p_type);
            end;
            if ~isempty(strcmp('v2sco', fieldnames(stimfile.waveform{1})))
                showplot(stimfile, 'v2sco', '-m', p_type);
            end;
        else
            cla
        end;
    end;
    if STIMBUFFER == 2
        if ~isempty(stimfile.waveform)
            
            if ~isempty(strcmp('v', fieldnames(stimfile.waveform{1})))
                showplot(stimfile, 'v', '-g', p_type);
            end;
            if ~isempty(strcmp('vsco', fieldnames(stimfile.waveform{1})))
                showplot(stimfile, 'vsco', '-m', p_type);
            end;
        else
            cla
        end;
    end;
end

if axno == 1
    set(gca, 'Tag', 'ACQ_DAC0');
    acq_setcrosshair(gca, 'DAC0', 'ms', '', ...
        [pvf1.left+pvf1.width*0.95 pvf1.bottom+pvf1.height*0.5 pvf1.width*0.22 pvf1.height*0.2]);
    ha = gca;
elseif axno == 2
    set(gca, 'Tag', 'ACQ_DAC1');
    acq_setcrosshair(gca, 'DAC1', 'ms', '', ...
        [pvf2.left+pvf2.width*0.95 pvf2.bottom+pvf2.height*0.5 pvf2.width*0.22 pvf2.height*0.2]);
    ha = gca;
end;

set(ha, 'box','off');
set(ha, 'color', 'black');
set(ha, 'XColor', c_ax);
set(ha, 'YColor', c_ax);
set(ha, 'Fontsize', fsize);
set_axis;

set(hu, 'UserData', hp);

return;

function showplot(stimfile, var, color, p_type)
maxpltpts = 2048;
sw = stimfile.waveform;
tb = stimfile.tbase;
for i=1:length(sw)
    switch var
        case 'v'
            d = sw{i}.v;
            t = tb{i}.v;
        case 'vsco'
            if i ~= 1
                continue
            end;
            d = sw{i}.vsco;
            t = tb{i}.vsco;
        case 'v2'
            if ~any(strcmp('v2', fieldnames(sw{i})))
                continue
            end;
            
            d = sw{i}.v2;
            t = tb{i}.v;
        case 'v2sco'
            if ~any(strcmp('v2sco', fieldnames(sw{i}))) || i ~= 1
                continue
            end;
            d = sw{i}.v2sco;
            t = tb{i}.vsco;
            
        otherwise
            return;
    end;
    np = length(d);
    skip = 1;
    if(np > maxpltpts)
        skip = floor(np/maxpltpts);
    end;
    if(~p_type)
        [x1, y1] = stairs(t, d);
        plot(x1, y1, color);
    else
        plot(t(1:skip:end), d(1:skip:end), color);
    end;
    hold on;
end

        


function set_axis()
% set current axes to encompass the data
v = axis;
if(v(3) < 0)
    v(3) = v(3)*1.1;
else
    v(3) = v(3)*0.9;
end;
if(v(4) < 0)
    v(4) = v(4)*0.9;
else
    v(4) = v(4)*1.1;
end;
if(v(3) == 0)
    v(3) = -0.1 * v(4);
end;
if(v(4) == 0)
    v(4) = -0.1*v(3);
end;
axis(v);
return;



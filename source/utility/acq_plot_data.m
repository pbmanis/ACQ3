function acq_plot_data (varargin)
% (erase_flag, first, ONLINE, data, flag, IN_DFILE)
% acq_plot: plot data in ACQ windows
% Usage:
%     Not normally called directly by the user
%
% We plot the data in the right side of the main window, according to the controllinig information
% ini displim/chlim
% Input variables:
% erase_flag: if set to 1, forces erase and redraw of axes before plotting
% first: if set to 1, indicates first draw of this window.
% online; contains the online analysis information (currently incomplete)
% data: is the data array to be plotted.
% flag: indicates whether plot is in scope mode or not. If it is not,
%     we behave normally. If it is 0, we are in "scope" mode, and traces are drawn
%     once only in a different way than normal. Also, the axes and trace color are different
%     if 'flag' is 2, we plot in green also
% IN_DFILE: contains the data file information (rates, etc; like datac dfile structure)

% 2/22/2001.
% Paul B. Manis, Ph.D.
% Multiple channel display incorporated.
%
% 7/4/05 - changed to use varargin and assign based on input call....
% also added DISPCTL structure to control how the display appears.
% DISPCTL has the following parameters:
% .online   = 1, enables online window; = 0, disables online window.
% .ysizes  - array of ysizes for data to be shown. Sum is divided up, so
% you can scale it as you wish. Default is [2 1 1 1 1 1 1 1]. The number of
% channels displayed is used, so with 2 channels, ch 1 would get twice the
% space of ch2; with 3 channels, ch1 would be half the screen, and 2 and 3
% would share the rest, etc....


global BUTTONS
global ONLINE_DATA DFILE
global DEVICE_ID
global DISPCTL ONLINE

% maintain variables as persistent within this routine, across calls.
persistent HFRAME
persistent HLINE % handle of lines in plot for scope mode...
persistent HL % handle array of lines in regular mode display
persistent HP % handle list of plots in the display.
persistent HO % handle list of on-line graphs.
persistent time tmax % time array and max limit
persistent rfc % refresh counter and counter information
persistent rfn % max refresh
persistent rfcol % color.

% Initialize DISPCTL here if it is empty; but we can change it with another
% routine elsewhere.
%
if(isempty(DISPCTL))
    initdispctl;
end;

if(~isempty(ONLINE) && any([ONLINE.Enable{:}]))
    DISPCTL.online = 1; % allow the online analysis to show up on top
else
    DISPCTL.online = 0;
end;


% very first thing: verify that we have the right window to work with
h0 = findobj('Tag', 'Acq'); % get the big window
if(isempty(h0))
    return; % usually happens when we close out.
end;
% (erase_flag, first, ONLINE, data, flag, IN_DFILE)

if(nargin == 1)
    erase_flag = varargin{1};
    first = 1; ONLINE = []; data = []; scope_flag = 1; IN_DFILE = DFILE;
end;

if(nargin == 2)
    erase_flag = varargin{1}; first = varargin{2};
    ONLINE = []; data = []; scope_flag = 1; IN_DFILE = DFILE;
end;
if(nargin == 3)
    erase_flag = varargin{1}; first = varargin{2}; ONLINE = varargin{3};
else
    data = []; scope_flag = 1; IN_DFILE = DFILE;
end;
if(nargin == 4)
    erase_flag = varargin{1}; first = varargin{2}; ONLINE = varargin{3};  data = varargin{4};
else
    scope_flag = 1; IN_DFILE = DFILE;
end;

if(nargin == 5)
    erase_flag = varargin{1}; first = varargin{2}; ONLINE = varargin{3}; data=varargin{4}; scope_flag = varargin{5};
else
    IN_DFILE = DFILE;
end;
if(nargin == 6)
    erase_flag = varargin{1}; first = varargin{2};
    ONLINE = varargin{3}; data=varargin{4}; scope_flag = varargin{5};
    IN_DFILE = varargin{6};
end;


if(isfield(IN_DFILE, 'Refresh') && IN_DFILE.Refresh.v == 0) % we have nothing to refresh - just return
    return;
end;


c_ax = [0.37 0.37 0.9]; % axes color
c_da = [1 1 1]; % default plot color
c_sc = [0 1 0; 1 0 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
fsize=7; % font size
emode_sc = 'background'; % erase mode when running in scope mode
emode_da = 'background'; % erase mode when running in data acquisition...

msg_pos = [0.37 0.00 0.15 0.07]; %#ok<NASGU> % messages (changes later...)

if(scope_flag == 0 || scope_flag == 2) % set plotting color for data and axis depending on mode
    c_ax = [0.5 0.5 0.5];
    c_da = [1 0 0]; % plot in color when not storing data is RED
end;
if(DEVICE_ID == -1)
    c_da = [1 1 0]; % in testmode, plot yellow.
    c_ax = [0.3 0.3 0.3];
end;

dfile = IN_DFILE; % make time base
nchannel = length(dfile.Channels.v);
if(first)
    time=acq_make_time(dfile);
    tmax = max(time);
end;
if(isempty(data))
    data = NaN*zeros(length(time),nchannel);
end;

bs=size(time);
bufsize=bs(2);
skip = dfile.Record_Skip.v;
if(isempty(HP) || length(HP) < nchannel) % handles to plots here...
    first = 1;
    %   QueMessage('acq_plot_data.m: HP is empty, generating plot',1);
end

if(first==1) % rebuild the screen ('erase'), but we may proceed to use it to plot data (if erase_flag > 0)
    rfc = 1; % clear refresh counter
    if(~isempty(HP)) % delete previous line objects...
        k = ishandle(HP);
        delete(HP(k));
        HP = [];
    end;
    if(~isempty(HO))
        k = ishandle(HO);
        delete(HO(k));
        HO=[];
    end;

    h0 = findobj('Tag', 'Acq'); % get the big window
    figsz=get(h0, 'Position');

    h2=findobj('Tag', 'DataFrame'); % now get the frame we work inside
    set(h2, 'Visible', 'off');

    hola = findobj('Tag', 'OLAFrame');
    set(hola, 'Visible', 'off');

    hutil = findobj('Tag', 'UtilityFrame');

    if(~isempty(HFRAME)) % remove elements of the frames
        for i=1:length(HFRAME)
            if(ishandle(HFRAME(i)))
                delete(HFRAME(i));
            end;

        end
    end;
    HFRAME = []; %#ok<NASGU> % clear the handle list.

    figure(h0); % point to the figure
    set(gcf, 'Backingstore', 'off'); % change the graphing mode
    set(gcf, 'Renderer', 'painters');
    HLINE = []; % all of the lines in the plot have been erased...

    % frame and figure sizes are in characters - for general compatibility with Unix
    framesz = get(h2, 'Position'); % get the frame within which we will draw
    ofr = get(hola, 'Position');
    ufr = get(hutil, 'Position'); % position of utility frame...
    % extend the frame if the on-line stuff is OFF
    if(DISPCTL.online == 0 && DISPCTL.utility == 1)
        framesz(4) = ofr(4) + BUTTONS.y*0.65-1 + 2; % increase by the height of the ola.
    else
        framesz(4) = ofr(2) - 2; % set back to lower position, which is ola's bottom position
    end;
    if(DISPCTL.online == 0 && DISPCTL.utility == 0)
        % turn off the utility plot...
        set(hutil, 'Visible', 'off');
        hp_util = get(hutil, 'UserData'); % get list of handles in the frame
        if(~isempty(hp_util))
            for i=1:length(hp_util)
                if(ishandle(hp_util(i)))
                    delete(hp_util(i));
                end;
            end
        end;

        framesz(4) = ofr(4) + ufr(4) + BUTTONS.y*0.65-1+5;
    end;

    set(h2, 'Position', framesz);

    wl = 0.08; %#ok<NASGU>
    ww = 0.90; %#ok<NASGU>
    wh1 =0.60; %#ok<NASGU>
    wh2 = 0.25;
    w1b = wh2 + 0.09; %#ok<NASGU>
    w2b = 0.05; %#ok<NASGU>

    %   if(nchannel<=2) % build the basic data plotting areas for 2 plots (large/small)
    %       sp1=[wl w1b ww wh1];
    %       sp1f = frameit(sp1, framesz, figsz);
    %       sp2=[wl w2b  ww wh2];
    %       sp2f = frameit(sp2, framesz, figsz);
    %   else % multiple channels requested: just make all the same size
    t = 0.95;
    b = 0.05;
    suma = sum(DISPCTL.ysizes(1:nchannel)); % get area to show
    dy = (t-b)*DISPCTL.ysizes(1:nchannel)/suma;
    for ind = 1:nchannel
        %   ht = (t - b) / nchannel; % n equally spaced windows...
        %        jind = nchannel - ind + 1;
        yp = t - sum(dy(1:ind)) -b/2;
        eval(sprintf('sp%d=[wl %f  ww %f];', ind, yp, dy(ind)*0.9));
        eval(sprintf('sp%df = frameit(sp%d, framesz, figsz);', ind, ind));
    end;
    %  end

    % now we set the display scaling

    % the DFILE.Data_Mode determines the y display factors and title.
    switch(lower(dfile.Data_Mode.v))
        case 'cc' % for current clamp, display the voltage on top, big, and the current below
            ytop = sort([DISPCTL.ymin(1) DISPCTL.ymax(1)]);
            ybot = sort([DISPCTL.ymin(2) DISPCTL.ymax(2)]);
            %             for ivc = 1:2:length(DISPCTL.unit)
            %                 DISPCTL.unit{ivc+1} = 'pA';
            %                 DISPCTL.unit{ivc} = 'mV';
            %             end;
            ytt = DISPCTL.unit{1};
            ytb = DISPCTL.unit{2};
        case 'vc'
            ytop = sort([DISPCTL.ymin(1) DISPCTL.ymax(1)]);
            ybot = sort([DISPCTL.ymin(2) DISPCTL.ymax(2)]);
            %             for ivc = 1:2:length(DISPCTL.unit)
            %                 DISPCTL.unit{ivc} = 'pA';
            %                 DISPCTL.unit{ivc+1} = 'mV';
            %             end;
            ytt = DISPCTL.unit{1};
            ytb = DISPCTL.unit{2};
        case 'fp'
            ytop = [-2 2];
            ybot = [-2 2];
            DISPCTL.unit{1} = 'mV';
            DISPCTL.unit{2} = 'mV';
            ytt = DISPCTL.unit{1};
            ytb = DISPCTL.unit{2};
        otherwise
    end;

    if(isnan(ytop))
        ytop = 100;
    end;

    % main window 1 - always up (dependent variable)
    HP(1)=subplot('position', [sp1f.left sp1f.bottom sp1f.width sp1f.height]);
    set(gca, 'Tag', 'Acq_MW1');
    set(gca, 'XLimMode', 'manual');
    set(gca, 'YLimMode', 'manual');
    set(gca, 'XLim', [0 max(time)]);
    set(gca, 'YLim', ytop);
    set(gca, 'color', 'black');
    set(gca, 'XColor', c_ax);
    set(gca, 'YColor', c_ax);
    if(nchannel == 1)
        xlabel('T (ms)');
    else
        set(gca, 'XTickLabel', {}); % no tick labels
    end;
    set(gca, 'Fontsize', fsize);
    if(DISPCTL.grid(1))
        set(gca, 'GridLinestyle', ':');
        grid on;
    end;
    ylabel(ytt);
    v = get(gca, 'Xlim');
    v(2)=tmax;
    set(gca, 'Xlim', v);
    % insert the crosshair/cursor readout
    acq_setcrosshair(gca, 'MW1', 'ms', DISPCTL.unit{1}, ...
        [sp1f.left+sp1f.width*.8 sp1f.bottom+sp1f.height sp1f.width*0.15 sp1f.height*0.15]);
    %        [sp1f.left+sp1f.width*0.85 sp1f.bottom+sp1f.height*0.8 sp1f.width*0.1 sp1f.height*0.2]);

    % main window 2 - always up (independent variable)
    HP(2) = subplot('position', [sp2f.left sp2f.bottom sp2f.width sp2f.height]);
    set(gca, 'Tag', 'Acq_MW2');
    set(gca, 'XLimMode', 'manual');
    set(gca, 'YLimMode', 'manual');
    set(gca, 'XLim', [0 max(time)]);
    set(gca, 'YLim', ybot);
    if(DISPCTL.grid(2))
        set(gca, 'GridLinestyle', ':');
        grid on;
    end;
    set(gca, 'Fontsize', fsize);
    if(nchannel == 2)
        xlabel('T (ms)');
    else
        set(gca, 'XTickLabel', {}); % no tick labels
    end;
    ylabel(ytb);
    v = get(gca, 'Xlim');
    v(2)=tmax;
    set(gca, 'Xlim', v);
    set(gca, 'color', 'black');
    set(gca, 'XColor', c_ax);
    set(gca, 'YColor', c_ax);
    %set(gca, 'Tag', 'Iframe');
    % insert the crosshair/cursor readout
    acq_setcrosshair(gca, 'MW2', 'ms', DISPCTL.unit{2}, ...
        [sp2f.left+sp2f.width*0.8 sp2f.bottom+sp2f.height sp2f.width*0.15 sp2f.height*0.15]);
    %        [sp2f.left+sp2f.width*0.8 sp2f.bottom+sp2f.height*0.6 sp2f.width*0.1 sp2f.height*0.2]);

    if(nchannel > 2) % for multiple channels if they are present
        for ind = 3:nchannel % main window 3
            eval(sprintf('HP(%d) = subplot(''position'', [sp%df.left sp%df.bottom sp%df.width sp%df.height]);', ...
                ind, ind, ind, ind, ind));
            set(gca, 'Tag', sprintf('Acq_MW%d', ind));
            set(gca, 'XLimMode', 'manual');
            set(gca, 'XLim', [0 max(time)]);
            %            if(diff(CHLIM(ind).V) ~= 0)
            set(gca, 'YLimMode', 'manual');
            set(gca, 'YLim', [DISPCTL.ymin(ind) DISPCTL.ymax(ind)]);
            %            else
            %               set(gca, 'YLimMode', 'auto');
            %          end;
            if(DISPCTL.grid(ind))
                set(gca, 'GridLinestyle', ':');
                grid on;
            end;
            set(gca, 'Fontsize', fsize);
            ylabel(sprintf('%s', DISPCTL.unit{ind}));
            if(nchannel == ind)
                xlabel('T (ms)');
            else
                set(gca, 'XTickLabel', {}); % no tick labels
            end;
            v = get(gca, 'Xlim');
            v(2)=tmax;
            set(gca, 'Xlim', v);
            xlabel('T (ms)');
            set(gca, 'color', 'black');
            set(gca, 'XColor', c_ax);
            set(gca, 'YColor', c_ax);
            % insert the crosshair/cursor readout for EVERY window
            cmd = sprintf('acq_setcrosshair(gca, ''MW%d'', ''ms'', ''%s'', [sp%df.left+sp%df.width*0.8 sp%df.bottom+sp%df.height*0.8 sp%df.width*0.1 sp%df.height*0.2]);', ...
                ind, DISPCTL.unit{ind}, ind, ind, ind, ind, ind, ind);
            eval(cmd);

        end;
    else
        HP(3)=HP(2); % safe pointer!
    end
    HFRAME = HP;

    %--------------------------------
    % ON-Line analysis windows:
    %
    % make on-line window (1)
    hola=findobj('Tag', 'OLAFrame'); % now get the frame we work inside
    set(hola, 'Visible', 'off');
    if(isfield(ONLINE, 'Enable') && DISPCTL.online ~= 0)
        hp_ola = get(hola, 'UserData'); % get list of handles in the frame
        if(~isempty(hp_ola))
            for i=1:length(hp_ola)
                if(ishandle(hp_ola(i)))
                    delete(hp_ola(i));
                end;
            end
        end;
        hp_ola = []; % clear the handle list.

        framesz = get(hola, 'Position'); % get the frame within which we will draw

        olaw=[0.05 0.02 0.4 0.95];
        olaf = frameit(olaw, framesz, figsz);

        % make the on-line window (2)
        olaw2=[0.54 0.02 0.4 0.95];
        olaf2 = frameit(olaw2, framesz, figsz);
        % get point mode information
        if(~isfield(ONLINE, 'PointMode'))
            ONLINE.PointMode{1} = 1;
            ONLINE.PointMode{2} = 1;
        end;
        if(length(ONLINE.PointMode) == 1)
            ONLINE.PointMode{2} = 1;
        end

        lstyle = cell(1,2);
        msize = cell(1,2);
        for i = 1:2
            switch ONLINE.PointMode{i}
                case 1
                    lstyle{i} = '-';
                    msize{i} = 2.5;
                case 2
                    lstyle{i} = 'none';
                    msize{i} = 2.5; % make points a bit bigger
                otherwise
                    lstyle{i} = '-';
                    msize{i} = 2.5;
            end;
        end;


        % % now set parameters for ola window 1
        hp_ola(1)=subplot('position', [olaf.left olaf.bottom olaf.width olaf.height]);
        thblue = [0.5 0.5 1];
        if(isempty(ONLINE_DATA.dx{1}))
            HO(1) = line([0 1], [NaN NaN], 'Parent', hp_ola(1), 'color', c_da, ...
                'MarkerFaceColor', thblue, 'MarkerEdgeColor', thblue, 'Marker', 'o', 'MarkerSize', msize{1}, ...
                'LineStyle', lstyle{1});
        else % plot the existing data....
            HO(1) = line(ONLINE_DATA.dx{1}, ONLINE_DATA.dy{1}, 'Parent', hp_ola(1), 'color', c_da, ...
                'MarkerFaceColor', thblue, 'MarkerEdgeColor', thblue, 'Marker', 'o', 'MarkerSize', msize{1}, ...
                'LineStyle', lstyle{1});
        end;
        set(gca, 'XLimMode', 'auto');
        set(gca, 'YLimMode', 'auto');
        set(gca, 'color', 'black');
        set(gca, 'XColor', c_ax);
        set(gca, 'YColor', c_ax);
        set(gca, 'Fontsize', fsize);
        set(gca, 'Tag', 'Acq_OLAW1'); % set a tag on the window
        % insert the crosshair/cursor readout
        acq_setcrosshair(gca, 'OLA1', 'ms', 'mV', ...
            [olaf.left+olaf.width*0.9 olaf.bottom+olaf.height*0.8 olaf.width*0.22 olaf.height*0.2]);

        % olawindow 2
        hp_ola(2)=subplot('position', [olaf2.left olaf2.bottom olaf2.width olaf2.height]);
        set(gca, 'XLimMode', 'auto');
        set(gca, 'YLimMode', 'auto');
        if(isempty(ONLINE_DATA.dx{2})) % initialize?
            HO(2) = line([0 1], [NaN NaN], 'Parent', hp_ola(2), 'color', c_da, ...
                'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red', 'Marker', 'o', 'MarkerSize', msize{2}, ...
                'LineStyle', lstyle{2});
        else % plot the existing data....
            HO(2) = line(ONLINE_DATA.dx{2}, ONLINE_DATA.dy{2}, 'Parent', hp_ola(2), 'color', c_da, ...
                'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red', 'Marker', 'o', 'MarkerSize', msize{2}, ...
                'LineStyle', lstyle{2});
        end;
        set(gca, 'color', 'black');
        set(gca, 'XColor', c_ax);
        set(gca, 'YColor', c_ax);
        set(gca, 'Fontsize', fsize);
        set(gca, 'Tag', 'Acq_OLAW2'); % set a tag on the window
        % insert the crosshair/cursor readout
        acq_setcrosshair(gca, 'OLA2', 'ms', 'mV', ...
            [olaf2.left+olaf2.width*0.9 olaf2.bottom+olaf2.height*0.8 olaf2.width*0.22 olaf2.height*0.2]);

        set(hola, 'UserData', [hp_ola HO]);
    else % disable the on-line analysis window and plots...
        hp_ola = get(hola, 'UserData'); % get list of handles in the frame
        if(~isempty(hp_ola))
            for i=1:length(hp_ola)
                if(ishandle(hp_ola(i)))
                    delete(hp_ola(i));
                end;
            end
        end;
        hp_ola = []; % clear the handle list.
        hx = findobj('tag', 'OLA1');
        if(ishandle(hx))
            delete(hx);
        end;
        hx = findobj('tag', 'OLA2');
        if(ishandle(hx))
            delete(hx);
        end;

    end;
    % ------ END of ONLINE analysis window setup...


    % build the array of plots for the data...
    if(dfile.Refresh.v <= 0)
        s = ls;
        if(iscell(s)) % temporayr patch to allow this to not FAIL (1/1/2005).
            s = s{1};
        end;
        rfn = length(s.waveform)*s.Repeats.v*s.Stim_Repeat.v; % number of plots before refresh is number of acquisition sin the protocol
    else
        rfn = dfile.Refresh.v;
    end;
    if(rfn > 50)
        rfn = 50;
        error 'display requires too much storage - change refresh number!'
    end;
    tx = 1:10;
    %First, we have to determine which window the data goes to according to the mode
    wtarget = getwintarget(dfile);

    if(rfn == 0)
        rfn = 1;
    end;
    HL = NaN*(zeros(nchannel, rfn));
    for ind=1:rfn
        for j = 1:nchannel
            HL(j,ind)  = line(tx, tx*NaN, 'Parent', HFRAME(wtarget(j)), 'color', c_da);
        end;
    end;

    first = 0;   %#ok<NASGU> % last step  - must make sure its 0
    rfcol = 1;
end
if(erase_flag < 0) % just set up
    return
end;


%-------------------------------------------------------------------------------
% Plot the data during acquisition.
%First, we have to determine which window the data goes to according to the mode
%
wtarget = getwintarget(dfile);

%fprintf(2, 'rfn: %d rfc: %d  first: %d  scope_flag: %d\n', rfn, rfc, first, flag);
if(scope_flag ~= 0)
    %    Normal plots. Refresh screen (erase) every rfn cycles - just before the next display
    if(rfn > 0) % negative numbers mean no refresh
        if(rfc < 0)
            rfc = 1;
        end;
        if(rfc > rfn) % time to refresh
            for ind = 1:rfn % clear plots
                for j = 1:nchannel
                    set(HL(j,ind),'XData', time(1:2), 'YData', time(1:2)*NaN); %, 'Parent', HP(vwin));
                    fprintf(1, 'Plotting data');
                end;
            end;
            rfc = 1;
        end;
    end;

    % now display by loading the object
    for j = 1:nchannel
        set(HL(j,rfc), 'XData', time(1:skip:bufsize), 'YData', data(1:skip:bufsize, j));
    end;
    %     set(HL(2,rfc), 'XData', time(1:skip:bufsize), 'YData', data(1:skip:bufsize, 2));
    %     for j = 3:nchannel % note we actually refer to the data that arrived, not nchannel!
    %         set(HL(j,rfc), 'XData', time(1:skip:bufsize), 'YData', data(1:skip:bufsize, j));
    %     end;

    rfc = rfc + 1;

    hola=findobj('Tag', 'OLAFrame'); % now get the frame we work inside
    if(isempty(hola))
        QueMessage( 'acq_plot_data: OLAFrame not found', 1);
        return;
    end;
    set(hola, 'Visible', 'off');

    if(isfield(ONLINE, 'Enable') && DISPCTL.online ~= 0)
        %hp_ola = get(hola, 'UserData');
        hp_ola(1) = findobj('tag', 'Acq_OLAW1');
        hp_ola(2) = findobj('tag', 'Acq_OLAW2');
        if(isempty(hp_ola))
            QueMessage('acq_plot_data: hp_ola handle bad', 1);
            return;
        end;
        pfactor = 1.2;
        for iola = 1:2
            if(isfield(ONLINE, 'Enable') && ONLINE.Enable{iola})

                subplot(hp_ola(iola));
                %xl = get(gca, 'XLim');
                if(length(ONLINE_DATA.dx{iola}) >= 2 && any(abs(diff(ONLINE_DATA.dx{iola})) > 0) || any(out_of_bounds(ONLINE_DATA.dx{iola}, pfactor)))
                    set(gca, 'XLim', limits(ONLINE_DATA.dx{iola}, pfactor)); % [min(ONLINE.dx{iola}), 1.5 * max(ONLINE.dx{iola})]);
                end;
                %yl = get(gca, 'YLim');
                if(length(ONLINE_DATA.dy{iola}) >= 2 && any(abs(diff(ONLINE_DATA.dy{iola}))>0) || any(out_of_bounds(ONLINE_DATA.dy{iola}, pfactor)))
                    set(gca, 'YLim', limits(ONLINE_DATA.dy{iola}, pfactor)); % [min(ONLINE.dy{iola}), 1.5*max(ONLINE.dy{iola})]);
                end;
                if(length(ONLINE_DATA.dx{iola}) == 1)
                    set(HO(iola), 'XData', [NaN ONLINE_DATA.dx{iola}], 'YData', [NaN ONLINE_DATA.dy{iola}]);
                else
                    set(HO(iola), 'XData', ONLINE_DATA.dx{iola}, 'YData', ONLINE_DATA.dy{iola});

                end;
            end;
        end;
    end;

else % we are not writing data - so things are a little different
    maxcol = size(c_sc, 1);
    if(rfcol >= maxcol)
        rfcol = 1;
    end;
    if(isempty(HLINE)) % create the line objects ...
        for j = 1:nchannel
            if(size(data, 2) >= nchannel)
                HLINE(j) = line(time, data(:,j), 'Parent', HFRAME(wtarget(j)), 'color', c_sc(1,:));
            end;
        end;
        rfcol = rfcol+1;
    else
        for j = 1:nchannel
            if(size(data, 2) >= nchannel)
                set(HLINE(j),'YData', data(:,j), 'color', c_sc(1,:)); 
            end;
        end;
        rfcol = rfcol + 1;
    end;
end;


return;


function [wtarget] = getwintarget(dfile)
% map the channels to the display depending on the data acquisition mode.
% note that this depends on the channel order.
% modified heaviliy pbm 11/1/06 to pay attention to mode and channel order.
% IN cc the mapping is v1=1, i1=2, v2=3, i2=4, etc.
% in vc the mapping is i1=1, v1=2, i2=3, v2=4, etc.
% Assumes incoming is in the same order...
% Modified 8/08 to pay attention to the v1 i1 v2 i2 etc in the channel list
% dfile.Channel.v

nch = length(dfile.Channels.v);
wtarget = zeros(nch, 1);

cl = textscan(dfile.ChannelList.v, '%s ');
nch = length(cl{1});

if(strcmpi(dfile.Data_Mode.v,'cc'))
    dmode = 1;
else
    dmode = 0;
end;

% break down encoded channel list
for i = 1:nch
    ch = char(lower(cl{1}(i)));
    sig_type(i) = ch(1);
    amp_num(i) = str2num(ch(2));
end;
ilist = find(sig_type == 'i');
vlist = find(sig_type == 'v');

ich = 1;
wtarget = zeros(nch, 1);
for i = 1:nch
    switch(dmode)
        case 1 % in current clamp.... v is on top, is next for each amp
            switch(sig_type(i))
                case 'i'
                    wtarget(amp_num(i)*2) = ilist(amp_num(i));
                case 'v'
                    wtarget(amp_num(i)*2 - 1) = vlist(amp_num(i));
            end;
        case 0
            switch(sig_type(i))
                case 'i'
                    wtarget(amp_num(i)*2 - 1) = ilist(amp_num(i));
                case 'v'
                    wtarget(amp_num(i)*2) = vlist(amp_num(i));
            end; 
        otherwise
          % wtarget = 1:nch; % default is channel order... 
           % vwin = 1; iwin = 2; % default is same as CC - which won't work for multiple channels
            %        fprintf(1, 'Using default channel mapping\n');
    end;
end;
return;



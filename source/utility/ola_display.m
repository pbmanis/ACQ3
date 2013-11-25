function ola_display(win)

global ONLINE_DATA ONLINE DISPCTL ONLINE_NAMES

if(DISPCTL.online == 0) % if the display is off, skip it.
    return;
end;

flag = 1;
%fprintf(1, 'o_d: entering, win = %d\n', win);
hp_ola=zeros(1, 2);
for i = 1:2
    hp_ola(i) = findobj('-regexp', 'tag', sprintf('Acq_OLAW%d', i));
end;

if(isempty(hp_ola) || max(hp_ola) == 0)
    QueMessage('acq_plot_data: hp_ola handle bad', 1);
    return;
end;

if(win == 0 || isempty(win))
    % disable the on-line analysis window and plots...
    set(hp_ola, 'visible', 'off');
    return;
end;

if(~isempty(ONLINE_NAMES))
    hx=xlabel(hp_ola(win), sprintf('%s vs. %s', ONLINE_NAMES(ONLINE.ModeX{win},:), ONLINE_NAMES(ONLINE.ModeY{win},:)));
    set(hx, 'fontsize', 11);
end;

hw = get(hp_ola); % get the data within the axes

color = {'blue', 'red'};
lstyle = {'-', '-'};
marker = {'s', 'o'};

c_ax = [0.37 0.37 0.9]; % axes color
c_da = [1 1 1]; % default plot color
% c_sc = [0 1 0; 1 0 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
fsize=7; % font size

if(~isfield(ONLINE, 'PointMode'))
    ONLINE.PointMode{1} = 1;
    ONLINE.PointMode{2} = 1;
end;
if(length(ONLINE.PointMode) == 1)
    ONLINE.PointMode{2} = 1;
end

% override the defaults with different PointMode settings.

switch ONLINE.PointMode{win}
    case 1
        lstyle{win} = '-';
        msize{win} = 2.5;
    case 2
        lstyle{win} = 'none';
        msize{win} = 2.5; % make points a bit bigger
    case 3
        lstyle{win} = '-';
        msize{win} = 1.0; % "histogram mode"
    case 4
        lstyle{win} = 'none'; % just points, no lines
        msize{win} = 3.0;
    otherwise
        lstyle{win} = '-';
        msize{win} = 2.5;
end;


olaf.bottom = 0.1; olaf.width = 0.37; olaf.height = 0.7;
olaf.left(1) = 0.1; olaf.left(2) = 0.55;
%hp_ola = get(hf, 'UserData'); % get list of handles in the frame

% fprintf(1, 'before flag\n');
if (~flag)

    hp_ola(win) = subplot('position', [olaf.left(win) olaf.bottom olaf.width olaf.height]);
    % thblue = [0.5 0.5 1];
    if(isempty(ONLINE_DATA.dx{win}))
        HO(win) = line([0 1], [NaN NaN], 'Parent', hp_ola(win), 'EraseMode', 'none', 'color', c_da, ...
            'MarkerFaceColor', color{win}, 'MarkerEdgeColor', color{win}, 'Marker', 'o', 'MarkerSize', msize{1}, ...
            'LineStyle', lstyle{win});
    else % plot the existing data....
        HO(win) = line(ONLINE_DATA.dx{win}, ONLINE_DATA.dy{win}, 'Parent', hp_ola(win), 'EraseMode', 'none', 'color', c_da, ...
            'MarkerFaceColor', color{win}, 'MarkerEdgeColor', color{win}, 'Marker', marker{win}, 'MarkerSize', msize{1}, ...
            'LineStyle', lstyle{win});
    end;
    set(gca, 'XLimMode', 'auto');
    set(gca, 'YLimMode', 'auto');
    set(gca, 'color', [0.25 0.25 0.25]);
    set(gca, 'XColor', c_ax);
    set(gca, 'YColor', c_ax);
    set(gca, 'Fontsize', fsize);
    set(gca, 'Tag', sprintf('Acq_OLAW%d', win)); % set a tag on the window
    % insert the crosshair/cursor readout
    acq_setcrosshair(gca, sprintf('OLA%d', win), 'ms', 'mV', ...
        [olaf.left(win)+olaf.width*0.9 olaf.bottom+olaf.height*0.8 olaf.width*0.22 olaf.height*0.2]);
    set(hf, 'UserData', [hp_ola HO]);
else
    pfactor = 1.2;

    if(isfield(ONLINE, 'Enable'))
        if(ONLINE.Enable{win})

            %axes(hp_ola(win));
            %         xl = get(gca, 'XLim');
            if(length(ONLINE_DATA.dx{win}) >= 2 && any(abs(diff(ONLINE_DATA.dx{win})) > 0) || any(out_of_bounds(ONLINE_DATA.dx{win}, pfactor)))
                set(hp_ola(win), 'XLim', limits(ONLINE_DATA.dx{win}, pfactor)); % [min(ONLINE.dx{win}), 1.5 * max(ONLINE.dx{win})]);
            end;
            %        yl = get(gca, 'YLim');
            if(length(ONLINE_DATA.dy{win}) >= 2 && any(abs(diff(ONLINE_DATA.dy{win}))>0) || any(out_of_bounds(ONLINE_DATA.dy{win}, pfactor)))
                set(hp_ola(win), 'YLim', limits(ONLINE_DATA.dy{win}, pfactor)); % [min(ONLINE.dy{win}), 1.5*max(ONLINE.dy{win})]);
            end;
            if(length(ONLINE_DATA.dx{win}) == 1)
                set(hw(win).Children, 'XData', [NaN ONLINE_DATA.dx{win}], 'YData', [NaN ONLINE_DATA.dy{win}]);
                set(hw(win).Children, 'EraseMode', 'none', 'color', c_da, ...
                    'MarkerFaceColor', color{win}, 'MarkerEdgeColor', color{win}, 'Marker', 'o', 'MarkerSize', msize{win}, ...
                    'LineStyle', lstyle{win});
            else
                set(hw(win).Children, 'XData', ONLINE_DATA.dx{win}, 'YData', ONLINE_DATA.dy{win});
                        set(hw(win).Children, 'color', c_da, ...
                    'MarkerFaceColor', color{win}, 'MarkerEdgeColor', color{win}, 'Marker', 'o', 'MarkerSize', msize{win}, ...
                    'LineStyle', lstyle{win});
        
            end;
        end;
    end;
end;






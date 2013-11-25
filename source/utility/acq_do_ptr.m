function acq_do_ptr(h_fig, arg)

% doptr - returns the pixel info at the pointer location
%
%    doptr(H_FIG, 0) serves as the ButtonMotion callback for the figure
%    H_FIG, displaying the data measurement at the current location of
%    the pointer.
%		doptr(H_FIG, 1) is the button down function, which displays a "delta"
%		relative to the mouse down point
%		doptr(H_FIG, 2) is the button up function, which returns the display to
%		normal coordinates.


% Original code by:   S.C. Molitor (smolitor@bme.jhu.edu)
% Date: May 17, 1999
% modified 7/9/2001 P. Manis.
% use USERDATA of the axes to get information regarding axis display.
% and handle generically, rather than for specific instances.
%
% expects the axis user data to have a structure with the following fields:
% ax.text_handle : handle to text uicontrol where coordinates will be displayed
% ax.xunit : string for x unit display
% ax.yunit : string for y unit display
% ax.textposition : location of uicontrol (redundant, but easier coding).
% therefore, when you build a display/subplot, if these fields are set and
% this callback is registered with the main window (as the WindowMotionFcn ''datac_do_ptr(gcbf)'' or so,
% then moving the mouse over the window should display the coordinates and change the arrow to a
% crosshair. note that if the text uicontrol is not 'visible', it will be ignored.

% first, check input arguments

crossfontsize = 8;

if (nargin ~= 2)
    return
elseif (~istype(h_fig, 'figure'))
    disp('Not figure')
    return
end


units = get(h_fig, 'Units'); % get old units.
set(h_fig, 'Units', 'normalized'); % make sure we have the right coordinate measure to return for localPtrpos
h_axes = findobj(h_fig, 'Type', 'axes');
ptr_flag = zeros(1, length(h_axes));
for i = 1:length(h_axes) % search all the windows for the pointer
    axinfo = get(h_axes(i), 'UserData'); % There may be information in userdata we can use
    [ptr_pos, ptr_flag(i)] = localPtrpos(h_fig, h_axes(i)); % is pointer in this axis?
    if (ptr_flag(i)) % yes, this one has the cursor in iti
        if(isempty(axinfo) || isfield(axinfo, 'PlotHandle')) % not OUR baby...
            set(h_fig, 'Units', units);
            return;
        end;
        if(isfield(axinfo, 'text_handle') && strcmp(get(axinfo.text_handle, 'Visible'), 'on'))
            if(isempty(axinfo.xunit)) % set the unit labels if possible
                xunit = 'X';
            else
                xunit = axinfo.xunit;
            end;
            if(isempty(axinfo.yunit))
                yunit = 'Y';
            else
                yunit = axinfo.yunit;
            end;

            set(h_fig, 'Pointer', 'cross', 'PointerShapeHotSpot', [1, 1]); % change to crosshair
            % determine how display will be presented.
            if(~isfield(axinfo, 'delta_mode')) % see if it exists yet
                axinfo.delta = [0, 0];
                axinfo.delta_mode = 0; % 0 is the normal mode, 1 is "delta" mode
                axinfo.line_handle = [];
            end;
            if(~isfield(axinfo, 'lastaxis'))
                axinfo.lastaxis = 0;
            end;
            if(~isfield(axinfo, 'axislimits'))
                axinfo.axislimits = [get(h_axes(i), 'Xlim'); get(h_axes(i), 'Ylim')];
            end;
            switch(arg)
                case 1 % button down... save the delatx arguments and offset the position
                    axinfo.select = get(gcf, 'SelectionType');
                    axinfo.curpos = ptr_pos;
                    axinfo.down_pos = ptr_pos;
                    axinfo.up_pos = ptr_pos;
                    axinfo.delta = ptr_pos;
                    axinfo.delta_mode = 1;
                    axinfo.lastaxis = setlastaxis(h_axes, i);

                    axinfo.line_handle = line('Xdata', [ptr_pos(1) ptr_pos(1)], ...
                        'Ydata', [ptr_pos(2) ptr_pos(2)], ...
                        'color', 'red', 'linewidth', 1, ...
                        'marker', 'o', 'markersize', 6, 'markerfacecolor', 'red', 'markeredgecolor', 'r', ...
                        'erasemode', 'xor');
                    axinfo.rect_handle = rectangle('Position', [ptr_pos(1), ptr_pos(2), 1, 1], ...
                        'edgecolor', 'cyan', 'linewidth', 0.5, 'linestyle', '--', ...
                        'facecolor', 'none', ...
                        'erasemode', 'xor');

                case 2 % button up - restore orignial position
                    [ptr_pos, ptr_flag(i)] = localPtrpos(h_fig, h_axes(i)); % is pointer in this axis?

                    axinfo.curpos = ptr_pos;
                    axinfo.up_pos = ptr_pos;
                    axinfo.delta = [0, 0];
                    axinfo.delta_mode = 0;
                    delete(axinfo.line_handle); % remove the line....
                    axinfo.line_handle = [];
                    if(isfield(axinfo, 'rect_handle') && ~isempty(axinfo.rect_handle) && ishandle(axinfo.rect_handle)) % if line exists, draw it (button down mode)
                        delete(axinfo.rect_handle);
                        axinfo.rect_handle = [];
                    end;
                    axinfo.lastaxis = setlastaxis(h_axes, i);

                otherwise
                    axinfo.curpos = ptr_pos;
                    % motion would be 0 - do nothing.
            end;
            if(isfield(axinfo, 'line_handle') & ishandle(axinfo.line_handle)) %#ok<AND2> % if line exists, draw it (button down mode)
                set(axinfo.line_handle, 'Xdata', [axinfo.delta(1) ptr_pos(1)], ...
                    'Ydata', [axinfo.delta(2) ptr_pos(2)]);
            end;
            if(isfield(axinfo, 'rect_handle') && ~isempty(axinfo.rect_handle) && ishandle(axinfo.rect_handle))
                xl = ptr_pos(1)-axinfo.delta(1);
                yl = ptr_pos(2)-axinfo.delta(2);

                x0 = axinfo.delta(1);
                y0 = axinfo.delta(2);
                if(xl < 0)
                    x0 = x0 + xl;
                    xl = -xl;
                end;
                if(yl < 0)
                    y0 = y0 + yl;
                    yl = - yl;
                end;
                if(xl == 0)
                    xl = 1;
                end;
                if(yl == 0)
                    yl = 1;
                end;
                set(axinfo.rect_handle, 'Position', [x0 y0 xl yl]);
            end;

            ptr_pos = ptr_pos - axinfo.delta; % adjust position relative to last button down position
            ptr_text = sprintf('%.1f%s %.1f%s', ptr_pos(1), xunit, ptr_pos(2), yunit); % display position in axes units
            set(axinfo.text_handle, 'String', ptr_text, 'fontname', 'arial', 'position', axinfo.text_position, ...
                'background', [0 0 0], 'horizontalalignment', 'right', ...
                'fontsize', crossfontsize, 'foregroundcolor', 'yellow');
            set(axinfo.lastaxis, 'UserData', axinfo); % update the information for this axis
            if(arg == 2 && ~isfield(axinfo, 'callback'))
                switch(axinfo.select)
                    case 'normal'
                        acq_cursormenu('zoom');
                    case 'extend'
                        acq_cursormenu('restore');
                    case 'alt'
                        acq_cursormenu('yzoom');
                    otherwise
                end;
            end;
            if(arg == 2 && isfield(axinfo, 'callback') && ~isempty(axinfo.callback))
                try
                    eval(axinfo.callback);
                catch ME
                    fprintf(1, 'acq_do_ptr: Pointer callback %s failed?', axinfo.callback);
                end;

            end;
        end;
    end;
end
if(all(ptr_flag == 0)) % if not in the window, reselect the arrow.
    set(h_fig, 'Pointer', 'arrow');
    h_axes = findobj(h_fig, 'Type', 'axes');
    for i = 1:length(h_axes) % search all the windows for the pointer
        axinfo = get(h_axes(i), 'UserData');
        if(~isempty(axinfo))
            axinfo.delta_mode = 0; % turn off delta mode too when we run outside the box.
            axinfo.delta = [0, 0];
            if(isfield(axinfo, 'line_handle') & ishandle(axinfo.line_handle)) %#ok<AND2>
                delete(axinfo.line_handle);
                axinfo.line_handle = [];
            end;
            if(isfield(axinfo, 'rect_handle') && ~isempty(axinfo.rect_handle) && ishandle(axinfo.rect_handle))
                delete(axinfo.rect_handle);
                axinfo.rect_handle = [];
            end;
            set(h_axes(i), 'UserData', axinfo);
        end;
    end;
end;
set(h_fig, 'units', units); % always restore units.
return


function [axis_ptr, axis_flag] = localPtrpos(h_fig, h_axes, ptr_type)

% PTRPOS - obtains the pointer position relative to the axes
%
%    [PTR, FLAG] = PTRPOS(H_FIG, H_AXES) returns the coordinates
%    of the current pointer position within the figure window H_FIG
%    relative to the axes specified by the object handle H_AXES.  The
%    (X, Y) pointer coordinates are returned as the row vector PTR,
%    and FLAG is a logical value to indicate whether or not the
%    pointer is within axes limits.
%
%    [...] = PTRPOS(H_FIG, H_AXES, 'image') returns coordinate
%    suitable for image data.  The coordinates are rounded to
%    the nearest integer, and the value of FLAG is calculated
%    to prevent pointer values exceeding image indices.

% By:   S.C. Molitor (smolitor@bme.jhu.edu)
% Date: May 17, 1999
% Modified:
% Paul B. Manis
% 07/09/01.  The axis coordinates must be normalized, so the calculations
% of axis_x1, etc., were modified to take that into account.

% check input arguments

if ((nargin < 2) || (nargin > 3))
    return
elseif (~istype(h_fig, 'figure'))
    return
elseif (~istype(h_axes, 'axes'))
    return
elseif (nargin == 2)
    ptr_type = '';
elseif (~ischar(ptr_type))
    return
end


% determine pointer position normalized to the screen size
% correction factos are for a mac. not sure why they are needed, but they
% are....

scr_size = get(0, 'ScreenSize');
ptr_pos = get(0, 'PointerLocation');
ptr_x = (ptr_pos(1) - scr_size(1))/scr_size(3)+(2/scr_size(3));
ptr_y = (ptr_pos(2) - scr_size(2))/scr_size(4)-(2/scr_size(4));

% determine the axis position normalized to the screen size
scr_size = [0 0 1 1];
figure_pos = get(h_fig, 'Position');
axis_pos = get(h_axes, 'Position');
axis_x1 = ((figure_pos(1) + axis_pos(1)*figure_pos(3)) - scr_size(1))/scr_size(3);
axis_x2 = ((axis_x1 + axis_pos(3)*figure_pos(3)) - scr_size(1))/scr_size(3);
axis_y1 = ((figure_pos(2) + axis_pos(2)*figure_pos(4)) - scr_size(2))/scr_size(4);
axis_y2 = ((axis_y1 + axis_pos(4)*figure_pos(4)) - scr_size(2))/scr_size(4);

% normalize pointer X coordinate relative to X axis limits
% account for reversed X axis direction

x_lim = get(h_axes, 'XLim');
if (strcmp(get(h_axes, 'XDir'), 'reverse'))
    axis_ptr(1) = x_lim(2) + (x_lim(1) - x_lim(2))*(ptr_x - axis_x1)/(axis_x2 - axis_x1);
else
    axis_ptr(1) = x_lim(1) + (x_lim(2) - x_lim(1))*(ptr_x - axis_x1)/(axis_x2 - axis_x1);
end

% normalize pointer Y coordinate relative to Y axis limits
% account for reversed Y axis direction

y_lim = get(h_axes, 'YLim');
if (strcmp(get(h_axes, 'YDir'), 'reverse'))
    axis_ptr(2) = y_lim(2) + (y_lim(1) - y_lim(2))*(ptr_y - axis_y1)/(axis_y2 - axis_y1);
else
    axis_ptr(2) = y_lim(1) + (y_lim(2) - y_lim(1))*(ptr_y - axis_y1)/(axis_y2 - axis_y1);
end

% determine whether pointer falls within axis range
% round to nearest integer to prevent out of range pixel indices

if (strcmp(ptr_type, 'image'))
    axis_ptr = round(axis_ptr);
    if ((axis_ptr(1) >= ceil(x_lim(1))) && (axis_ptr(1) <= floor(x_lim(2))) && ...
            (axis_ptr(2) >= ceil(y_lim(1))) && (axis_ptr(2) <= floor(y_lim(2))))
        axis_flag = 1;
    else
        axis_flag = 0;
    end
else
    if ((axis_ptr(1) >= x_lim(1)) && (axis_ptr(1) <= x_lim(2)) && ...
            (axis_ptr(2) >= y_lim(1)) && (axis_ptr(2) <= y_lim(2)))
        axis_flag = 1;
    else
        axis_flag = 0;
    end
end
return

% function to set identity of the most recent axes accessed by the mouse.
% all of the other pointers are set to 0 at the same time.

function lastaxis = setlastaxis(h_axes, icurrent)
for j = 1:length(h_axes)
    axinfo = get(h_axes(j), 'UserData'); % update the information for this axis
    if(j ~= icurrent)
        axinfo.lastaxis = 0;
    else
        axinfo.lastaxis = h_axes(j);
    end;
    set(h_axes(j), 'UserData', axinfo);
end;
lastaxis = h_axes(icurrent); % also return the axis

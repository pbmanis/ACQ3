function acq_setcrosshair(axis_handle, tag, xu, yu, pos, callback)
%
% acq_setcrosshair; given an axis and a named tag for the text window to
% display the measurements, set up for a crosshair callback for the axis.
%

% check the arguments.
crossfontsize = 9;

if(nargin < 5)
    error('acq_setcrosshair has insufficient arguments  in call');
end;
if(~ishandle(axis_handle))
    error('acq_setcrosshair: axis_handle argument is not correct');
end;
if(~ischar(tag))
    error('acq_setcrosshair: tag argument is bad');
end;
if(~ischar(xu))
    error('acq_setcrosshair: xunit argument is bad');
end;
if(~ischar(yu))
    error('acq_setcrosshair: yunit argument is bad');
end;
if(~isnumeric(pos) && length(pos) ~= 4)
    error('acq_setcrosshair: position for display field is bad');
end;

% safe to proceed:

htext = findobj('Tag', tag); % find/create the display window information
if(isempty(htext))
    htext = uicontrol(...
        'units', 'normalized', ...
        'Position', pos, ...
        'foregroundcolor', 'blue', ...
        'backgroundcolor', 'black', ...
        'Style', 'text', ...
        'horizontalalignment', 'right', ...
        'fontsize', crossfontsize, ...
        'string', sprintf('%.1f%s %.1f%s', 0, xu, 0, yu),  ...
        'Tag', tag );
else
    set(htext, 'Visible', 'on');
end;

% build the axinfo structure.

axinfo.text_handle = htext;
axinfo.text_position = pos;
axinfo.delta_mode = 0;
axinfo.delta = [0, 0];
axinfo.line_handle = [];
axinfo.xunit = xu;
axinfo.yunit = yu;
axinfo.curpos = [0 0]; % current crosshair position (absolute in axis coordinates)
axinfo.down_pos = [0 0];
axinfo.up_pos = [0 0];
axinfo.select = 'normal';
axinfo.axislimits = [get(axis_handle, 'XLim'); get(axis_handle, 'Ylim')];
if(nargin > 5)
    axinfo.callback = callback;
end;

% store the structure.
if(~isempty(axis_handle))
    set(axis_handle, 'UserData', axinfo);
end;

return;

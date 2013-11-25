function [res] = scrollwin(cmd, value, label, scrollrange, position)
% build an entry box with a little scroll next to it.
% The scroll controller is an RGB image over an axes
%

persistent mstate
persistent v inc

h = findobj('Tag', 'testfig');
if(nargin == 0)
   cmd = 'setup';
   v = 0;
   inc = 1;
   mstate.ud = 'up';
end;

switch(cmd)
   
case 'mousedown'
   h_fig = gcf;
   units = get(h_fig, 'Units'); % get old units.
   set(h_fig, 'Units', 'normalized'); % make sure we have the right coordinate measure to return for localPtrpos
   ptr_flag = [];
   hv = findobj('Tag', 'val1');
   hi = findobj('Tag', 'inc1');
   h_axes = findobj(gcf, 'Type', 'uicontrol'); % find all the axes.
   for i = 1:length(h_axes) % search all the windows for the pointer
      [ptr_pos, ptr_flag(i)] = localPtrpos(h_fig, h_axes(i), 'image') % is pointer in window?
      if (ptr_flag(i)) % yes, this one has the cursor in it
         axinfo = get(h_axes(i), 'UserData'); % There may be information in userdata we can use
         mstate.ax = h_axes(i);
         mstate.pos = ptr_pos;
         mstate.rpos = get(0, 'PointerLocation');
         updnarrow;
         if(ptr_pos(1) < 10) % arrows
            if(ptr_pos(2) > 5) % up
               v = v + inc;
            else
               v = v - inc;
            end;
            set(hv, 'String', num2str(v));
         else % x axis > 10, use increment control.
            if(ptr_pos(2) > 5)
               inc = inc * 10;
            else
               inc = inc / 10;
            end;
            set(hi, 'String', num2str(inc));
         end;
      end;
   end;
   set(h_fig, 'Units', units); % restore...
   mstate.ud = 'down'; % SET THIS ONLY WHEN DONE.
   
case 'mouseup'
   mstate.ud = 'up'
   updnarrow_off;
case 'mousemove'
   if(strcmp(mstate.ud, 'down'))
         set(0, 'PointerLocation', mstate.rpos); % keep same position as when button hit!
   h_fig = gcf;
   units = get(h_fig, 'Units'); % get old units.
   set(h_fig, 'Units', 'normalized'); % make sure we have the right coordinate measure to return for localPtrpos
   ptr_flag = [];
   hv = findobj('Tag', 'val1');
   hi = findobj('Tag', 'inc1');
   h_axes = findobj(gcf, 'Type', 'uicontrol'); % find all the axes.
   for i = 1:length(h_axes) % search all the windows for the pointer
      [ptr_pos, ptr_flag(i)] = localPtrpos(h_fig, h_axes(i)); % is pointer in window?
      if (ptr_flag(i)) % yes, this one has the cursor in it
         axinfo = get(h_axes(i), 'UserData'); % There may be information in userdata we can use
         mstate.ax = h_axes(i);
         mstate.pos = ptr_pos;
         if(ptr_pos(1) < 10) % arrows
            if(ptr_pos(2) > 5) % up
               v = v + inc;
            else
               v = v - inc;
            end;
            set(hv, 'String', num2str(v));
         end;
      end;
      set(h_fig, 'Units', units); % restore...
   end;
else
end;

case 'increset'
   inc = 1;
   
case 'setup'  
   if(isempty(h))
      h = figure('Tag', 'testfig');
      set(h, 'WindowButtonDownFcn', 'scrollwin(''mousedown'');');
      set(h, 'WindowButtonUpFcn', 'scrollwin(''mouseup'');');
      set(h, 'WindowButtonMotionFcn', 'scrollwin(''mousemove'');');
      mstate.ud  = 'up';      
   end;
   clf;
   
   % get the scroll image
   [scicon, scmap] = imread('c:\mat_datac\acq\source\utility\scroll.jpg');
   axes('Position', [0.5 0.5 0.05 0.05]);
   image('CData', scicon, ...
      'tag', 'sc1');
   uicontrol('Units', 'Normalized', ...
      'Position', [0.57,0.5,0.1, 0.05], ...
      'tag', 'val1', ...
      'String', num2str(v), ...
      'fontsize', 7);
   uicontrol('Units', 'Normalized', ...
      'Position', [0.5,0.55,0.05, 0.05], ...
      'tag', 'inc1', ...
      'String', num2str(inc), ...
      'callback', 'scrollwin(''increset'');', ...
      'fontsize', 5);
   
otherwise
end;


function [axis_ptr, axis_flag] = localPtrpos(h_fig, h_axes, ptr_type);

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
% 07/09/01.  The axis coordinates must be noromalized, so the calculations
% of axis_x1, etc., were modified to take that into account.

axis_ptr = [];
axis_flag = 0;

% check input arguments

if ((nargin < 2) | (nargin > 3))
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

scr_size = get(0, 'ScreenSize');
ptr_pos = get(0, 'PointerLocation');
ptr_x = (ptr_pos(1) - scr_size(1))/scr_size(3);
ptr_y = (ptr_pos(2) - scr_size(2))/scr_size(4);

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
   if ((axis_ptr(1) >= ceil(x_lim(1))) & (axis_ptr(1) <= floor(x_lim(2))) & ...
         (axis_ptr(2) >= ceil(y_lim(1))) & (axis_ptr(2) <= floor(y_lim(2))))
      axis_flag = 1;
   else
      axis_flag = 0;
   end
else
   if ((axis_ptr(1) >= x_lim(1)) & (axis_ptr(1) <= x_lim(2)) & ...
         (axis_ptr(2) >= y_lim(1)) & (axis_ptr(2) <= y_lim(2)))
      axis_flag = 1;
   else
      axis_flag = 0;
   end
end
return


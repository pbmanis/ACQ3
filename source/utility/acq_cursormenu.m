function acq_cursormenu(varargin)
%
% handle the cursor actions via callbacks.
% Allows any trace with cursors attached to be zoomed (rescaled), restored,
% and possibly the cursor positions to be transferred into the online
% analysis structure.
%
% 3/26/2008
% Paul B. Manis
% UNC Chapel Hill
%

global ONLINE

if(nargin > 0)
    cmd = varargin{1};
else
    return; % no arguments, silently die.
end;

h = acq_getlastpos;
if(isempty(h))
    return;
end;

xd = sort([h.down_pos(1) h.up_pos(1)]);
yd = sort([h.down_pos(2) h.up_pos(2)]);

switch cmd
    case 'zoom'
        if(isfield(h, 'down_pos') && isfield(h, 'up_pos'))
            % and now redraw the display
            if(h.down_pos(1) ~= h.up_pos(1) && h.down_pos(2) ~= h.up_pos(2))
                set(h.lastaxis, 'Xlim', xd, ...
                    'Ylim', yd);
            end;
        end;
        
    case 'yzoom' % only on the y axis
        if(isfield(h, 'down_pos') && isfield(h, 'up_pos'))
            % and now redraw the display
            if(h.down_pos(1) ~= h.up_pos(1) && h.down_pos(2) ~= h.up_pos(2))
                set(h.lastaxis, 'Ylim', yd);
            end;
        end;
        
    case 'restore'
        if(isfield(h, 'axislimits'))
            set(h.lastaxis, 'Xlim', sort(h.axislimits(1,:)), ...
                'Ylim', sort(h.axislimits(2,:)));
            h.lastaxis = 0;
        end;

    case 'cxx1'   % put the cursor information into the online data array
        ONLINE.T1X{1} = xd(1);
        ONLINE.T2X{1} = xd(2);
        on_line('update', 0);
        
    case 'cxx2'
        ONLINE.T1X{2} = xd(1);
        ONLINE.T2X{2} = xd(2);
        on_line('update', 0);
   
    case 'cxy1'   % put the cursor information into the online data array
        ONLINE.T1Y{1} = xd(1);
        ONLINE.T2Y{1} = xd(2);
        on_line('update', 0);
        
    case 'cxy2'
        ONLINE.T1Y{2} = xd(1);
        ONLINE.T2Y{2} = xd(2);
        on_line('update', 0);
 
        
    case 'cy1'   % put the cursor information into the online data array
        ONLINE.T1Y{1} = yd(1);
        ONLINE.T2Y{1} = yd(2);
        on_line('update', 0);
        
    case 'cy2'
        ONLINE.T1Y{2} = yd(1);
        ONLINE.T2Y{2} = yd(2);
        on_line('update', 0);
        
    otherwise
        return;
end;


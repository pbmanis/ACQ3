function result=struct_edit(cmd, arg, varargin)
% struct_edit  -  function to edit values in a structure
% Creates a 'modal' window to be used for editing. Only one such window per title can exist at a time.
% called with cmd = 'edit': makes new figure to open for editing the selected structure in arg1
% called with cmd = 'update': returns the modified entry
% called with cmd = 'get': returns the name of the current top (displayed) structure.
%
% The structure in arg must follow this format:
%
%	struct.name	- window name (for handle access)
%	struct.title - title for title bar in window
%	struct.editable (set to 0 to disable editing; set to 1 to enable editing)
%   struct.callback - call back routine when done to update data
% 	struct.frame	- the name of the window frame that "holds" the data
%	struct.version - for your internal use regarding the version number of the structure
%	struct.ancillary 1 ( you can put other stuff in the structure here )
% 	...
%	struct.start		( placeholder - indicates start of data that can be edited )
%	struct.element1
%	struct.element2
%	....
%	struct.elementn
%	struct.end (placeholder - indicates end of data that can be edited )%
%
% The title is used as the title of the edit window
% Only the elements between struct.start and struct.end will be available in the editor
% Each element is itself a structure, generated by a call to create_element, as follows:
%	element.v	 - element value - may be any allowable matlab variable type
%	element.vh		- high limit (or Inf)
%	element.vl		- low limit (or -Inf)
%	element.n		- order in the display - ties are sorted alphabetically by the title
%	element.t		- title for element in the display (text)
%	element.f		- format string for the element in the display (defines field width for edit)
%	element.lock	- if 1, data element is "locked" and cannot be edited.
%
% 8/7/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% Modified to operate on the basis of association with a frame in a single window, rather than
% promulgating multiple windows. Each structure should be associated with a frame, and when
% the structure is selected, the elements of the frame (e.g. the list of handles stored in the frame's
% UserData area) are made visible, while all other frame elements are made invisible.
%
% 10/12/2000
% Modified again. The tags of the text elements are used to identify those associated with a window, on
% the fly, rather than holding them in a userdata structure. The coding is simpler, and appears to be
% more robust with respect to changing windows.
% P. Manis.
%
global WIN_TITLE
persistent MODIFIED %#ok<PUSE>
global STIMBUFFER

if(nargout > 0)
    result = [];
end;
if nargin > 2
    STIMBUFFER = varargin{1};
end;
sbuffer = STIMBUFFER;
switch lower(cmd)
    
    case 'edit'
        if(iscell(arg) && length(arg) > 1)
            hsl = findobj('Tag', 'Acq_Stim_N');
            sel=get(hsl, 'String'); % find which one is selected
            val = get(hsl, 'Value');
            sel = char(sel(val));
            makeeditor(arg{sel}, sbuffer);
        else
            struct_edit('clear', arg, sbuffer);
            makeeditor(arg, sbuffer);
        end;
        WIN_TITLE = arg.frame;
        MODIFIED = 0;
        
        %     case 'stimedit'
        %         hsl = findobj('Tag', 'Acq_Stim_N');
        %         sel=get(hsl, 'String'); % find which one is selected
        %         val = get(hsl, 'Value');
        %         sel = schar(sel(val));
        %         for i = 1:length(STIM)
        %             STIM{i}.current = sel;
        %         end;
        %         makeeditor(STIM{sel});
        %         WIN_TITLE=STIM{sel}.frame;
        %         MODIFIED = 0;
        
        %     case 'stimdelete'
        %         hsl = findobj('Tag', 'Acq_Stim_N');
        %         sel = get(hsl, 'String');
        %         val = get(hsl, 'Value');
        %         sel = char(sel(val)); % get the current selection
        %         % we will delete the STIM cell with the current val from the list,
        %         % then we will force redisplay of the list, with the new first value selected.
        %         % note if the STIM only has one element, we will NOT delete it.
        %         %
        %         if(length(STIM) == 1)
        %             return;
        %         end;
        %         k = 0;
        %         n = length(STIM);
        %         ns = cell(1,n);
        %         for i = 1:n
        %             if(i ~= sel)
        %                 k = k + 1;
        %                 ns{k} = STIM{i};
        %                 ns{k}.current = 1;
        %                 ns{k}.nstim = n; % update
        %             end;
        %         end;
        %         STIM = ns;
        %         % now force redisplay with the first one.
        %         struct_edit('redisplay', STIM{1});
        
    case 'load' % for loading in a new set of parameters
        WIN_TITLE = arg.frame;
        EditLoad(WIN_TITLE, arg, sbuffer);
        
    case 'redisplay'
        makeeditor(arg, sbuffer);
        WIN_TITLE = arg.frame;
        MODIFIED=0;
        
    case 'get' % return the name of the current stimulus structure
        if(nargout > 0)
            result = WIN_TITLE;
        end;
        return;
        
    case 'update'
        if(isempty(WIN_TITLE))
            QueMessage('struct_edit: Internal error on update - empty WIN_TITLE',1);
            return;
        end;
        res = get_local_data(WIN_TITLE);
        if(isempty(res))
            QueMessage('struct_edit: Internal error on update - empty result',1);
            return;
        end;
        eval(sprintf('%s(''%s'',res);', res.callback, res.NAME));
        %pv; % execute an automatic preview
        if(nargout > 0)
            result = res;
        end;
        return;
        
    case 'clear'
        if(isempty(arg))
            return;
        end;
        arg = {arg};
        [h] = get_handles(arg{1}, 'd');
        if(isempty(h))
            %      fprintf('struct_edit: no handles for arg type = %s\n', arg.NAME);
            return;
        end;
        for i=1:length(h)
            delete(h(i));
        end;
        [h] = get_handles(arg{1}, 't');
        if(isempty(h))
            %      fprintf('struct_edit: no handles for arg type = %s\n', arg.NAME);
            return;
        end;
        for i=1:length(h)
            delete(h(i));
        end;
        
    otherwise
end

return;


function makeeditor(arg, sbuffer) %#ok<INUSD>
% -------------------------------------------------
% make the editor list - just read the names from the
% control stucture stored in userdata of the main window
% and build a list based on that
% the list callback routes to a routine that handles the
% display window when we double-click
%
% 12/8/98 P. Manis

if(iscell(arg))
    [s_field, e_field, err] = get_valid_elements(arg{1}); %#ok<ASGLU>
    if(err)
        return;
    end;
else
    [s_field, e_field, err] = get_valid_elements(arg); %#ok<ASGLU>
    if(err)
        return;
    end;
end;

thisframe = findobj('Tag', arg.frame); % check for pre-existing data
if(isempty(thisframe))
    %   fprintf(2, 'struct_edit: No frame to support type %s\n', arg.frame); % for debugging
    return;
end;
frh = get(thisframe, 'UserData'); % access the data
if(isempty(frh)) % frame is not built yet? - then build it
    %       fprintf(2, 'Building frame for %s\n', arg.frame);
    set(thisframe, 'Units', 'characters');
    figsz=get(thisframe, 'Position');
    
    b_ht = 1.7;
    %pad_check = 7; pad_edit = 5; pad_list = 5; pad_pop = 7;
    %pad_push = 4; pad_radio = 7; pad_static = 4;
    %but_vpad = 0.125;
    but_hpad = 1.5;
    
    % but_vspc = b_ht + but_vpad; % space to allocate for each button or field
    
    buttonlist = [];
    % buttonlist = add_button(buttonlist, 'Stimulus', 'e stim;', 'Stimulus Parameters', 'stim', 'on');
    % buttonlist = add_button(buttonlist, 'Acquisition', 'e acq;', 'Acquisition Parameters', 'acqe', 'on');
    % buttonlist = add_button(buttonlist, 'Configuration', 'e config;', 'Configuration', 'config', 'on');
    % buttonlist = add_button(buttonlist, 'Update', 'struct_edit(''update'');', 'Update Information', 'Update', 'on');
    
    maxtitle = 0;
    for i=1:length(buttonlist)
        l = length(buttonlist(i).title);
        if(l > maxtitle)
            maxtitle = l;
        end
    end
    but_width = maxtitle+2*but_hpad;
    button_x = figsz(1) + 1;  % place the buttons to the right side of the display
    button_y = figsz(4)-b_ht+0.5;
    
    % get the data and put it in our window
    h0 = findobj('Tag', 'Acq');
    cmd_hspc = but_width + but_hpad; % extra padding
    for i=1:length(buttonlist)
        b_x = button_x+(i-1)*cmd_hspc;
        if(~isempty(buttonlist(i).pos))
            b_x = 1;
        end
        uicontrol('Parent', h0, ...
            'Units', 'characters', ...
            'FontUnits', 'points', ...
            'FontName', 'Arial', ...
            'FontSize', 11, ...
            'ForegroundColor', 'blue', ...
            'Position', [b_x button_y but_width+0.5 b_ht], ...
            'String', buttonlist(i).title, ...
            'ToolTipString', buttonlist(i).tooltip, ...
            'Callback', buttonlist(i).callback, ...
            'Enable', buttonlist(i).enable, ...
            'Tag', buttonlist(i).tag);
    end
end
set_local_data(arg); % store locally
[s_field, e_field, err] = get_valid_elements(arg);
figure(findobj('Tag', 'Acq'));
if(err)
    return;
end;

arg = updateeditwindow(arg, (s_field:e_field)); % set to top
set(thisframe, 'UserData', arg);
set_local_data(arg); % store locally
switch_frame(arg);

return;


function switch_frame(arg)
% switch visiblity of the frames
% if its not our frame, make all the objects invisible
% if its our frame (e.g., arg.frame) make ours visible.
% Modified: 9/24/2000. P. Manis
% Cleaner switch - does not regenerate display on every call
%

[h, hn] = get_handles(arg, 'd');
if(isempty(h))
    fprintf('struct_edit, switch_frame: no handles for arg type = %s\n', arg.NAME);
    return;
end;
set(hn, 'Visible', 'off');
set(h, 'Visible', 'on');

[h, hn] = get_handles(arg, 't');
if(isempty(h))
    fprintf('struct_edit, switch_frame: no handles for arg type = %s\n', arg.NAME);
    return;
end;
set(hn, 'Visible', 'off');
set(h, 'Visible', 'on');

return;

function [s_field, e_field, err] = get_valid_elements(arg)
if(iscell(arg))
    QueMessage(sprintf('Edit structure %s is multiple-cell array.....', arg{1}.name));
    err = 1;
    return;
end;
err = 0;
names=fieldnames(arg);
%nfield = length(names);
s_field = find(strncmp('start', names, 3) == 1, 1, 'first');
e_field = find(strncmp('end', names, 3) == 1, 1, 'first');
if(isempty(s_field) || isempty(e_field))
    QueMessage(sprintf('Edit structure %s lacks start or end field', arg.name));
    err = 1;
    return;
end
s_field=s_field+1;
e_field=e_field-1;
return;


function [arg] = updateeditwindow(in_arg, SEL)
% update the list in the edit window for the control structure
% note that we consider lower level structures priveleged - they can be viewed
% but the cannot be edited. (they are normally used to store
% results from data analysis)
% 12/8/98 P. Manis
% Modified 8/7/2000: returns a list of the handles to the elements we created
% The redraw argument causes the previous elements of the arg.fhandles
% if any to be removed and new ones to be drawn. This is useful if the
% structure has changed...
% Modified (indirectly) 10/12/2000: text_entry does not create a new handle of the
% same name if one already exists. This is because of errors in controlling
% the display when more than one object has the same handle.

global STIMBUFFER

arg = in_arg;

%winl = [];
but_vspc=1.4;
owner = findobj('Tag', arg.frame);
set(owner, 'Units', 'character');
p = get(owner, 'Position');
top=p(2); % length(SEL)*1.25;
x0 = p(1)+ 1.5;
names=fieldnames(arg);
%nfield = size(names);
maxw=max(length(char(names(SEL))));
fw = p(3)+4;
k = 1;
t2 = top + p(4) - 1.5 * but_vspc;
ti = arg.title;
if strcmp(in_arg.NAME, 'STIM')
    ti = [ti sprintf('  [buffer = %d]', STIMBUFFER)];
end;
uicontrol('Units', 'characters', ...
    'Position', [p(1)+1.5, t2, p(3)-25, but_vspc], ...
    'Style', 'text', ...
    'String', ti, ...
    'horizontalAlignment', 'Center', ...
    'FontUnits', 'points', ...
    'FontName', 'Arial', ...
    'FontWeight', 'Bold', ...
    'FontSize', 11, ...
    'background', [0 0.35 0.35], ...
    'foreground', 'white');

if(isfield(arg, 'Version') && arg.Version == 2 && strncmp('STIM', arg.NAME, 4)) % do something special for new STIM - drop down selection
    hsl = findobj('tag', 'Acq_Stim_N');
    if(isempty(hsl))
        hsl = uicontrol('Units', 'characters', ...
            'Position', [p(1)+p(3)-18, t2, 10, but_vspc], ...
            'Style', 'popupmenu', ...
            'String', sprintf('%d|', (1:arg.nstim)), ...
            'value', arg.current, ...
            'horizontalAlignment', 'Right', ...
            'FontUnits', 'points', ...
            'FontName', 'Arial', ...
            'FontSize', 11, ...
            'tag', 'Acq_Stim_N');
        set(hsl, 'callback', 'struct_edit(''stimedit'', 0);');
        get(hsl, 'value')
    else
        set(hsl, 'String', sprintf('%d|', (1:arg.nstim)));
        set(hsl, 'Value', arg.current);
    end;
end;

t2 = t2 - 2 * but_vspc;
id=get_id(arg);
for i=min(SEL):max(SEL)
    %    j = i - min(SEL) + 3;
    thisname = char(names(i));
    thisarg = strcat('arg.', thisname);
    u=eval(char(thisarg));
    h1 =  []; %#ok<NASGU>
    
    if(isstruct(u)) % if data is in a structure, display it appropriately
        if(u.m >= 0) % editable type?
            if(isnumeric(u.v))
                h1 = text_entry(u.t, u.t, num_2_str(u.v, u.f), fw, maxw, x0, t2, id);
            elseif(ischar(u.v))
                h1 = text_entry(u.t, u.t, u.v, fw, maxw, x0, t2, id);
            else
                h1 = text_entry(u.t, u.t, num_2_str(u.v), fw, maxw, x0, t2, id);
            end
            
        else % not in a structure! use simple display
            h1 = text_entry(u.t, u.t, num2str(u.v, u.f), fw, maxw, x0, t2, id, u.m);
        end
    else
        h1 = text_entry(u, u, u, fw, maxw, x0, t2, id);
    end;
    
    if(~isempty(h1))
        eval([char(thisarg) '.h = h1;']); % store the handle in the structure itself (easy to find)
        k = k + 1;
    end;
    t2 = t2 - but_vspc;
end
return;


function EditLoad(win_title, d, sbuffer)
%global STIM  %#ok<NUSED> # we fill STIM with an eval statement.

% copy the data coming from d into the window win_title
if(d.frame ~= win_title)
    fprintf(2, 'EditLoad: d.frame and win_title not matched\n');
    fprintf(2, '... d.frame = %s, win_title = %s\n', d.frame, win_title);
    return;
end;
dnew = d;
id=get_id(dnew);
if(strncmp('FStim', d.frame, 5)) % change the screen if the method changes in stim files
    hid = findobj('Tag', ['d_' id '_Method']); % get the method
    methd = unblank(get(hid, 'String')); % as of 3/08, important as string seems to be padded
    if(~strcmpi(methd, unblank(d.Method.v)))
        struct_edit('clear', dnew, sbuffer);
        makeeditor(dnew, sbuffer);
        %eval(['new ' methd]); % create / update the new method
    end;
end

h = findobj('Tag', win_title); % keep current...
set(h, 'UserData', dnew); % update with the new data
%fprintf(2, '\n++++ EDITLOAD\n');
%STIM
eval([d.NAME '= dnew;']); % store data into correct structure
%STIM
%fprintf(2, '\n---- EDITLOAD\n');
[ds, de, err] = get_valid_elements(dnew); % read the data area from the incoming structure
if(err)
    fprintf(2, 'EditLoad: ? Unable to get_valid_elements from data\n');
    return;
end;
%hfd = findobj('Tag', dnew.frame);
names = fieldnames(dnew);
for i = ds:de
    thisname = names{i};
    thisarg = eval(sprintf('dnew.%s.t',thisname));
    h = findobj('Tag', ['d_' id '_' thisarg]); % find the data element.........
    if(~isempty(h))
        x = eval(char(['dnew.' thisname]));
        thisone = sprintf('dnew.%s.v',thisname);
        hs=eval(thisone);
        % generate a result according to the format statement in the field
        % hs is ALWAYS a string...
        % we have to strip the formatting to get it right.
        if(strfind(x.f, 'e'))
            fmt = '%g';
        elseif strfind(x.f, 'f')
            fmt = '%g';
        elseif strfind(x.f, 'g')
            fmt = '%g';
        elseif strfind(x.f, 'd')
            fmt = '%d';
        else
            fmt=x.f;
        end
        if(strcmp(fmt,'%s') || strcmp(fmt,'%c'))
            c=sprintf(sprintf('%s', fmt), hs); % correctly format the display
        else
            %         c=sprintf(sprintf('%s ', fmt), hs); % correctly format the display
            c = num_2_str(hs, fmt);
        end;
        %fprintf('%s = %s (h=[%d])\n', thisname, c, h);
        set(h, 'String', ['  ' c]); % and put it in the display
    else
        fprintf(2,'EditLoad: For %s, unable to find tag: %s, thisarg: %s\n', d.frame, thisname, thisarg);
    end;
end;
switch_frame(dnew);
%drawnow;
return;
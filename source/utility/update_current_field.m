function update_current_field(curr_s, pointer, fmt)

global DFILE STIM STIM2%#ok<NUSED>

id=get_id(eval(curr_s));

h = findobj('Tag', ['d_' id '_' eval([pointer '.t'])]);
v = eval([pointer '.v']); % get the new current value held there
if(~isempty(h))
    % generate a result according to the format statement in the field
    % hs is ALWAYS a string...
    % we have to strip the formatting to get it right.
    if(findstr('e', fmt))
        sfmt = '%g';
    elseif findstr('f', fmt)
        sfmt = fmt;
    elseif findstr('g', fmt)
        sfmt = '%g';
    else
        sfmt=fmt;
    end
    if(strcmp(fmt,'%s') || strcmp(fmt,'%c'))
        fmtc = 1; % character format - we have to handle things one way for strings, another for numbers
    else
        fmtc = 0;
    end;
    if(fmtc)
        c=sprintf(sprintf('%s', sfmt), unblank(v)); % correctly format the display
    else
        %c=sprintf(sprintf('%s ', sfmt), v); % correctly format the display
        c = num_2_str(v, sfmt);
    end;
    set(h, 'String', [' ' c]); % and put it in the display
else
    QueMessage(sprintf('cmd_struct/update: No tag in field %s\n', pointer),1);
end;


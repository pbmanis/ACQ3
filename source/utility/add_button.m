function [list] = add_button(olist, title, callback, tooltip, tag, enable, pos, color, strlist)
% add_button  -  make a button in a list of buttons
% buttons can be displayed easily in the order in which they were listed
% 3/2000 Paul B. Manis
% pmanis@med.unc.edu

n=length(olist);
n=n+1; % point to the next entry
if(isempty(olist))
   n = 1;
end
list = olist;
if(strcmp(title, 'hrule'))
   list(n).title = 'hrule';
   list(n).callback = '';
   list(n).tooltip = '';
   list(n).enable = 0;
   list(n).tag = 0;
   list(n).pos = 0;
   list(n).color = '';
   return;
end;

list(n).title = title;
list(n).callback = callback;
list(n).tooltip = tooltip;
list(n).enable = enable;
list(n).tag = tag;
if(nargin > 6)
    list(n).pos = pos;
else
    list(n).pos = [];
end
if(nargin > 7)
    list(n).color = color;
else
    list(n).color = 'blue';
end
if(nargin > 8)
    list(n).strlist = strlist; % for a drop-down list... 
else
    list(n).strlist = [];
end;

return;

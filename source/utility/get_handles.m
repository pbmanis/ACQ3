function [handles, nothandles] = get_handles(arg, ty)
% Return the handles of the data areas that correspond to the type arg
% e.g., handles starting with 'd_S', 'd_D', and 'd_C'
% also returns in nothandles the handles that are in the list that don't correspond to the choice.
handles=[];
nothandles=[];
id=get_id(arg);
if(isempty(id))
   return;
end;
id= [ty '_' id '_'];  % make the type. Note we can use this to get the titles too (t_D_).
x=findobj(gcf, 'style', 'text');
y = get(x, 'Tag'); % get the tags for the text objects
a = strmatch(id, y);
handles=x(a); % return list of handles that correspond
a = strmatch([ty '_'], y); % that is all of the handles of 'type'
hnot=x(a); % return list of handles that correspond
nothandles=setdiff(hnot, handles); % find handles not in the selected group of ha 
return;

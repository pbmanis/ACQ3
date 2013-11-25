function element = create_element(v, m, n, t, fmt, lock, vl, vh)
% create_element  -  create an element in the correct form for the structure editor
% -------------------------------------------------
% 
% create a structure for an initialized element
% values are initialized as necessary
% not that the lock argument is a placeholder = if it is present, the element is locked.
%
% 11/30/99 P. Manis

element.v = v; %	 - element value - may be any allowable matlab variable type
element.h = []; % display handle for text box with data in it

if(nargin > 1)
   element.m = m; %  - array versus variable storage (used by cmd_struct when parsing commands)
else
   element.m = 0; % sets to single if missing
end;

if(nargin > 2)
   element.n = n; % 		- order in the display - ties are sorted alphabetically by the title
else
   element.n = 0;
end;

if(nargin > 3)
   element.t = t;
else
   element.t = ''; % 		- title for element in the display (text)
end;

if(nargin > 4)
   element.f = fmt;
else
   element.f = '%6.2f'; % 		- format string for the element in the display (defines field width for edit)
end;

if(nargin > 5)
   element.lock = 1;
else
   element.lock	= 0; % - if 1, data element is "locked" and cannot be edited.
end;

if(nargin > 6)
   element.vl = vl;
else
   element.vl = -Inf;
end

if(nargin > 7)
   element.vh = vh;
else
   element.vh = Inf;
end

return;

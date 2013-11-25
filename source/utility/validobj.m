function valid_flag = validobj(obj_var, obj_class);

% VALIDOBJ - Determines if object is valid member of a class
%
%    FLAG = VALIDOBJ(OBJ, CLASS) determines if the variable OBJ is a valid
%    member of CLASS.

% 11/5/01 SCM

% test if OBJ is member of CLASS
valid_flag = 0;
if (nargin < 2)
    return
elseif (isempty(obj_var))
    return
elseif (~ischar(obj_class))
    return
elseif (~isa(obj_var, obj_class))
    return
end

% check for valid SERIAL/DAQ object if needed 
switch (obj_class)
case {'serial', 'analoginput', 'analogoutput', 'digitalio'}
    if (~isvalid(obj_var))
        return
    end
end

% return TRUE if variable made it through
valid_flag = 1;
return

function type_flag = istype(h_object, object_type);

% ISTYPE - verify object type
%
%    FLAG = ISTYPE(H_OBJECT, TYPE) determines whether H_OBJECT is a valid
%    object handle whose 'Type' property equals the character string TYPE.
%    See Handle Graphics Objects under the MATLAB Helpdesk for more detail
%    on object types.

% By:   S.C. Molitor (smolitor@bme.jhu.edu)
% Date: January 25, 1999

% check input arguments

type_flag = 0;
if (nargin ~= 2)
   return
elseif (length(h_object) ~= 1)
   return
elseif (~ishandle(h_object))
   return
elseif (~ischar(object_type))
   return
end

% check for object handle existence & appropriate type

if (strcmp(get(h_object, 'Type'), object_type))
   type_flag = 1;
end
return

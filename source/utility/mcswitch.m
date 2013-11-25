% MCSWITCH - detect MC700A mode change
%
%	[FLAG, OLD, NEW] = MCSWITCH detects a mode change from the
%	MC700A telegraph server and sets FLAG to TRUE if the change
%	occurred before a timeout period.  The OLD and NEW modes are
%	also returned.
%  
%	[ ... ] = MCSWITCH(COM, BUS, CHAN, TIMEOUT) allows the user
%	to specify the COM port (default is 1), the bus ID (default
%	is 0), the amplifier channel (default is 1), and the timeout
%	duration in seconds (default is 30 sec).

% 7/11/03 SCM
% MEX DLL

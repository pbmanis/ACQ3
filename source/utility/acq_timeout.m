function ACQ_TimeOut()
%function ACQ_TimeOut(objects, event)
%
% function to execute if the AI times out..... waiting for a trigger.
%
global STOP_ACQ AI

event = AI.eventlog;
if(isempty({event.Type}))
    %EventType = event.Type;
    EventType = 'timeout';
    EventData = event.Data;
else
    EventType = event(1).Type;
    % Determine the time of the event.
    EventData = event(1).Data;
end;

% Create a display indicating the type of event, the time of the event and
% the name of the object.
QueMessage(sprintf(['Warning: [probably timeout] event occurred ',...
        ' for the object AI' '.\n']), 1);

stop(AI); % (was (stop(obj)))

acq_stop;
return;

function acqtimer(obj, event)
% toggle the dio lines down and up quickly. If hardware triggers are 
% enabled for AI and AO, the wiring will allow them to be triggerede
% from this signal.
% 8/08 P. Manis
if(isvalid(obj)) % make sure we have a valid device here...
    u = getvalue(obj.Line(3:6));
    putvalue(obj,[0 0 u]); % reset the dio's low
    putvalue(obj,[1 1 u]); % reset the dio's high again...
end;

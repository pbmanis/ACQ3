function [varargout] = show_ampstatus()
%
% show the amplifier status in the display area.
%
global DEVICE_ID
global AmpStatus

if(nargout > 0)
    varargout{1} = 0;
end;

if(DEVICE_ID < 0)
    return;
end;
%AmpStatus = telegraph;
if(isempty(AmpStatus) || isempty(AmpStatus.Data))
    if(nargout > 0)
        varargout{1} = 1;
    end;

    return;
end;

if(isstruct(AmpStatus.Data))
    ext = zeros(length(AmpStatus.Data),1);
    for i = 1:length(AmpStatus.Data)
        mo = AmpStatus.Data(i).mode;
        switch mo
            case {'V', 'V-Clamp'}
                ext(i) = AmpStatus.Data(i).VC_extcmd;
            case {'I', 'I-Clamp'}
                ext(i) = AmpStatus.Data(i).CC_extcmd;
            otherwise
                ext(i) = 0;
        end;
    end;
else
    ext = 0;
end;
hamp=findobj('Tag', 'AmpStatus');

if(length(AmpStatus.Data) <= 1)
    ampstat = sprintf('M: %1c G: %5.1f F: %5.1f Ig: %5.0f', ...
    AmpStatus.Mode, AmpStatus.Gain, AmpStatus.LPF, ext);
end;

if(length(AmpStatus.Data) > 1)
    ampstat = cell(length(AmpStatus.Data), 1);
    for i = 1:length(AmpStatus.Data)
        mo = AmpStatus.Data(i).mode(1);
        ga = AmpStatus.Data(i).scaled_gain;
        fil = AmpStatus.Data(i).lpf/1000;
        ig = ext(i);
        st = sprintf('M: %1c G: %5.1f F: %5.1f Ig: %5.1f', mo, ga, fil, ig);
        ampstat{i} = st;
    end;
end;

if(~isempty(hamp))
    set(hamp, 'String', ampstat);
else
    fprintf(1, '%s\n', ampstat);
end;


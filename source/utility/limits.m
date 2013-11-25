function [lim]= limits(arg, factor)
%
% determine correct plotting limits
%
% This algorithm controls the update of the on-line display axes.
% Must handle args of all patterns:
%  + +
%  0 +
%  - 0
%  - +
%  - -
%
% input is arg, the array of data to be plotted.
% output is lim, a 2x1 array [min max], in sorted order.
%
% 3/12/2001 Paul B. Manis.
%
a = min(arg);
b = max(arg);
if(isnan(a) && ~isnan(b))
    lim = [0, b*factor];
    return;
end;
if(isnan(b) && ~isnan(a))
    lim = [min(arg)/factor, 0];
    return;
end;
if(isnan(a) && isnan(b))
    lim = [0 1];
    return;
end;

if(a >= 0 && b > 0)
    lim = [(1/factor)*a, factor*b];
    return;
end;
if (a < 0 && b == 0)
    lim = [factor * a, 0];
    return;
end;
if(a < 0 && b > 0)
    lim = [factor * a, factor * b];
    return;
end;
if(a < 0 && b < 0)
    lim = [factor * a, (1/factor) * b];
    return;
end;
if (a == 0 && b == 0)
    lim = [0 1];
    return;
end;

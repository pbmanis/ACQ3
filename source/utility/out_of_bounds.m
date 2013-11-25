function [res] = out_of_bounds(arg, factor)

if(length(arg) <= 2) % always force things with too few points
    res = ones(length(arg), 1);
    return;
end;
% length here is always > 2
res = zeros(length(arg), 1);
lim = limits(arg(1:end-1), factor); % previous limits. We are just checking the new point
if(arg(end) <= min(lim))
    res(end) = 1;
end
if(arg(end) >= max(lim))
    res(end) = 1;
end;
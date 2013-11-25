function [y]=unblank(x)
y=deblank(fliplr(deblank(fliplr(x))));
return;

function [pos] = frameit (sp, frame, fig)
% *****************************************************************
% 
% *****************************************************************
% compute position of subplot within a frame
pos.left = (frame(1)/fig(3))+ sp(1)*(frame(3)/fig(3));
pos.bottom = (frame(2)/fig(4))+sp(2)*(frame(4)/fig(4));
pos.width = sp(3)*(frame(3)/fig(3));
pos.height = sp(4)*(frame(4)/fig(4));
return;
